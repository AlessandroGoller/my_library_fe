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
  bool _isLoading_register = false;

  // Function to handle login button press
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
        // Login successful, navigate to next screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BookManagementApp()),
        );
        showCustomDialog(context, 'Succesful Login', '');
      } else {
        // Login failed, display error message
        showCustomDialog(context, 'Login Error', result.item2);
      }
    } catch (e) {
      // Handle login error
      showCustomDialog(context, 'Login Error', 'Error during connection API\n$e');
    }
    setState(() {
      _isLoading_login = false;
    });
  }

  Future<void> _register() async {
    setState(() {
      _isLoading_register = true;
    });
    try {
      final result = await Auth().registerWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (result.item1) {
        // Registration successful, navigate to next screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BookManagementApp()),
        );
        showCustomDialog(context, 'Succesful Registration\nPlease confirm your account from the email', '');
      } else {
        // Registration failed, display error message
        showCustomDialog(context, 'Registration Error', result.item2);
      }
    } catch (e) {
      // Handle registration error
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
        title: Text('Login'),
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
              onPressed: _isLoading_register ? null : _register,
              child: _isLoading_register ? CircularProgressIndicator() : Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}