import 'package:eato/pages/onboarding/onboarding3.dart';
import 'package:eato/pages/onboarding/onboarding4.dart';
import 'package:flutter/material.dart';

class FreeMembershipPage extends StatelessWidget {
  const FreeMembershipPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 30.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the WelcomePage
          },
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: const Text("Back"),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.start, // Align children at the top
          crossAxisAlignment:
              CrossAxisAlignment.center, // Keep children horizontally centered
          children: [
            const SizedBox(
                height: 10.0), // Add small space between AppBar and Image
            Image.asset(
              'assets/images/flogo.png',
              height: 400,
              width: 400,
            ),
            const SizedBox(height: 32.0),
            Align(
              alignment: Alignment.centerLeft, // Align text to the left
              child: const Text(
                "Free Membership!",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 16.0),
            Align(
              alignment: Alignment.centerLeft, // Align text to the left
              child: const Text(
                "Any student studying in the Faculty of Engineering, University of Ruhuna, can open an account.",
                style: TextStyle(fontSize: 16.0),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 65.0),
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
                        builder: (context) => const GetStartedPage(),
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
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
