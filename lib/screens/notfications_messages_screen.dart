import 'package:flutter/material.dart';
import 'package:junk_and_gems/screens/browse_materials_screen.dart';

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


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2E4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F2E4),
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF88844D),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF88844D),
          labelColor: const Color(0xFF88844D),
          unselectedLabelColor: const Color(0xFF88844D).withOpacity(0.6),
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
          _buildNotificationsTab(),
          _buildMessagesTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  /// =========================
  /// Notifications Tab
  /// =========================
  Widget _buildNotificationsTab() {
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
      {
        'title': 'Welcome, Mahloil',
        'subtitle': 'A new artisan has joined the platform.',
        'time': '1 hour ago',
        'action': 'View Profile',
        'icon': Icons.group,
        'color': Colors.blue,
        'isUnread': false,
      },
      {
        'title': 'Listing Update',
        'subtitle': 'Your listing for wires is gaining interest',
        'time': '3 hours ago',
        'action': 'View Listing',
        'icon': Icons.list_alt,
        'color': Colors.purple,
        'isUnread': false,
      },
      {
        'title': 'Platform Update',
        'subtitle': 'System maintenance is scheduled for tonight',
        'time': '1 day ago',
        'action': 'Learn More',
        'icon': Icons.notifications,
        'color': Colors.red,
        'isUnread': false,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: notifications.map((notification) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: notification['isUnread'] as bool
                  ? Border.all(color: const Color(0xFFBEC092), width: 2)
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Circle
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (notification['color'] as Color).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      notification['icon'] as IconData,
                      color: notification['color'] as Color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Text Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification['title'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF88844D),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notification['subtitle'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              notification['time'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFBEC092),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                notification['action'] as String,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF88844D),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// =========================
  /// Messages Tab
  /// =========================
  Widget _buildMessagesTab() {
    final List<Map<String, dynamic>> conversations = [
      {
        'name': 'Nthati R.',
        'message': "I'm interested in the old...",
        'time': '2m ago',
        'isUnread': true,
      },
      {
        'name': 'Mahloil M.',
        'message': 'Can I pick up the fabric...',
        'time': '5m ago',
        'isUnread': true,
      },
      {
        'name': 'Limakatso L.',
        'message': 'The upcycled bags are...',
        'time': '1h ago',
        'isUnread': false,
      },
      {
        'name': 'Liteboho N.',
        'message': 'Do you still have the...',
        'time': '2h ago',
        'isUnread': false,
      },
      {
        'name': 'Louise G.',
        'message': 'Are the glass jars still...',
        'time': '3h ago',
        'isUnread': false,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Search Bar
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBEC092), width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.search,
                      color: const Color(0xFF88844D).withOpacity(0.6)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search Messages...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Chips
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFBEC092),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Unread',
                  style: TextStyle(
                      color: Color(0xFF88844D),
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFBEC092), width: 1),
                ),
                child: const Text(
                  'Archived',
                  style: TextStyle(
                      color: Color(0xFF88844D),
                      fontWeight: FontWeight.w500,
                      fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Conversations List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: conversations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              return _buildConversationCard(
                name: conversation['name'] as String,
                message: conversation['message'] as String,
                time: conversation['time'] as String,
                isUnread: conversation['isUnread'] as bool,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConversationCard({
    required String name,
    required String message,
    required String time,
    required bool isUnread,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
        border: isUnread
            ? Border.all(color: const Color(0xFFBEC092), width: 2)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar Circle
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  color: const Color(0xFFBEC092),
                  borderRadius: BorderRadius.circular(25)),
              child: const Icon(Icons.person, color: Color(0xFF88844D)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF88844D))),
                      const Spacer(),
                      Text(time,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.black.withOpacity(0.5))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(message,
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.7),
                          fontWeight: isUnread
                              ? FontWeight.w600
                              : FontWeight.normal),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// =========================
  /// Bottom Navigation Bar
  /// =========================
   Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFFBEC092),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home, false, onTap: () => Navigator.pop(context)),
          _navItem(Icons.inventory_2_outlined, false, onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BrowseMaterialsScreen()),
            );
          }),
          _navItem(Icons.shopping_bag_outlined, false),
          _navItem(Icons.notifications_active_outlined, true, onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const NotificationsMessagesScreen()),
            );
          }),
          _navItem(Icons.person_outline, false),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, bool isSelected, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: isSelected
            ? const BoxDecoration(color: Color(0xFFF7F2E4), shape: BoxShape.circle)
            : null,
        padding: const EdgeInsets.all(12),
        child: Icon(icon, color: const Color(0xFF88844D), size: 28),
      ),
    );
  }
}
