import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> userData = {};
  User? firebaseUser;
  bool isLoading = true;
  String loginType = 'Unknown';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userService = UserService();

      // Get login type using the service method
      final loginTypeResult = await userService.getLoginType();

      // Check MongoDB user data
      final mongoData = await userService.getUserData();

      // Check Firebase user
      final firebaseUser = userService.currentUser;

      setState(() {
        userData = mongoData;
        this.firebaseUser = firebaseUser;
        loginType = loginTypeResult;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: 'Profile',
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  // Profile Avatar
                  CircleAvatar(
                    radius: 60.r,
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(
                      Icons.person,
                      size: 60.r,
                      color: Colors.blue.shade600,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Login Type Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: loginType == 'Firebase' ? Colors.orange : Colors.blue,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'Logged in via: $loginType',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20.h),

                  // User Info Cards based on login type
                  if (loginType == 'Firebase' && firebaseUser != null) ...[
                    _buildInfoCard('Email', firebaseUser!.email ?? 'N/A'),
                    _buildInfoCard('Display Name', firebaseUser!.displayName ?? 'N/A'),
                    _buildInfoCard('User ID', firebaseUser!.uid),
                    _buildInfoCard('Email Verified', firebaseUser!.emailVerified ? 'Yes' : 'No'),
                    _buildInfoCard('Created', firebaseUser!.metadata.creationTime?.toString() ?? 'N/A'),
                  ] else if (loginType == 'MongoDB') ...[
                    _buildInfoCard('First Name', userData['firstName'] ?? 'N/A'),
                    _buildInfoCard('Email', userData['email'] ?? 'N/A'),
                    _buildInfoCard('Type', userData['type'] ?? 'N/A'),
                  ] else ...[
                    _buildInfoCard('Status', 'Not logged in'),
                  ],
                  
                  SizedBox(height: 20.h),
                  
                  // Management Buttons (for both Firebase and MongoDB users)
                  if (loginType == 'Firebase' || loginType == 'MongoDB') ...[
                    _buildActionButton(
                      'Update Username',
                      Icons.person,
                      () => _showUpdateUsernameDialog(),
                    ),
                    SizedBox(height: 12.h),
                    _buildActionButton(
                      'Change Password',
                      Icons.lock,
                      () => _showChangePasswordDialog(),
                    ),
                    SizedBox(height: 12.h),
                    _buildActionButton(
                      'Delete Account',
                      Icons.delete_forever,
                      () => _showDeleteAccountDialog(),
                      isDestructive: true,
                    ),
                    SizedBox(height: 20.h),
                  ],
                  
                  // Edit Profile Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Edit profile feature coming soon!'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profile'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: CustomText(
                text: label,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            Expanded(
              flex: 3,
              child: CustomText(
                text: value,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: isDestructive ? Colors.white : null),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDestructive ? Colors.red : null,
          foregroundColor: isDestructive ? Colors.white : null,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  void _showUpdateUsernameDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Username'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New Username',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                try {
                  final userService = UserService();

                  if (loginType == 'Firebase') {
                    await userService.updateUsername(username: controller.text);
                  } else if (loginType == 'MongoDB') {
                    await userService.updateUsernameMongoDb(username: controller.text);
                  }

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Username updated successfully')),
                    );
                    _loadUserData(); // Refresh data
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (currentPasswordController.text.isNotEmpty &&
                  newPasswordController.text.isNotEmpty) {
                try {
                  final userService = UserService();

                  if (loginType == 'Firebase') {
                    await userService.resetPasswordFromCurrentPassword(
                      currentPassword: currentPasswordController.text,
                      newPassword: newPasswordController.text,
                      email: firebaseUser?.email ?? '',
                    );
                  } else if (loginType == 'MongoDB') {
                    await userService.changePasswordMongoDb(
                      currentPassword: currentPasswordController.text,
                      newPassword: newPasswordController.text,
                    );
                  }

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password changed successfully')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This action cannot be undone. Please enter your password to confirm.'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (passwordController.text.isNotEmpty) {
                try {
                  final userService = UserService();

                  if (loginType == 'Firebase') {
                    await userService.deleteAccount(
                      email: firebaseUser?.email ?? '',
                      password: passwordController.text,
                    );
                  } else if (loginType == 'MongoDB') {
                    await userService.deleteAccountMongoDb(
                      password: passwordController.text,
                    );
                  }

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Account deleted successfully')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}