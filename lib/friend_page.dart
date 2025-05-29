import 'package:drp_19/storage.dart';
import 'package:flutter/material.dart';
import 'internet.dart';
import 'friend.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({super.key});

  @override
  _FriendPageState createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  String _username = '';
  String _userId = '';
  String _tempFriendName = '';
  List<FriendRecord> _friends = [];

  @override
  void initState() {
    super.initState();
    _loadInitialUserState();
  }

  // Load username and id from storage to local variables
  Future<void> _loadInitialUserState() async {
    String? username = await SleepStorage.loadUsername();
    String? userId = await SleepStorage.loadUserId();
    List<FriendRecord> friend = await Internet.getFriendList(userId ?? '');
    setState(() {
      _username = username ?? 'Not yet registered';
      _userId = userId ?? '';
      _friends = friend;
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
          // Register button if username is not set
          if (_userId.isEmpty)
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
                          title: Text('Enter your username'),
                          content: TextField(
                            onChanged: (value) {
                              _username = value;
                            },
                            decoration: InputDecoration(hintText: "Username"),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, _username),
                              child: Text('Submit'),
                            ),
                          ],
                        );
                      },
                    );
                    if (newUsername != null && newUsername.isNotEmpty) {
                      await SleepStorage.saveUsername(newUsername);
                      final id = await Internet.fetchUid(newUsername);
                      setState(() {
                        _username = newUsername;
                        _userId = id ?? '';
                      });
                      await SleepStorage.saveUserId(_userId);
                      if (_userId.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error fetching user ID')),
                        );
                      }
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
            )
          else
            Scaffold(
              appBar: AppBar(title: Text("Friends")),
              body: Stack(

                children: [

                  // Friends list
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    '   Your User Name: $_username',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                  

                  // friend list
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.12, left: screenHeight * 0.05),
                    child: ListView.builder(
                      itemCount: _friends.length,
                      itemBuilder: (context, index) {
                        final friend = _friends[index];
                        return ListTile(
                          title: Text(friend.username),
                          subtitle: Text('ID: ${friend.userId}'),
                        );
                      },
                    ),
                  ),

                  // If userId is set, show add friend button
                  Positioned(
                    top: screenHeight * 0.05,
                    right: screenHeight * 0.03,
                    child: SizedBox(
                      width: 150,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: // Prompt user to enter friend's id
                        () async {
                          String? friendUsername = await showDialog<String>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Enter friend\'s name'),
                                content: TextField(
                                  onChanged: (value) {
                                    _tempFriendName = value;
                                  },
                                  decoration: InputDecoration(hintText: "name"),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, _tempFriendName),
                                    child: Text('Submit'),
                                  ),
                                ],
                              );
                            },
                          );
                          if (friendUsername != null && friendUsername.isNotEmpty) {
                            bool? addFriendStates = await Internet.addFriend(_userId, friendUsername);
                            if (addFriendStates ?? false) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text('friend request sent')));
                            } else {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text('error sending friend request')));
                            }

                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withAlpha(200),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          "Add friend",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
              ]
            )
          )
        ],
      ),
    );
  }
}
