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
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    print('🚀 ChatScreen initialized');
    print('💬 Conversation ID: ${widget.conversationId}');
    print('👤 Current User: ${widget.currentUserId}');
    print('👥 Other User: ${widget.otherUserId}');
    _initializeChat();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    await _loadToken();
    await _loadMessages();
    _startPolling();
    _markAsRead();
  }

  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _token = prefs.getString('token');
      });
      print('🔑 Token loaded: ${_token != null}');
      if (_token != null) {
        print('🔑 Token (first 20 chars): ${_token!.substring(0, 20)}...');
      }
    } catch (e) {
      print('❌ Error loading token: $e');
    }
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _loadMessages();
    });
  }

 Future<void> _loadMessages() async {
  if (_token == null) {
    print('❌ Token not available');
    setState(() {
      _error = 'Authentication token not available. Please log in again.';
      _isLoading = false;
    });
    return;
  }

  try {
    print('📨 Loading messages for conversation: ${widget.conversationId}');
    print('🔑 Using token: ${_token!.substring(0, 20)}...');
    
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3003/api/conversations/${widget.conversationId}/messages'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
    );

    print('📨 Response status: ${response.statusCode}');
    print('📨 Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print('✅ SUCCESS: Loaded ${data.length} messages from server');
      
      if (data.isEmpty) {
        print('ℹ️ Server returned empty messages array');
      } else {
        // Print first 3 messages for debugging
        for (var i = 0; i < data.length && i < 3; i++) {
          final msg = data[i];
          print('💬 Message $i: ID=${msg['id']}, Sender=${msg['sender_id']}, Text="${msg['message_text']}"');
        }
      }

      setState(() {
        _messages.clear();
        _messages.addAll(data.cast<Map<String, dynamic>>());
        _isLoading = false;
        _error = null;
      });

      _scrollToBottom();
    } else if (response.statusCode == 403) {
      print('❌ ACCESS DENIED: User cannot access this conversation');
      setState(() {
        _isLoading = false;
        _error = 'You do not have access to this conversation';
      });
    } else if (response.statusCode == 404) {
      print('❌ NOT FOUND: Conversation does not exist');
      setState(() {
        _isLoading = false;
        _error = 'Conversation not found. It may have been deleted.';
      });
    } else if (response.statusCode == 401) {
      print('❌ UNAUTHORIZED: Token may be invalid or expired');
      setState(() {
        _isLoading = false;
        _error = 'Session expired. Please log in again.';
      });
    } else if (response.statusCode == 500) {
      print('❌ SERVER ERROR: ${response.body}');
      // Try to parse error message from server
      try {
        final errorData = json.decode(response.body);
        setState(() {
          _isLoading = false;
          _error = 'Server error: ${errorData['error'] ?? 'Unknown error'}';
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          _error = 'Server error. Please try again later.';
        });
      }
    } else {
      print('❌ HTTP ERROR: ${response.statusCode}');
      print('❌ Response body: ${response.body}');
      setState(() {
        _isLoading = false;
        _error = 'Failed to load messages (Error ${response.statusCode})';
      });
    }
  } catch (error) {
    print('❌ NETWORK ERROR: $error');
    setState(() {
      _isLoading = false;
      _error = 'Network error. Please check your connection.';
    });
  }
}

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _messages.isNotEmpty) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _markAsRead() async {
    if (_token == null) return;
    
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:3003/api/conversations/${widget.conversationId}/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({'userId': widget.currentUserId}),
      );
      
      if (response.statusCode == 200) {
        print('✅ Messages marked as read');
      } else {
        print('❌ Failed to mark as read: ${response.statusCode}');
      }
    } catch (error) {
      print('❌ Mark as read error: $error');
    }
  }

  Future<void> _sendMessage() async {
  final String messageText = _messageController.text.trim();
  if (messageText.isEmpty || _token == null) return;

  // Create temporary message
  final tempMessage = {
    'id': 'temp-${DateTime.now().millisecondsSinceEpoch}',
    'message_text': messageText,
    'sender_id': widget.currentUserId,
    'sender_name': 'You',
    'sent_at': DateTime.now().toIso8601String(),
    'is_temp': true,
  };

  // Add to UI immediately
  setState(() {
    _messages.add(tempMessage);
  });
  _messageController.clear();
  _scrollToBottom();

  try {
    print('🚀 Sending message: "$messageText"');
    print('📨 To conversation: ${widget.conversationId}');
    print('👤 From user: ${widget.currentUserId}');
    
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3003/api/conversations/${widget.conversationId}/messages'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: json.encode({
        'senderId': widget.currentUserId,
        'messageText': messageText,
      }),
    );

    print('🚀 Send response: ${response.statusCode}');
    print('🚀 Response body: ${response.body}');
    
    if (response.statusCode == 201) {
      final newMessage = json.decode(response.body);
      print('✅ Message sent successfully: ${newMessage['id']}');
      
      // Replace temporary message with real one
      setState(() {
        _messages.removeWhere((msg) => 
          msg['is_temp'] == true && 
          msg['message_text'] == messageText
        );
        _messages.add(newMessage);
      });
      
      _scrollToBottom();
    } else {
      // Handle error response
      String errorMessage = 'Failed to send message';
      try {
        final errorBody = json.decode(response.body);
        errorMessage = errorBody['error'] ?? errorMessage;
      } catch (e) {
        // Use default error message
      }
      
      throw Exception(errorMessage);
    }
  } catch (error) {
    print('❌ Send message error: $error');
    
    // Remove temporary message
    setState(() {
      _messages.removeWhere((msg) => 
        msg['is_temp'] == true && 
        msg['message_text'] == messageText
      );
    });
    
    // Show error to user
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: $error'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () {
              _messageController.text = messageText;
            },
          ),
        ),
      );
    }
  }
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
            icon: Icon(Icons.refresh, color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D)),
            onPressed: _loadMessages,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.red,
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _error = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? _buildLoadingState(isDarkMode)
                : _messages.isEmpty
                    ? _buildEmptyState(isDarkMode)
                    : _buildMessagesList(isDarkMode),
          ),
          _buildMessageInput(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading messages...',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : const Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Conversation ID: ${widget.conversationId}',
            style: TextStyle(
              color: isDarkMode ? Colors.white54 : const Color(0xFF999999),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: isDarkMode ? Colors.white38 : const Color(0xFFCCCCCC),
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start the conversation!',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : const Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadMessages,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBEC092),
              foregroundColor: const Color(0xFF88844D),
            ),
            child: const Text('Refresh Messages'),
          ),
          const SizedBox(height: 16),
          Text(
            'Debug Info:',
            style: TextStyle(
              color: isDarkMode ? Colors.white54 : const Color(0xFF999999),
              fontSize: 12,
            ),
          ),
          Text(
            'Conversation: ${widget.conversationId}',
            style: TextStyle(
              color: isDarkMode ? Colors.white54 : const Color(0xFF999999),
              fontSize: 12,
            ),
          ),
          Text(
            'Current User: ${widget.currentUserId}',
            style: TextStyle(
              color: isDarkMode ? Colors.white54 : const Color(0xFF999999),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(bool isDarkMode) {
    return ListView.builder(
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
          senderName: isMe ? 'You' : (message['sender_name'] ?? widget.userName),
          isDarkMode: isDarkMode,
          isTemp: message['is_temp'] == true,
        );
      },
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
              backgroundColor: const Color(0xFFBEC092),
              child: Icon(
                Icons.person, 
                size: 16, 
                color: isDarkMode ? Colors.white : const Color(0xFF88844D)
              ),
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
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe 
                        ? const Color(0xFFBEC092) 
                        : (isDarkMode ? const Color(0xFF2D2D2D) : Colors.white),
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
                      Flexible(
                        child: Text(
                          message,
                          style: TextStyle(
                            color: isMe 
                                ? const Color(0xFF88844D) 
                                : (isDarkMode ? Colors.white : Colors.black87),
                            fontSize: 16,
                          ),
                          softWrap: true,
                        ),
                      ),
                      if (isTemp && isMe) ...[
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: const Color(0xFF88844D).withOpacity(0.6),
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
              backgroundColor: const Color(0xFFBEC092),
              child: Icon(
                Icons.person, 
                size: 16, 
                color: isDarkMode ? Colors.white : const Color(0xFF88844D)
              ),
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
              decoration: const BoxDecoration(
                color: Color(0xFFBEC092),
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