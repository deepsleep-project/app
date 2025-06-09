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


  void _tryToBuy(ShopItem item) {
    if (_status[item.id - 1]) {
      _showSnackBar('Already bought this one');
      return;
    } else {
      if (_currency < item.price) {
        _showSnackBar('Not enough currency');
      } else {
        setState(() {
          _currency -= item.price;
          _status[item.id - 1] = true;
        });
        SleepStorage.saveCurrency(_currency);
        SleepStorage.saveShopItemStates(_status);
        _showSnackBar('Successfully bought');
      }
    }
  }


  int _currency = 0;

  //List<bool> _status = [true, true, true, true, true, true, true, true];
  //List<bool> _status = [false, false, false,false, false,false,false, false];
  List<bool> _status = [false, false, false,false, false,false,false, false];

  @override
  initState() {
    super.initState();
    _loadInitialSleepState();
  }

  Future<void> _loadInitialSleepState() async {
    super.initState();
    int currency = await SleepStorage.loadCurrency();
    List<bool> status= await SleepStorage.loadShopItemStates();
    setState(() {
      _status = status;
      _currency = currency;
    });
  }

  
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

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
          top: screenHeight * 0.08,
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
          top: screenHeight * 0.23,
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
              SizedBox(height: screenHeight * 0.015),
              Row(
                spacing: screenHeight * 0.05,
                children: [
                  _buildItemViews(items[4]),
                  _buildItemViews(items[5]),
                ],
              ),
              SizedBox(height: screenHeight * 0.003),
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
            _status[item.id - 1] ?  "Already Bought" : '${item.price}' ,
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
