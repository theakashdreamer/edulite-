import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/user_model.dart';

class AuthRepository {
  Future<UserModel> login(String mobile, String name) async {
    final res = await http.post(
      Uri.parse("http://192.168.29.155:5000/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"mobile": mobile, "name": name}),
    );

    final data = jsonDecode(res.body);
    if (!data['success']) throw Exception("Login failed");

    return UserModel.fromJson(data['user']);
  }
}
