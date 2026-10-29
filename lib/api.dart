// Angel Jefferson Sanchez Ventura
// Matricula:2021-1816

import 'dart:convert';

import 'package:http/http.dart' as http;

Future<dynamic> getJson(String url) async {
  final r = await http.get(Uri.parse(url));
  if (r.statusCode != 200) throw Exception('Error ${r.statusCode}');
  return jsonDecode(utf8.decode(r.bodyBytes));
}
