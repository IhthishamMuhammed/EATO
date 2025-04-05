import 'package:eato/Model/coustomUser.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/Food&Store.dart'; // Adjust the path to your Store model file
 // Adjust the path to your CustomUser model file

class UserProvider with ChangeNotifier {
  CustomUser? _currentUser;

  // Getter for the current user
  CustomUser? get currentUser => _currentUser;

  /// Fetch user data by ID from Firestore and update the local state
  Future<void> fetchUser(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        _currentUser = CustomUser.fromFirestore(data, snapshot.id);
        notifyListeners();
      } else {
        print('No user found with ID: $userId');
      }
    } catch (e) {
      print('Error fetching user with ID $userId: $e');
    }
  }

  /// Update user data in Firestore
  Future<void> updateUser(CustomUser user) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .set(user.toMap(), SetOptions(merge: true));
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  /// Check if the current user owns a store
  bool isStoreOwner() {
    return _currentUser?.myStore != null;
  }

  /// Clear the current user data (for logout scenarios)
  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }

  /// Add or update the store of the current user
  Future<void> addOrUpdateStore(Store store) async {
    if (_currentUser == null) {
      print('Error: No logged-in user to associate a store with');
      return;
    }

    try {
      final updatedUser = _currentUser!.copyWith(myStore: store);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(updatedUser.id)
          .set(updatedUser.toMap(), SetOptions(merge: true));
      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      print('Error adding/updating store: $e');
    }
  }

  /// Remove the store from the current user's profile
  Future<void> removeStore() async {
    if (_currentUser == null || _currentUser!.myStore == null) {
      print('Error: No store to remove for the current user');
      return;
    }

    try {
      final updatedUser = _currentUser!.copyWith(myStore: null);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(updatedUser.id)
          .set(updatedUser.toMap(), SetOptions(merge: true));
      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      print('Error removing store: $e');
    }
  }
}
