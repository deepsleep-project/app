import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'tent_page.dart';
import 'storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _formattedTime = '';
  bool _isSleeping = false;

  @override
  void initState() {
    super.initState();
    _updateTime();
    Timer.periodic(Duration(seconds: 1), (timer) {
      _updateTime();
    });
    _loadInitialState();
  }

  void _updateTime() {
    final now = DateTime.now();
    final formatter = DateFormat('HH:mm');
    setState(() {
      _formattedTime = formatter.format(now);
    });
  }

    void _goToNextPage() {
    Navigator.of(context).push(_createFadeRoute());
  }

  Route _createFadeRoute() {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => TentPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
       });
    }


  Future<void> _loadInitialState() async {
    bool sleeping = await SleepStorage.loadIsSleeping();
    setState(() {
      _isSleeping = sleeping;
    });
  }

  Future<void> _startSleep() async {
    if (_isSleeping) {
      _showSnackBar('already asleep');
      return;
    }
    final now = DateTime.now().toIso8601String();
    await SleepStorage.saveStartTime(now);
    await SleepStorage.saveIsSleeping(true);
    setState(() {
      _isSleeping = true;
    });
    _showSnackBar('start sleep, current time: $_formattedTime');
  }

  Future<void> _endSleep() async {
    if (!_isSleeping) {
      _showSnackBar('not current sleeping');
      return;
    }
    final end = DateTime.now().toIso8601String();
    final start = await SleepStorage.loadStartTime();
    if (start == null) {
      _showSnackBar('null current time');
      return;
    }

    final records = await SleepStorage.loadRecords();
    records.add(SleepRecord(start: start, end: end));
    await SleepStorage.saveRecords(records);
    await SleepStorage.saveIsSleeping(false);

    setState(() {
      _isSleeping = false;
    });

    _showSnackBar('wake up, curent time: $_formattedTime');
  }

  Future<void> _viewHistory() async {
    final records = await SleepStorage.loadRecords();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('History'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final r = records[index];
              return ListTile(
                title: Text('Start: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(r.start))}'),
                subtitle: Text('End: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(r.end))}'),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Shut down'),
          )
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: Image.asset(
              'assets/day.png',
              fit: BoxFit.fitHeight,
              height: screenHeight,
            ),
          ),
          Transform.translate(
            offset: Offset(0, -screenHeight * 0.20),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formattedTime,
                    style: TextStyle(
                      fontSize: 90,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withAlpha(230),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildButton('Start sleep', _startSleep),
                  const SizedBox(height: 10),
                  _buildButton('End sleep', _endSleep),
                  const SizedBox(height: 10),
                  _buildButton('Sleep history', _viewHistory),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.2,
            left: screenHeight * 0.08,
            right: screenHeight * 0.1,
            height: screenHeight * 0.19,
            child: GestureDetector(
              onTap: _goToNextPage,
              child: Container(color: Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withAlpha(200),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 18)),
    );
  }
}
