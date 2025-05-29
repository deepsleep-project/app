import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String?> fetchUid(String username) async {
  final url = Uri.parse('http://146.169.26.221:3000/user/register');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'name': username}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print(data['uid']);
    return data['uid'];
  } else {
    print('Failed to fetch UID. Status code: ${response.statusCode}');
    return null;
  }
}
