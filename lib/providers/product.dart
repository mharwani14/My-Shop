import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl,
      this.isFavorite = false});

  void _setfavorite(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> togglefav(String? token, String? userId) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    try {
      final response = await http.put(
        Uri.parse(
            'https://flutter-upgrade-f1d6e-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$token'),
        body: json.encode(
          isFavorite
        ),
      );
      if (response.statusCode >= 400) {
        _setfavorite(oldStatus);
      }
      
    } catch (error) {
      _setfavorite(oldStatus);
    }
  }
}
