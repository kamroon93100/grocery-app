import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Timer? _pollingTimer;
  int    _lastNotifId = 0;

  Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        // Handle notification tap
      },
    );

    // Request permissions on Android 13+
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> showNotification({
    required int    id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'grocery_channel',
      'Grocery Notifications',
      channelDescription: 'Order updates and offers',
      importance:    Importance.high,
      priority:      Priority.high,
      ticker:        'Grocery Store',
      icon:          '@mipmap/ic_launcher',
      enableVibration: true,
      playSound:       true,
    );

    const details = NotificationDetails(android: androidDetails);
    await _notifications.show(id, title, body, details, payload: payload);
  }

  Future<void> showOrderNotification(String orderNumber, String status) async {
    await showNotification(
      id:    DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '📦 Order Update',
      body:  'Order #$orderNumber is now $status',
    );
  }

  Future<void> showWelcomeNotification(String name) async {
    await showNotification(
      id:    1,
      title: '🛒 Welcome to Local Grocery!',
      body:  'Hi $name, browse fresh groceries and get free delivery above \$50',
    );
  }

  Future<void> showOrderPlacedNotification(String orderNumber, double amount) async {
    await showNotification(
      id:    DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '✅ Order Placed Successfully!',
      body:  'Order #$orderNumber  •  \$${amount.toStringAsFixed(2)}  •  Cash on Delivery',
    );
  }

  Future<void> showPromoNotification(String title, String message) async {
    await showNotification(
      id:    DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🎉 $title',
      body:  message,
    );
  }

  // Start polling for new notifications from backend
  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await _checkNewNotifications();
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
  }

  Future<void> _checkNewNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.keyToken);
      if (token == null) return;

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.notifications}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type':  'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data          = jsonDecode(response.body);
        final notifications = data['data']?['notifications'] as List?;

        if (notifications != null && notifications.isNotEmpty) {
          for (final notif in notifications) {
            final id = notif['id'].hashCode;
            if (id > _lastNotifId && notif['isRead'] == false) {
              await showNotification(
                id:    id,
                title: notif['title'] ?? 'Notification',
                body:  notif['body']  ?? '',
              );
              _lastNotifId = id;
            }
          }
        }
      }
    } catch (e) {
      // Silent fail - don't crash on notification errors
    }
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
