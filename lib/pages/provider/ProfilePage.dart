import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eato/Model/coustomUser.dart';
import 'package:eato/Provider/userProvider.dart';
import 'package:eato/Provider/StoreProvider.dart';

class ProfilePage extends StatefulWidget {
  final CustomUser currentUser;

  const ProfilePage({Key? key, required this.currentUser}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 3; // Profile tab is selected by default
  bool isEditing = false;

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    
    setState(() {
      _currentIndex = index;
    });
    
    switch (index) {
      case 0: // Orders
        Navigator.pushReplacementNamed(context, '/orders');
        break;
      case 1: // Requests
        Navigator.pushReplacementNamed(context, '/requests');
        break;
      case 2: // Add food
        Navigator.pushReplacementNamed(context, '/addFood');
        break;
      case 3: // Profile - Already here
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final storeProvider = Provider.of<StoreProvider>(context);
    final store = storeProvider.userStore;

    // Use updated currentUser if available from provider
    final user = userProvider.currentUser ?? widget.currentUser;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Header
              Container(
                padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Container(
                      height: 2,
                      color: Colors.purple,
                    ),
                  ],
                ),
              ),
              
              // Profile Info
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Profile Image
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                    SizedBox(width: 20),
                    // Name
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name.split(' ').first,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user.name.split(' ').length > 1 
                              ? user.name.split(' ').last 
                              : '',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Owner Details Section
              Container(
                color: Colors.purple.withOpacity(0.2),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Owner details',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              
              // Mobile Number
              _buildInfoField(
                label: 'Mobile number',
                value: user.phoneNumber != null && user.phoneNumber!.isNotEmpty
                    ? user.phoneNumber!.replaceRange(
                        4, 
                        user.phoneNumber!.length, 
                        '*' * (user.phoneNumber!.length - 4)
                      )
                    : 'Not set',
                onEdit: () {
                  // Handle editing mobile number
                  _showEditDialog(
                    context,
                    'Edit Mobile Number',
                    user.phoneNumber ?? '',
                    (newValue) {
                      // Update mobile number in database
                      final updatedUser = user.copyWith(
                        phoneNumber: newValue,
                      );
                      Provider.of<UserProvider>(context, listen: false)
                          .updateUser(updatedUser);
                    },
                  );
                },
              ),
              
              // User Type / Role
              _buildInfoField(
                label: 'User Type',
                value: user.userType.isNotEmpty 
                    ? user.userType 
                    : 'Not set',
                onEdit: null, // User type should not be editable
              ),
              
              // Location
              _buildInfoField(
                label: 'Location:',
                value: '42 Street, Gate 1, NoState Name, Missing Country Name',
                onEdit: () {
                  // Handle editing location
                  _showEditDialog(
                    context,
                    'Edit Location',
                    '42 Street, Gate 1, NoState Name, Missing Country Name',
                    (newValue) {
                      // Update location in database
                      // Note: You'll need to add a location field to your user model
                    },
                  );
                },
              ),
              
              // Shop Details Section (only for meal providers)
              if (user.userType.toLowerCase().contains('provider'))
                Container(
                  color: Colors.purple.withOpacity(0.2),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  margin: EdgeInsets.only(top: 16),
                  child: Text(
                    'Shop Details',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              
              // Shop Name (only for meal providers)
              if (user.userType.toLowerCase().contains('provider'))
                _buildInfoField(
                  label: 'Shop Name:',
                  value: store?.name ?? 'Not set',
                  onEdit: () {
                    // Handle editing shop name
                    if (store != null) {
                      _showEditDialog(
                        context,
                        'Edit Shop Name',
                        store.name,
                        (newValue) {
                          // Update shop name in database
                          final updatedStore = store.copyWith(
                            name: newValue,
                          );
                          Provider.of<StoreProvider>(context, listen: false)
                              .createOrUpdateStore(updatedStore, user.id);
                        },
                      );
                    }
                  },
                ),
              
              // Shop Location (only for meal providers)
              if (user.userType.toLowerCase().contains('provider'))
                _buildInfoField(
                  label: 'Location:',
                  value: '42 Street, Gate 1, NoState Name, Missing Country Name',
                  onEdit: () {
                    // Handle editing shop location
                    _showEditDialog(
                      context,
                      'Edit Shop Location',
                      '42 Street, Gate 1, NoState Name, Missing Country Name',
                      (newValue) {
                        // Update shop location in database
                        // Note: You'll need to add a location field to your store model
                      },
                    );
                  },
                ),
              
              // Subscribers count (only for meal providers)
              if (user.userType.toLowerCase().contains('provider'))
                _buildInfoField(
                  label: 'Subscribers count',
                  value: '25',
                  onEdit: null, // No edit option for subscribers
                ),
              
              // Shop Contact Number (only for meal providers)
              if (user.userType.toLowerCase().contains('provider'))
                _buildInfoField(
                  label: 'Mobile number',
                  value: store?.contact ?? 'Not set',
                  onEdit: () {
                    // Handle editing shop contact
                    if (store != null) {
                      _showEditDialog(
                        context,
                        'Edit Shop Contact',
                        store.contact,
                        (newValue) {
                          // Update shop contact in database
                          final updatedStore = store.copyWith(
                            contact: newValue,
                          );
                          Provider.of<StoreProvider>(context, listen: false)
                              .createOrUpdateStore(updatedStore, user.id);
                        },
                      );
                    }
                  },
                ),
              
              // Delivery Options (only for meal providers)
              if (user.userType.toLowerCase().contains('provider'))
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Row(
                      children: [
                        // Pickup button
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (store != null) {
                                final updatedStore = store.copyWith(
                                  isPickup: true,
                                );
                                Provider.of<StoreProvider>(context, listen: false)
                                    .createOrUpdateStore(updatedStore, user.id);
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: store?.isPickup ?? true ? Colors.purple : Colors.transparent,
                                borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(30),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Pickup',
                                  style: TextStyle(
                                    color: store?.isPickup ?? true ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        // Delivery button
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (store != null) {
                                final updatedStore = store.copyWith(
                                  isPickup: false,
                                );
                                Provider.of<StoreProvider>(context, listen: false)
                                    .createOrUpdateStore(updatedStore, user.id);
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !(store?.isPickup ?? true) ? Colors.purple : Colors.transparent,
                                borderRadius: BorderRadius.horizontal(
                                  right: Radius.circular(30),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Delivery',
                                  style: TextStyle(
                                    color: !(store?.isPickup ?? true) ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Logout button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Log out the user
                    Provider.of<UserProvider>(context, listen: false).clearCurrentUser();
                    // Navigate to login screen
                    Navigator.pushNamedAndRemoveUntil(
                      context, 
                      '/', 
                      (route) => false
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Text('Logout'),
                  ),
                ),
              ),
              
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  void _showEditDialog(
    BuildContext context,
    String title,
    String initialValue,
    Function(String) onSave,
  ) {
    final TextEditingController controller = TextEditingController(text: initialValue);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                onSave(controller.text);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
              ),
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoField({
    required String label,
    required String value,
    Function()? onEdit,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
            ),
            if (onEdit != null) ...[
              SizedBox(width: 8),
              GestureDetector(
                onTap: onEdit,
                child: Icon(
                  Icons.edit,
                  size: 18,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _onTabTapped,
      selectedItemColor: Colors.purple,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.article_outlined),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none),
          label: 'Requests',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: 'Add food',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}