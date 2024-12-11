import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
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
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            const Text(
              "Sign up to create a new account.",
              style: TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 32),
            TextField(
              decoration: InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18.0),),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: "Mobile number or Email ID",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18.0),),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Create Password",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18.0),),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Confirm Password",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18.0),),
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                // Handle Sign Up logic here
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
              
              child: const Text("Sign Up"),
              
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Go back to Login page if user wants to log in
                Navigator.pop(context); // Navigate back to LoginPage
              },
              child: const Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}
