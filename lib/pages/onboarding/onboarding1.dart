import 'package:eato/pages/onboarding/onboarding2.dart';
import 'package:eato/pages/onboarding/onboarding4.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment:
              CrossAxisAlignment.center, // Keep image and buttons centered
          children: [
            Image.asset(
              'assets/images/logo.png', // Add your image here
              height: 400,
              width: 400,
            ),
            const SizedBox(height: 32.0),
            Align(
              alignment: Alignment.centerLeft, // Align this text to the left
              child: const Text(
                "Welcome to EATO",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Align(
              alignment: Alignment.centerLeft, // Align this text to the left
              child: const Text(
                "Browse through our extensive list of restaurants and dishes, and when you're ready to order, simply add your desired items to your cart and checkout. It's that easy!",
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            const SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // Keep buttons aligned as needed
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>  RoleSelectionPage(),
                      ),
                    );
                    // Navigate to the last step or skip action
                  },
                  style: TextButton.styleFrom(
                    side: const BorderSide(
                        color: Colors.black, width: 1.0), // Black border
                    foregroundColor: Colors.black, // Text color
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0), // Optional padding
                    minimumSize: const Size(150, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          18.0), // Adjust corner radius here
                    ),
                  ),
                  child: const Text("Skip", style: TextStyle(fontSize: 18.0)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FreeMembershipPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(150, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          18.0), // Adjust corner radius here
                    ),
                  ),
                  child: const Text(
                    "Next",
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
