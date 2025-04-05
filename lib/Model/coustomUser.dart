import 'package:eato/Model/Food&Store.dart';

class CustomUser {
  final String id;
  final String role;
  final String name;
  final String email;
  final String phoneNumber;
  final Store? myStore; // Marked nullable for users without a store

  CustomUser({
    required this.id,
    required this.role,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.myStore,
  });

  // Factory method to create a CustomUser from Firestore data
  factory CustomUser.fromFirestore(Map<String, dynamic> data, String id) {
    return CustomUser(
      id: id,
      role: data['role'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      myStore: data['myStore'] != null
          ? Store.fromFirestore(data['myStore'], data['myStore']['id'] ?? '')
          : null, // Parse the store if it exists
    );
  }

  // Convert CustomUser to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'myStore': myStore?.toMap(), // Convert the store to a Map
    };
  }
   CustomUser copyWith({
    String? id,
    String? role,
    String? name,
    String? email,
    String? phoneNumber,
    Store? myStore,
  }) {
    return CustomUser(
      id: id ?? this.id,
      role: role ?? this.role,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      myStore: myStore ?? this.myStore,
    );
  }
}
