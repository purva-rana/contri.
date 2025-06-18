// models/session.dart
import 'diner.dart';
import 'dish.dart';

class Session {
  final int? id;
  final String date;
  final double tax;
  final double tip;
  final List<Diner> diners;
  final List<Dish> dishes;

  Session({
    this.id,
    required this.date,
    required this.tax,
    required this.tip,
    required this.diners,
    required this.dishes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'tax': tax,
      'tip': tip,
      'diners': diners.map((d) => d.toMap()).toList(),
      'dishes': dishes.map((d) => d.toMap()).toList(),
    };
  }

  static Session fromMap(Map<String, dynamic> map, List<Diner> diners, List<Dish> dishes) {
    return Session(
      id: map['id'],
      date: map['date'],
      tax: map['tax'],
      tip: map['tip'],
      diners: diners,
      dishes: dishes,
    );
  }
}
