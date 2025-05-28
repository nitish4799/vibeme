import 'package:flutter/material.dart';
import 'package:vibeme/screens/chat_messages.dart';
import 'package:vibeme/screens/new_message.dart';

class Chats extends StatelessWidget {
  const Chats({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(children: [ChatMessages(), NewMessage()]);
  }
}
