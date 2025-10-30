import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:math';

class NotificationService {
  static const String baseUrl = 'https://junk-and-gems-api.onrender.com/api';
  
  // Local notifications plugin instance
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  static bool _isInitialized = false;

  // Motivational tips for daily notifications
  static const List<String> motivationalTips = [
    "💚 Turn trash into treasure, donate an item today!",
    "💚 Small actions, big impact! Reduce waste by giving items a second life.",
    "💚 Declutter with purpose - donate today!",
    "💚 Your unused items could be someone's treasure!",
    "💚 Donating helps reduce waste and helps others!",
    "💚 Make space, make a difference - donate now!",
    "💚 One person's trash is another's treasure!",
    "💚 Give your items a second chance at life!",
  ];

  // ============================================================================
  // LOCAL NOTIFICATIONS - NEW FEATURES
  // ============================================================================

  /// Initialize local notifications
  static Future<void> initializeLocalNotifications() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();
    
    _isInitialized = true;
    print('✅ Local notifications initialized');
  }

  /// Request notification permissions (iOS & Android 13+)
  static Future<bool> _requestPermissions() async {
    // iOS permissions
    final iosPlatform = _localNotifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    
    if (iosPlatform != null) {
      final granted = await iosPlatform.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      if (granted != true) {
        print('⚠️ iOS notification permissions denied');
        return false;
      }
    }

    // Android 13+ permissions
    final androidPlatform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlatform != null) {
      final granted = await androidPlatform.requestNotificationsPermission();
      if (granted != true) {
        print('⚠️ Android notification permissions denied');
        return false;
      }
    }

    return true;
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    print('📱 Notification tapped: ${response.payload}');
    
    // Store the payload for the app to handle navigation
    if (response.payload != null) {
      _handleNotificationNavigation(response.payload!);
    }
  }

  static void _handleNotificationNavigation(String payload) {
    // Parse the payload and navigate accordingly
    final prefs = SharedPreferences.getInstance();
    prefs.then((p) => p.setString('pending_notification_action', payload));
  }

  /// Schedule daily motivational tip
  static Future<void> scheduleDailyTip({
    int hour = 10, 
    int minute = 0,
    bool enabled = true,
  }) async {
    if (!enabled) {
      await _localNotifications.cancel(999); // Cancel daily tip
      print('🔕 Daily tips disabled');
      return;
    }

    final random = Random();
    final tip = motivationalTips[random.nextInt(motivationalTips.length)];

    await _localNotifications.zonedSchedule(
      999, // Fixed ID for daily tips
      'EcoConnect Tip 🌱',
      tip,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_tips',
          'Daily Tips',
          channelDescription: 'Daily eco-friendly tips and reminders',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_tip',
    );

    print('✅ Daily tip scheduled for $hour:${minute.toString().padLeft(2, '0')}');
  }

  /// Calculate next instance of specified time
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Show instant local notification
  static Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = 'instant_notifications',
    String channelName = 'Instant Notifications',
  }) async {
    await _localNotifications.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: 'Real-time app notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          styleInformation: const BigTextStyleInformation(''),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  /// Show notification for new user joining
  static Future<void> showNewUserLocalNotification(String userName, String userId) async {
    await showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '👋 New User Joined!',
      body: '$userName just joined the community',
      payload: 'new_user:$userId',
    );
  }

  /// Show notification for new material listed
  static Future<void> showNewMaterialLocalNotification(
    String materialName, 
    String materialId,
  ) async {
    await showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '♻️ New Material Available',
      body: 'Check out: $materialName',
      payload: 'new_material:$materialId',
    );
  }

  /// Show notification for new product on sale
  static Future<void> showNewProductLocalNotification(
    String productName,
    String productId,
  ) async {
    await showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🛍️ New Product on Sale',
      body: '$productName is now available!',
      payload: 'new_product:$productId',
    );
  }

  /// Poll backend and show local notifications for unread items
  static Future<void> syncAndShowLocalNotifications(String userId) async {
    try {
      final result = await getUserNotifications(userId, unreadOnly: true);
      
      if (result['success'] == true) {
        final notifications = result['notifications'] as List;
        
        for (var notification in notifications) {
          await _showLocalNotificationFromBackend(notification);
        }
        
        print('✅ Synced ${notifications.length} notifications');
      }
    } catch (e) {
      print('❌ Error syncing notifications: $e');
    }
  }

  /// Convert backend notification to local notification
  static Future<void> _showLocalNotificationFromBackend(
    Map<String, dynamic> notification,
  ) async {
    final type = notification['type'] ?? 'general';
    final title = notification['title'] ?? 'Notification';
    final message = notification['message'] ?? '';
    final id = notification['id'] ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;

    String emoji = '📢';
    switch (type) {
      case 'new_user':
        emoji = '👋';
        break;
      case 'material_claimed':
      case 'new_material':
        emoji = '♻️';
        break;
      case 'product_sold':
      case 'new_product':
        emoji = '🛍️';
        break;
      case 'message':
        emoji = '💬';
        break;
      case 'achievement':
        emoji = '⭐';
        break;
    }

    await showLocalNotification(
      id: id,
      title: '$emoji $title',
      body: message,
      payload: '$type:${notification['relatedUserId'] ?? ''}',
    );
  }

  /// Start periodic sync (polls every 5 minutes)
  static void startPeriodicSync(String userId) {
    Stream.periodic(const Duration(minutes: 5)).listen((_) async {
      await syncAndShowLocalNotifications(userId);
    });
    print('✅ Started periodic notification sync');
  }

  /// Cancel all local notifications
  static Future<void> cancelAllLocalNotifications() async {
    await _localNotifications.cancelAll();
    print('✅ Cancelled all local notifications');
  }

  /// Cancel specific local notification
  static Future<void> cancelLocalNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  // ============================================================================
  // EXISTING BACKEND API METHODS
  // ============================================================================

  /// Get all notifications for a user
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

  /// Get unread notification count
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

  /// Mark notifications as read
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

  /// Create custom notification
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

  /// Parse notification for display
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