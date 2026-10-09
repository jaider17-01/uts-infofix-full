import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';

/// Tarjeta de usuario reutilizable.
/// El chevron ">" navega a /user-profile.
class UserCard extends StatelessWidget {
  final bool showEquipment;
  final String? equipment;
  final String? lab;
  final String? dateTime;

  const UserCard({
    super.key,
    this.showEquipment = false,
    this.equipment,
    this.lab,
    this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // User row — chevron navigates to profile detail
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            onTap: () => Navigator.pushNamed(context, '/user-profile'),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user?.fullName.isNotEmpty == true
                          ? user!.fullName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(
                              color: AppColors.textGray, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  // Functional chevron
                  const Icon(Icons.chevron_right,
                      color: AppColors.textGray, size: 22),
                ],
              ),
            ),
          ),

          // Equipment row (optional)
          if (showEquipment && equipment != null) ...[
            const Divider(height: 1),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.computer_rounded,
                          color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Computador en uso: ',
                        style: const TextStyle(fontSize: 13),
                      ),
                      Text(
                        equipment!,
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13),
                      ),
                    ],
                  ),
                  if (dateTime != null) ...[
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        dateTime!,
                        style: const TextStyle(
                            color: AppColors.textGray, fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

