import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:santiago_longexam_mobile/models/message_model.dart';
import 'user_service.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // get all users (Firebase only - original method)
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection('Users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // Get all Firebase users only
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final userService = UserService();
    final userData = await userService.getUserData();
    final currentUserEmail = userData['email'] ?? '';

    List<Map<String, dynamic>> allUsers = [];

    try {
      // Get Firebase users only
      final firebaseSnapshot = await _firestore.collection('Users').get();
      final firebaseUsers = firebaseSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'source': 'Firebase',
          'uid': doc.id,
        };
      }).toList();

      allUsers.addAll(firebaseUsers);

      // Remove current logged-in user based on email
      allUsers.removeWhere((user) =>
        user['email']?.toString().toLowerCase() == currentUserEmail.toLowerCase());

      // Sort by firstName
      allUsers.sort((a, b) {
        final nameA = (a['firstName'] ?? '').toString();
        final nameB = (b['firstName'] ?? '').toString();
        return nameA.compareTo(nameB);
      });

    } catch (e) {
      print('Error fetching Firebase users: $e');
    }

    return allUsers;
  }


  // send message
  Future<void> sendMessage(String receiverId, message) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    MessageModel newMessage = MessageModel(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
    );

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomID = ids.join("_");

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .add(newMessage.toMap());
  }

  // get message
  Stream<QuerySnapshot> getMessage(String userID, otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join("_");

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}

// get uid by email
Future<String?> getUidByEmail(String email) async {
  QuerySnapshot q = await FirebaseFirestore.instance
      .collection('Users')
      .where('email', isEqualTo: email)
      .limit(1)
      .get();

  if (q.docs.isEmpty) {
    return null;
  }

  return q.docs.first.get('uid') as String?;
  // Ensure your Users doc actually stores the Firebase Auth UID in a field `uid`
}
