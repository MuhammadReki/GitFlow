import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/github_notification.dart';
import '../../../data/services/auth_storage.dart';
import '../../../data/services/github_api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<GitHubNotification> _allNotifications = [];
  List<GitHubNotification> _filtered = [];
  bool _isLoading = true;
  String? _error;
  bool _showUnreadOnly = true;
  String? _token;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _token = await AuthStorage.getToken();
      if (_token == null) {
        if (!mounted) return;
        setState(() {
          _error = 'Token tidak ditemukan';
          _isLoading = false;
        });
        return;
      }

      final notifs = await GitHubApiService.getNotifications(
        _token!,
        all: !_showUnreadOnly,
      ).timeout(const Duration(seconds: 15));

      if (!mounted) return;
      setState(() {
        _allNotifications = notifs;
        _filtered = notifs;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('🔴 _load error: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Gagal load notifikasi: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _openNotification(GitHubNotification notif) async {
    if (notif.isUnread && _token != null) {
      await GitHubApiService.markNotificationAsRead(_token!, notif.id);
      if (!mounted) return;
      _load();
    }

    if (notif.subjectUrl != null && notif.subjectUrl!.isNotEmpty) {
      String webUrl = notif.subjectUrl!;
      webUrl = webUrl
          .replaceFirst('https://api.github.com/repos/', 'https://github.com/')
          .replaceFirst('/pulls/', '/pull/');
      final uri = Uri.parse(webUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  Future<void> _markAllAsRead() async {
    if (_token == null) return;
    final ok = await GitHubApiService.markAllNotificationsAsRead(_token!);
    if (ok && mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterTabs(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Aktivitas GitHub lu',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _markAllAsRead,
            icon: const Icon(Icons.done_all_rounded),
            color: const Color(0xFF6366F1),
          ),
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
            color: const Color(0xFF6366F1),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: Row(
        children: [
          _buildFilterChip('Belum Dibaca', true),
          const SizedBox(width: 8),
          _buildFilterChip('Semua', false),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isUnreadOnly) {
    final isActive = _showUnreadOnly == isUnreadOnly;
    return GestureDetector(
      onTap: () {
        setState(() => _showUnreadOnly = isUnreadOnly);
        _load();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF6366F1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? const Color(0xFF6366F1)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6366F1)),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 60, color: Color(0xFFDC2626)),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _load,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_off_rounded,
                size: 60, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 16),
            Text(
              _showUnreadOnly
                  ? 'Gak ada notifikasi baru'
                  : 'Gak ada notifikasi',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: const Color(0xFF6366F1),
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _buildNotifCard(_filtered[i]),
      ),
    );
  }

  Widget _buildNotifCard(GitHubNotification notif) {
    final isUnread = notif.isUnread;
    return GestureDetector(
      onTap: () => _openNotification(notif),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUnread
                ? const Color(0xFF6366F1).withValues(alpha: 0.4)
                : const Color(0xFFE5E7EB),
            width: isUnread ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _iconColor(notif.iconName).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _iconData(notif.iconName),
                color: _iconColor(notif.iconName),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF6366F1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          notif.subjectTitle ?? 'Notifikasi',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: isUnread
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: const Color(0xFF111827),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          notif.subjectType ?? 'Notif',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          notif.repoFullName ?? '',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.reasonLabel,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconData(String name) {
    switch (name) {
      case 'issue':
        return Icons.error_outline_rounded;
      case 'pr':
        return Icons.merge_type_rounded;
      case 'release':
        return Icons.rocket_launch_rounded;
      case 'commit':
        return Icons.commit_rounded;
      case 'discussion':
        return Icons.forum_outlined;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _iconColor(String name) {
    switch (name) {
      case 'issue':
        return const Color(0xFF10B981);
      case 'pr':
        return const Color(0xFF8B5CF6);
      case 'release':
        return const Color(0xFFF59E0B);
      case 'commit':
        return const Color(0xFF6366F1);
      case 'discussion':
        return const Color(0xFF06B6D4);
      default:
        return const Color(0xFF6366F1);
    }
  }
}