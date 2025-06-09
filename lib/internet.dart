import 'dart:convert';
import 'package:deepsleep/friend_request.dart';
import 'package:http/http.dart' as http;
import 'friend.dart';

// final String _serverURL = 'https://deepsleep.onrender.com';
final String _serverURL = 'http://146.169.26.221:3000';

abstract class Internet {
  // Register a new user and return their UID
  static Future<String?> registerUser(String username) async {
    final url = Uri.parse('$_serverURL/user/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': username}),
    );

    if (response.statusCode == 200) {
      final data = response.body;
      return data;
    } else {
      return null;
    }
  }

  static Future<String?> fetchUserUID(String username) async {
    final url = Uri.parse('$_serverURL/user/$username');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }

  // Send a friend request to another user
  static Future<bool?> addFriend(String userUID, String friendName) async {
    final urlRequestUid = Uri.parse('$_serverURL/user/$friendName');

    final friendUID = await http.get(urlRequestUid);
    final urlAddFriend = Uri.parse('$_serverURL/friend/add/${friendUID.body}');

    if (friendUID.statusCode == 200) {
      await http.post(
        urlAddFriend,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'uid': userUID}),
      );
      return true;
    } else {
      return false;
    }
  }

  static Future<String?> fetchFriendName(String userUID) async {
    final url = Uri.parse('$_serverURL/user/name/$userUID');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }

  // Fetch friend requests for the user
  static Future<List<FriendRequest>?> fetchFriendRequest(String userUID) async {
    final url = Uri.parse('$_serverURL/friend/request/$userUID');

    List<String> requests = [];
    List<FriendRequest> friendRequests = [];

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      requests = jsonList.cast<String>();
    } else {
      return null;
    }

    for (var reqID in requests) {
      String? friendName = await fetchFriendName(reqID);
      if (friendName == null) continue;
      friendRequests.add(FriendRequest(username: friendName, userId: reqID));
    }
    return friendRequests;
  }

  static Future<List<FriendRecord>?> getFriendList(String uid) async {
    final url = Uri.parse('$_serverURL/friend/$uid');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final ids = jsonDecode(response.body);

      List<FriendRecord> result = [];

      for (int i = 0; i < ids.length; i++) {
        String name = await fetchFriendName(ids[i]) ?? '';
        bool isAsleep = await getAsleep(ids[i]);
        int strike1 = await strikefetch(ids[i]);
        result.add(
          FriendRecord(
            username: name,
            userId: ids[i],
            isAsleep: isAsleep,
            streak: strike1,
          ),
        );
      }
      return result;
    } else {
      return null;
    }
  }

  static Future<void> respondToFriendRequest(
    String userUID,
    String friendUID,
    bool accept,
  ) async {
    final url = Uri.parse('$_serverURL/friend/respond/$userUID');

    await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'uid': friendUID, 'accept': accept}),
    );
  }

  static Future<bool> getAsleep(String friendUID) async {
    final url = Uri.parse('$_serverURL/awake/$friendUID');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return !(jsonDecode(response.body)["awake"] as bool);
    } else {
      return false;
    }
  }

  static Future<int> strikefetch(String friendUID) async {
    final url = Uri.parse('$_serverURL/streak/get/$friendUID');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as int;
    } else {
      return 0;
    }
  }

  static Future<void> setstrike(String friendUID, int strike) async {
    final url = Uri.parse('$_serverURL/streak/set');
    await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'uid': friendUID, 'streak': strike}),
    );
  }

  static Future<void> setAsleep(String userUID) async {
    final url = Uri.parse('$_serverURL/sleep');
    await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'uid': userUID}),
    );
  }

  static Future<void> setAwake(String userUID) async {
    final url = Uri.parse('$_serverURL/wake');
    await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'uid': userUID}),
    );
  }
}
