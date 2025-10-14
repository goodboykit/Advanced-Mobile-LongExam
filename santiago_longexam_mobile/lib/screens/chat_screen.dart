import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/chat_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';
import '../constants.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchChatController = TextEditingController();
  final ChatService _chatService = ChatService();
  String? _currentUserEmail;
  String _searchText = '';
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load current user email first, then load users
    await _loadCurrentUserEmail();
    await _loadUsers();
  }

  Future<void> _loadCurrentUserEmail() async {
    try {
      final userData = await UserService.userService.value.getUserData();
      setState(() {
        _currentUserEmail = userData['email'];
      });
    } catch (e) {
      // Try to get from Firebase as fallback
      final user = UserService.userService.value.currentUser;
      setState(() {
        _currentUserEmail = user?.email;
      });
    }
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await _chatService.getAllUsers();
      // Don't filter out current user - show all users including self

      setState(() {
        _allUsers = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isCurrentUser(Map<String, dynamic> user) {
    if (_currentUserEmail == null || _currentUserEmail!.isEmpty) {
      return false;
    }
    final userEmail = user['email']?.toString().toLowerCase() ?? '';
    final currentEmail = _currentUserEmail!.toLowerCase();
    return userEmail == currentEmail;
  }

  void _filterUsers(String searchText) {
    setState(() {
      _searchText = searchText;
      if (searchText.isEmpty) {
        _filteredUsers = _allUsers;
      } else {
        _filteredUsers = _allUsers.where((user) {
          final firstName = (user['firstName'] ?? '').toString().toLowerCase();
          final lastName = (user['lastName'] ?? '').toString().toLowerCase();
          final email = (user['email'] ?? '').toString().toLowerCase();
          final username = (user['username'] ?? '').toString().toLowerCase();
          final search = searchText.toLowerCase();

          return firstName.contains(search) ||
                 lastName.contains(search) ||
                 email.contains(search) ||
                 username.contains(search);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchChatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(bottom: 80.h), // Add padding to avoid bottom nav overlap
          child: Column(
            children: [
              SizedBox(height: 20.h),
            // Enhanced Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 0,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchChatController,
                  textInputAction: TextInputAction.search,
                  onChanged: _filterUsers,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade400
                          : Colors.grey.shade500,
                      fontSize: 14.sp,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                    suffixIcon: _searchChatController.text.isNotEmpty
                        ? IconButton(
                            tooltip: 'Clear search',
                            icon: Icon(
                              Icons.clear,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                              size: 20,
                            ),
                            onPressed: () {
                              _searchChatController.clear();
                              _filterUsers('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // User Count and Refresh
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: _searchText.isEmpty
                        ? '${_filteredUsers.length} users available'
                        : '${_filteredUsers.length} results found',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                  ),
                  IconButton(
                    onPressed: _loadUsers,
                    icon: Icon(
                      Icons.refresh,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                    tooltip: 'Refresh users',
                  ),
                ],
              ),
            ),

            // Users List
            if (_isLoading)
              Container(
                height: ScreenUtil().screenHeight * 0.5,
                padding: EdgeInsets.all(16.sp),
                child: const Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
              )
            else if (_filteredUsers.isEmpty)
              Container(
                height: ScreenUtil().screenHeight * 0.5,
                padding: EdgeInsets.all(16.sp),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchText.isEmpty ? Icons.people_outline : Icons.search_off,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 16.h),
                      CustomText(
                        text: _searchText.isEmpty
                            ? 'No users found'
                            : 'No users match your search',
                        fontSize: 16.sp,
                        color: Colors.grey.shade500,
                      ),
                      if (_searchText.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        TextButton(
                          onPressed: () {
                            _searchChatController.clear();
                            _filterUsers('');
                          },
                          child: const Text('Clear search'),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = _filteredUsers[index];
                  final isCurrentUser = _isCurrentUser(user);

                  return Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    child: Card(
                      elevation: 0,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? (isCurrentUser ? Colors.grey.shade700 : Colors.grey.shade800)
                          : (isCurrentUser ? Colors.grey.shade100 : Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isCurrentUser
                              ? AppColors.primary.withOpacity(0.3)
                              : (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade200),
                          width: isCurrentUser ? 1.5 : 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        onTap: isCurrentUser
                            ? null // Disable tap for current user
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatDetailScreen(
                                      currentUserEmail: _currentUserEmail!,
                                      tappedUser: user,
                                    ),
                                  ),
                                );
                              },
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: isCurrentUser
                                  ? AppColors.primary.withOpacity(0.3)
                                  : AppColors.primary.withOpacity(0.2),
                              child: CustomText(
                                text: user['firstName'] != null && user['firstName'].isNotEmpty
                                    ? user['firstName'].substring(0, 1).toUpperCase()
                                    : '?',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: CustomText(
                                      text: '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim(),
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  if (isCurrentUser) ...[
                                    SizedBox(width: 8.w),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 2.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                      child: Text(
                                        'You',
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        subtitle: CustomText(
                          text: user['email'] ?? 'No email',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w300,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                        trailing: isCurrentUser
                            ? null // No arrow for current user
                            : Icon(
                                Icons.chevron_right,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade400,
                                size: 20,
                              ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
