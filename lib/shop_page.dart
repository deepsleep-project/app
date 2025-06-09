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

  void _trytobuy(ShopItem item) {
    if (_status[item.id - 1]) {
      _showSnackBar('Already bought this on');
      return;
    } else {
      if (_currency < item.price) {
        _showSnackBar('Not enough currency');
      } else {
        SleepStorage.saveCurrency(_currency - item.price);
        _status[item.id - 1] = true;
        SleepStorage.saveShopItemStates(_status);
        _showSnackBar('Succesfully buy');
      }

    }
  }

  int _currency = 0;

  List<bool> _status = [true,true,true,true,true,true,true,true];

  @override
  initState()  {
    super.initState();
    _loadInitialSleepState();
  }

  Future<void> _loadInitialSleepState() async {
    super.initState();
    int currency = await SleepStorage.loadCurrency();
    //List<bool> status= await SleepStorage.loadShopItemStates();
    setState(() {
      //_status = status;
      _currency = currency;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
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
          top: screenHeight * 0.08, // adjust for padding/status bar
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
       Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: items.map((item) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    _trytobuy(item);
                  },
                  child: Image.asset(
                    item.imagepath,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.name.isNotEmpty ? item.name : 'No Name',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      )
      ],
    );
  }
}
