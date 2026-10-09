import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notifications_provider.dart';
import '../utils/app_theme.dart';

class AppHeader extends StatelessWidget {
  final bool showNotification;
  final bool showBack;
  final VoidCallback? onBack;

  const AppHeader({
    super.key,
    this.showNotification = false,
    this.showBack = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final notifs = context.watch<NotificationsProvider>();
    final unread = notifs.unreadCount;

    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 8,
        bottom: 12,
      ),
      child: Row(
        children: [
          // Back button or logo
          if (showBack)
            GestureDetector(
              onTap: onBack ?? () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
              ),
            )
          else
            _buildLogo(),

          const SizedBox(width: 10),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'UTS ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      TextSpan(
                        text: 'InfoFix',
                        style: TextStyle(
                          color: Color(0xFFC5D4A0),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!showBack)
                  const Text(
                    'UNIDADES TECNOLÓGICAS DE SANTANDER',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 9,
                      letterSpacing: 0.8,
                    ),
                  ),
              ],
            ),
          ),

          // Notification bell — FUNCTIONAL
          if (showNotification)
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/notifications');
                  },
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 26,
                  ),
                  tooltip: 'Notificaciones',
                ),
                if (unread > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: IgnorePointer(
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            unread > 9 ? '9+' : '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.computer_rounded, color: Colors.white, size: 22),
    );
  }
}

