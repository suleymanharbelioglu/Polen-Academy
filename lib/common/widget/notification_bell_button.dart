import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/data/auth/source/auth_firebase_service.dart';
import 'package:polen_academy/domain/notification/entity/notification_entity.dart';
import 'package:polen_academy/domain/notification/repository/notification_repository.dart';
import 'package:polen_academy/service_locator.dart';

/// App bar'da zil ikonu: sağ altında okunmamış sayısı, tıklanınca bildirim paneli.
class NotificationBellButton extends StatelessWidget {
  const NotificationBellButton({
    super.key,
    this.iconColor = Colors.white,
  });

  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final uid = sl<AuthFirebaseService>().getCurrentUserUid();
    if (uid == null || uid.isEmpty) {
      return IconButton(
        icon: Icon(Icons.notifications_none, color: iconColor),
        onPressed: () {},
      );
    }
    return StreamBuilder<int>(
      stream: sl<NotificationRepository>().watchUnreadCount(uid),
      initialData: 0,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: Icon(Icons.notifications_none, color: iconColor),
              onPressed: () => _showNotificationPanel(context, uid),
            ),
            if (count > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _showNotificationPanel(BuildContext context, String userId) async {
    final result = await sl<NotificationRepository>().getForUser(userId, limit: 30);
    final list = result.fold((_) => <NotificationEntity>[], (l) => l);
    await sl<NotificationRepository>().markAllAsRead(userId);
    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => _NotificationPanelDialog(
        notifications: list,
        onClose: () => Navigator.pop(ctx),
      ),
    );
  }
}

class _NotificationPanelDialog extends StatelessWidget {
  const _NotificationPanelDialog({
    required this.notifications,
    required this.onClose,
  });

  final List<NotificationEntity> notifications;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.secondBackground,
      contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
      title: Row(
        children: [
          const Text('Bildirimler', style: TextStyle(color: Colors.white, fontSize: 18)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: onClose,
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
        child: SizedBox(
          width: double.maxFinite,
          child: notifications.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Bildirim yok.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final n = notifications[index];
                  return ListTile(
                    key: ValueKey(n.id),
                    title: Text(
                      n.title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    subtitle: Text(
                      n.body,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: onClose,
          child: const Text('Kapat', style: TextStyle(color: AppColors.primaryCoach)),
        ),
      ],
    );
  }
}
