import 'package:flutter/material.dart';

class AddBookView extends StatefulWidget {
  const AddBookView({Key? key}) : super(key: key);

  @override
  _AddBookViewState createState() => _AddBookViewState();
}

class _AddBookViewState extends State<AddBookView> {
  String userInput = '';
  List<Map<String, dynamic>> responseData = [];
  bool isLoading = false;

  Future<void> cicala_API(String userInput) async {
    // Simula una chiamata API asincrona
    setState(() {
      isLoading = true;
    });

    // Aggiorna la UI con un piccolo ritardo
    await Future.delayed(Duration(seconds: 2));

    // Simula la risposta dall'API
    List<Map<String, dynamic>> response = [
      {'title': 'Libro 1', 'author': 'Autore 1'},
      {'title': 'Libro 2', 'author': 'Autore 2'},
      {'title': 'Libro 3', 'author': 'Autore 3'},
    ];

    setState(() {
      isLoading = false;
      responseData = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Book'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  userInput = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Inserisci il testo',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                cicala_API(userInput);
              },
              child: Text('Invia'),
            ),
            SizedBox(height: 16),
            if (isLoading)
              CircularProgressIndicator()
            else if (responseData.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: responseData.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(responseData[index]['title']),
                      subtitle: Text(responseData[index]['author']),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
