import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String userName;

  const ChatScreen({super.key, required this.userName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hi! I'm interested in the plastic bottles you listed.",
      isSent: false,
      time: '10:30 AM',
    ),
    ChatMessage(
      text: "Yes we still have them. When can you come pick them up?",
      isSent: true,
      time: '10:31 AM',
    ),
    ChatMessage(
      text: "I can come by this afternoon around 3 PM. What's the exact address?",
      isSent: false,
      time: '10:32 AM',
    ),
    ChatMessage(
      text: "You see where the big tree ends next to Machabeng, yes look for the black gate.",
      isSent: true,
      time: '10:33 AM',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2E4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F2E4),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: const Color(0xFF88844D),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            // User Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFBEC092),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.person,
                color: const Color(0xFF88844D),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF88844D),
                  ),
                ),
                Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF88844D).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: const Color(0xFF88844D),
            ),
            onPressed: () {
              // Handle more options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              reverse: false,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          
          // Message Input Section
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isSent) ...[
            // Receiver's avatar (only for received messages)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFBEC092),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.person,
                size: 18,
                color: const Color(0xFF88844D),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: message.isSent
                        ? const Color(0xFF88844D)
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: message.isSent
                          ? const Radius.circular(16)
                          : const Radius.circular(4),
                      bottomRight: message.isSent
                          ? const Radius.circular(4)
                          : const Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isSent
                          ? const Color(0xFFF7F2E4)
                          : const Color(0xFF88844D),
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message.time,
                  style: TextStyle(
                    fontSize: 10,
                    color: const Color(0xFF88844D).withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          if (message.isSent) ...[
            const SizedBox(width: 8),
            // Sender's avatar (only for sent messages)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFBEC092),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.person,
                size: 18,
                color: const Color(0xFF88844D),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Attachment Button
          IconButton(
            icon: Icon(
              Icons.attach_file,
              color: const Color(0xFF88844D),
            ),
            onPressed: () {
              // Handle attachment
            },
          ),
          const SizedBox(width: 8),
          
          // Message Input Field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F2E4),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFBEC092),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Write a message...',
                        hintStyle: TextStyle(
                          color: const Color(0xFF88844D).withOpacity(0.6),
                        ),
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.emoji_emotions_outlined,
                      color: const Color(0xFF88844D).withOpacity(0.6),
                    ),
                    onPressed: () {
                      // Handle emoji
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // Send Button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF88844D),
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: const Color(0xFFF7F2E4),
                size: 20,
              ),
              onPressed: () {
                _sendMessage();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _messages.add(ChatMessage(
          text: text,
          isSent: true,
          time: _getCurrentTime(),
        ));
        _messageController.clear();
      });
      
      // Auto-reply after 1 second (simulate response)
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _messages.add(ChatMessage(
            text: "Okay I will come. 👍🏽👍🏽",
            isSent: false,
            time: _getCurrentTime(),
          ));
        });
      });
      
      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          _messages.add(ChatMessage(
            text: "See you soon. 😃",
            isSent: false,
            time: _getCurrentTime(),
          ));
        });
      });
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String text;
  final bool isSent;
  final String time;

  ChatMessage({
    required this.text,
    required this.isSent,
    required this.time,
  });
}