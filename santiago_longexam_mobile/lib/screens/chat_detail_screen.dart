import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/custom_text.dart';
import '../services/chat_service.dart';
import '../services/user_service.dart';
import '../constants.dart';

final ChatService chatService = ChatService();

class ChatDetailScreen extends StatefulWidget {
  final String currentUserEmail;
  final Map<String, dynamic> tappedUser;

  const ChatDetailScreen({
    super.key,
    required this.currentUserEmail,
    required this.tappedUser,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen>
    with TickerProviderStateMixin {
  final TextEditingController _msgCtrl = TextEditingController();
  final FocusNode _msgFocus = FocusNode();
  final ScrollController _scrollCtrl = ScrollController();

  late Future<String> _currentUserIdFuture;
  bool _isSending = false;
  String _sendingStatus = '';
  Timestamp? _sendingStartedAt;
  String? _pendingMessageId;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const _postSendDelay = Duration(milliseconds: 600);

  @override
  void initState() {
    super.initState();
    _currentUserIdFuture = _getCurrentUserId();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  Future<String> _getCurrentUserId() async {
    try {
      // Try to get current user from Firebase Auth first
      final currentUser = UserService.userService.value.currentUser;
      if (currentUser != null) {
        return currentUser.uid;
      }
      
      // Fallback to user data from service
      final userData = await UserService.userService.value.getUserData();
      return userData['uid'] ?? '';
    } catch (e) {
      print('Error getting current user ID: $e');
      return '';
    }
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _msgFocus.dispose();
    _scrollCtrl.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _send(String currentUserId, String receiverId) async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
      _sendingStatus = 'Sending...';
      _sendingStartedAt = Timestamp.now();
      _pendingMessageId = DateTime.now().millisecondsSinceEpoch.toString();
    });

    try {
      _fadeController.forward();
      _slideController.forward();

      setState(() {
        _sendingStatus = 'Delivering...';
      });

      await chatService.sendMessage(receiverId, text);

      setState(() {
        _sendingStatus = 'Delivered';
      });

      _msgCtrl.clear();
      _msgFocus.requestFocus();

      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          0.0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }

      // Simulate seen status after a delay
      await Future.delayed(const Duration(milliseconds: 1000));
      setState(() {
        _sendingStatus = 'Seen';
      });

      await Future.delayed(_postSendDelay);
    } catch (e) {
      setState(() {
        _sendingStatus = 'Failed';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send: $e'),
            backgroundColor: Colors.red.shade600,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _send(currentUserId, receiverId),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
          _sendingStartedAt = null;
          _pendingMessageId = null;
        });
        _fadeController.reset();
        _slideController.reset();
      }
    }
  }

  Widget _buildModernChatBubble({
    required String message,
    required bool isMe,
    required Timestamp timestamp,
    bool isLast = false,
  }) {
    final time = DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
    final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(
        vertical: 3.h,
        horizontal: 16.w,
      ),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondary.withOpacity(0.8),
                    AppColors.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: CustomText(
                  text: widget.tappedUser['firstName']?.toString().substring(0, 1).toUpperCase() ?? '?',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
              decoration: BoxDecoration(
                gradient: isMe
                    ? LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primaryDark,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isMe ? null : Colors.grey.shade50,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                  bottomLeft: isMe ? Radius.circular(20.r) : Radius.circular(4.r),
                  bottomRight: isMe ? Radius.circular(4.r) : Radius.circular(20.r),
                ),
                border: isMe ? null : Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isMe 
                        ? AppColors.primary.withOpacity(0.2)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: isMe ? 12 : 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: message.isEmpty ? '[empty]' : message,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    color: isMe ? Colors.white : Colors.black87,
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomText(
                        text: timeString,
                        fontSize: 11.sp,
                        color: isMe ? Colors.white70 : Colors.grey.shade500,
                        fontWeight: FontWeight.w400,
                      ),
                      if (isMe && isLast) ...[
                        SizedBox(width: 6.w),
                        _buildMessageStatusIcon(),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            SizedBox(width: 8.w),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.8),
                    AppColors.primary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: CustomText(
                  text: 'You',
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageStatusIcon() {
    switch (_sendingStatus) {
      case 'Sending...':
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1000),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: value,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
              ),
            );
          },
        );
      case 'Delivering...':
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Icon(
                Icons.access_time,
                size: 14,
                color: Colors.white70,
              ),
            );
          },
        );
      case 'Delivered':
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Icon(
                Icons.done,
                size: 14,
                color: Colors.white70,
              ),
            );
          },
        );
      case 'Seen':
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Icon(
                Icons.done_all,
                size: 14,
                color: Colors.blue.shade300,
              ),
            );
          },
        );
      case 'Failed':
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Icon(
                Icons.error_outline,
                size: 14,
                color: Colors.red.shade300,
              ),
            );
          },
        );
      default:
        return Icon(
          Icons.done,
          size: 14,
          color: Colors.white70,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tappedUserId = (widget.tappedUser['uid'] ?? '').toString();
    final tappedUserName = (widget.tappedUser['firstName'] ?? '').toString();

    return FutureBuilder<String>(
      future: _currentUserIdFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snap.hasError || !snap.hasData || snap.data!.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Error loading user data')),
          );
        }

        final currentUserId = snap.data!;

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            centerTitle: false,
            title: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: widget.tappedUser['source'] == 'Firebase'
                      ? Colors.orange.shade100
                      : Colors.blue.shade100,
                  child: CustomText(
                    text: tappedUserName.isNotEmpty
                        ? tappedUserName.substring(0, 1).toUpperCase()
                        : '?',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: widget.tappedUser['source'] == 'Firebase'
                        ? Colors.orange.shade700
                        : Colors.blue.shade700,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: '${widget.tappedUser['firstName'] ?? ''} ${widget.tappedUser['lastName'] ?? ''}'.trim(),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      CustomText(
                        text: widget.tappedUser['source'] ?? 'User',
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Voice call feature coming soon!')),
                  );
                },
                icon: const Icon(Icons.call),
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Video call feature coming soon!')),
                  );
                },
                icon: const Icon(Icons.videocam),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'clear', child: Text('Clear Chat')),
                  const PopupMenuItem(value: 'block', child: Text('Block User')),
                ],
                onSelected: (value) {
                  if (value == 'clear') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Clear chat feature coming soon!')),
                    );
                  }
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Messages
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: chatService.getMessage(currentUserId, tappedUserId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            SizedBox(height: 16.h),
                            CustomText(
                              text: 'Loading messages...',
                              fontSize: 14.sp,
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red.shade300,
                            ),
                            SizedBox(height: 16.h),
                            CustomText(
                              text: 'Error loading messages',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            SizedBox(height: 8.h),
                            CustomText(
                              text: snapshot.error.toString(),
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
                      );
                    }

                    final docs = snapshot.data?.docs ?? [];

                    if (docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 16.h),
                            CustomText(
                              text: 'No messages yet',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                            SizedBox(height: 8.h),
                            CustomText(
                              text: 'Say hello to start the conversation!',
                              fontSize: 12.sp,
                              color: Colors.grey.shade500,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollCtrl,
                      reverse: true,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final msgText = doc['message'] ?? '';
                        final senderId = doc['senderId'] ?? '';
                        final timestamp = doc['timestamp'] ?? Timestamp.now();
                        final isMe = senderId == currentUserId;
                        final isLast = index == 0; // Most recent message

                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 300 + (index * 50)),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: Opacity(
                                opacity: value,
                                child: _buildModernChatBubble(
                                  message: msgText,
                                  isMe: isMe,
                                  timestamp: timestamp,
                                  isLast: isLast && isMe,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              // Modern Message Composer
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    child: Row(
                      children: [
                        // Attachment button with animation
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 300),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: 0.8 + (0.2 * value),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary.withOpacity(0.1),
                                      AppColors.primary.withOpacity(0.2),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.add_rounded,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Attachment feature coming soon!')),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 12.w),

                        // Message input field with enhanced styling
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _msgCtrl,
                              focusNode: _msgFocus,
                              enabled: !_isSending,
                              textInputAction: TextInputAction.send,
                              minLines: 1,
                              maxLines: 4,
                              onChanged: (value) {
                                setState(() {}); // Trigger rebuild for send button
                              },
                              onSubmitted: (_) {
                                if (!_isSending && _msgCtrl.text.trim().isNotEmpty) {
                                  _send(currentUserId, tappedUserId);
                                }
                              },
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: Colors.black87,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Type a message...',
                                hintStyle: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.grey.shade500,
                                  fontSize: 15.sp,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20.w,
                                  vertical: 14.h,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),

                        // Enhanced Send button with animations
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: _msgCtrl.text.trim().isNotEmpty
                                ? LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primaryDark,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: _msgCtrl.text.trim().isEmpty
                                ? Colors.grey.shade300
                                : null,
                            shape: BoxShape.circle,
                            boxShadow: _msgCtrl.text.trim().isNotEmpty
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: _isSending
                              ? Container(
                                  padding: const EdgeInsets.all(10),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : TweenAnimationBuilder<double>(
                                  duration: const Duration(milliseconds: 200),
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  builder: (context, value, child) {
                                    return Transform.scale(
                                      scale: 0.8 + (0.2 * value),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.send_rounded,
                                          color: _msgCtrl.text.trim().isNotEmpty
                                              ? Colors.white
                                              : Colors.grey.shade500,
                                          size: 22,
                                        ),
                                        onPressed: _msgCtrl.text.trim().isNotEmpty && !_isSending
                                            ? () => _send(currentUserId, tappedUserId)
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Sending status indicator
              if (_isSending)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  color: AppColors.primary.withOpacity(0.1),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      CustomText(
                        text: _sendingStatus,
                        fontSize: 12.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
