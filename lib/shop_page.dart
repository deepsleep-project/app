import 'package:deepsleep/internet.dart';
import 'package:deepsleep/storage.dart';
import 'package:flutter/material.dart';
import 'shop_item.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _TentPageState();
}

class _TentPageState extends State<ShopPage> {
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _tryToBuy(ShopItem item) async {
    if (_status.contains(item.id)) {
      _showSnackBar('You already bought this item');
      return;
    } else {
      if (_currency < item.price) {
        _showSnackBar('You do not have enough energy');
      } else {
        bool timeout = false;
        await Internet.setItemPurchase(_userId, item.id).timeout(
          const Duration(seconds: 60),
          onTimeout: () async {
            timeout = true;
            return;
          },
        );
        if (timeout) {
          _showSnackBar('Connection failed. Please try again.');
          return;
        }

        setState(() {
          _currency -= item.price;
          _status.add(item.id);
        });
        SleepStorage.saveCurrency(_currency);
        SleepStorage.saveShopItemStates(_status);
        _showSnackBar('Successfully bought ${item.name}');
      }
    }
  }

  String _userId = '';
  int _currency = 0;
  List<int> _status = [];

  @override
  initState() {
    super.initState();
    _loadInitialSleepState();
  }

  Future<void> _loadInitialSleepState() async {
    super.initState();
    String userId = await SleepStorage.loadUserId();
    int currency = await SleepStorage.loadCurrency();
    List<int> status = await SleepStorage.loadShopItemStates();
    setState(() {
      _userId = userId;
      _status = status;
      _currency = currency;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Image.asset(
            'assets/shop.png',
            fit: BoxFit.cover,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),

          // Back button
          Positioned(
            top: screenHeight * 0.07,
            left: screenHeight * 0.03,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
              tooltip: 'Back',
              style: IconButton.styleFrom(
                backgroundColor: Colors.black45,
                shape: CircleBorder(),
              ),
            ),
          ),

          Positioned(
            top: screenHeight * 0.07,
            left: screenWidth * 0.73,
            child: SizedBox(
              width: 250,
              height: 55,
              child: Row(
                children: [
                  Icon(Icons.bolt, size: 30, color: Colors.yellow),
                  Text(
                    _currency.toString(),
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.225,
            left: screenHeight * 0.08,
            child: Column(
              children: [
                Row(
                  spacing: screenHeight * 0.05,
                  children: [
                    _buildItemViews(items[0]),
                    _buildItemViews(items[1]),
                  ],
                ),
                SizedBox(height: screenHeight * 0.015),
                Row(
                  spacing: screenHeight * 0.05,
                  children: [
                    _buildItemViews(items[2]),
                    _buildItemViews(items[3]),
                  ],
                ),
                SizedBox(height: screenHeight * 0.008),
                Row(
                  spacing: screenHeight * 0.05,
                  children: [
                    _buildItemViews(items[4]),
                    _buildItemViews(items[5]),
                  ],
                ),
                Row(
                  spacing: screenHeight * 0.05,
                  children: [
                    _buildItemViews(items[6]),
                    _buildItemViews(items[7]),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildItemViews(ShopItem item) {
    final screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () => _tryToBuy(item),
      child: Column(
        children: [
          Image.asset(
            item.imagepath,
            width: screenHeight * 0.13,
            height: screenHeight * 0.13,
          ),
          Text(
            item.name,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
          Text(
            _status.contains(item.id) ? "Already Bought" : '${item.price}',
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
