import 'package:flutter/material.dart';
import '/screens/item_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';

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
    
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: AnimatedBuilder(
            animation: _appBarAnimation,
            builder: (context, child) {
              return AppBar(
                automaticallyImplyLeading: false,
                title: FadeTransition(
                  opacity: _appBarAnimation,
                  child: Text(
                    _navigationItems[_selectedIndex]['title'],
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                actions: [
                  FadeTransition(
                    opacity: _appBarAnimation,
                    child: IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () => Navigator.pushNamed(context, '/settings'),
                    ),
                  ),
                ],
              );
            },
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
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onTappedBar,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'Items'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 11,
          unselectedFontSize: 10,
          showUnselectedLabels: true,
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