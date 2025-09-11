import 'dart:async';
import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    getIsLogin();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> getIsLogin() async {
    final userData = await UserService().getUserData();

    if (userData['token'] != null && userData['token'] != '') {
      // User is logged in
      Timer(
        const Duration(seconds: 4),
        () => Navigator.popAndPushNamed(context, '/home'),
      );
    } else {
      // User is not logged in
      Timer(
        const Duration(seconds: 4),
        () => Navigator.popAndPushNamed(context, '/login'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppGradients.primaryGradient,
        ),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.05, // 5% padding on sides
                vertical: screenSize.height * 0.05,   // 5% padding top/bottom
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top spacer for better vertical distribution
                  const Spacer(flex: 1),
                  
                  // Animated Logo Section - Larger for web
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: EdgeInsets.all(screenSize.width * 0.05),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                          boxShadow: const [AppShadows.medium],
                        ),
                        child: Container(
                          width: screenSize.width * 0.25, // Responsive logo size
                          height: screenSize.width * 0.25,
                          constraints: const BoxConstraints(
                            minWidth: 120,
                            minHeight: 120,
                            maxWidth: 200,
                            maxHeight: 200,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                            boxShadow: [AppShadows.soft],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(screenSize.width * 0.125),
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: AppGradients.secondaryGradient,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.school_rounded,
                                size: screenSize.width * 0.12,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const Spacer(flex: 1),
                  
                  // App Title with Animation - Larger text for web
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: double.infinity,
                        child: Column(
                          children: [
                            Text(
                              'Advanced Mobile',
                              style: TextStyle(
                                fontSize: screenSize.width * 0.06,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                                letterSpacing: 2.0,
                                height: 1.2,
                              ).merge(AppTextStyles.heading1),
                              textAlign: TextAlign.center,
                            ),
                            
                            SizedBox(height: screenSize.height * 0.02),
                            
                            Text(
                              'Long Exam Application',
                              style: TextStyle(
                                fontSize: screenSize.width * 0.04,
                                color: AppColors.white.withOpacity(0.9),
                                letterSpacing: 1.0,
                                height: 1.3,
                              ).merge(AppTextStyles.bodyLarge),
                              textAlign: TextAlign.center,
                            ),
                            
                            SizedBox(height: screenSize.height * 0.02),
                            
                            // Additional subtitle for better design
                            Text(
                              'Santiago, Kit Nicholas',
                              style: TextStyle(
                                fontSize: screenSize.width * 0.025,
                                color: AppColors.white.withOpacity(0.7),
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w300,
                              ).merge(AppTextStyles.bodyMedium),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const Spacer(flex: 2),
                  
                  // Animated Loading Indicator - Enhanced for web
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: double.infinity,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(screenSize.width * 0.03),
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(UIConstants.radiusXL),
                              boxShadow: const [AppShadows.soft],
                            ),
                            child: SizedBox(
                              width: screenSize.width * 0.08,
                              height: screenSize.width * 0.08,
                              child: const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                strokeWidth: 4,
                              ),
                            ),
                          ),
                          
                          SizedBox(height: screenSize.height * 0.03),
                          
                          Text(
                            'Loading your experience...',
                            style: TextStyle(
                              fontSize: screenSize.width * 0.03,
                              color: AppColors.white.withOpacity(0.8),
                              letterSpacing: 0.5,
                            ).merge(AppTextStyles.bodyMedium),
                            textAlign: TextAlign.center,
                          ),
                          
                          SizedBox(height: screenSize.height * 0.01),
                          
                          // Progress indicator dots
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (index) => 
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.white.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const Spacer(flex: 1),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}