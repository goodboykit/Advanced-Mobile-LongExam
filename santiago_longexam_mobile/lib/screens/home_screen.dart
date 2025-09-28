import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/screens/item_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';

import '../widgets/custom_text.dart';
import '../constants.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, this.username = ''});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  late AnimationController _appBarAnimationController;
  late Animation<double> _appBarAnimation;

  @override
  void initState() {
    super.initState();
    _appBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _appBarAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _appBarAnimationController,
      curve: Curves.easeOut,
    ));
    _appBarAnimationController.forward();
  }

  @override
  void dispose() {
    _appBarAnimationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _navigationItems => [
    {
      'icon': Icons.inventory_2_outlined,
      'activeIcon': Icons.inventory_2,
      'label': 'Items',
      'title': 'Items'
    },
    {
      'icon': Icons.chat_bubble_outline,
      'activeIcon': Icons.chat_bubble,
      'label': 'Chat',
      'title': 'Chat'
    },
    {
      'icon': Icons.person_outline,
      'activeIcon': Icons.person,
      'label': 'Profile',
      'title': 'Profile'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return PopScope(
      canPop: false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppGradients.primaryGradient,
            ),
            child: AnimatedBuilder(
              animation: _appBarAnimation,
              builder: (context, child) {
                return AppBar(
                  automaticallyImplyLeading: false,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  title: FadeTransition(
                    opacity: _appBarAnimation,
                    child: Text(
                      _navigationItems[_selectedIndex]['title'],
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  actions: [
                    FadeTransition(
                      opacity: _appBarAnimation,
                      child: Container(
                        margin: const EdgeInsets.only(right: UIConstants.spacingM),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(UIConstants.radiusM),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.settings_outlined,
                            color: AppColors.white,
                            size: UIConstants.iconM,
                          ),
                          onPressed: () => Navigator.pushNamed(context, '/settings'),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(), // Disable PageView scrolling to allow ListView scrolling
          children: const [
            ItemScreen(),
            ChatScreen(),
            ProfileScreen(),
          ],
          onPageChanged: (page) {
            setState(() {
              _selectedIndex = page;
            });
          },
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.1),
                blurRadius: UIConstants.elevationM,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Container(
              height: 75, // Increased from 70 to accommodate content
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.spacingL,
                vertical: UIConstants.spacingXS, // Reduced from spacingS
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _navigationItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = index == _selectedIndex;
                  
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _onTappedBar(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: UIConstants.spacingXS, // Reduced from spacingS
                          vertical: UIConstants.spacingXS,   // Reduced from spacingS
                        ),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(UIConstants.radiusL),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  isSelected ? item['activeIcon'] : item['icon'],
                                  color: isSelected 
                                      ? AppColors.primary
                                      : theme.colorScheme.onSurface.withOpacity(0.6),
                                  size: UIConstants.iconM,
                                ),
                              ),
                            ),
                            Flexible(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 9, // Even smaller font
                                  color: isSelected 
                                      ? AppColors.primary
                                      : theme.colorScheme.onSurface.withOpacity(0.6),
                                  fontWeight: isSelected 
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                                child: Text(
                                  item['label'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onTappedBar(int value) {
    setState(() {
      _selectedIndex = value;
    });
    _pageController.jumpToPage(value);
  }
}