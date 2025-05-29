import 'dart:convert';
import 'package:drp_19/friend_request.dart';
import 'package:http/http.dart' as http;

final String _serverURL = 'http://146.169.26.221:3000';

abstract class Internet {
  // Register a new user and return their UID
  static Future<String?> fetchUid(String username) async {
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
}
