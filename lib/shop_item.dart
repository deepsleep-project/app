import 'package:flutter/material.dart';

class ShopItem {
  final int id;
  final String name;
  final String imagepath;
  final int price;
  final double x;
  final double y;
  final double w;
  final double h;
  ShopItem({
    required this.id,
    required this.name,
    required this.imagepath,
    required this.price,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
  });

  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Positioned(
      top: screenHeight * y,
      left: screenWidth * x,
      child: Image.asset(
        imagepath,
        width: screenHeight * w,
        height: screenHeight * h,
      ),
    );
  }
}

final items = [
  ShopItem(
    id: 1,
    name: 'campbag',
    imagepath: 'assets/items/campbag.png',
    price: 400,
    x: 0.02,
    y: 0.68,
    w: 0.2,
    h: 0.2,
  ),
  ShopItem(
    id: 2,
    name: 'chair',
    imagepath: 'assets/items/chair.png',
    price: 500,
    x: 0.55,
    y: 0.55,
    w: 0.25,
    h: 0.25,
  ),
  ShopItem(
    id: 3,
    name: 'clock',
    imagepath: 'assets/items/clock.png',
    price: 500,
    x: 0.57,
    y: 0.25,
    w: 0.12,
    h: 0.12,
  ),
  ShopItem(
    id: 4,
    name: 'plant',
    imagepath: 'assets/items/plant.png',
    price: 200,
    x: 0.74,
    y: 0.63,
    w: 0.15,
    h: 0.15,
  ),
  ShopItem(
    id: 5,
    name: 'books',
    imagepath: 'assets/items/books.png',
    price: 200,
    x: 0.62,
    y: 0.67,
    w: 0.15,
    h: 0.15,
  ),
  ShopItem(
    id: 6,
    name: 'painting',
    imagepath: 'assets/items/painting.png',
    price: 400,
    x: 0.07,
    y: 0.31,
    w: 0.19,
    h: 0.19,
  ),
  ShopItem(
    id: 7,
    name: 'lamp',
    imagepath: 'assets/items/lamp.png',
    price: 500,
    x: 0.48,
    y: 0.77,
    w: 0.17,
    h: 0.17,
  ),
  ShopItem(
    id: 8,
    name: 'duck',
    imagepath: 'assets/items/duck.png',
    price: 1000,
    x: 0.40,
    y: 0.50,
    w: 0.12,
    h: 0.12,
  ),
];
