import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:junk_and_gems/screens/browse_materials_screen.dart';
import 'package:junk_and_gems/screens/chat_screen.dart';
import 'package:junk_and_gems/screens/marketplace_screen.dart';
import 'package:junk_and_gems/screens/profile_screen.dart';
import 'package:junk_and_gems/screens/other_user_profile_screen.dart';
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
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoadingMessages = true;
  bool _isLoadingNotifications = true;
  String? _errorMessage;
  int _unreadNotificationCount = 0;

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
    await Future.wait([
      _loadConversations(),
      _loadNotifications(),
    ]);
  }

  Future<void> _loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _currentUserId = prefs.getString('userId');
        _token = prefs.getString('token');
      });
      print('✅ Current User ID: $_currentUserId');
    } catch (e) {
      print('❌ Error loading current user: $e');
    }
  }

  Future<void> _loadNotifications() async {
    if (_currentUserId == null) {
      setState(() {
        _isLoadingNotifications = false;
      });
      return;
    }

    setState(() {
      _isLoadingNotifications = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://junk-and-gems-api.onrender.com/api/users/$_currentUserId/notifications?limit=50'),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> rawNotifications = data['notifications'] ?? [];
        
        setState(() {
          _notifications = rawNotifications.map((notif) {
            return _parseNotification(notif);
          }).toList();
          _unreadNotificationCount = data['unreadCount'] ?? 0;
          _isLoadingNotifications = false;
        });
      } else {
        print('❌ Error loading notifications: ${response.statusCode}');
        setState(() {
          _isLoadingNotifications = false;
        });
      }
    } catch (e) {
      print('❌ Exception loading notifications: $e');
      setState(() {
        _isLoadingNotifications = false;
      });
    }
  }

  Map<String, dynamic> _parseNotification(Map<String, dynamic> notif) {
    final type = notif['type'] ?? 'general';
    
    return {
      'id': notif['id'],
      'type': type,
      'title': notif['title'] ?? 'Notification',
      'subtitle': notif['message'] ?? '',
      'time': notif['time'] ?? 'Recently',
      'isUnread': !(notif['isRead'] ?? false),
      'relatedUserId': notif['relatedUserId'],
      'relatedUserName': notif['relatedUserName'],
      'relatedUserImage': notif['relatedUserImage'],
      'action': _getActionForType(type),
      'icon': _getIconForType(type),
      'color': _getColorForType(type),
    };
  }

  String _getActionForType(String type) {
    switch (type) {
      case 'new_user':
        return 'Say Hi';
      case 'material_claimed':
        return 'View';
      case 'product_sold':
        return 'Details';
      case 'message':
        return 'Reply';
      default:
        return 'View';
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'new_user':
        return Icons.person_add;
      case 'material_claimed':
        return Icons.inventory;
      case 'product_sold':
        return Icons.shopping_bag;
      case 'message':
        return Icons.message;
      case 'achievement':
        return Icons.stars;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'new_user':
        return Colors.green;
      case 'material_claimed':
        return Colors.orange;
      case 'product_sold':
        return Colors.blue;
      case 'message':
        return Colors.purple;
      case 'achievement':
        return Colors.amber;
      default:
        return const Color(0xFF88844D);
    }
  }

  Future<void> _markNotificationAsRead(int notificationId) async {
    if (_currentUserId == null) return;

    try {
      final response = await http.put(
        Uri.parse('https://junk-and-gems-api.onrender.com/api/users/$_currentUserId/notifications/read'),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
        body: json.encode({
          'notificationIds': [notificationId],
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          final index = _notifications.indexWhere((n) => n['id'] == notificationId);
          if (index != -1) {
            _notifications[index]['isUnread'] = false;
            if (_unreadNotificationCount > 0) {
              _unreadNotificationCount--;
            }
          }
        });
      }
    } catch (e) {
      print('❌ Error marking notification as read: $e');
    }
  }

  Future<void> _loadConversations() async {
    if (_currentUserId == null || _token == null) {
      setState(() {
        _isLoadingMessages = false;
        _errorMessage = 'Please log in to view messages';
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://junk-and-gems-api.onrender.com/api/users/$_currentUserId/conversations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _conversations = data.cast<Map<String, dynamic>>();
          _isLoadingMessages = false;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _isLoadingMessages = false;
          _errorMessage = 'Failed to load conversations';
        });
      }
    } catch (error) {
      setState(() {
        _isLoadingMessages = false;
        _errorMessage = 'Network error';
      });
    }
  }

  void _navigateToChat(Map<String, dynamic> conversation) {
    if (_currentUserId == null) return;

    final conversationId = conversation['conversation_id']?.toString() ?? '1';
    final otherUserId = conversation['other_user_id']?.toString() ?? '2';
    final userName = conversation['other_user_name']?.toString() ?? 'User';

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
    ).then((_) => _loadConversations());
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF7F2E4),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDarkMode),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildNotificationsTab(isDarkMode),
                  _buildMessagesTab(isDarkMode),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context, isDarkMode),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D)),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/logo.png', width: 36, height: 36),
                    const SizedBox(width: 12),
                    Text(
                      'Notifications & Messages',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: isDarkMode ? const Color(0xFFBEC092) : const Color(0xFF88844D)),
                onPressed: () {
                  _loadNotifications();
                  _loadConversations();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFBEC092).withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFBEC092).withOpacity(0.3),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF88844D), Color(0xFFBEC092)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF88844D).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: isDarkMode ? Colors.white70 : const Color(0xFF88844D),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.notifications, size: 18),
                      const SizedBox(width: 8),
                      const Text('Notifications'),
                      if (_unreadNotificationCount > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            _unreadNotificationCount > 9 ? '9+' : _unreadNotificationCount.toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble, size: 18),
                      SizedBox(width: 8),
                      Text('Messages'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab(bool isDarkMode) {
    if (_isLoadingNotifications) {
      return _buildLoadingState(isDarkMode, 'Loading notifications...');
    }

    if (_notifications.isEmpty) {
      return _buildEmptyState(
        isDarkMode: isDarkMode,
        icon: Icons.notifications_off,
        title: 'No notifications yet',
        subtitle: 'Your notifications will appear here',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        
        return RefreshIndicator(
          onRefresh: _loadNotifications,
          color: const Color(0xFF88844D),
          child: ListView.builder(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            itemCount: _notifications.length,
            itemBuilder: (context, index) {
              return _buildNotificationCard(
                _notifications[index],
                isDarkMode,
                index,
                isTablet,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildNotificationCard(
    Map<String, dynamic> notification,
    bool isDarkMode,
    int index,
    bool isTablet,
  ) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 200 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (notification['color'] as Color).withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: notification['isUnread'] as bool
              ? Border.all(
                  color: const Color(0xFFBEC092),
                  width: 2,
                )
              : null,
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(isTablet ? 20 : 16),
          leading: Container(
            padding: EdgeInsets.all(isTablet ? 14 : 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (notification['color'] as Color).withOpacity(0.3),
                  (notification['color'] as Color).withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (notification['color'] as Color).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              notification['icon'] as IconData,
              color: notification['color'] as Color,
              size: isTablet ? 28 : 24,
            ),
          ),
          title: Text(
            notification['title'] as String,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 18 : 16,
              color: isDarkMode ? Colors.white : const Color(0xFF333333),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              notification['subtitle'] as String,
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : const Color(0xFF666666),
                fontSize: isTablet ? 15 : 14,
                height: 1.4,
              ),
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                notification['time'] as String,
                style: TextStyle(
                  color: isDarkMode ? Colors.white54 : const Color(0xFF999999),
                  fontSize: isTablet ? 13 : 12,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 12 : 10,
                  vertical: isTablet ? 6 : 4,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF88844D), Color(0xFFBEC092)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  notification['action'] as String,
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          onTap: () => _handleNotificationTap(notification),
        ),
      ),
    );
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    // Mark as read
    if (notification['isUnread'] == true && notification['id'] != null) {
      _markNotificationAsRead(notification['id']);
    }

    final type = notification['type'];
    
    switch (type) {
      case 'new_user':
        // Navigate to the new user's profile
        if (notification['relatedUserId'] != null && notification['relatedUserName'] != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtherUserProfileScreen(
                userName: notification['relatedUserName'],
                userId: notification['relatedUserId'].toString(),
              ),
            ),
          );
        }
        break;
      case 'material_claimed':
      case 'recommendation':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BrowseMaterialsScreen()),
        );
        break;
      case 'product_sold':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MarketplaceScreen(userName: 'User')),
        );
        break;
      case 'message':
        // Would navigate to chat if we had the conversation data
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(notification['subtitle'] as String),
            backgroundColor: const Color(0xFF88844D),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(notification['subtitle'] as String),
            backgroundColor: const Color(0xFF88844D),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
    }
  }

  Widget _buildMessagesTab(bool isDarkMode) {
    if (_errorMessage != null) {
      return _buildErrorState(isDarkMode);
    }

    if (_isLoadingMessages) {
      return _buildLoadingState(isDarkMode, 'Loading conversations...');
    }

    if (_conversations.isEmpty) {
      return _buildEmptyState(
        isDarkMode: isDarkMode,
        icon: Icons.chat_bubble_outline,
        title: 'No conversations yet',
        subtitle: 'Start chatting with artisans and contributors!',
        actionButton: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MarketplaceScreen(userName: 'User')),
            );
          },
          icon: const Icon(Icons.shopping_bag_outlined),
          label: const Text('Browse Products'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF88844D),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        
        return RefreshIndicator(
          onRefresh: _loadConversations,
          color: const Color(0xFF88844D),
          child: ListView.builder(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            itemCount: _conversations.length,
            itemBuilder: (context, index) {
              final conversation = _conversations[index];
              return _buildConversationCard(conversation, isDarkMode, index, isTablet);
            },
          ),
        );
      },
    );
  }

  Widget _buildConversationCard(
    Map<String, dynamic> conversation,
    bool isDarkMode,
    int index,
    bool isTablet,
  ) {
    final unreadCountString = conversation['unread_count']?.toString() ?? '0';
    final unreadCount = int.tryParse(unreadCountString) ?? 0;
    final isUnread = unreadCount > 0;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 200 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF88844D).withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: isUnread
              ? Border.all(color: const Color(0xFFBEC092), width: 2)
              : null,
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(isTablet ? 20 : 16),
          leading: Container(
            width: isTablet ? 58 : 54,
            height: isTablet ? 58 : 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF88844D), Color(0xFFBEC092)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF88844D).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: isTablet ? 28 : 26,
            ),
          ),
          title: Text(
            conversation['other_user_name']?.toString() ?? 'Unknown User',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 18 : 16,
              color: isDarkMode ? Colors.white : const Color(0xFF333333),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              conversation['last_message']?.toString() ?? 'No messages yet',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : const Color(0xFF666666),
                fontSize: isTablet ? 15 : 14,
                fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatLastMessageTime(conversation['last_message_time']),
                style: TextStyle(
                  color: isDarkMode ? Colors.white54 : const Color(0xFF999999),
                  fontSize: isTablet ? 13 : 12,
                ),
              ),
              if (isUnread) ...[
                const SizedBox(height: 6),
                Container(
                  padding: EdgeInsets.all(isTablet ? 8 : 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF88844D), Color(0xFFBEC092)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF88844D).withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    unreadCount > 9 ? '9+' : unreadCount.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 12 : 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          onTap: () => _navigateToChat(conversation),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required bool isDarkMode,
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? actionButton,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        
        return Center(
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 48 : 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(isTablet ? 32 : 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFBEC092).withOpacity(0.2),
                        const Color(0xFF88844D).withOpacity(0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: isTablet ? 80 : 64,
                    color: const Color(0xFF88844D),
                  ),
                ),
                SizedBox(height: isTablet ? 32 : 24),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : const Color(0xFF333333),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isTablet ? 16 : 12),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: isDarkMode ? Colors.white70 : const Color(0xFF666666),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (actionButton != null) ...[
                  SizedBox(height: isTablet ? 32 : 24),
                  actionButton,
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(bool isDarkMode, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFBEC092).withOpacity(0.2),
                  const Color(0xFF88844D).withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: Color(0xFF88844D),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : const Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _errorMessage ?? 'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : const Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _loadNotifications();
                _loadConversations();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF88844D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
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
      if (difference.inMinutes < 60) return '${difference.inMinutes}m';
      if (difference.inHours < 24) return '${difference.inHours}h';
      if (difference.inDays < 7) return '${difference.inDays}d';
      
      return '${dateTime.day}/${dateTime.month}';
    } catch (e) {
      return 'Recently';
    }
  }

  Widget _buildBottomNavBar(BuildContext context, bool isDarkMode) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
          _buildNavItem(Icons.home_filled, false, 'Home', isDarkMode, onTap: () {
            Navigator.pop(context);
          }),
          _buildNavItem(Icons.inventory_2_outlined, false, 'Browse', isDarkMode, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const BrowseMaterialsScreen()));
          }),
          _buildNavItem(Icons.shopping_bag_outlined, false, 'Shop', isDarkMode, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const MarketplaceScreen(userName: 'User')));
          }),
          _buildNavItem(Icons.notifications, true, 'Alerts', isDarkMode, onTap: () {}),
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
      ),
    );
  }
}