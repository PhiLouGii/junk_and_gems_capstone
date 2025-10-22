import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static const String baseUrl = 'https://junk-and-gems-api.onrender.com/api';

  // Get all notifications for a user
  static Future<Map<String, dynamic>> getUserNotifications(
    String userId, {
    bool unreadOnly = false,
    int limit = 50,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final uri = Uri.parse('$baseUrl/users/$userId/notifications').replace(
        queryParameters: {
          'unread_only': unreadOnly.toString(),
          'limit': limit.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'notifications': data['notifications'] ?? [],
          'unreadCount': data['unreadCount'] ?? 0,
        };
      } else {
        print('Error fetching notifications: ${response.statusCode}');
        return {
          'success': false,
          'notifications': [],
          'unreadCount': 0,
          'error': 'Failed to fetch notifications',
        };
      }
    } catch (e) {
      print('Exception fetching notifications: $e');
      return {
        'success': false,
        'notifications': [],
        'unreadCount': 0,
        'error': e.toString(),
      };
    }
  }

  // Get unread notification count
  static Future<int> getUnreadCount(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/notifications/unread-count'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['unreadCount'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('❌ Error fetching unread count: $e');
      return 0;
    }
  }

  // Mark notifications as read
  static Future<bool> markNotificationsAsRead(
    String userId, {
    List<int>? notificationIds,
    bool markAll = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId/notifications/read'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          if (notificationIds != null) 'notificationIds': notificationIds,
          'markAll': markAll,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Marked notifications as read');
        return true;
      } else {
        print('❌ Error marking notifications as read: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Exception marking notifications as read: $e');
      return false;
    }
  }

  // Create custom notification
  static Future<bool> createNotification({
    required List<String> userIds,
    required String notificationType,
    required String title,
    required String message,
    String? relatedUserId,
    int expiresInDays = 7,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$baseUrl/notifications/create'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'userIds': userIds,
          'notificationType': notificationType,
          'title': title,
          'message': message,
          if (relatedUserId != null) 'relatedUserId': relatedUserId,
          'expiresInDays': expiresInDays,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error creating notification: $e');
      return false;
    }
  }

  // Parse notification for display
  static Map<String, dynamic> parseNotification(Map<String, dynamic> notif) {
    return {
      'id': notif['id'],
      'type': notif['type'] ?? 'general',
      'title': notif['title'] ?? 'Notification',
      'subtitle': notif['message'] ?? '',
      'time': notif['time'] ?? 'Recently',
      'isUnread': !(notif['isRead'] ?? false),
      'relatedUserId': notif['relatedUserId'],
      'relatedUserName': notif['relatedUserName'],
      'relatedUserImage': notif['relatedUserImage'],
      'action': _getActionForType(notif['type']),
      'icon': _getIconForType(notif['type']),
      'color': _getColorForType(notif['type']),
    };
  }

  static String _getActionForType(String? type) {
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

  static dynamic _getIconForType(String? type) {
    // Returns IconData code point as int for cross-platform compatibility
    switch (type) {
      case 'new_user':
        return 0xe491; // Icons.person_add
      case 'material_claimed':
        return 0xe86c; // Icons.inventory
      case 'product_sold':
        return 0xe59c; // Icons.shopping_bag
      case 'message':
        return 0xe0ca; // Icons.message
      case 'achievement':
        return 0xe838; // Icons.stars
      default:
        return 0xe7f4; // Icons.notifications
    }
  }

  static Map<String, int> _getColorForType(String? type) {
    switch (type) {
      case 'new_user':
        return {'r': 76, 'g': 175, 'b': 80}; // Green
      case 'material_claimed':
        return {'r': 255, 'g': 152, 'b': 0}; // Orange
      case 'product_sold':
        return {'r': 33, 'g': 150, 'b': 243}; // Blue
      case 'message':
        return {'r': 156, 'g': 39, 'b': 176}; // Purple
      case 'achievement':
        return {'r': 255, 'g': 193, 'b': 7}; // Amber
      default:
        return {'r': 136, 'g': 132, 'b': 77}; // Default app color
    }
  }
}