import 'package:flutter/material.dart';

class TentPage extends StatefulWidget {
  const TentPage({super.key});

  @override
  State<TentPage> createState() => _TentPageState();
}

class _TentPageState extends State<TentPage> {
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
    );
  }
}
