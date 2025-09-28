import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/chat_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';
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
    _loadCurrentUserEmail();
    _loadUsers();
  }

  Future<void> _loadCurrentUserEmail() async {
    final userData = await UserService.userService.value.getUserData();
    setState(() {
      _currentUserEmail = userData['email'];
    });
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await _chatService.getAllUsers();
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
        child: Column(
          children: [
            SizedBox(height: 20.h),
            // Enhanced Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchChatController,
                  textInputAction: TextInputAction.search,
                  onChanged: _filterUsers,
                  decoration: InputDecoration(
                    hintText: 'Search users by name or email...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14.sp,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey.shade600,
                      size: 22,
                    ),
                    suffixIcon: _searchChatController.text.isNotEmpty
                        ? IconButton(
                            tooltip: 'Clear search',
                            icon: Icon(
                              Icons.clear,
                              color: Colors.grey.shade600,
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
                      horizontal: 20.w,
                      vertical: 15.h,
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
                    color: Colors.grey.shade600,
                  ),
                  IconButton(
                    onPressed: _loadUsers,
                    icon: Icon(
                      Icons.refresh,
                      color: Colors.grey.shade600,
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
                  final userSource = user['source'] ?? 'Unknown';

                  return Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        onTap: () {
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
                              backgroundColor: userSource == 'Firebase'
                                  ? Colors.orange.shade100
                                  : Colors.blue.shade100,
                              child: CustomText(
                                text: user['firstName'] != null && user['firstName'].isNotEmpty
                                    ? user['firstName'].substring(0, 1).toUpperCase()
                                    : '?',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: userSource == 'Firebase'
                                    ? Colors.orange.shade700
                                    : Colors.blue.shade700,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: userSource == 'Firebase'
                                      ? Colors.orange
                                      : Colors.blue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: CustomText(
                                text: '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim(),
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: userSource == 'Firebase'
                                    ? Colors.orange.withOpacity(0.1)
                                    : Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: CustomText(
                                text: userSource,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                                color: userSource == 'Firebase'
                                    ? Colors.orange.shade700
                                    : Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        subtitle: CustomText(
                          text: user['email'] ?? 'No email',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w300,
                          color: Colors.grey.shade600,
                        ),
                        trailing: Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.grey.shade400,
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
    );
  }
}
