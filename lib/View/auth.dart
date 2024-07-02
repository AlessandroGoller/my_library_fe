import 'package:flutter/material.dart';
import 'package:my_library/Services/auth.dart';
import 'package:my_library/Services/util.dart';
import 'book_management.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading_login = false;

  Future<void> _login() async {
    setState(() {
      _isLoading_login = true;
    });

    try {
      final result = await Auth().loginWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (result.item1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BookManagementApp()),
        );
        showCustomDialog(context, 'Succesful Login', '');
      } else {
        showCustomDialog(context, 'Login Error', result.item2);
      }
    } catch (e) {
      showCustomDialog(context, 'Login Error', 'Error during connection API\n$e');
    }

    setState(() {
      _isLoading_login = false;
    });
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isLoading_login ? null : _login,
              child: _isLoading_login ? CircularProgressIndicator() : Text('Login'),
            ),
            ElevatedButton(
              onPressed: _navigateToRegister,
              child: Text('Go to Registration Page'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _timezoneController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading_register = false;

  Future<void> _register() async {
    setState(() {
      _isLoading_register = true;
    });

    try {
      // Convertire timezone a double, se possibile
      double? timezone;
      if (_timezoneController.text.isNotEmpty) {
        timezone = double.tryParse(_timezoneController.text);
        if (timezone == null) {
          throw FormatException('Timezone must be a valid number.');
        } else if (timezone < -12.0 || timezone > 14.0) {
          throw RangeError('Timezone must be between -12 and +14.');
        }
      }


      final result = await Auth().registerWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
        timezone: timezone,
        username: _usernameController.text.trim().isEmpty ? null : _usernameController.text.trim(),
      );

      if (result.item1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BookManagementApp()),
        );
        showCustomDialog(context, 'Successful Registration\nPlease confirm your account from the email', '');
      } else {
        showCustomDialog(context, 'Registration Error', result.item2);
      }
    } catch (e) {
      showCustomDialog(context, 'Registration Error', 'Error during connection API\n$e');
    }

    setState(() {
      _isLoading_register = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name (Optional)'),
            ),
            TextField(
              controller: _timezoneController,
              decoration: InputDecoration(labelText: 'Timezone (Optional, e.g., -5.0)'),
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username (Optional)'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isLoading_register ? null : _register,
              child: _isLoading_register ? CircularProgressIndicator() : Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
