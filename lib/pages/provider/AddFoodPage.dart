// AddFoodPage.dart

import 'dart:io';

import 'package:eato/Model/Food&Store.dart';
import 'package:eato/Provider/FoodProvider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddFoodPage extends StatefulWidget {
  final String storeId;

  AddFoodPage({super.key, required this.storeId});

  @override
  _AddFoodPageState createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  XFile? _pickedImage;
  String? _uploadedImageUrl; // URL for image after uploading to Firebase Storage

  // Function to pick image from gallery or camera
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = pickedFile;
      });
    }
  }

  // Function to upload picked image to Firebase Storage
  Future<void> _uploadImage() async {
    if (_pickedImage == null) return;

    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('food_images/$fileName');

      await storageRef.putFile(File(_pickedImage!.path));
      _uploadedImageUrl = await storageRef.getDownloadURL(); // Get URL after upload
    } catch (e) {
      print("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image upload failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Food'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Food Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter food name' : null,
              ),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Food Type'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter food type' : null,
              ),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter price' : null,
              ),
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                    labelText: 'Meal Time (Breakfast, Lunch, Dinner)'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter meal time' : null,
              ),
              GestureDetector(
                onTap: _pickImage, // Trigger image picking
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _pickedImage == null
                      ? Center(child: Text('Pick an image'))
                      : Image.file(File(_pickedImage!.path), fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Upload image and get URL
                      await _uploadImage();

                      final food = Food(
                        id: '', // Assign unique id
                        name: _nameController.text,
                        type: _typeController.text,
                        price: double.tryParse(_priceController.text) ?? 0.0,
                        time: _timeController.text,
                        imageUrl: _uploadedImageUrl ?? '',
                      );

                      // Add food to Firestore under the store's 'foods' subcollection
                      Provider.of<FoodProvider>(context, listen: false)
                          .addFood(widget.storeId, food);
                      Navigator.pop(context); // Pop back after adding food
                    }
                  },
                  child: const Text('Add Food'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
