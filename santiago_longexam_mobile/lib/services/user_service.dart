import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

class UserService {
  Map<String, dynamic> data = {};
  
  // Firebase Auth instance
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  
  // Global UserService instance
  static ValueNotifier<UserService> userService = ValueNotifier(UserService());
  
  // Get current user
  User? get currentUser => firebaseAuth.currentUser;
  
  // Get auth state changes stream
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      http.Response response = await http.post(
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
      http.Response response = await http.post(
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
  
  // ========== FIREBASE AUTHENTICATION METHODS ==========
  
  /// **Firebase Sign In with Email and Password**
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
  
  /// **Firebase Create Account with Email and Password**
  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
  
  /// **Firebase Sign Out**
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }
  
  /// **Update Username/Display Name**
  Future<void> updateUsername({required String username}) async {
    await currentUser!.updateDisplayName(username);
  }
  
  /// **Delete User Account**
  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.delete();
    await firebaseAuth.signOut();
  }
  
  /// **Reset Password from Current Password**
  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.updatePassword(newPassword);
  }
  
  /// **Send Password Reset Email**
  Future<void> sendPasswordResetEmail({required String email}) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  // ========== MONGODB PROFILE MANAGEMENT METHODS ==========

  /// **MongoDB Update Username**
  Future<Map<String, dynamic>> updateUsernameMongoDb({required String username}) async {
    final userData = await getUserData();
    final token = userData['token'];

    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found');
    }

    try {
      http.Response response = await http.put(
        Uri.parse('$host/api/users/update-username'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'username': username,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update username');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: Unable to connect to server');
    }
  }

  /// **MongoDB Change Password**
  Future<Map<String, dynamic>> changePasswordMongoDb({
    required String currentPassword,
    required String newPassword,
  }) async {
    final userData = await getUserData();
    final token = userData['token'];

    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found');
    }

    try {
      http.Response response = await http.put(
        Uri.parse('$host/api/users/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: Unable to connect to server');
    }
  }

  /// **MongoDB Delete Account**
  Future<Map<String, dynamic>> deleteAccountMongoDb({
    required String password,
  }) async {
    final userData = await getUserData();
    final token = userData['token'];

    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found');
    }

    try {
      http.Response response = await http.delete(
        Uri.parse('$host/api/users/delete-account'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // Clear local data after successful deletion
        await logout();
        return responseData;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete account');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: Unable to connect to server');
    }
  }

  /// **Get Login Type** - Determines if user is logged in via Firebase or MongoDB
  Future<String> getLoginType() async {
    // Check Firebase user
    if (currentUser != null) {
      return 'Firebase';
    }

    // Check MongoDB user data
    final userData = await getUserData();
    if (userData['email']?.isNotEmpty == true && userData['token']?.isNotEmpty == true) {
      return 'MongoDB';
    }

    return 'Not logged in';
  }
}