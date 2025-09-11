import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../widgets/custom_text.dart';
import '../providers/theme_provider.dart';
import '../services/user_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeModel = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: 'Settings',
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        children: [
          // Section title
          Padding(
            padding: EdgeInsets.only(bottom: 12.h, top: 8.h),
            child: CustomText(
              text: 'Appearance',
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          GestureDetector(
            onTap: () => themeModel.toggleTheme(),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 4.h,
                ),
                title: CustomText(
                  text: 'Dark Mode',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
                trailing: IconButton(
                  onPressed: () => themeModel.toggleTheme(),
                  icon: themeModel.isDark
                      ? Icon(Icons.dark_mode, size: 24.sp)
                      : Icon(Icons.light_mode, size: 24.sp),
                ),
              ),
            ),
          ),

          SizedBox(height: 20.h),

          // Logout Section
          Padding(
            padding: EdgeInsets.only(bottom: 12.h, top: 8.h),
            child: CustomText(
              text: 'Account',
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          GestureDetector(
            onTap: () async {
              await UserService().logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 4.h,
                ),
                title: CustomText(
                  text: 'Logout',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
                trailing: Icon(Icons.logout, size: 24.sp),
              ),
            ),
          ),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}