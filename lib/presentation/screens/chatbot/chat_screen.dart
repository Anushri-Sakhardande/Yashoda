import 'package:flutter/material.dart';
import 'package:yashoda/core/services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];

  void _sendMessage() async {
    String userMessage = _controller.text;
    setState(() {
      messages.add({"role": "user", "message": userMessage});
      _controller.clear();
    });

    String response = await ChatService.sendMessage(userMessage);

    setState(() {
      messages.add({"role": "assistant", "message": response});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F2EA),
      appBar: AppBar(
        backgroundColor: Color(0xFFF4B860),
        title: Text("Yashoda AI"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return Align(
                  alignment: msg["role"] == "user"
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg["role"] == "user"
                          ? Color(0xFFFFE3B3)
                          : Color(0xFFFFD18C),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(msg["message"] ?? ""),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            color: Color(0xFFFFF3DC),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration:
                    InputDecoration(hintText: "Type your message..."),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Color(0xFFF4B860)),
                  onPressed: _sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
