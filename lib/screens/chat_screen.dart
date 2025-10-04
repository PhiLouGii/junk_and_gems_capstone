import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:junk_and_gems/providers/theme_provider.dart';

class ChatScreen extends StatefulWidget {
  final String userName;
  final String otherUserId;
  final String currentUserId;
  final String conversationId;
  final Map<String, String>? product;

  const ChatScreen({
    super.key,
    required this.userName,
    required this.otherUserId,
    required this.currentUserId,
    required this.conversationId,
    this.product,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  Timer? _pollingTimer;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadToken();
    _loadMessages();
    _startPolling();
    _markAsRead();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
    });
  }

  void _startPolling() {
    // Poll for new messages every 3 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _loadMessages();
    });
  }

  Future<void> _loadMessages() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3003/api/conversations/${widget.conversationId}/messages'),
        headers: {
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _messages.clear();
          _messages.addAll(data.cast<Map<String, dynamic>>());
        });
        
        // Scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        print('Failed to load messages: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Load messages error: $error');
    }
  }

  Future<void> _markAsRead() async {
    try {
      await http.put(
        Uri.parse('http://10.0.2.2:3003/api/conversations/${widget.conversationId}/read'),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
        body: json.encode({'userId': widget.currentUserId}),
      );
    } catch (error) {
      print('Mark as read error: $error');
    }
  }

  Future<void> _sendMessage() async {
    final String messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    // Create a temporary message to show immediately
    final tempMessage = {
      'id': 'temp-${DateTime.now().millisecondsSinceEpoch}',
      'message_text': messageText,
      'sender_id': widget.currentUserId,
      'sender_name': 'You',
      'sent_at': DateTime.now().toIso8601String(),
      'conversation_id': widget.conversationId,
      'is_temp': true, // Mark as temporary
    };

    // Add the temporary message immediately to the UI
    setState(() {
      _messages.add(tempMessage);
    });

    // Clear the input field
    _messageController.clear();

    // Scroll to bottom to show the new message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3003/api/conversations/${widget.conversationId}/messages'),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
        body: json.encode({
          'senderId': widget.currentUserId,
          'messageText': messageText,
        }),
      );

      print('Send message response status: ${response.statusCode}');
      print('Send message response body: ${response.body}');

      if (response.statusCode == 201) {
        final newMessage = json.decode(response.body);
        
        // Replace the temporary message with the real one from the server
        setState(() {
          final tempIndex = _messages.indexWhere((msg) => msg['is_temp'] == true && msg['message_text'] == messageText);
          if (tempIndex != -1) {
            _messages.removeAt(tempIndex);
            _messages.add(newMessage);
          } else {
            _messages.add(newMessage);
          }
        });

        // Reload messages to ensure we have the latest state
        _loadMessages();
      } else {
        final errorResponse = json.decode(response.body);
        
        // Remove the temporary message if sending failed
        setState(() {
          _messages.removeWhere((msg) => msg['is_temp'] == true && msg['message_text'] == messageText);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: ${errorResponse['error']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      print('Send message error: $error');
      
      // Remove the temporary message if there was an error
      setState(() {
        _messages.removeWhere((msg) => msg['is_temp'] == true && msg['message_text'] == messageText);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending message: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildProductInfo(bool isDarkMode) {
    if (widget.product == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFE4E5C2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                widget.product!['image'] ?? 'assets/images/featured3.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                    child: Icon(
                      Icons.recycling,
                      color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product!['title'] ?? 'Product',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.product!['price'] ?? 'M400',
                  style: TextStyle(
                    color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF7F2E4),
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF7F2E4),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.userName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
              ),
            ),
            const Text(
              'Online',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProductInfo(isDarkMode),
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      'No messages yet.\nStart the conversation!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : const Color(0xFF88844D),
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMe = message['sender_id'].toString() == widget.currentUserId;
                      
                      return _buildMessageBubble(
                        message: message['message_text'] ?? '',
                        isMe: isMe,
                        time: _formatTime(message['sent_at'] ?? ''),
                        senderName: isMe ? 'You' : message['sender_name'] ?? 'User',
                        isDarkMode: isDarkMode,
                        isTemp: message['is_temp'] == true,
                      );
                    },
                  ),
          ),
          _buildMessageInput(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String message,
    required bool isMe,
    required String time,
    required String senderName,
    required bool isDarkMode,
    bool isTemp = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Icon(Icons.person, size: 16, color: isDarkMode ? Colors.white : const Color(0xFF88844D)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe) 
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 4),
                    child: Text(
                      senderName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : const Color(0xFF88844D),
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe ? Theme.of(context).colorScheme.secondary : 
                           isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message,
                        style: TextStyle(
                          color: isMe ? (isDarkMode ? Colors.white : const Color(0xFF88844D)) : 
                                 (isDarkMode ? Colors.white : Colors.black87),
                          fontSize: 16,
                        ),
                      ),
                      if (isTemp && isMe) ...[
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isDarkMode ? Colors.white70 : const Color(0xFF88844D).withOpacity(0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 16, right: 16),
                  child: Text(
                    isTemp ? 'Sending...' : time,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDarkMode ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Icon(Icons.person, size: 16, color: isDarkMode ? Colors.white : const Color(0xFF88844D)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFF7F2E4),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : const Color(0xFF88844D),
                ),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.white70 : const Color(0xFF88844D),
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send,
                color: isDarkMode ? Colors.white : const Color(0xFF88844D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp).toLocal();
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Now';
    }
  }
}