import 'package:deepsleep/storage.dart';
import 'package:flutter/material.dart';
import 'shop_item.dart';

class TentPage extends StatefulWidget {
  const TentPage({super.key});

  @override
  State<TentPage> createState() => _TentPageState();
}

class _TentPageState extends State<TentPage> {
  List<int> _status = [];

  @override
  void initState() {
    super.initState();
    _loadInitialSleepState();
  }

  Future<void> _loadInitialSleepState() async {
    List<int> status = await SleepStorage.loadShopItemStates();
    setState(() {
      _status = status;
      // _status = [1, 3, 4, 5, 6, 7, 8];
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // Background image
        Image.asset(
          'assets/tent.png',
          fit: BoxFit.fill,
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

        for (var item in items)
          if (_status.contains(item.id) && item.name != 'chair')
            item.build(context),
      ],
    );
  }
}
