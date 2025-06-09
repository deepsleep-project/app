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
    return Positioned(
      top: screenHeight * x,
      left: screenHeight * y,
      child: Image.asset(imagepath, width: w, height: h),
    );
  }
}

final items = [
  ShopItem(
    id: 1,
    name: 'campbag',
    imagepath: 'assets/items/campbag.png',
    price: 100,
    x: 0.1,
    y: 0.1,
    w: 30,
    h: 30,
  ),
  ShopItem(
    id: 2,
    name: 'chair',
    imagepath: 'assets/items/chair.png',
    price: 100,
    x: 0.2,
    y: 0.1,
    w: 30,
    h: 30,
  ),
  ShopItem(
    id: 3,
    name: 'clock',
    imagepath: 'assets/items/clock.png',
    price: 100,
    x: 0.3,
    y: 0.1,
    w: 30,
    h: 30,
  ),
  ShopItem(
    id: 4,
    name: 'lamp',
    imagepath: 'assets/items/lamp.png',
    price: 100,
    x: 0.4,
    y: 0.1,
    w: 30,
    h: 30,
  ),
  ShopItem(
    id: 5,
    name: 'plant',
    imagepath: 'assets/items/plant.png',
    price: 100,
    x: 0.7,
    y: 0.1,
    w: 30,
    h: 30,
  ),
  ShopItem(
    id: 6,
    name: 'painting',
    imagepath: 'assets/items/painting.png',
    price: 100,
    x: 0.8,
    y: 0.1,
    w: 30,
    h: 30,
  ),
  ShopItem(
    id: 7,
    name: 'books',
    imagepath: 'assets/items/books.png',
    price: 100,
    x: 0.5,
    y: 0.1,
    w: 30,
    h: 30,
  ),
  ShopItem(
    id: 8,
    name: 'duck',
    imagepath: 'assets/items/duck.png',
    price: 100,
    x: 0.6,
    y: 0.1,
    w: 30,
    h: 30,
  ),
];
