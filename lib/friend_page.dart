import 'package:drp_19/storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FriendPage extends StatefulWidget {
  const FriendPage({super.key});

  @override
  _FriendPageState createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadInitialUserState();
  }

  // Load username and id from storage to local variables
  Future<void> _loadInitialUserState() async {
    String? username = await SleepStorage.loadUsername();
    setState(() {
      _username = username ?? 'Unknown User';
    });
  }

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
          Positioned(
            top: screenHeight * 0.08,
            right: screenHeight * 0.03,
            child: SizedBox(
              width: 150,
              height: 50,
              child: ElevatedButton(
                onPressed: //Prompt user to enter new username
                () async {
                  String? newUsername = await showDialog<String>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Enter New Username'),
                        content: TextField(
                          onChanged: (value) {
                            _username = value;
                          },
                          decoration: InputDecoration(hintText: "Username"),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, _username),
                            child: Text('Submit'),
                          ),
                        ],
                      );
                    },
                  );

                  if (newUsername != null && newUsername.isNotEmpty) {
                    await SleepStorage.saveUsername(newUsername);
                    setState(() {
                      _username = newUsername;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withAlpha(200),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text("Register", style: const TextStyle(fontSize: 18)),
              ),
            ),
          ),

          // Friends list
          Center(
            child: Text(
              _username,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
