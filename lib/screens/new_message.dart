import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});
  @override
  State<NewMessage> createState() {
    return _NewMessage();
  }
}

class _NewMessage extends State<NewMessage> {
  final _messageController = TextEditingController();

  void submitMessage() async {
    final message = _messageController.text;
    _messageController.clear();
    print(message);
    final user = FirebaseAuth.instance.currentUser;
    final uid = user!.uid;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();
    final userName = data!['username'];
final profileImageUrl = data['profileImageUrl'];

FirebaseFirestore.instance.collection('chats').add({
  'message': message,
  'username': userName,
  'userId': user.uid,
  'sentAt': Timestamp.now(),
  if (profileImageUrl != null && profileImageUrl.toString().trim().isNotEmpty)
    'imageUrl': profileImageUrl
});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(hintText: 'Enter message...'),
            ),
          ),
          IconButton(onPressed: submitMessage, icon: Icon(Icons.send)),
        ],
      ),
    );
  }
}
