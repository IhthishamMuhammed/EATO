import 'dart:io';
import 'package:eato/Provider/userProvider.dart';
import 'package:eato/pages/provider/AddFoodPage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:eato/Model/Food&Store.dart';
import 'package:eato/Provider/StoreProvider.dart';
import 'package:eato/Model/coustomUser.dart';
import 'package:eato/Provider/FoodProvider.dart';

class StoreDetailsPage extends StatefulWidget {
  final CustomUser currentUser;

  const StoreDetailsPage({Key? key, required this.currentUser})
      : super(key: key);

  @override
  _StoreDetailsPageState createState() => _StoreDetailsPageState();
}

class _StoreDetailsPageState extends State<StoreDetailsPage> {
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _shopContactController = TextEditingController();
  bool isPickup = true;
  XFile? _pickedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    storeProvider.fetchUserStore(
        widget.currentUser); // Fetch store details based on current user
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          storeProvider.userStore == null ? 'Manage Your Shop' : 'Your Shop',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.purple,
        centerTitle: true,
      ),
      body: storeProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: storeProvider.userStore == null
                    ? _buildAddStoreForm(storeProvider, currentUser!.id)
                    : _buildStoreDetails(storeProvider),
              ),
            ),
    );
  }

  Widget _buildAddStoreForm(StoreProvider storeProvider, String UserId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Your Shop',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 16),
        TextField(
          controller: _shopNameController,
          decoration: InputDecoration(labelText: 'Shop Name'),
        ),
        SizedBox(height: 16),
        TextField(
          controller: _shopContactController,
          decoration: InputDecoration(labelText: 'Shop Contact Number'),
        ),
        SizedBox(height: 16),
        SwitchListTile(
          title: Text('Enable Pickup Option'),
          value: isPickup,
          onChanged: (value) => setState(() => isPickup = value),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: _pickImage,
          child: Text('Pick Shop Image'),
        ),
        if (_pickedImage != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Image.file(File(_pickedImage!.path), height: 150),
          ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            if (_shopNameController.text.isNotEmpty &&
                _shopContactController.text.isNotEmpty &&
                _pickedImage != null) {
              final newStore = Store(
                id: DateTime.now()
                    .toString(), // Store ID can be set by Firestore in production
                name: _shopNameController.text,
                contact: _shopContactController.text,
                isPickup: isPickup,
                imageUrl: _pickedImage!.path,
                foods: [], // Initial empty list of foods
              );

              // Save new store
              await storeProvider.createOrUpdateStore(newStore, UserId);

              // Navigate to the 'Your Shop' screen after creating the store
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      StoreDetailsPage(currentUser: widget.currentUser),
                ),
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Shop created successfully!')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('Please fill all fields and select an image')),
              );
            }
          },
          child: Text('Create Shop'),
        ),
      ],
    );
  }

  Widget _buildStoreDetails(StoreProvider storeProvider) {
    final userStore =
        storeProvider.userStore; // Accessing user store from the provider
    final foodProvider = Provider.of<FoodProvider>(context);
    String storeId = userStore?.id ?? ''; // Safely access storeId

    // If store does not exist, show loading indicator or message
    if (userStore == null) {
      return Center(child: Text("No store found."));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Shop Details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Text('Name: ${userStore.name}'),
        Text('Contact: ${userStore.contact}'),
        Text('Pickup Available: ${userStore.isPickup ? "Yes" : "No"}'),
        SizedBox(height: 16),
        if (userStore.imageUrl.isNotEmpty)
          Image.file(File(userStore.imageUrl), height: 150),
        SizedBox(height: 16),

        // Edit shop details (future functionality)
        ElevatedButton(
          onPressed: () {
            // Logic for editing store details (Optional for future)
          },
          child: Text('Edit Shop Details'),
        ),
        SizedBox(height: 16),

        // Fetch foods from the FoodProvider and display list
        FutureBuilder<void>(
          future: foodProvider.fetchFoods(storeId), // Fetch foods via provider
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError ||
                !snapshot.hasData ||
                foodProvider.foods.isEmpty) {
              return Center(
                  child: Text('Failed to load foods or no foods available.'));
            }

            // List of foods from the provider
            List<Food> foods = foodProvider.foods;
            return Expanded(
              child: ListView.builder(
                itemCount: foods.length,
                itemBuilder: (context, index) {
                  var food = foods[index];
                  return ListTile(
                    title: Text(food.name),
                    subtitle: Text("\$${food.price.toString()}"),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        await foodProvider.deleteFood(storeId, food.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Food removed!')),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),

        // Add New Food Button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddFoodPage(storeId: storeId),
                ),
              );
            },
            child: Text('Add New Food'),
          ),
        ),

        // Remove shop button - Delete the store using StoreProvider
        ElevatedButton(
          onPressed: () async {
            await storeProvider.deleteStore(storeProvider.userStore?.id ?? '');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Shop deleted successfully')),
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text('Remove Shop'),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _pickedImage = pickedImage;
      });
    }
  }
}
