import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;
import 'friend.dart';

abstract class Internet {
  static Future<String?> fetchUid(String username) async {
    final url = Uri.parse('http://146.169.26.221:3000/user/register');

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

  static Future<bool?> addFriend(String userUID, String friendName) async {
    final urlRequestUid = Uri.parse('http://146.169.26.221:3000/user/$friendName');

    final friendUID = await http.get(
      urlRequestUid
    );
    final urlAddFriend = Uri.parse('http://146.169.26.221:3000/friend/add/${friendUID.body}');

    if (friendUID.statusCode == 200) {
      await http.post(
        urlAddFriend,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'myUid': userUID}),
      );
      return true;
    } else {
      return false;
    }
  }

  static Future<FriendRecord?> getFriendList(String username) async {
    final url = Uri.parse('http://146.169.26.221:3000/user/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': username}),
    );

    if (response.statusCode == 200) {
      final data = response.body;
      return null;
    } else {
      return null;
    }
  }
}
