import 'package:eato/Provider/userProvider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'package:eato/Model/coustomUser.dart';
import 'signup.dart';
import 'phoneVerification.dart'; 
import 'package:eato/pages/customer/customer_home.dart';
import 'package:eato/pages/provider/ProviderHomePage.dart';


class LoginPage extends StatefulWidget {
  final String role;

  const LoginPage({required this.role, Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  String getHomeRoute() {
    return widget.role == 'customer' ? '/customerHome' : '/mealProviderHome';
  }

  Future<void> loginUser(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Login using Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Fetch user data
      await userProvider.fetchUser(userCredential.user!.uid);

      // Debug prints to identify the issue
      print("DEBUG: User data from Firebase: ${userProvider.currentUser?.toMap()}");
      print("DEBUG: User type in database: ${userProvider.currentUser?.userType}");
      print("DEBUG: Expected role from app: ${widget.role}");

      // Flexible role matching check
      bool roleMatches = false;
      
      // Check if userType exists and matches (case-insensitive)
      if (userProvider.currentUser?.userType != null) {
        final dbRole = userProvider.currentUser!.userType.toLowerCase();
        final expectedRole = widget.role.toLowerCase();
        
        // Direct match
        if (dbRole == expectedRole) {
          roleMatches = true;
        }
        // Meal provider variations
        else if (expectedRole == 'mealprovider' && 
                (dbRole == 'provider' || 
                 dbRole == 'meal provider' || 
                 dbRole == 'meal_provider')) {
          roleMatches = true;
        }
        // Customer variations
        else if (expectedRole == 'customer' && 
                (dbRole == 'user' || 
                 dbRole == 'client')) {
          roleMatches = true;
        }
      }
      
      if (!roleMatches) {
        print("DEBUG: Role mismatch - DB: ${userProvider.currentUser?.userType}, Expected: ${widget.role}");
        throw Exception("Role mismatch! You're trying to log in with the wrong account type.");
      }

      // Check if phone verification is needed
      final currentUser = userProvider.currentUser;
      if (currentUser != null && 
          (currentUser.phoneNumber == null || currentUser.phoneNumber!.isEmpty)) {
        // Navigate to phone verification page first
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhoneVerificationPage(
              phoneNumber: '', // Will be filled on the next page
              userType: widget.role,
              isSignUp: false,
              userData: null,
            ),
          ),
        );
      } else {
        // Navigate directly to the appropriate home page 
        // instead of using named routes
        if (!mounted) return;
        
        if (widget.role.toLowerCase() == 'customer') {
          // Import and use your customer home page directly
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => CustomerHomePage(), // Replace with your actual class
            ),
            (route) => false,
          );
        } else {
          // Import and use your provider home page directly
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => ProviderHomePage( // Replace with your actual class
                currentUser: userProvider.currentUser!,
              ),
            ),
            (route) => false,
          );
        }
        
        // Or if you've fixed the routes in main.dart, you can use:
        // Navigator.pushReplacementNamed(context, getHomeRoute());
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: ${e.toString()}")),
      );
    }
  }

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
            ),
            const SizedBox(height: 20),
            const Text("Login to your account", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 32),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email ID",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18.0)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18.0)),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => loginUser(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Login", style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage(role: widget.role)),
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