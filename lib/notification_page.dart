import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _supa = Supabase.instance.client;

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final uid = _supa.auth.currentUser?.id;
      if (uid == null) {
        setState(() {
          _notifications = [];
          _loading = false;
        });
        return;
      }

      final rows = await _supa
          .from('user_notifications')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false);

      _notifications = List<Map<String, dynamic>>.from(rows as List);

      // Mark all unread as read
      final unreadIds = _notifications
          .where((n) => n['is_read'] == false)
          .map((n) => n['id'].toString())
          .toList();

      if (unreadIds.isNotEmpty) {
        await _supa
            .from('user_notifications')
            .update({'is_read': true})
            .inFilter('id', unreadIds);
      }
    } catch (e) {
      debugPrint('notification load error: $e');
    }
    setState(() => _loading = false);
  }

  // Delete one notification
  Future<void> _deleteOne(String id) async {
    try {
      await _supa.from('user_notifications').delete().eq('id', id);
      setState(() {
        _notifications.removeWhere((n) => n['id'].toString() == id);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Delete all notifications
  Future<void> _deleteAll() async {
    final uid = _supa.auth.currentUser?.id;
    if (uid == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete All?'),
        content: const Text('Remove all your notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await _supa.from('user_notifications').delete().eq('user_id', uid);
      setState(() => _notifications.clear());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final titleSize = width * 0.06;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/backg.png', fit: BoxFit.cover),
          ),
          Positioned.fill(child: Container(color: Colors.white.withAlpha(64))),
          SafeArea(
            child: Column(
              children: [
                // ── Top bar ──
                Container(
                  margin: EdgeInsets.all(width * 0.04),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(217),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 4),
                      Image.asset('assets/logoremove.jpeg', height: 28),
                      const SizedBox(width: 10),
                      const Text(
                        "Notifications",
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const Spacer(),
                      if (_notifications.isNotEmpty)
                        IconButton(
                          icon: const Icon(
                            Icons.delete_sweep,
                            color: Colors.red,
                          ),
                          tooltip: 'Delete All',
                          onPressed: _deleteAll,
                        ),
                    ],
                  ),
                ),

                // ── Body ──
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _supa.auth.currentUser == null
                      ? const Center(
                          child: Text(
                            "Please login to see notifications",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : _notifications.isEmpty
                      ? const Center(
                          child: Text(
                            "No notifications yet",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.04,
                            ),
                            itemCount: _notifications.length,
                            itemBuilder: (_, i) =>
                                _notifCard(_notifications[i]),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _notifCard(Map<String, dynamic> n) {
    final title = (n['title'] ?? '').toString();
    final body = (n['body'] ?? '').toString();
    final type = (n['type'] ?? 'info').toString();
    final isRead = n['is_read'] == true;
    final createdAt = (n['created_at'] ?? '').toString();

    // Parse date
    String dateStr = '';
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      dateStr =
          '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {}

    // Icon + color based on type
    IconData icon;
    Color iconColor;
    switch (type) {
      case 'payment_received':
        icon = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case 'payment_failed':
        icon = Icons.cancel;
        iconColor = Colors.red;
        break;
      case 'pickup_approved':
        icon = Icons.local_shipping;
        iconColor = Colors.green;
        break;
      case 'pickup_rejected':
        icon = Icons.block;
        iconColor = Colors.red;
        break;
      default:
        icon = Icons.info_outline;
        iconColor = const Color.fromARGB(255, 30, 111, 168);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isRead ? Colors.white.withAlpha(200) : Colors.blue.withAlpha(25),
        borderRadius: BorderRadius.circular(14),
        border: isRead
            ? null
            : Border.all(
                color: const Color.fromARGB(255, 30, 111, 168).withAlpha(80),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                    color: const Color.fromARGB(255, 14, 63, 122),
                  ),
                ),
                if (body.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  dateStr,
                  style: const TextStyle(fontSize: 11, color: Colors.black45),
                ),
              ],
            ),
          ),
          // Delete button
          GestureDetector(
            onTap: () => _deleteOne(n['id'].toString()),
            child: const Icon(Icons.close, size: 18, color: Colors.black38),
          ),
        ],
      ),
    );
  }
}
