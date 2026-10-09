import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notifications_provider.dart';
import '../utils/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifs = context.watch<NotificationsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Notificaciones',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          if (notifs.notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                notifs.markAllRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Todas marcadas como leídas')),
                );
              },
              child: const Text('Marcar leídas',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
            ),
        ],
      ),
      body: notifs.notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_rounded,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('Sin notificaciones',
                      style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textGray,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  const Text('Aquí aparecerán tus avisos',
                      style: TextStyle(fontSize: 13, color: AppColors.textGray)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifs.notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final n = notifs.notifications[i];
                return GestureDetector(
                  onTap: () {
                    notifs.markRead(n.id);
                    if (n.reportId != null) {
                      Navigator.pushNamed(ctx, '/report-detail',
                          arguments: n.reportId);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: n.isRead
                          ? Colors.white
                          : AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: n.isRead
                          ? Border.all(color: AppColors.borderColor)
                          : Border.all(
                              color: AppColors.primary.withValues(alpha: 0.25)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6)
                      ],
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: n.isRead
                                ? Colors.grey.shade100
                                : AppColors.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            n.isRead
                                ? Icons.notifications_rounded
                                : Icons.notifications_active_rounded,
                            color: n.isRead
                                ? AppColors.textGray
                                : AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(n.title,
                                        style: TextStyle(
                                            fontWeight: n.isRead
                                                ? FontWeight.w500
                                                : FontWeight.bold,
                                            fontSize: 14)),
                                  ),
                                  if (!n.isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(n.body,
                                  style: const TextStyle(
                                      color: AppColors.textGray,
                                      fontSize: 12,
                                      height: 1.4)),
                              const SizedBox(height: 6),
                              Text(notifs.timeAgo(n.timestamp),
                                  style: const TextStyle(
                                      color: AppColors.textGray,
                                      fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

