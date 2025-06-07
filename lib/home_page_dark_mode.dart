import 'dart:async';
import 'package:deepsleep/home_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'tent_page.dart';

class DarkHomePage extends StatefulWidget {
  const DarkHomePage({super.key});

  @override
  State<DarkHomePage> createState() => _TentPageState();
}

class _TentPageState extends State<DarkHomePage> {
  String _formattedTime = '';

  void _updateTime() {
    final now = DateTime.now();
    final formatter = DateFormat('HH:mm');
    setState(() {
      _formattedTime = formatter.format(now);
    });
  }

  // Navigate to tent_page
  void _goToTentPage() {
    Navigator.of(context).push(_createFadeRouteToTentPage());
  }

  // Create a fade transition route to the tent_page
  Route _createFadeRouteToTentPage() {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => TentPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _updateTime();
    // Update the time every second
    Timer.periodic(Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: PageView(
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Stack(
            fit: StackFit.expand,
            children: [
              Align(
                alignment: Alignment.bottomRight,
                child: Image.asset(
                  'assets/night.png',
                  fit: BoxFit.fitHeight,
                  height: screenHeight,
                ),
              ),
              Transform.translate(
                offset: Offset(0, -screenHeight * 0.19),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formattedTime,
                        style: TextStyle(
                          fontFamily: "Digital",
                          letterSpacing: -2,
                          fontSize: 80,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 200,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        HomePage(),
                                transitionsBuilder:
                                    (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                transitionDuration: Duration(milliseconds: 500),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withAlpha(200),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Get up',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
              // Invisible button to navigate to tent_page
              Positioned(
                bottom: screenHeight * 0.2,
                left: screenHeight * 0.08,
                right: screenHeight * 0.1,
                height: screenHeight * 0.19,
                child: GestureDetector(
                  onTap: _goToTentPage,
                  child: Container(color: Colors.transparent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
