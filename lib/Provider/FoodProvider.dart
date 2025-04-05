import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eato/Model/Food&Store.dart';

class FoodProvider with ChangeNotifier {
  List<Food> _foods = [];  // Local list to store the foods

  List<Food> get foods => _foods;  // Getter to retrieve the foods list

  // Fetch foods for a given store by storeId
Future<void> fetchFoods(String storeId) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')  // Ensure 'users' collection exists
        .doc(storeId)  // Verify this is the correct storeId reference
        .collection('stores')  // Make sure the 'stores' collection exists
        .doc(storeId)  // Check if the store document exists here
        .collection('foods')  // Ensure 'foods' is a subcollection under store
        .get();
    
    if (snapshot.docs.isEmpty) {
      print("No foods found for store $storeId.");
    } else {
      _foods = snapshot.docs
          .map((doc) => Food.fromFirestore(doc.data(), doc.id))
          .toList();
      notifyListeners(); // Trigger UI update
    }
  } catch (e) {
    print("Error fetching foods: $e");
    // For deeper debugging, print more details
    debugPrintStack();
  }
}





  // Add new food to a store's food collection
  Future<void> addFood(String storeId, Food food) async {
    try {
      await FirebaseFirestore.instance
       .collection('users')  // Top level: users collection
          .doc(storeId)  // Store document (via storeId, assuming stores are directly under users)
          .collection('stores')  // Store collection
          .doc(storeId)  // Store document
          .collection('foods')  // Foods sub-collection
          .add(food.toMap());  // Add food to Firestore
      
      // Fetch updated list of foods after adding the new one
      fetchFoods(storeId);
    } catch (e) {
      print("Error adding food: $e");  // Error handling
    }
  }

  // Update food information in Firestore
  Future<void> updateFood(String storeId, Food food) async {
    try {
      await FirebaseFirestore.instance
       .collection('users')  // Top level: users collection
          .doc(storeId)  // Store document (via storeId, assuming stores are directly under users)
          .collection('stores')  // Store collection
          .doc(storeId)  // Store document
          .collection('foods')  // Foods sub-collection
          .doc(food.id)  // Food document ID
          .set(food.toMap());  // Update food with new values

      // Fetch updated foods after modifying an existing one
      fetchFoods(storeId);
    } catch (e) {
      print("Error updating food: $e");  // Error handling
    }
  }

  // Delete food from the store's food collection
  Future<void> deleteFood(String storeId, String foodId) async {
    try {
      await FirebaseFirestore.instance
       .collection('users')  // Top level: users collection
          .doc(storeId)  // Store document (via storeId, assuming stores are directly under users)
          .collection('stores')  // Store collection
          .doc(storeId)  // Store document
          .collection('foods')  // Foods sub-collection
          .doc(foodId)  // Food document ID
          .delete();  // Delete the document

      // Fetch updated foods after deleting the item
      fetchFoods(storeId);
    } catch (e) {
      print("Error deleting food: $e");  // Error handling
    }
  }
}
