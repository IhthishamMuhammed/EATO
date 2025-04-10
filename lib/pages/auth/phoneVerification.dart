import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eato/Model/coustomUser.dart';
import 'package:eato/Provider/userProvider.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

// Import your home pages directly
// Replace these paths with your actual import paths
import 'package:eato/pages/customer/customer_home.dart';  
import 'package:eato/pages/provider/ProviderHomePage.dart';

class PhoneVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final String userType;
  final bool isSignUp;
  final Map<String, String>? userData;

  const PhoneVerificationPage({
    Key? key,
    required this.phoneNumber,
    required this.userType,
    required this.isSignUp,
    this.userData,
  }) : super(key: key);

  @override
  State<PhoneVerificationPage> createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _verificationId = '';
  bool _isCodeSent = false;
  bool _isVerifying = false;
  String _errorMessage = '';
  bool _debug = true; // Keep this true to show debug info
  int? _forceResendingToken;

  final List<TextEditingController> _codeControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    
    // Auto-focus to next digit
    for (int i = 0; i < 5; i++) {
      _focusNodes[i].addListener(() {
        if (_codeControllers[i].text.length == 1) {
          FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
        }
      });
    }
    
    // DEVELOPMENT WORKAROUND
    // Generate a fake verification ID for testing
    if (kDebugMode) {
      _verificationId = 'fake-verification-id-for-testing';
      _isCodeSent = true;
      _debugLog("DEVELOPMENT MODE: Using fake verification ID");
    } else {
      // Only try to send real SMS in production
      _verifyPhoneNumber();
    }
  }

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var focus in _focusNodes) {
      focus.dispose();
    }
    super.dispose();
  }

  void _debugLog(String message) {
    if (_debug) {
      print("PHONE AUTH DEBUG: $message");
      setState(() {
        _errorMessage += "\n$message";
      });
    } else {
      print("PHONE AUTH: $message");
    }
  }

  Future<void> _verifyPhoneNumber() async {
    setState(() {
      _isVerifying = true;
      _errorMessage = '';
    });

    try {
      // Ensure proper phone number format
      final String phoneNumber = widget.phoneNumber.trim();
      final String formattedPhoneNumber = phoneNumber.startsWith('+') 
          ? phoneNumber 
          : '+$phoneNumber';
      
      _debugLog("Attempting to verify phone number: $formattedPhoneNumber");

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhoneNumber,
        timeout: const Duration(seconds: 120),
        forceResendingToken: _forceResendingToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          _debugLog("Auto verification completed");
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          _handleVerificationError(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          _debugLog("Verification code sent to $formattedPhoneNumber");
          setState(() {
            _verificationId = verificationId;
            _forceResendingToken = resendToken;
            _isCodeSent = true;
            _isVerifying = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Verification code sent!")),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _debugLog("Auto retrieval timeout");
          setState(() {
            _verificationId = verificationId;
          });
        },
      );
    } catch (e) {
      _debugLog("Error in phone verification: $e");
      setState(() {
        _isVerifying = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Phone verification error: $e")),
      );
    }
  }

  void _handleVerificationError(FirebaseAuthException e) {
    String errorMsg = "Verification failed";
    
    switch (e.code) {
      case 'invalid-phone-number':
        errorMsg = "The phone number format is incorrect";
        break;
      case 'too-many-requests':
        errorMsg = "Too many requests. Try again later";
        break;
      case 'operation-not-allowed':
        errorMsg = "Phone auth not enabled in Firebase or not allowed for this region";
        break;
      case 'quota-exceeded':
        errorMsg = "SMS quota exceeded for the project";
        break;
      default:
        errorMsg = "${e.message}";
    }
    
    _debugLog("Verification failed: $errorMsg (code: ${e.code})");
    setState(() {
      _isVerifying = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMsg)),
    );
  }

  // THIS IS THE DEVELOPMENT WORKAROUND FUNCTION
  // Instead of using real SMS verification, we'll simulate it for development
  Future<void> _signInForTesting() async {
    _debugLog("DEVELOPMENT MODE: Bypassing phone verification");
    
    try {
      setState(() {
        _isVerifying = true;
      });
      
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      if (widget.isSignUp) {
        // For sign up process - create new user
        _debugLog("Creating new user account");
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: widget.userData!['email']!,
          password: widget.userData!['password']!,
        );
        
        // User created successfully
        User user = userCredential.user!;
        _debugLog("User created with ID: ${user.uid}");
        
        // Create user document in Firestore
        _debugLog("Creating user document in Firestore");
        final userMap = {
          'name': widget.userData!['name']!,
          'email': widget.userData!['email']!,
          'phoneNumber': widget.phoneNumber,
          'userType': widget.userType,
          'profileImageUrl': '',
        };
        
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(userMap);
        
        // Create and store user in provider
        final customUser = CustomUser(
          id: user.uid,
          name: widget.userData!['name']!,
          email: widget.userData!['email']!,
          phoneNumber: widget.phoneNumber,
          userType: widget.userType,
          profileImageUrl: '',
        );
        
        userProvider.setCurrentUser(customUser);
        
        if (!mounted) return;
        
        _debugLog("Navigation to home screen");
        // Use direct navigation instead of named routes
        if (widget.userType == 'customer') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => CustomerHomePage(),
            ),
            (route) => false, // Clear all previous routes
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => ProviderHomePage(
                currentUser: userProvider.currentUser!,
              ),
            ),
            (route) => false, // Clear all previous routes
          );
        }
      } else {
        // For login process - update phone number
        _debugLog("Login flow - updating phone number");
        final user = _auth.currentUser;
        if (user != null) {
          _debugLog("Current user ID: ${user.uid}");
          
          // Update the phone number in Firestore
          _debugLog("Updating phone number in Firestore");
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'phoneNumber': widget.phoneNumber});
          
          // Get updated user data from Firestore
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
              
          if (userDoc.exists) {
            Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
            
            // Create updated CustomUser
            CustomUser updatedUser = CustomUser(
              id: user.uid,
              name: userData['name'] ?? '',
              email: userData['email'] ?? '',
              phoneNumber: widget.phoneNumber,
              userType: userData['userType'] ?? widget.userType,
              profileImageUrl: userData['profileImageUrl'] ?? '',
            );
            
            // Update user in provider
            userProvider.setCurrentUser(updatedUser);
          }
          
          if (!mounted) return;
          
          _debugLog("Navigation to home screen");
          // Use direct navigation instead of named routes
          if (widget.userType == 'customer') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => CustomerHomePage(),
              ),
              (route) => false, // Clear all previous routes
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => ProviderHomePage(
                  currentUser: userProvider.currentUser!,
                ),
              ),
              (route) => false, // Clear all previous routes
            );
          }
        }
      }
    } catch (e) {
      _debugLog("Authentication failed: $e");
      setState(() {
        _isVerifying = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Authentication failed: $e")),
      );
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      setState(() {
        _isVerifying = true;
      });
      
      _debugLog("Starting authentication with credential");
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      if (widget.isSignUp) {
        // For sign up process - create new user
        _debugLog("Creating new user account");
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: widget.userData!['email']!,
          password: widget.userData!['password']!,
        );
        
        // Update the phone number in Firebase Auth
        User user = userCredential.user!;
        _debugLog("User created with ID: ${user.uid}");
        
        try {
          _debugLog("Attempting to update phone number directly");
          await user.updatePhoneNumber(credential);
        } catch (e) {
          _debugLog("Error updating phone directly: $e");
          // If unable to update phone directly, try linking method
          try {
            _debugLog("Attempting to link credential instead");
            await user.linkWithCredential(credential);
          } catch (linkError) {
            _debugLog("Error linking credential: $linkError");
            // Continue anyway, as we'll update in Firestore
          }
        }
        
        // Create user document in Firestore
        _debugLog("Creating user document in Firestore");
        final userMap = {
          'name': widget.userData!['name']!,
          'email': widget.userData!['email']!,
          'phoneNumber': widget.phoneNumber,
          'userType': widget.userType,
          'profileImageUrl': '',
        };
        
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(userMap);
        
        // Create and store user in provider
        final customUser = CustomUser(
          id: user.uid,
          name: widget.userData!['name']!,
          email: widget.userData!['email']!,
          phoneNumber: widget.phoneNumber,
          userType: widget.userType,
          profileImageUrl: '',
        );
        
        userProvider.setCurrentUser(customUser);
        
        if (!mounted) return;
        
        _debugLog("Navigation to home screen");
        // Use direct navigation instead of named routes
        if (widget.userType == 'customer') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => CustomerHomePage(),
            ),
            (route) => false, // Clear all previous routes
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => ProviderHomePage(
                currentUser: userProvider.currentUser!,
              ),
            ),
            (route) => false, // Clear all previous routes
          );
        }
      } else {
        // For login process - update phone number
        _debugLog("Login flow - updating phone number");
        final user = _auth.currentUser;
        if (user != null) {
          _debugLog("Current user ID: ${user.uid}");
          try {
            // Try linking phone credential to existing user
            _debugLog("Attempting to update phone directly");
            await user.updatePhoneNumber(credential);
          } catch (e) {
            _debugLog("Error updating phone: $e");
            try {
              // If unable to update phone directly, try linking method
              _debugLog("Attempting to link credential instead");
              await user.linkWithCredential(credential);
            } catch (linkError) {
              _debugLog("Error linking credential: $linkError");
              // Continue anyway, as we'll update in Firestore
            }
          }
          
          // Update the phone number in Firestore
          _debugLog("Updating phone number in Firestore");
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'phoneNumber': widget.phoneNumber});
          
          // Get updated user data from Firestore
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
              
          if (userDoc.exists) {
            Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
            
            // Create updated CustomUser
            CustomUser updatedUser = CustomUser(
              id: user.uid,
              name: userData['name'] ?? '',
              email: userData['email'] ?? '',
              phoneNumber: widget.phoneNumber,
              userType: userData['userType'] ?? widget.userType,
              profileImageUrl: userData['profileImageUrl'] ?? '',
            );
            
            // Update user in provider
            userProvider.setCurrentUser(updatedUser);
          }
          
          if (!mounted) return;
          
          _debugLog("Navigation to home screen");
          // Use direct navigation instead of named routes
          if (widget.userType == 'customer') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => CustomerHomePage(),
              ),
              (route) => false, // Clear all previous routes
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => ProviderHomePage(
                  currentUser: userProvider.currentUser!,
                ),
              ),
              (route) => false, // Clear all previous routes
            );
          }
        }
      }
    } catch (e) {
      _debugLog("Authentication failed: $e");
      setState(() {
        _isVerifying = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Authentication failed: $e")),
      );
    }
  }

  void _verifyCode() {
    if (kDebugMode) {
      // In development, use the simplified flow
      _signInForTesting();
      return;
    }
    
    final code = _codeControllers.map((c) => c.text).join();
    
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the full 6-digit code")),
      );
      return;
    }
    
    _debugLog("Verifying 6-digit code: $code");
    
    // Normal verification in production
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: code,
    );
    
    _signInWithCredential(credential);
  }

  void _requestNewCode() {
    for (var c in _codeControllers) {
      c.clear();
    }
    FocusScope.of(context).requestFocus(_focusNodes[0]);
    
    if (kDebugMode) {
      _debugLog("Debug mode: No need to request new code");
      return;
    }
    
    _debugLog("Requesting new verification code");
    _verifyPhoneNumber();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 30,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text("Back"),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "Verify Phone Number",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              kDebugMode
                  ? Text(
                      "DEVELOPMENT MODE: Enter any 6 digits or click Verify",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.red[600]),
                    )
                  : Text(
                      "We have sent a 6-digit code to your number.\nEnter it below to verify.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.phoneNumber.startsWith('+') 
                          ? widget.phoneNumber 
                          : '+${widget.phoneNumber}',
                      style: const TextStyle(fontSize: 16)
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.purple[100],
                        ),
                        child: const Icon(Icons.edit, size: 16, color: Colors.purple),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (index) => SizedBox(
                    width: 40,
                    height: 50,
                    child: TextField(
                      controller: _codeControllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.purple, width: 2),
                        ),
                      ),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      onChanged: (value) {
                        if (value.length == 1 && index < 5) {
                          FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Didn't receive code? ", style: TextStyle(color: Colors.grey[600])),
                  GestureDetector(
                    onTap: _requestNewCode,
                    child: const Text(
                      "Get a new one",
                      style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isVerifying
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Verify", style: TextStyle(fontSize: 18)),
                ),
              ),
              
              // Debug information (only visible when _debug is true)
              if (_debug && _errorMessage.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 30),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.red[50],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Debug Information:",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                      const SizedBox(height: 8),
                      Text(_errorMessage, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}