import 'package:flutter/material.dart';
import 'package:my_shop/models/http_exception.dart';
import 'product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductsProvider with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl: 'https://sc04.alicdn.com/kf/UTB8erpEtNHEXKJk43Jeq6yeeXXaV.jpg',
    // ),
    // Product(
    //     id: 'p2',
    //     title: 'Trousers',
    //     description: 'A nice pair of trousers.',
    //     price: 59.99,
    //     imageUrl:
    //         'https://www.shutterstock.com/image-photo/trousers-men-isolated-on-white-260nw-179206496.jpg'),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  var _showFavoruties = false;
  List<Product> get items {
    if (_showFavoruties) {
      // return _items.where((product) => product.isFavorite).toList();
    }
    return [..._items];
  }

  final String? token;
  final String? userId;
  ProductsProvider(this.token, this.userId);

//We need to send token to requests to fetch our products when we login,
//we can do that by passing our token in our url
  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filtered =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    try {
      final response = await http.get(Uri.parse(
          'https://flutter-upgrade-f1d6e-default-rtdb.firebaseio.com/products.json?auth=$token&$filtered'));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData.isEmpty) {
        return;
      }
      final favoriteResponse = await http.get(Uri.parse(
          'https://flutter-upgrade-f1d6e-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$token'));
      final favoriteData = json.decode(favoriteResponse.body);
      List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          imageUrl: prodData['imageUrl'],
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://flutter-upgrade-f1d6e-default-rtdb.firebaseio.com/products.json?auth=$token'),
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId': userId
        }),
      );

      final newProduct = Product(
          title: product.title,
          imageUrl: product.imageUrl,
          price: product.price,
          description: product.description,
          isFavorite: product.isFavorite,
          id: json.decode(response.body)['name']);
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }

    // return http
    //     .post(
    //   Uri.parse(
    //       'https://flutter-upgrade-f1d6e-default-rtdb.firebaseio.com/products.json'),
    //   body: json.encode({
    //     'title': product.title,
    //     'description': product.description,
    //     'imageUrl': product.imageUrl,
    //     'price': product.price,
    //     'isFavorite': product.isFavorite
    //   }),
    // )
    //     .then((response) {
    //   print(json.decode(response.body));
    //   final newProduct = Product(
    //       title: product.title,
    //       imageUrl: product.imageUrl,
    //       price: product.price,
    //       description: product.description,
    //       isFavorite: product.isFavorite,
    //       id: json.decode(response.body)['name']);
    //   _items.add(newProduct);
    //   notifyListeners();
    // }).catchError((error) {
    //   print(error);
    //   throw error;
    // });
  }

  List<Product> get favourites {
    return _items.where((prod) => prod.isFavorite).toList();
  }

  // void showFavourties() {
  //   _showFavoruties = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoruties = false;
  //   notifyListeners();
  // }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      await http.patch(
          Uri.parse(
              'https://flutter-upgrade-f1d6e-default-rtdb.firebaseio.com/products/$id.json?auth=$token'),
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
            // 'isFavorite': newProduct.isFavorite,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final existingIndex = _items.indexWhere((prod) => prod.id == id);
    dynamic existingProduct = _items[existingIndex];
    _items.removeAt(existingIndex);
    notifyListeners();
    final response = await http.delete(Uri.parse(
        'https://flutter-upgrade-f1d6e-default-rtdb.firebaseio.com/products/$id.json?auth=$token'));

    if (response.statusCode >= 400) {
      _items.insert(existingIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product');
    }
    existingProduct = null;
  }
}
