import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  final String userName;
  final String otherUserId;
  final String currentUserId;
  final String conversationId;

  const ChatScreen({
    super.key,
    required this.userName,
    required this.otherUserId,
    required this.currentUserId,
    required this.conversationId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
    // Start polling for new messages (in real app, use WebSockets)
    _startMessagePolling();
  }

  void _loadMessages() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3003/api/conversations/${widget.conversationId}/messages'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> messagesData = json.decode(response.body);
        setState(() {
          _messages.clear();
          _messages.addAll(messagesData.map((data) => ChatMessage(
            id: data['id'].toString(),
            text: data['message_text'],
            isSent: data['sender_id'].toString() == widget.currentUserId,
            time: _formatTime(data['sent_at']),
            senderName: data['sender_name'],
          )).toList());
        });
        
        // Scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      }
    } catch (error) {
      print('Error loading messages: $error');
    }
  }

  void _startMessagePolling() {
    // Poll for new messages every 3 seconds
    // In production, use WebSockets for real-time updates
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _loadMessages();
        _startMessagePolling();
      }
    });
  }

  String _formatTime(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp).toLocal();
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Now';
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3003/api/conversations/${widget.conversationId}/messages'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'senderId': widget.currentUserId,
          'messageText': text,
        }),
      );

      if (response.statusCode == 201) {
        _messageController.clear();
        _loadMessages(); // Reload messages to include the new one
      }
    } catch (error) {
      print('Error sending message: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2E4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F2E4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF88844D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFBEC092),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.person, color: Color(0xFF88844D)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF88844D),
                  ),
                ),
                const Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF88844D),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF88844D)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
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
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFBEC092),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.person, size: 18, color: Color(0xFF88844D)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: message.isSent ? const Color(0xFF88844D) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: message.isSent ? const Radius.circular(16) : const Radius.circular(4),
                      bottomRight: message.isSent ? const Radius.circular(4) : const Radius.circular(16),
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
                      color: message.isSent ? const Color(0xFFF7F2E4) : const Color(0xFF88844D),
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
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFBEC092),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.person, size: 18, color: Color(0xFF88844D)),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file, color: Color(0xFF88844D)),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F2E4),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFBEC092), width: 1),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Write a message...',
                        hintStyle: TextStyle(color: const Color(0xFF88844D).withOpacity(0.6)),
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.emoji_emotions_outlined, color: const Color(0xFF88844D).withOpacity(0.6)),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF88844D),
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Color(0xFFF7F2E4), size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String id;
  final String text;
  final bool isSent;
  final String time;
  final String senderName;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isSent,
    required this.time,
    required this.senderName,
  });
}