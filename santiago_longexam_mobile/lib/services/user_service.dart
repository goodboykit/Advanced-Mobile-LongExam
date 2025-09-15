import 'dart:convert';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class UserService {
  Map<String, dynamic> data = {};

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      Response response = await post(
        Uri.parse('$host/api/users/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "email": email, 
          "password": password
        }),
      );

      if (response.statusCode == 200) {
        data = jsonDecode(response.body);
        return data;
      } else {
        // Parse error message from server
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Login failed');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: Unable to connect to server');
    }
  }

  Future<Map<String, dynamic>> registerUser({
    required String firstName,
    required String lastName,
    required int age,
    required String gender,
    required String contactNumber,
    required String email,
    required String username,
    required String password,
    required String address,
  }) async {
    try {
      Response response = await post(
        Uri.parse('$host/api/users'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'age': age,
          'gender': gender,
          'contactNumber': contactNumber,
          'email': email,
          'username': username,
          'password': password,
          'address': address,
          'isActive': true,
          'type': 'user',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        data = jsonDecode(response.body);
        return data;
      } else {
        // Parse error message from server
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to register user');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: Unable to connect to server');
    }
  }

  // Save data into SharedPreferences
  /// **Save User Data to SharedPreferences**
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', userData['firstName'] ?? '');
    await prefs.setString('email', userData['email'] ?? '');
    await prefs.setString('token', userData['token'] ?? '');
    await prefs.setString('type', userData['type'] ?? '');
  }

  /// **Retrieve User Data from SharedPreferences**
  Future<Map<String, dynamic>> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'firstName': prefs.getString('firstName') ?? '',
      'email': prefs.getString('email') ?? '',
      'token': prefs.getString('token') ?? '',
      'type': prefs.getString('type') ?? '',
    };
  }

  /// **Check if User is Logged In**
  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  /// **Logout and Clear User Data**
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}