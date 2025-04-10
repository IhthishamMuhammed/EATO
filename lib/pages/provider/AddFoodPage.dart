import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:eato/Provider/userProvider.dart';
import 'package:eato/Provider/FoodProvider.dart';
import 'package:eato/pages/provider/ProfilePage.dart';
import 'package:eato/Model/Food&Store.dart';

import 'dart:io' as io; // Required for mobile/desktop File

class AddFoodPage extends StatefulWidget {
  final String storeId;

  AddFoodPage({super.key, required this.storeId});

  @override
  _AddFoodPageState createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String _selectedMealTime = 'Breakfast';
  String _selectedFoodCategory = '';
  String _selectedFoodType = '';
  final ImagePicker _picker = ImagePicker();
  int _currentIndex = 2;

  XFile? _pickedImage;
  Uint8List? _webImageData;
  String? _uploadedImageUrl;
  bool _isLoading = false;

  final List<String> _mealTimes = ['Breakfast', 'Lunch', 'Dinner'];
  final List<String> _foodCategories = ['Rice and Curry', 'String Hoppers', 'Roti', 'Egg Roti', 'Short Eats', 'Hoppers'];
  final List<String> _foodTypes = ['Vegetarian', 'Non-Vegetarian', 'Vegan', 'Dessert'];

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final webImageData = await pickedFile.readAsBytes();
        setState(() {
          _pickedImage = pickedFile;
          _webImageData = webImageData;
        });
      } else {
        setState(() {
          _pickedImage = pickedFile;
        });
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_pickedImage == null) return;

    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = FirebaseStorage.instance.ref().child('food_images/$fileName');

      if (kIsWeb) {
        await storageRef.putData(_webImageData!);
      } else {
        await storageRef.putFile(io.File(_pickedImage!.path));
      }

      _uploadedImageUrl = await storageRef.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image upload failed: $e")));
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(currentUser: Provider.of<UserProvider>(context, listen: false).currentUser!),
        ),
      );
    }
  }

  Future<void> _saveFood() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select a food image")));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _uploadImage();

      final food = Food(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        type: _selectedFoodType,
        price: double.tryParse(_priceController.text) ?? 0,
        time: _selectedMealTime,
        imageUrl: _uploadedImageUrl ?? '',
      );

      await Provider.of<FoodProvider>(context, listen: false).addFood(widget.storeId, food);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Food added successfully')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add food: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Food', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Meal time tabs
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _mealTimes.map((mealTime) {
                    bool isActive = mealTime == _selectedMealTime;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMealTime = mealTime),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              mealTime,
                              style: TextStyle(
                                color: isActive ? Colors.purple : Colors.grey,
                                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                          Container(height: 2, width: 100, color: isActive ? Colors.purple : Colors.transparent),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                color: Colors.purple.withOpacity(0.1),
                child: Text('Add New Food', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDropdown('Food Category', _foodCategories, (val) => _selectedFoodCategory = val),
                        SizedBox(height: 16),
                        _buildDropdown('Food Type', _foodTypes, (val) => _selectedFoodType = val),
                        SizedBox(height: 16),
                        _buildTextInput('Food Name', _nameController),
                        SizedBox(height: 16),
                        _buildTextInput('Food Price', _priceController, isNumeric: true),
                        SizedBox(height: 24),
                        Center(
                          child: Column(
                            children: [
                              Text('Food picture', style: TextStyle(fontWeight: FontWeight.w500)),
                              SizedBox(height: 12),
                              GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.purple),
                                  ),
                                  child: _pickedImage == null
                                      ? Icon(Icons.add_photo_alternate, color: Colors.purple, size: 40)
                                      : ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: kIsWeb
                                              ? Image.memory(_webImageData!, fit: BoxFit.cover, width: 100, height: 100)
                                              : Image.file(io.File(_pickedImage!.path), fit: BoxFit.cover, width: 100, height: 100),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),
                        Center(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveFood,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              minimumSize: Size(200, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            ),
                            child: Text('Save', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: Center(
                child: CircularProgressIndicator(color: Colors.purple),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildTextInput(String label, TextEditingController controller, {bool isNumeric = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            filled: true,
            fillColor: Colors.grey[200],
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter $label';
            if (isNumeric && double.tryParse(value) == null) return 'Enter valid number';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> options, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding: EdgeInsets.symmetric(horizontal: 12),
            border: InputBorder.none,
          ),
          items: options.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
          onChanged: (val) => setState(() => onChanged(val!)),
          validator: (val) => val == null || val.isEmpty ? 'Please select $label' : null,
        ),
      ],
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
        BottomNavigationBarItem(icon: Icon(Icons.article_outlined), label: 'Orders'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Requests'),
        BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Add food'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}
