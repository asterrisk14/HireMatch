import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/app_notification.dart';
import '../services/notification_service.dart';


class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _service = NotificationService();
  List<AppNotification> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _service.getNotifications();
    if (!mounted) return;
    setState(() {
      _notifications = items;
      _loading = false;
    });
  }

  Future<void> _markAsRead(AppNotification n) async {
    if (!n.isRead) {
      await _service.markAsRead(n.id);
      await _load();
    }
  }

  Future<void> _markAllAsRead() async {
    await _service.markAllAsRead();
    await _load();
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}.${dt.month}.${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.tealDark,
        foregroundColor: Colors.white,
        title: const Text('Notifications'),
        actions: [
          if (_notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Mark all read', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.tealDark))
          : _notifications.isEmpty
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'No notifications yet.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      )
          : RefreshIndicator(
        onRefresh: _load,
        color: AppColors.tealDark,
        child: ListView.separated(
          itemCount: _notifications.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final n = _notifications[i];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: n.isRead
                    ? const Color(0xFFE6F2F2)
                    : const Color(0xFF0E7C7C),
                child: Icon(
                  Icons.notifications,
                  color: n.isRead ? const Color(0xFF0E7C7C) : Colors.white,
                  size: 20,
                ),
              ),
              title: Text(
                n.message,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: n.isRead ? FontWeight.normal : FontWeight.w600,
                  color: AppColors.tealDark,
                ),
              ),
              subtitle: Text(
                _timeAgo(n.createdAt),
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              trailing: n.isRead
                  ? null
                  : Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF0E7C7C),
                  shape: BoxShape.circle,
                ),
              ),
              onTap: () => _markAsRead(n),
            );
          },
        ),
      ),
    );
  }
}