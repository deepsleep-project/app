import 'package:drp_19/friend_request.dart';
import 'package:drp_19/storage.dart';
import 'package:flutter/material.dart';
import 'internet.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({super.key});

  @override
  _FriendPageState createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  String _username = '';
  String _userId = '';
  String _tempFriendName = '';
  List<FriendRequest> _friendRequests = [];

  @override
  void initState() {
    super.initState();
    _loadInitialUserState();
  }

  // Load username and id from storage to local variables
  Future<void> _loadInitialUserState() async {
    String? username = await SleepStorage.loadUsername();
    String? userId = await SleepStorage.loadUserId();
    setState(() {
      _username = username ?? 'Not yet registered';
      _userId = userId ?? '';
    });
  }

  Future<void> _refreshFriendsList() async {
    if (_userId.isNotEmpty) {
      final requests = await Internet.fetchFriendRequest(_userId) ?? [];
      setState(() {
        _friendRequests = requests;
      });
      if (_friendRequests.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('You have new friend requests')));
      }
    }
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
            child: Row(
              spacing: 15,
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _refreshFriendsList,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withAlpha(200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Center(child: Icon(Icons.refresh, size: 30)),
                  ),
                ), // Register button if username is not set, otherwise show add friend button
                _userId.isEmpty
                    ? SizedBox(
                        width: 150,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            String? newUsername = await showDialog<String>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Enter your username'),
                                  content: TextField(
                                    onChanged: (value) {
                                      _username = value;
                                    },
                                    decoration: InputDecoration(
                                      hintText: "Username",
                                    ),
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
                                  SnackBar(
                                    content: Text('Error fetching user ID'),
                                  ),
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
                          child: Text(
                            "Register",
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      )
                    : // Add friend button if user is registered
                      SizedBox(
                        width: 150,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            String? friendUsername = await showDialog<String>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Enter friend\'s name'),
                                  content: TextField(
                                    onChanged: (value) {
                                      _tempFriendName = value;
                                    },
                                    decoration: InputDecoration(
                                      hintText: "name",
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(
                                        context,
                                        _tempFriendName,
                                      ),
                                      child: Text('Submit'),
                                    ),
                                  ],
                                );
                              },
                            );
                            if (friendUsername != null &&
                                friendUsername.isNotEmpty) {
                              bool? addFriendStates = await Internet.addFriend(
                                _userId,
                                friendUsername,
                              );
                              if (addFriendStates ?? false) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('friend request sent'),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'error sending friend request',
                                    ),
                                  ),
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
                          child: Text(
                            "Add friend",
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
              ],
            ),
          ),
          // ...existing code...
          // add friend requests list
          Positioned(
            top:
                screenHeight * 0.17, // adjust as needed to appear below buttons
            left: screenHeight * 0.03,
            right: screenHeight * 0.03,
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      _username,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      _userId,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                FriendRequestList(friendRequests: _friendRequests),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FriendRequestList extends StatefulWidget {
  final List<FriendRequest> friendRequests;

  const FriendRequestList({super.key, required this.friendRequests});

  @override
  _FriendRequestListState createState() => _FriendRequestListState();
}

class _FriendRequestListState extends State<FriendRequestList> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: widget.friendRequests.map((request) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Username on the left
                Expanded(
                  child: Text(request.username, style: TextStyle(fontSize: 18)),
                ),
                // Buttons on the right
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Handle accept
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Icon(Icons.check, color: Colors.white, size: 20),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Handle decline
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
