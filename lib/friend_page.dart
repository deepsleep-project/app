import 'package:deepsleep/friend_request.dart';
import 'package:deepsleep/storage.dart';
import 'package:flutter/material.dart';
import 'internet.dart';
import 'friend.dart';
import 'friend_tent.dart';
import 'dart:async';

class FriendPage extends StatefulWidget {
  const FriendPage({super.key});

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  String _username = 'You are not registered.';
  String _userId = '';
  String _tempFriendName = '';
  List<FriendRecord> _friends = [];
  List<FriendRequest> _friendRequests = [];

  Timer? _refreshTimer;

  // final List<FriendRequest> _exampleRequests = [
  //   FriendRequest(username: 'Richard', userId: '76789'),
  //   FriendRequest(username: 'Linda', userId: '67890'),
  // ];

  // final List<FriendRecord> _exampleFriends = [
  //   FriendRecord(
  //     username: 'Michael',
  //     userId: '25632',
  //     isAsleep: false,
  //     streak: 9,
  //     friendTent: [1, 3, 5],
  //   ),
  //   FriendRecord(
  //     username: 'Alice',
  //     userId: '12345',
  //     isAsleep: true,
  //     streak: 15,
  //     friendTent: [2, 4, 6, 8],
  //   ),
  //   FriendRecord(
  //     username: 'Bob',
  //     userId: '23456',
  //     isAsleep: false,
  //     streak: 7,
  //     friendTent: [1, 4],
  //   ),
  //   FriendRecord(
  //     username: 'Charlie',
  //     userId: '34567',
  //     isAsleep: true,
  //     streak: 12,
  //     friendTent: [3, 5, 7],
  //   ),
  //   FriendRecord(
  //     username: 'Diana',
  //     userId: '45678',
  //     isAsleep: true,
  //     streak: 20,
  //     friendTent: [1, 2, 3, 4, 5, 6, 7, 8],
  //   ),
  //   FriendRecord(
  //     username: 'Eve',
  //     userId: '56789',
  //     isAsleep: true,
  //     streak: 5,
  //     friendTent: [2, 6, 8],
  //   ),
  //   FriendRecord(
  //     username: 'Frank',
  //     userId: '67890',
  //     isAsleep: true,
  //     streak: 18,
  //     friendTent: [1, 7, 8],
  //   ),
  //   FriendRecord(
  //     username: 'Grace',
  //     userId: '78901',
  //     isAsleep: true,
  //     streak: 11,
  //     friendTent: [3, 4, 5],
  //   ),
  //   FriendRecord(
  //     username: 'Helen',
  //     userId: '89012',
  //     isAsleep: false,
  //     streak: 14,
  //     friendTent: [2, 5, 8],
  //   ),
  //   FriendRecord(
  //     username: 'Ivan',
  //     userId: '90123',
  //     isAsleep: true,
  //     streak: 8,
  //     friendTent: [1, 6, 7],
  //   ),
  //   FriendRecord(
  //     username: 'Judy',
  //     userId: '01234',
  //     isAsleep: false,
  //     streak: 16,
  //     friendTent: [4, 5, 8],
  //   ),
  // ];

  @override
  void initState() {
    super.initState();
    _loadInitialUserState(); // optional: initial load
    _refreshTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      _loadInitialUserState();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // Load username and id from storage to local variables
  Future<void> _loadInitialUserState() async {
    String? username = await SleepStorage.loadUsername();
    String? userId = await SleepStorage.loadUserId();

    setState(() {
      _username = username ?? 'You are not registered.';
      _userId = userId;
    });
    List<FriendRequest> requests = [];
    List<FriendRecord> friends = [];
    bool timeout = false;
    bool hasResult = false;

    if (userId.isNotEmpty) {
      try {
        requests =
            await Internet.fetchFriendRequest(userId).timeout(
              const Duration(seconds: 60),
              onTimeout: () {
                timeout = true;
                return [];
              },
            ) ??
            [];
        hasResult = true;
      } catch (_) {
        timeout = true;
      }
    }

    if ((userId).isNotEmpty && (!timeout)) {
      try {
        friends =
            await Internet.getFriendList(userId).timeout(
              const Duration(seconds: 60),
              onTimeout: () {
                timeout = true;
                return [];
              },
            ) ??
            [];
        hasResult = true;
      } catch (_) {
        timeout = true;
      }
    }

    if (timeout && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network timeout: failed to reach server.')),
      );
      return;
    } else {
      sortFriend(friends);
    }
    setState(() {
      _friendRequests = requests;
      _friends = friends;
      if (_friendRequests.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You have new friend requests.')),
        );
      }
      // else if (!timeout && hasResult) {
      //   ScaffoldMessenger.of(
      //     context,
      //   ).showSnackBar(SnackBar(content: Text('Successfully refreshed.')));
      // }
    });
  }

  void sortFriend(List<FriendRecord> list) async {
    bool isasleep = await SleepStorage.loadIsSleeping();
    int streak1 = await SleepStorage.loadStreak();
    List<int> tentitem = await SleepStorage.loadShopItemStates();

    list.add(
      FriendRecord(
        username: _username,
        userId: _userId,
        isAsleep: isasleep,
        streak: streak1,
        friendTent: tentitem,
      ),
    );
    list.sort((a, b) => b.streak.compareTo(a.streak));
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
          // Refresh button
          Positioned(
            top: screenHeight * 0.08,
            right: screenHeight * 0.03,
            child: Row(
              spacing: 15,
              children: [
                // _refreshButton(),
                // Register button if username is not set, otherwise show add friend button
                _userId.isEmpty ? _registerButton() : _addFriendButton(),
              ],
            ),
          ),

          // Main content
          Positioned.fill(
            top: screenHeight * 0.16,
            left: screenHeight * 0.015,
            right: screenHeight * 0.015,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // User info container
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person, color: Colors.blue, size: 28),
                        SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _username,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (_userId.isNotEmpty)
                              Text(
                                _userId,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (_userId.isNotEmpty) ...[
                    FriendRequestList(
                      userId: _userId,
                      friendRequests: _friendRequests,
                    ),
                    FriendList(
                      friends: _friends,
                      // friends: _exampleFriends.toList()
                      //  ..sort((a, b) => b.streak.compareTo(a.streak)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _refreshButton() {
    return SizedBox(
      width: 50,
      height: 50,
      child: IconButton(
        onPressed: _loadInitialUserState,
        style: IconButton.styleFrom(
          foregroundColor: Colors.deepPurple,
          backgroundColor: Colors.grey.withAlpha(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        icon: Icon(Icons.refresh, size: 30),
      ),
    );
  }

  Widget _registerButton() {
    return SizedBox(
      width: 150,
      height: 50,
      child: IconButton(
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
          if (newUsername != null && newUsername.startsWith('login@')) {
            String actualUsername = newUsername.substring(6);
            final id = await Internet.fetchUserUID(actualUsername);
            setState(() {
              _username = actualUsername;
              _userId = id ?? '';
            });

            if (_userId.isEmpty && mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error logging in')));
            } else {
              final energy = await Internet.fetchEnergy(id ?? '');
              final List<int> items =
                  await Internet.fetchPurchasedItems(id ?? '') ?? [];
              await SleepStorage.saveUsername(_username);
              await SleepStorage.saveUserId(_userId);
              await SleepStorage.saveCurrency(energy);
              await SleepStorage.saveShopItemStates(items);
            }
          } else if (newUsername != null && newUsername.isNotEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Request sent')));

            final id = await Internet.registerUser(newUsername).timeout(
              const Duration(seconds: 60),
              onTimeout: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Network timeout: failed to reach server.'),
                  ),
                );
                return;
              },
            );

            if (!mounted) return;

            if (id == null || id.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error registering user')),
              );
            } else {
              setState(() {
                _username = newUsername;
                _userId = id;
              });

              await SleepStorage.saveUsername(newUsername);
              await SleepStorage.saveUserId(_userId);
            }
          }
        },
        style: IconButton.styleFrom(
          backgroundColor: Colors.grey.withAlpha(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        icon: Text(
          "Register",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      ),
    );
  }

  Widget _addFriendButton() {
    return SizedBox(
      width: 150,
      height: 50,
      child: IconButton(
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
                  decoration: InputDecoration(hintText: "name"),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, _tempFriendName),
                    child: Text('Submit'),
                  ),
                ],
              );
            },
          );
          if (friendUsername != null && friendUsername == 'money@') {
            int energy = await SleepStorage.loadCurrency();
            await SleepStorage.saveCurrency(energy + 500);
          } else if (friendUsername != null &&
              friendUsername == 'logout@' &&
              mounted) {
            _userId = '';
            _username = 'You are not registered.';
            await SleepStorage.saveUsername(_username);
            await SleepStorage.saveUserId(_userId);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Successfully logged out')));
          } else if (friendUsername != null && friendUsername.isNotEmpty) {
            bool? addFriendStates = await Internet.addFriend(
              _userId,
              friendUsername,
            );
            if ((addFriendStates ?? false) && mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('friend request sent')));
            } else if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('error sending friend request')),
              );
            }
          }
        },
        style: IconButton.styleFrom(
          backgroundColor: Colors.grey.withAlpha(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        icon: Text(
          "Add friend",
          style: const TextStyle(fontSize: 18, color: Colors.deepPurple),
        ),
      ),
    );
  }
}

// FriendRequestList widget to display friend requests
class FriendRequestList extends StatefulWidget {
  final String userId;
  final List<FriendRequest> friendRequests;

  const FriendRequestList({
    super.key,
    required this.userId,
    required this.friendRequests,
  });

  @override
  State<FriendRequestList> createState() => _FriendRequestListState();
}

class _FriendRequestListState extends State<FriendRequestList> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (widget.friendRequests.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                child: Text(
                  'New friend request',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ...widget.friendRequests.map((request) {
            return Container(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              padding: EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
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
                    child: Text(
                      request.username,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  // Buttons on the right
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Handle accept friend request
                          Internet.respondToFriendRequest(
                            widget.userId,
                            request.userId,
                            true,
                          );
                          setState(() {
                            widget.friendRequests.remove(request);
                          });
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
                          // Handle reject friend request
                          Internet.respondToFriendRequest(
                            widget.userId,
                            request.userId,
                            false,
                          );
                          setState(() {
                            widget.friendRequests.remove(request);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
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
          }),
        ],
      ),
    );
  }
}

// FriendList widget to display all friends
class FriendList extends StatefulWidget {
  final List<FriendRecord> friends;

  const FriendList({super.key, required this.friends});

  @override
  State<FriendList> createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
  // Navigate to tent_page
  void _enterfriendtent(FriendRecord friend) {
    Navigator.of(context).push(_createFadeRouteToTentPage(friend));
  }

  // Create a fade transition route to the tent_page
  Route _createFadeRouteToTentPage(FriendRecord friend) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) =>
          FriendTentPage(friend: friend),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  bool _isCJK(int codeUnit) {
    return (codeUnit >= 0x4E00 &&
            codeUnit <= 0x9FFF) || // CJK Unified Ideographs
        (codeUnit >= 0x3400 && codeUnit <= 0x4DBF) || // CJK Extension A
        (codeUnit >= 0xAC00 && codeUnit <= 0xD7AF) || // Hangul
        (codeUnit >= 0x3040 && codeUnit <= 0x309F) || // Hiragana
        (codeUnit >= 0x30A0 && codeUnit <= 0x30FF); // Katakana
  }

  // 估算字符宽度：CJK 算 2，其他算 1
  int _charWidth(String ch) {
    int code = ch.runes.first;
    return _isCJK(code) ? 2 : 1;
  }

  String _trunc(String input) {
    int currentWidth = 0;
    StringBuffer result = StringBuffer();

    for (var rune in input.runes) {
      String ch = String.fromCharCode(rune);
      int width = _charWidth(ch);

      if (currentWidth + width > 24) {
        result.write('...');
        break;
      }

      result.write(ch);
      currentWidth += width;
    }

    return result.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.friends.asMap().entries.map((entry) {
        final index = entry.key;
        final friend = entry.value;

        Color bgColor;
        Icon rankIcon;

        if (index == 0) {
          bgColor = Colors.amber[200]!;
          rankIcon = Icon(Icons.emoji_events, color: Colors.amber, size: 28);
        } else if (index == 1) {
          bgColor = Colors.grey[300]!;
          rankIcon = Icon(Icons.emoji_events, color: Colors.grey, size: 28);
        } else if (index == 2) {
          bgColor = Colors.brown[300]!;
          rankIcon = Icon(Icons.emoji_events, color: Colors.brown, size: 28);
        } else {
          bgColor = Colors.blue[50]!;
          rankIcon = Icon(Icons.person, color: Colors.blueGrey, size: 28);
        }

        return Container(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          padding: EdgeInsets.only(left: 12, right: 12, top: 15, bottom: 15),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),

          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _enterfriendtent(friend),
            child: Row(
              children: [
                rankIcon,
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          ' ${_trunc(friend.username)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 10),
                        friend.isAsleep
                            ? Icon(Icons.dark_mode, color: Colors.indigo)
                            : Icon(Icons.light_mode, color: Colors.orange),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.local_fire_department, color: Colors.red),
                        Text(
                          'Streak: ${friend.streak}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
