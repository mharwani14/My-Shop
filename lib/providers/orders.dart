import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime time;
  OrderItem(
      {required this.id,
      required this.amount,
      required this.products,
      required this.time});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String? token;
  final String? userId;
  Orders(this.token, this.userId);
  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    // String tot = double.parse(total.toString()).toString();

    final timeStamp = DateTime.now();
    final response = await http.post(
      Uri.parse(
          'https://flutter-upgrade-f1d6e-default-rtdb.firebaseio.com/orders/$userId.json?auth=$token'),
      body: json.encode({
        'amount': total,
        'dateTime': timeStamp.toIso8601String(),
        'products': cartProducts
            .map((cartIt) => {
                  'id': cartIt.id,
                  'title': cartIt.title,
                  'quantity': cartIt.quantity,
                  'price': cartIt.price
                })
            .toList()
      }),
    );
    _orders.insert(
      0,
      OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          products: cartProducts,
          time: timeStamp),
    );
    notifyListeners();
  }

  Future<void> fetchAndSet() async {
    final response = await http.get(Uri.parse(
        'https://flutter-upgrade-f1d6e-default-rtdb.firebaseio.com/orders/$userId.json?auth=$token'));
    final List<OrderItem> loadedOrders = [];
    final extractedResponse =
        json.decode(response.body) as Map<String, dynamic>;
    if (extractedResponse.isEmpty) {
      return;
    }
    extractedResponse.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
          amount: orderData['amount'],
          id: orderId,
          products: (orderData['products'] as List<dynamic>)
              .map(
                (item) => CartItem(
                  id: item['id'],
                  title: item['title'],
                  quantity: item['quantity'],
                  price: item['price'],
                ),
              )
              .toList(),
          time: DateTime.parse(orderData['dateTime']),
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }
}
