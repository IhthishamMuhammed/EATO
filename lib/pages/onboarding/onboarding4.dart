import 'package:eato/pages/auth/login.dart';
import 'package:flutter/material.dart';

class RoleSelectionPage extends StatefulWidget {
  @override
  _RoleSelectionPageState createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      if (_pageController.page != null) {
        setState(() {
          _currentIndex = _pageController.page!.toInt();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
        padding: const EdgeInsets.symmetric(horizontal: 100.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            const Text(
              "Select your role",
              style: TextStyle(
                fontSize: 27,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/customerLogin'); // Define route
              },
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  CircleAvatar(
                    radius: 110, // Image size
                    backgroundColor: Colors.purple,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/customer.png', // Path to the image
                        fit: BoxFit.cover,
                        width: 350, // Image width
                        height: 350, // Image height
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0, // Positioned at the bottom
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/customerLogin');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple, // Background color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4), // Rounded corners
                        ),
                      ),
                      child: const Text(
                        "Customer",
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/providerLogin'); // Define route
              },
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  CircleAvatar(
                    radius: 110, // Image size
                    backgroundColor: Colors.purple,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/meal_provider.png', // Path to the image
                        fit: BoxFit.cover,
                        width: 350, // Image width
                        height: 350, // Image height
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0, // Positioned at the bottom
                    child: ElevatedButton(
                      onPressed: () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple, // Background color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // Rounded corners
                        ),
                      ),
                      child: const Text(
                        "Meal Provider",
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



