import 'package:flutter/material.dart';
import 'package:eato/pages/auth/signup.dart'; // Import SignUpPage

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 30.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text("Back"),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome!",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 20),
            const Text(
              "Login to your account",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.left,
            ), // Push buttons to the bottom

            const SizedBox(height: 32),
           TextField(
  decoration: InputDecoration(
    labelText: "Mobile number or Email ID",
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18.0), // Apply border radius
    ),
  ),
),

            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18.0),),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Handle forgot password
                },
                child: const Text("Forgot password?"),
              ),
            ),
            const SizedBox(height: 200),
            ElevatedButton(
              onPressed: () {
                // If Login is successful, navigate to HomePage
                Navigator.pushNamed(context, '/home'); // Define your home route
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                minimumSize: const Size(150, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
              ),
              child: const Text("Login"),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Navigate to SignUpPage if user wants to sign up
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              child: const Text("Don't have an account? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
