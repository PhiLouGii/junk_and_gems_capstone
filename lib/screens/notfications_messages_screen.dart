import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:junk_and_gems/screens/browse_materials_screen.dart';
import 'package:junk_and_gems/screens/chat_screen.dart';
import 'package:junk_and_gems/screens/marketplace_screen.dart';
import 'package:junk_and_gems/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:junk_and_gems/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsMessagesScreen extends StatefulWidget {
  const NotificationsMessagesScreen({super.key});

  @override
  State<NotificationsMessagesScreen> createState() =>
      _NotificationsMessagesScreenState();
}

class _NotificationsMessagesScreenState
    extends State<NotificationsMessagesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _currentUserId;
  String? _token;
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _loadCurrentUser();
    await _loadConversations();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _currentUserId = prefs.getString('userId');
        _token = prefs.getString('token');
      });
      print('✅ Current User ID: $_currentUserId');
      print('✅ Token: ${_token != null ? "Available" : "Missing"}');
      
      if (_token != null) {
        print('🔑 Token value: ${_token!.substring(0, 20)}...'); // Print first 20 chars for debugging
      }
    } catch (e) {
      print('❌ Error loading current user: $e');
    }
  }

  Future<void> _loadConversations() async {
    if (_currentUserId == null || _token == null) {
      print('❌ Cannot load conversations: No current user ID or token');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please log in to view messages';
      });
      return;
    }

    try {
      print('📡 Loading conversations for user: $_currentUserId');
      print('📡 Using token: Bearer $_token');
      
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3003/api/users/$_currentUserId/conversations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ Loaded ${data.length} conversations');
        
        setState(() {
          _conversations = data.cast<Map<String, dynamic>>();
          _isLoading = false;
          _errorMessage = null;
        });

        // Debug: Print all conversations
        for (var i = 0; i < _conversations.length; i++) {
          print('🎯 Conversation $i: ${_conversations[i]}');
        }
      } else if (response.statusCode == 401) {
        print('❌ Authentication failed - token may be invalid or expired');
        setState(() {
          _isLoading = false;
          _errorMessage = 'Authentication failed. Please log in again.';
        });
      } else {
        print('❌ Failed to load conversations: ${response.statusCode}');
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load conversations. Please try again.';
        });
      }
    } catch (error) {
      print('❌ Error loading conversations: $error');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Network error. Please check your connection.';
      });
    }
  }

  void _navigateToChat(Map<String, dynamic> conversation) {
    if (_currentUserId == null) return;

    final conversationId = conversation['conversation_id']?.toString() ?? '1';
    final otherUserId = conversation['other_user_id']?.toString() ?? '2';
    final userName = conversation['other_user_name']?.toString() ?? 'User';

    print('💬 Opening conversation: $conversationId with $userName ($otherUserId)');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          userName: userName,
          otherUserId: otherUserId,
          currentUserId: _currentUserId!,
          conversationId: conversationId,
        ),
      ),
    ).then((_) {
      // Refresh when returning from chat
      _loadConversations();
    });
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
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConversations,
            tooltip: 'Refresh Conversations',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF88844D),
          labelColor: const Color(0xFF88844D),
          unselectedLabelColor: isDarkMode ? Colors.white70 : const Color(0xFF88844D).withOpacity(0.6),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          tabs: const [
            Tab(text: 'Notifications'),
            Tab(text: 'Messages'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationsTab(isDarkMode),
          _buildMessagesTab(isDarkMode),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(context, isDarkMode),
    );
  }

  Widget _buildNotificationsTab(bool isDarkMode) {
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'New Waste materials available',
        'subtitle': 'Plastic bags have been listed near you',
        'time': '8 mins ago',
        'action': 'View',
        'icon': Icons.recycling,
        'color': Colors.green,
        'isUnread': true,
      },
      {
        'title': 'Product Sold!',
        'subtitle': 'Your upcycled rug just sold. Congrats!',
        'time': '15 mins ago',
        'action': 'Track',
        'icon': Icons.shopping_cart,
        'color': Colors.orange,
        'isUnread': true,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (notification['color'] as Color).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                notification['icon'] as IconData,
                color: notification['color'] as Color,
              ),
            ),
            title: Text(
              notification['title'] as String,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : const Color(0xFF333333),
              ),
            ),
            subtitle: Text(
              notification['subtitle'] as String,
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : const Color(0xFF666666),
              ),
            ),
            trailing: Text(
              notification['time'] as String,
              style: TextStyle(
                color: isDarkMode ? Colors.white54 : const Color(0xFF999999),
                fontSize: 12,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessagesTab(bool isDarkMode) {
  if (_errorMessage != null) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: isDarkMode ? Colors.white38 : const Color(0xFFCCCCCC),
          ),
          const SizedBox(height: 16),
          Text(
            'Authentication Required',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : const Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadConversations,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBEC092),
              foregroundColor: const Color(0xFF88844D),
            ),
            child: const Text('Retry'),
          ),
          const SizedBox(height: 10),
          Text(
            'Debug Info:',
            style: TextStyle(
              color: isDarkMode ? Colors.white54 : const Color(0xFF999999),
              fontSize: 12,
            ),
          ),
          Text(
            'User ID: $_currentUserId',
            style: TextStyle(
              color: isDarkMode ? Colors.white54 : const Color(0xFF999999),
              fontSize: 12,
            ),
          ),
          Text(
            'Token: ${_token != null ? "Available" : "Missing"}',
            style: TextStyle(
              color: isDarkMode ? Colors.white54 : const Color(0xFF999999),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  if (_isLoading) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading conversations...',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  if (_conversations.isEmpty) {
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
            'No conversations yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with someone!',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : const Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadConversations,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBEC092),
              foregroundColor: const Color(0xFF88844D),
            ),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  return RefreshIndicator(
    onRefresh: _loadConversations,
    child: ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _conversations.length,
      itemBuilder: (context, index) {
        final conversation = _conversations[index];
        
        // FIX: Convert unread_count from string to int
        final unreadCountString = conversation['unread_count']?.toString() ?? '0';
        final unreadCount = int.tryParse(unreadCountString) ?? 0;
        final isUnread = unreadCount > 0;
        
        return Card(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFBEC092),
              child: Icon(
                Icons.person,
                color: isDarkMode ? Colors.white : const Color(0xFF88844D),
              ),
            ),
            title: Text(
              conversation['other_user_name']?.toString() ?? 'Unknown User',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : const Color(0xFF333333),
              ),
            ),
            subtitle: Text(
              conversation['last_message']?.toString() ?? 'No messages yet',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : const Color(0xFF666666),
                fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatLastMessageTime(conversation['last_message_time']),
                  style: TextStyle(
                    color: isDarkMode ? Colors.white54 : const Color(0xFF999999),
                    fontSize: 12,
                  ),
                ),
                if (isUnread) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF88844D),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            onTap: () => _navigateToChat(conversation),
          ),
        );
      },
    ),
  );
}

  String _formatLastMessageTime(dynamic timestamp) {
    if (timestamp == null) return 'Just now';
    
    try {
      final dateTime = DateTime.parse(timestamp.toString()).toLocal();
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) return 'Now';
      if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
      if (difference.inHours < 24) return '${difference.inHours}h ago';
      if (difference.inDays < 7) return '${difference.inDays}d ago';
      
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'Recently';
    }
  }

  Widget _buildBottomNavBar(BuildContext context, bool isDarkMode) {
    return Container(
      height: 70,
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_filled, false, 'Home', isDarkMode, onTap: () {}),
          _buildNavItem(Icons.inventory_2_outlined, false, 'Browse', isDarkMode, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const BrowseMaterialsScreen()));
          }),
          _buildNavItem(Icons.shopping_bag_outlined, false, 'Shop', isDarkMode, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const MarketplaceScreen(userName: 'User')));
          }),
          _buildNavItem(Icons.notifications_outlined, true, 'Alerts', isDarkMode, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsMessagesScreen()));
          }),
          _buildNavItem(Icons.person_outline, false, 'Profile', isDarkMode, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen(userName: 'User', userId: '')));
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isSelected, String label, bool isDarkMode, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF88844D) : (isDarkMode ? Colors.white54 : const Color(0xFF88844D).withOpacity(0.6)),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? const Color(0xFF88844D) : (isDarkMode ? Colors.white54 : const Color(0xFF88844D).withOpacity(0.6)),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}