import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupName;
  final String userName;

  GroupChatScreen({required this.groupName,required this.userName});

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  void sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('chat_rooms')
            .doc(widget.groupName)
            .collection('messages')
            .add({
          'message': message,
          'sender': widget.userName,
          'timestamp': FieldValue.serverTimestamp(),
        });
        _messageController.clear();
      } catch (e) {
        print("❌ Failed to send message: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color mainColor = Color(0xFFF4B942);
    final Color textFieldColor = Color(0xFFFFF3CD); // lighter version

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.groupName} Support Group"),
        backgroundColor: mainColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chat_rooms')
                  .doc(widget.groupName)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs;

                if (docs == null || docs.isEmpty) {
                  return Center(child: Text("No messages yet. Start the conversation!"));
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final messageData = docs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(messageData['message'] ?? ''),
                      subtitle: Text(messageData['sender'] ?? 'Unknown'),
                    );
                  },
                );
              },
            ),
          ),
          Divider(height: 1),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: textFieldColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type your message...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                  ),
                  onPressed: sendMessage,
                  child: Text("Send"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
