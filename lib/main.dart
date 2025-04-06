import 'package:eato/Provider/FoodProvider.dart';
import 'package:eato/Provider/StoreProvider.dart';
import 'package:eato/Provider/userProvider.dart';
import 'package:eato/pages/provider/AddFoodPage.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Firebase configuration
import 'firebase_options.dart';

// Import user-related classes
import 'package:eato/pages/onboarding/onboarding1.dart'; // Welcome Page
import 'package:eato/pages/customer/customer_home.dart'; // Customer Home
import 'package:eato/pages/provider/shopdetails.dart'; // Meal Provider Home

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization error: $e'); // Log Firebase errors
  }

  runApp(
    DevicePreview(
      enabled: false, // Set to `true` for Device Preview during development
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(
              create: (_) => StoreProvider()), // Store provider
          ChangeNotifierProvider(create: (_) => FoodProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Access user data from the provider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      // Load initial screen based on user state
      home: const InitialScreen(),
      routes: {
        '/customerHome': (context) => const CustomerHomePage(),
        '/mealProviderHome': (context) =>
            StoreDetailsPage(currentUser: userProvider.currentUser!),
      },
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return FutureBuilder(
      future: userProvider
          .fetchUser('exampleUserId'), // Replace with actual user ID
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || userProvider.currentUser == null) {
          // If user data isn't found, navigate to WelcomePage
          return const WelcomePage();
        }

        final userRole = userProvider.currentUser!.role;

        // Route based on role
        if (userRole == 'customer') {
          return const CustomerHomePage();
        } else if (userRole == 'provider') {
          // Navigate directly and pass currentUser after fetch
          return StoreDetailsPage(
            currentUser: userProvider.currentUser!,
          );
        } else {
          return Scaffold(
            body: Center(
              child: Text('Unknown role: $userRole'),
            ),
          );
        }
      },
    );
  }
}

