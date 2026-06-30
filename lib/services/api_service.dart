import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/models/task_model.dart';
import 'secure_storage_service.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  static Future<Map<String, String>> _headers({String? token}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final uri = Uri.parse('$baseUrl/login');
    final response = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );

    return _decode(response);
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final uri = Uri.parse('$baseUrl/register');
    final response = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    return _decode(response);
  }

  static Future<Map<String, dynamic>> logout() async {
    final token = await SecureStorageService().getToken();
    final uri = Uri.parse('$baseUrl/logout');
    final response = await http.post(
      uri,
      headers: await _headers(token: token),
    );

    return _decode(response);
  }

  static Future<Map<String, dynamic>> getUser() async {
    final token = await SecureStorageService().getToken();
    final uri = Uri.parse('$baseUrl/user');
    final response = await http.get(uri, headers: await _headers(token: token));

    return _decode(response);
  }

  static Future<List<TaskModel>> getTasks({
    String? category,
    bool? deleted,
  }) async {
    final query = <String, String>{};
    if (category != null && category.isNotEmpty) {
      query['category'] = category;
    }
    if (deleted != null) {
      query['deleted'] = deleted.toString();
    }

    final uri = Uri.parse(
      '$baseUrl/tasks',
    ).replace(queryParameters: query.isEmpty ? null : query);
    final token = await SecureStorageService().getToken();
    final response = await http.get(uri, headers: await _headers(token: token));

    final body = _decode(response);
    final tasks = (body['tasks'] as List<dynamic>?) ?? [];
    return tasks
        .map((data) => TaskModel.fromMap(Map<String, dynamic>.from(data)))
        .toList();
  }

  static Future<TaskModel> createTask(String title, String category) async {
    final uri = Uri.parse('$baseUrl/tasks');
    final token = await SecureStorageService().getToken();
    final response = await http.post(
      uri,
      headers: await _headers(token: token),
      body: jsonEncode({'title': title, 'category': category}),
    );

    final body = _decode(response);
    return TaskModel.fromMap(Map<String, dynamic>.from(body['task']));
  }

  static Future<TaskModel> updateTask(TaskModel task) async {
    final uri = Uri.parse('$baseUrl/tasks/${task.id}');
    final token = await SecureStorageService().getToken();
    final response = await http.put(
      uri,
      headers: await _headers(token: token),
      body: jsonEncode({
        'title': task.title,
        'category': task.category,
        'is_done': task.isDone,
        'is_deleted': task.isDeleted,
      }),
    );

    final body = _decode(response);
    return TaskModel.fromMap(Map<String, dynamic>.from(body['task']));
  }

  static Future<void> deleteTask(String id) async {
    final uri = Uri.parse('$baseUrl/tasks/$id');
    final token = await SecureStorageService().getToken();
    final response = await http.delete(
      uri,
      headers: await _headers(token: token),
    );

    _decode(response);
  }

  static Future<void> restoreTask(String id) async {
    final uri = Uri.parse('$baseUrl/tasks/$id/restore');
    final token = await SecureStorageService().getToken();
    final response = await http.post(
      uri,
      headers: await _headers(token: token),
    );

    _decode(response);
  }

  static Future<void> forceDeleteTask(String id) async {
    final uri = Uri.parse('$baseUrl/tasks/$id/force');
    final token = await SecureStorageService().getToken();
    final response = await http.delete(
      uri,
      headers: await _headers(token: token),
    );

    _decode(response);
  }

  static Map<String, dynamic> _decode(http.Response response) {
    final body = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : <String, dynamic>{};
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body as Map<String, dynamic>;
    }

    final error = (body is Map<String, dynamic> && body['message'] != null)
        ? body['message']
        : 'Unexpected API error';

    throw Exception(error);
  }
}