import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import '../constants.dart';

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

  String _getInitials() {
    if (loginType == 'Firebase' && firebaseUser != null) {
      final name = firebaseUser!.displayName ?? firebaseUser!.email ?? '';
      return name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
    } else if (loginType == 'MongoDB' && userData.isNotEmpty) {
      final firstName = userData['firstName'] ?? '';
      return firstName.isNotEmpty ? firstName.substring(0, 1).toUpperCase() : '?';
    }
    return '?';
  }

  String _getDisplayName() {
    if (loginType == 'Firebase' && firebaseUser != null) {
      return firebaseUser!.displayName ?? 'User';
    } else if (loginType == 'MongoDB' && userData.isNotEmpty) {
      final firstName = userData['firstName'] ?? '';
      final lastName = userData['lastName'] ?? '';
      return '$firstName $lastName'.trim().isNotEmpty
          ? '$firstName $lastName'.trim()
          : 'User';
    }
    return 'User';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // Custom App Bar with Profile Header
                SliverAppBar(
                  expandedHeight: 180.h,
                  pinned: true,
                  backgroundColor: isDark ? Colors.grey.shade900 : AppColors.primary,
                  title: Text(
                    'Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  centerTitle: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isDark
                              ? [Colors.grey.shade900, Colors.grey.shade800]
                              : [AppColors.primary, AppColors.primaryDark],
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 16,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Profile Avatar
                                CircleAvatar(
                                  radius: 32,
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  child: Text(
                                    _getInitials(),
                                    style: TextStyle(
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Display Name
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                                  child: Text(
                                    _getDisplayName(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Profile Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Account Information Section
                        Text(
                          'Account Information',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // User Info Cards based on login type
                        if (loginType == 'Firebase' && firebaseUser != null) ...[
                          _buildInfoCard(
                            context,
                            'Email',
                            firebaseUser!.email ?? 'N/A',
                            Icons.email_outlined,
                          ),
                          _buildInfoCard(
                            context,
                            'Display Name',
                            firebaseUser!.displayName ?? 'N/A',
                            Icons.person_outline,
                          ),
                          _buildInfoCard(
                            context,
                            'User ID',
                            firebaseUser!.uid,
                            Icons.fingerprint,
                          ),
                          _buildInfoCard(
                            context,
                            'Email Verified',
                            firebaseUser!.emailVerified ? 'Yes' : 'No',
                            Icons.verified_outlined,
                          ),
                          _buildInfoCard(
                            context,
                            'Created',
                            _formatDate(firebaseUser!.metadata.creationTime),
                            Icons.calendar_today_outlined,
                          ),
                        ] else if (loginType == 'MongoDB') ...[
                          _buildInfoCard(
                            context,
                            'Email',
                            userData['email'] ?? 'N/A',
                            Icons.email_outlined,
                          ),
                          _buildInfoCard(
                            context,
                            'Display Name',
                            userData['username'] ?? 'N/A',
                            Icons.person_outline,
                          ),
                          _buildInfoCard(
                            context,
                            'User ID',
                            userData['_id'] ?? 'N/A',
                            Icons.fingerprint,
                          ),
                          _buildInfoCard(
                            context,
                            'Email Verified',
                            'No',
                            Icons.verified_outlined,
                          ),
                          _buildInfoCard(
                            context,
                            'Created',
                            _formatDate(DateTime.tryParse(userData['createdAt'] ?? '')),
                            Icons.calendar_today_outlined,
                          ),
                        ] else ...[
                          _buildInfoCard(
                            context,
                            'Status',
                            'Not logged in',
                            Icons.info_outline,
                          ),
                        ],

                        SizedBox(height: 24.h),

                        // Account Actions Section
                        if (loginType == 'Firebase' || loginType == 'MongoDB') ...[
                          Text(
                            'Account Actions',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          SizedBox(height: 12.h),

                          _buildActionButton(
                            context,
                            'Update Username',
                            Icons.person_outline,
                            Colors.blue,
                            () => _showUpdateUsernameDialog(),
                          ),
                          SizedBox(height: 12.h),

                          _buildActionButton(
                            context,
                            'Change Password',
                            Icons.lock_outline,
                            Colors.orange,
                            () => _showChangePasswordDialog(),
                          ),
                          SizedBox(height: 12.h),

                          _buildActionButton(
                            context,
                            'Delete Account',
                            Icons.delete_forever_outlined,
                            Colors.red,
                            () => _showDeleteAccountDialog(),
                          ),
                          SizedBox(height: 24.h),

                          // Edit Profile Button
                          SizedBox(
                            width: double.infinity,
                            height: 50.h,
                            child: ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Edit profile feature coming soon!'),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                elevation: 2,
                              ),
                              child: Text(
                                'Edit Profile',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],

                        SizedBox(height: 80.h), // Extra padding for bottom nav
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  Widget _buildInfoCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
              size: 24.sp,
            ),
          ],
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
