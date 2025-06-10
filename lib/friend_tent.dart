import 'package:deepsleep/storage.dart';
import 'package:flutter/material.dart';
import 'shop_item.dart';
import 'internet.dart';
import 'friend.dart';

class FriendTentPage extends StatefulWidget {
  final FriendRecord friend; 
  
  const FriendTentPage({super.key, required this.friend}); 

  @override
  State<FriendTentPage> createState() => _TentPageState();
}

class _TentPageState extends State<FriendTentPage> {


  late final String _friendname = widget.friend.username;
  late final List<int> _status = widget.friend.friendTent;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // Background image
        Image.asset(
          'assets/tent.png',
          fit: BoxFit.cover,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
        ),
       Positioned(
  top: screenHeight * 0.09,
  left: 0,    
  right: 0, 
  child: Center(
    child: Text(
      '$_friendname\'s Tent',
      style: TextStyle(
        fontSize: 25,
        color: Colors.white,
        decoration: TextDecoration.none,
      ),
    ),
  ),
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
