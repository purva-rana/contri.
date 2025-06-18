// models/diner.dart
class Diner {
  final int? id;
  final int sessionId;
  final String name;
  final List<int> dishIds; // IDs of dishes this diner ate

  Diner({
    this.id,
    required this.sessionId,
    required this.name,
    required this.dishIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'name': name,
      'dishes': dishIds,
    };
  }

  static Diner fromMap(Map<String, dynamic> map, List<int> dishIds) {
    return Diner(
      id: map['id'],
      sessionId: map['session_id'],
      name: map['name'],
      dishIds: dishIds,
    );
  }
}