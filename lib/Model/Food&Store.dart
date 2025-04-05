class Food {
  final String id;
  final String name;
  final String type;
  final double price;
  final String time; // Breakfast, Lunch, Dinner
  final String imageUrl; // Food image URL
//git from ihthisam
  Food({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.time,
    required this.imageUrl,
  });

  // Firestore map conversion
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'price': price,
      'time': time,
      'imageUrl': imageUrl, // Add image URL to food map
    };
  }

  // Firestore document to Food instance
  factory Food.fromFirestore(Map<String, dynamic> data, String id) {
    return Food(
      id: id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      price: data['price'] ?? 0.0,
      time: data['time'] ?? 'Breakfast', // Default to Breakfast
      imageUrl: data['imageUrl'] ?? '', // Set image URL
    );
  }

  // CopyWith method to create a new object with updated properties
  Food copyWith({String? id, String? name, String? type, double? price, String? time, String? imageUrl}) {
    return Food(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      price: price ?? this.price,
      time: time ?? this.time,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class Store {
  final String id;
  final String name;
  final String contact;
  final bool isPickup;
  final String imageUrl;
  final List<Food> foods;

  Store({
    required this.id,
    required this.name,
    required this.contact,
    required this.isPickup,
    required this.imageUrl,
    required this.foods,
  });

  // fromFirestore method to convert Firestore data to Store object
  factory Store.fromFirestore(Map<String, dynamic> data, String id) {
    return Store(
      id: id,
      name: data['name'] ?? '',
      contact: data['contact'] ?? '',
      isPickup: data['isPickup'] ?? false,
      imageUrl: data['imageUrl'] ?? '',
      foods: [], // Initialize food as an empty list by default
    );
  }

 

  // Convert Store to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'contact': contact,
      'isPickup': isPickup,
      'imageUrl': imageUrl,
      // Foods are not directly stored in this document but are stored in the food subcollection
    };
  }
Store copyWith({
    String? id,
    String? name,
    String? contact,
    bool? isPickup,
    String? imageUrl,
    List<Food>? foods,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      isPickup: isPickup ?? this.isPickup,
      imageUrl: imageUrl ?? this.imageUrl,
      foods: foods ?? this.foods, // If foods is provided, it will update, otherwise keep the old foods list
    );
  }
  // Add new food to Firestore in the foods subcollection
  
}
