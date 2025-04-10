import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:eato/Model/Food&Store.dart';

class FoodProvider with ChangeNotifier {
  List<Food> _foods = [];
  bool _isLoading = false;

  List<Food> get foods => _foods;
  bool get isLoading => _isLoading;

  // Fetch foods for a specific store
  Future<void> fetchFoods(String storeId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final QuerySnapshot foodSnapshot = await FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .collection('foods')
          .get();

      _foods = foodSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Food(
          id: doc.id,
          name: data['name'] ?? '',
          type: data['type'] ?? '',
          price: (data['price'] ?? 0).toDouble(),
          time: data['time'] ?? 'Breakfast',
          imageUrl: data['imageUrl'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error fetching foods: $e');
      // Reset foods list in case of error
      _foods = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new food item
  Future<void> addFood(String storeId, Food food) async {
    _isLoading = true;
    notifyListeners();

    try {
      final docRef = await FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .collection('foods')
          .add({
        'name': food.name,
        'type': food.type,
        'price': food.price,
        'time': food.time,
        'imageUrl': food.imageUrl,
      });

      // Update the food item with the generated ID
      final newFood = Food(
        id: docRef.id,
        name: food.name,
        type: food.type,
        price: food.price,
        time: food.time,
        imageUrl: food.imageUrl,
      );

      _foods.add(newFood);
    } catch (e) {
      print('Error adding food: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a food item
  Future<void> deleteFood(String storeId, String foodId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .collection('foods')
          .doc(foodId)
          .delete();

      _foods.removeWhere((food) => food.id == foodId);
    } catch (e) {
      print('Error deleting food: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update a food item
  Future<void> updateFood(String storeId, Food updatedFood) async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .collection('foods')
          .doc(updatedFood.id)
          .update({
        'name': updatedFood.name,
        'type': updatedFood.type,
        'price': updatedFood.price,
        'time': updatedFood.time,
        'imageUrl': updatedFood.imageUrl,
      });

      // Update the food item in the local list
      final index = _foods.indexWhere((food) => food.id == updatedFood.id);
      if (index != -1) {
        _foods[index] = updatedFood;
      }
    } catch (e) {
      print('Error updating food: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}