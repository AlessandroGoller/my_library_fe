import 'package:flutter/material.dart';
import 'package:my_library/Services/auth.dart';

class MyHeader extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Book Management'),
      centerTitle: true,
      actions: [
        PopupMenuButton<String>(
          onSelected: (String result) {
            switch (result) {
              case 'logout':
                Auth().logout();
                Navigator.pushReplacementNamed(context, '/');
              case 'settings':
                // Gestisci le impostazioni qui
                break;
              // Aggiungi altri casi se necessario
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'settings',
              child: Text('Settings'),
            ),
            PopupMenuItem<String>(
              value: 'logout',
              child: Text('Logout'),
            ),
          ],
          child: Container(
            margin: EdgeInsets.only(right: 10.0),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
            ),
            child: Center(
              child: Text(
                'U', // Puoi cambiare con l'iniziale del username
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
