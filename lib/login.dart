import 'package:flutter/material.dart';
import 'auth_service.dart'; // Import the AuthService
import 'homepage.dart'; // Import the HomePage

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LoginForm(),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Instantiate the AuthService
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            // Perform login logic using AuthService
            String email = _emailController.text;
            String password = _passwordController.text;

            // Check if the user credentials are valid
            if (_authService.signIn(email, password)) {
              // Navigate to the home page after successful login
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            } else {
              // Show an error message or handle invalid credentials
              print('Invalid credentials');
            }
          },
          child: Text('Log In'),
        ),
      ],
    );
  }
}
