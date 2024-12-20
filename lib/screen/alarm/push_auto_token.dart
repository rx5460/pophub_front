import 'package:http/http.dart' as http;
import 'dart:convert';


import 'package:easy_localization/easy_localization.dart';
class PushAutoToken {
  final String apiUrl = "http://3.233.20.5:3000/token_create";

  Future<void> createToken(String userName) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userName": userName}),
    );

    if (response.statusCode == 201) {
      print("토큰이 성공적으로 생성 및 저장되었습니다: ${response.body}");
    } else {
      print("토큰 생성 오류: ${response.statusCode}");
    }
  }
}
