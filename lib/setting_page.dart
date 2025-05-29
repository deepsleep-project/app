import 'package:drp_19/storage.dart';
import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
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
        ],
      ),
    );
  }
}
