import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/providers/cfms_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CfmsProvider>(context, listen: false).fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cfms = Provider.of<CfmsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi Saya')),
      body: RefreshIndicator(
        onRefresh: () => cfms.fetchNotifications(),
        child: cfms.notifications.isEmpty
            ? const Center(child: Text('Belum ada notifikasi', style: TextStyle(color: Color(0xFF94A3B8))))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: cfms.notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final n = cfms.notifications[index];

                  return Card(
                    color: n.isRead ? Colors.white : AppTheme.primary.withOpacity(0.04),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: n.isRead ? const Color(0xFFE2E8F0) : AppTheme.primary.withOpacity(0.15),
                        child: Icon(Icons.notifications, color: n.isRead ? const Color(0xFF64748B) : AppTheme.primary),
                      ),
                      title: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold)),
                      subtitle: Text(n.message),
                      trailing: n.isRead
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.mark_email_read_outlined, color: AppTheme.primary),
                              onPressed: () => cfms.markNotificationRead(n.id),
                            ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
