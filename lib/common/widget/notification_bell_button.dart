import 'dart:async';

import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/data/auth/source/auth_firebase_service.dart';
import 'package:polen_academy/domain/notification/entity/notification_entity.dart';
import 'package:polen_academy/domain/notification/repository/notification_repository.dart';
import 'package:polen_academy/service_locator.dart';

/// App bar'da zil ikonu: sağ altında okunmamış sayısı, tıklanınca bildirim paneli.
class NotificationBellButton extends StatefulWidget {
  const NotificationBellButton({
    super.key,
    this.iconColor = Colors.white,
  });

  final Color iconColor;

  @override
  State<NotificationBellButton> createState() => _NotificationBellButtonState();
}

class _NotificationBellButtonState extends State<NotificationBellButton> {
  Stream<int>? _unreadCountStream;
  String? _userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initStream());
  }

  void _initStream() {
    if (!mounted) return;
    final uid = sl<AuthFirebaseService>().getCurrentUserUid();
    if (uid == _userId) return;
    _userId = uid;
    if (uid != null && uid.isNotEmpty) {
      final raw = sl<NotificationRepository>().watchUnreadCount(uid);
      _unreadCountStream = raw
          .handleError((Object e, StackTrace st) {
            // Firestore izin/bağlantı/indeks hatası: badge 0 gösterilir
          })
          .asBroadcastStream(onCancel: (s) => s.cancel());
    } else {
      _unreadCountStream = null;
    }
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant NotificationBellButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    final uid = sl<AuthFirebaseService>().getCurrentUserUid();
    if (uid != _userId) _initStream();
  }

  void _onBellTap(BuildContext context) {
    final uid = sl<AuthFirebaseService>().getCurrentUserUid() ?? _userId;
    if (uid != null && uid.isNotEmpty) {
      _showNotificationPanel(context, uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_unreadCountStream == null) {
      return IconButton(
        icon: Icon(Icons.notifications_none, color: widget.iconColor),
        onPressed: () => _onBellTap(context),
      );
    }
    return StreamBuilder<int>(
      stream: _unreadCountStream,
      initialData: 0,
      builder: (context, snapshot) {
        final count = snapshot.hasError ? 0 : (snapshot.data ?? 0);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: Icon(Icons.notifications_none, color: widget.iconColor),
              onPressed: () => _onBellTap(context),
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

  void _showNotificationPanel(BuildContext context, String fallbackUserId) {
    if (!context.mounted) return;
    final userId = sl<AuthFirebaseService>().getCurrentUserUid() ?? fallbackUserId;
    if (userId.isEmpty) return;

    // Önce sadece "Yükleniyor" dialog'u aç (içinde async yok, donma riski yok)
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Material(
          color: Colors.transparent,
          child: Card(
            color: AppColors.secondBackground,
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryCoach),
                  SizedBox(height: 16),
                  Text('Bildirimler yükleniyor...', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Veriyi dialog dışında yükle, bitince loading'i kapatıp sonuç dialog'unu aç
    sl<NotificationRepository>()
        .getForUser(userId, limit: 50)
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw TimeoutException('Zaman aşımı'),
        )
        .then((result) {
          if (!context.mounted) return;
          Navigator.of(context).pop(); // loading dialog kapat
          if (!context.mounted) return;
          final list = result.fold((_) => <NotificationEntity>[], (List<NotificationEntity> l) => l);
          final hasError = result.fold((_) => true, (_) => false);
          _showResultDialog(context, userId, list, hasError);
        })
        .catchError((_) {
          if (!context.mounted) return;
          Navigator.of(context).pop();
          if (!context.mounted) return;
          _showResultDialog(context, userId, <NotificationEntity>[], true);
        });
  }

  void _showResultDialog(
    BuildContext context,
    String userId,
    List<NotificationEntity> notifications,
    bool hasError,
  ) {
    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _NotificationResultDialog(
        notifications: notifications,
        hasError: hasError,
        onClose: () {
          Navigator.of(ctx).pop();
          if (context.mounted) {
            sl<NotificationRepository>().markAllAsRead(userId);
          }
        },
      ),
    );
  }
}

String _formatTime(DateTime at) {
  final now = DateTime.now();
  final diff = now.difference(at);
  if (diff.inMinutes < 1) return 'Az önce';
  if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
  if (diff.inHours < 24) return '${diff.inHours} saat önce';
  if (diff.inDays < 7) return '${diff.inDays} gün önce';
  return '${at.day.toString().padLeft(2, '0')}.${at.month.toString().padLeft(2, '0')}.${at.year} ${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';
}

/// Sadece hazır listeyi gösterir; içinde async yok, donma riski yok.
class _NotificationResultDialog extends StatelessWidget {
  const _NotificationResultDialog({
    required this.notifications,
    required this.hasError,
    required this.onClose,
  });

  final List<NotificationEntity> notifications;
  final bool hasError;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.of(context).size.height * 0.55;
    return AlertDialog(
      backgroundColor: AppColors.secondBackground,
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      title: Row(
        children: [
          const Icon(Icons.notifications_outlined, color: Colors.white70, size: 24),
          const SizedBox(width: 10),
          const Text('Bildirimler', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: onClose,
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: maxH - 60,
              child: hasError
                  ? _buildError(context)
                  : notifications.isEmpty
                      ? _buildEmpty(context)
                      : ListView.separated(
                          itemCount: notifications.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) => _NotificationTile(n: notifications[index]),
                        ),
            ),
            const SizedBox(height: 12),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onClose,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryCoach.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primaryCoach.withOpacity(0.5), width: 1),
                  ),
                  child: const Center(
                    child: Text('Kapat', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.white38),
          const SizedBox(height: 12),
          const Text('Bildirimler yüklenemedi.', style: TextStyle(color: Colors.white54, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none, size: 48, color: Colors.white38),
          const SizedBox(height: 12),
          const Text('Henüz bildirim yok.', style: TextStyle(color: Colors.white54, fontSize: 15)),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.n});

  final NotificationEntity n;

  @override
  Widget build(BuildContext context) {
    IconData icon = Icons.notifications;
    switch (n.type) {
      case NotificationType.sessionPlanned:
        icon = Icons.event;
        break;
      case NotificationType.sessionReminder:
        icon = Icons.schedule;
        break;
      case NotificationType.sessionCompletedOrCancelled:
        icon = Icons.event_available;
        break;
      case NotificationType.homeworkAssigned:
        icon = Icons.assignment;
        break;
      case NotificationType.homeworkCompletedByStudent:
        icon = Icons.check_circle;
        break;
      case NotificationType.homeworkStatusByCoach:
        icon = Icons.rate_review;
        break;
      case NotificationType.homeworkOverdue:
        icon = Icons.warning_amber_rounded;
        break;
    }
    final isRead = n.isRead;
    final titleColor = isRead ? Colors.white54 : Colors.white;
    final bodyColor = isRead ? Colors.white38 : Colors.white70;
    final iconColor = isRead ? Colors.white38 : AppColors.primaryCoach;
    return Container(
      key: ValueKey(n.id),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF252030),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isRead ? Colors.white12 : Colors.white24, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(n.title, style: TextStyle(color: titleColor, fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text(n.body, style: TextStyle(color: bodyColor, fontSize: 13, height: 1.3), maxLines: 3, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text(_formatTime(n.createdAt), style: TextStyle(color: bodyColor, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
