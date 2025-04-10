import 'package:flutter/material.dart';
import 'package:yashoda/presentation/screens/chatbot/chat_screen.dart';
 // <- correct

class ChatBotButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen()),
        );
      },
      child: Icon(Icons.chat_bubble_outline),
      tooltip: 'Chat with Yashoda AI',
      backgroundColor: Color(0xFFF4B860),
    );

  }
}
