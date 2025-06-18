// models/dish.dart
class Dish {
  final int? id;
  final int sessionId;
  final String name;
  final int quantity;
  final double price;

  Dish({
    this.id,
    required this.sessionId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  double get totalCost => quantity * price;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }

  static Dish fromMap(Map<String, dynamic> map) {
    return Dish(
      id: map['id'],
      sessionId: map['session_id'],
      name: map['name'],
      quantity: map['quantity'],
      price: map['price'],
    );
  }
}