import 'package:flutter/material.dart';
import 'package:donation_app/admin/event_management.dart';
import 'package:donation_app/food_page.dart';
import 'package:donation_app/cloth_page.dart';
import 'package:donation_app/money_don.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef EventUpdateCallback = void Function(Map<String, dynamic> updatedEvent);

class AfterJoinEventPage extends StatefulWidget {
  final Map<String, dynamic> event;
  final EventUpdateCallback? onEventUpdated;

  const AfterJoinEventPage({
    super.key,
    required this.event,
    this.onEventUpdated,
  });

  @override
  State<AfterJoinEventPage> createState() => _AfterJoinEventPageState();
}

class _AfterJoinEventPageState extends State<AfterJoinEventPage> {
  late Map<String, dynamic> _event;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
  }

  void _notifyUpdate() {
    widget.onEventUpdated?.call(_event);
  }

  Future<void> _showEditDialog() async {
    final titleCtrl = TextEditingController(
      text: _event['title'] as String? ?? '',
    );
    final dateCtrl = TextEditingController(
      text: _event['date'] as String? ?? '',
    );
    final timeCtrl = TextEditingController(
      text: _event['timeDisplay'] as String? ?? '',
    );
    final locationCtrl = TextEditingController(
      text: _event['location'] as String? ?? '',
    );
    final descCtrl = TextEditingController(
      text: _event['description'] as String? ?? '',
    );
    final noticeCtrl = TextEditingController(
      text: _event['notice'] as String? ?? '',
    );

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Event'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: dateCtrl,
                decoration: const InputDecoration(labelText: 'Date'),
              ),
              TextField(
                controller: timeCtrl,
                decoration: const InputDecoration(labelText: 'Time display'),
              ),
              TextField(
                controller: locationCtrl,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: noticeCtrl,
                decoration: const InputDecoration(labelText: 'Notice'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    final updatedTitle = titleCtrl.text.trim();
    final updatedDate = dateCtrl.text.trim();
    final updatedTime = timeCtrl.text.trim();
    final updatedLocation = locationCtrl.text.trim();
    final updatedDescription = descCtrl.text.trim();
    final updatedNotice = noticeCtrl.text.trim();

    titleCtrl.dispose();
    dateCtrl.dispose();
    timeCtrl.dispose();
    locationCtrl.dispose();
    descCtrl.dispose();
    noticeCtrl.dispose();

    if (shouldSave != true) {
      return;
    }

    // Update local state
    setState(() {
      _event['title'] = updatedTitle;
      _event['date'] = updatedDate;
      _event['timeDisplay'] = updatedTime;
      _event['location'] = updatedLocation;
      _event['description'] = updatedDescription;
      _event['notice'] = updatedNotice;
    });

    // Save to Supabase if event has an id
    final eventId = _event['id'] as String?;
    if (eventId != null) {
      try {
        await Supabase.instance.client
            .from('events')
            .update({
              'title': updatedTitle,
              'event_date': toIsoDate(updatedDate),
              'event_time': updatedTime,
              'location': updatedLocation,
              'description': updatedDescription,
              'notice_text': updatedNotice,
            })
            .eq('id', eventId);
      } catch (_) {}
    }

    _notifyUpdate();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Event details updated.')));
    }
  }

  Future<void> _toggleStatus() async {
    final current = (_event['status'] as String?) ?? 'Active';
    final newStatus = current == 'Active' ? 'Closed' : 'Active';

    setState(() {
      _event['status'] = newStatus;
    });

    // Save to Supabase
    final eventId = _event['id'] as String?;
    if (eventId != null) {
      try {
        await Supabase.instance.client
            .from('events')
            .update({'is_active': newStatus == 'Active'})
            .eq('id', eventId);
      } catch (_) {}
    }

    _notifyUpdate();

    final isActive = newStatus == 'Active';
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isActive ? 'Event reopened.' : 'Event closed.')),
      );
    }
  }

  bool get _isActive => ((_event['status'] as String?) ?? 'Active') == 'Active';

  // Navigate to the matching donation page based on action title
  void _onActionTap(String title) {
    final lower = title.toLowerCase();
    Widget? page;
    if (lower.contains('food')) {
      page = const FoodPage();
    } else if (lower.contains('cloth')) {
      page = const ClothDonation();
    } else if (lower.contains('money')) {
      page = const MoneyDonationPage();
    }

    if (page != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> actions = (_event['actions'] as List<dynamic>?) ?? [];
    final Color badgeColor = _event['cardColor'] as Color? ?? Colors.green;
    final String title = _event['title'] as String? ?? '';
    final String date = _event['date'] as String? ?? '';
    final String time = _event['timeDisplay'] as String? ?? '';
    final String location = _event['location'] as String? ?? '';
    final String description = _event['description'] as String? ?? '';
    final String notice = _event['notice'] as String? ?? '';
    final String status = (_event['status'] as String?) ?? 'Active';

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/backg.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Event Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (widget.onEventUpdated != null) ...[
                        TextButton.icon(
                          onPressed: _showEditDialog,
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Edit'),
                        ),
                        const SizedBox(width: 6),
                        ElevatedButton.icon(
                          onPressed: _toggleStatus,
                          icon: Icon(
                            _isActive ? Icons.close : Icons.check,
                            size: 18,
                          ),
                          label: Text(_isActive ? 'Close' : 'Activate'),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(230),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(30),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (date.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                        if (time.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            time,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                        if (location.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 18,
                                color: Colors.black54,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                location,
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 10),
                        Text(
                          description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.black87),
                        ),
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: badgeColor.withAlpha(200),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(230),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: badgeColor.withAlpha(220),
                              child: Icon(
                                _event['icon'] as IconData? ?? Icons.event,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'You can do the following to support this event.',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Select an action that you want to take for this event.',
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 12),
                        ...actions.map((action) {
                          final Color actionColor =
                              action['color'] as Color? ?? Colors.green;
                          final String actionTitle =
                              action['title'] as String? ?? '';
                          return GestureDetector(
                            onTap: () => _onActionTap(actionTitle),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(20),
                                    blurRadius: 6,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: actionColor.withAlpha(220),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      action['icon'] as IconData? ?? Icons.help,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          action['title'] as String? ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          action['subtitle'] as String? ?? '',
                                          style: const TextStyle(
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _onActionTap(actionTitle),
                                    child: CircleAvatar(
                                      backgroundColor: actionColor.withAlpha(
                                        220,
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Thank you for supporting the community in need.',
                    style: TextStyle(color: Colors.black.withAlpha(160)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
