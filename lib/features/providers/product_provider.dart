import 'package:flutter/material.dart';

import '../models/product_model.dart';
// import '../models/product_model.dart';

class ProductProvider with ChangeNotifier {
  final List<Product> _products = [
    Product(
      id: '1',
      name: 'Heavy Duty',
      description: 'Affordable, Comfortable, eco-friendly menstrual pads.',
      imageUrl: 'https://padupcreations.com/wp-content/uploads/2024/04/heavy_duty_pack-removebg-preview.png',
      link: 'https://padupcreations.com/shop/',
    ),
    Product(
      id: '2',
      name: 'Alora Premium Box Pack',
      description: 'Eco-friendly menstrual pads.',
      imageUrl: 'https://alorapads.com/wp-content/uploads/2024/10/Alora-Premium-Reusable-Pad-700x700.png',
      link: 'https://alorapads.com/buy/',
    ),
  ];

  List<Product> get products => [..._products];
}
