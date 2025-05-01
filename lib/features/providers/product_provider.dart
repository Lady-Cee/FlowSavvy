import 'package:flutter/material.dart';

import '../models/product_model.dart';
// import '../models/product_model.dart';

class ProductProvider with ChangeNotifier {
  final List<Product> _products = [
    Product(
      id: '1',
      name: 'Organic Pads',
      description: 'Comfortable, eco-friendly menstrual pads.',
      imageUrl: 'https://example.com/images/pads.jpg',
      link: 'https://example.com/product/organic-pads',
    ),
    Product(
      id: '2',
      name: 'Period Tracker Bracelet',
      description: 'Smart wearable to track your cycle.',
      imageUrl: 'https://example.com/images/bracelet.jpg',
      link: 'https://example.com/product/tracker',
    ),
  ];

  List<Product> get products => [..._products];
}
