import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --------------- Notice Type Options ---------------
// Admin picks one of these when creating a notice.
// Each has a label, color and icon.
class NoticeType {
  final String value; // stored in DB
  final String label; // shown in UI
  final Color color;
  final IconData icon;
  const NoticeType(this.value, this.label, this.color, this.icon);
}

const List<NoticeType> noticeTypes = [
  NoticeType('meeting', 'Meeting', Colors.indigo, Icons.groups),
  NoticeType('blood_urgent', 'Blood Urgent', Colors.red, Icons.bloodtype),
  NoticeType(
    'registration',
    'Registration',
    Colors.teal,
    Icons.app_registration,
  ),
  NoticeType('announcement', 'Announcement', Colors.deepPurple, Icons.campaign),
  NoticeType('event', 'Event', Colors.green, Icons.event),
  NoticeType('general', 'General', Colors.blueGrey, Icons.info),
];

NoticeType getNoticeType(String? value) {
  return noticeTypes.firstWhere(
    (t) => t.value == value,
    orElse: () => noticeTypes.last, // default = General
  );
}

// =====================================================
//  Admin Notice Management Page
// =====================================================
class NoticeManagePage extends StatefulWidget {
  const NoticeManagePage({super.key});

  @override
  State<NoticeManagePage> createState() => _NoticeManagePageState();
}

class _NoticeManagePageState extends State<NoticeManagePage> {
  List<Map<String, dynamic>> _notices = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  // Load all notices from Supabase (newest first)
  Future<void> _loadNotices() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final rows = await Supabase.instance.client
          .from('notices')
          .select()
          .order('created_at', ascending: false);
      if (!mounted) return;
      setState(() {
        _notices = List<Map<String, dynamic>>.from(rows as List);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // ---- Show dialog to create or edit a notice ----
  Future<void> _showNoticeDialog({Map<String, dynamic>? existing}) async {
    final titleCtrl = TextEditingController(
      text: existing?['title'] as String? ?? '',
    );
    final bodyCtrl = TextEditingController(
      text: existing?['body'] as String? ?? '',
    );
    final linkCtrl = TextEditingController(
      text: existing?['link'] as String? ?? '',
    );
    final locationCtrl = TextEditingController(
      text: existing?['location'] as String? ?? '',
    );
    final dateCtrl = TextEditingController(
      text: existing?['notice_date'] as String? ?? '',
    );
    final timeCtrl = TextEditingController(
      text: existing?['notice_time'] as String? ?? '',
    );

    // audience: 'club' or 'member'
    String audience = existing?['audience'] as String? ?? 'club';
    // notice type
    String noticeType = existing?['notice_type'] as String? ?? 'general';

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (stfCtx, setDialogState) {
            return AlertDialog(
              title: Text(existing == null ? 'New Notice' : 'Edit Notice'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------- Notice Type Dropdown ----------
                    const Text(
                      'Notice Type',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: noticeType,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      items: noticeTypes.map((t) {
                        return DropdownMenuItem(
                          value: t.value,
                          child: Row(
                            children: [
                              Icon(t.icon, size: 18, color: t.color),
                              const SizedBox(width: 8),
                              Text(t.label),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => noticeType = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    // ---------- Title ----------
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'Notice title',
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ---------- Description ----------
                    TextField(
                      controller: bodyCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Write the notice details here...',
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ---------- Location (optional) ----------
                    TextField(
                      controller: locationCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Location (optional)',
                        hintText: 'e.g. Room 201, Main Hall, Online...',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ---------- Link (optional) ----------
                    TextField(
                      controller: linkCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Link (optional)',
                        hintText: 'Google Meet / Zoom / Facebook post link...',
                        prefixIcon: Icon(Icons.link),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ---------- Date (optional) ----------
                    TextField(
                      controller: dateCtrl,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Date (optional)',
                        hintText: 'Pick a date...',
                        prefixIcon: const Icon(Icons.calendar_today),
                        suffixIcon: dateCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  setDialogState(() => dateCtrl.clear());
                                },
                              )
                            : null,
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: dialogCtx,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            dateCtrl.text =
                                '${picked.day}/${picked.month}/${picked.year}';
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),

                    // ---------- Time (optional) ----------
                    TextField(
                      controller: timeCtrl,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Time (optional)',
                        hintText: 'Pick a time...',
                        prefixIcon: const Icon(Icons.access_time),
                        suffixIcon: timeCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  setDialogState(() => timeCtrl.clear());
                                },
                              )
                            : null,
                      ),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: dialogCtx,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            timeCtrl.text = picked.format(context);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    // ---------- Audience toggle ----------
                    Row(
                      children: [
                        const Text(
                          'Audience: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Club'),
                          selected: audience == 'club',
                          selectedColor: Colors.blue.shade200,
                          onSelected: (_) {
                            setDialogState(() => audience = 'club');
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Member'),
                          selected: audience == 'member',
                          selectedColor: Colors.green.shade200,
                          onSelected: (_) {
                            setDialogState(() => audience = 'member');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogCtx, true),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    // Capture values before disposing
    final title = titleCtrl.text.trim();
    final body = bodyCtrl.text.trim();
    final link = linkCtrl.text.trim();
    final location = locationCtrl.text.trim();
    final noticeDate = dateCtrl.text.trim();
    final noticeTime = timeCtrl.text.trim();

    titleCtrl.dispose();
    bodyCtrl.dispose();
    linkCtrl.dispose();
    locationCtrl.dispose();
    dateCtrl.dispose();
    timeCtrl.dispose();

    if (saved != true) return;

    // Validate
    if (title.isEmpty || body.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Title and description are required.')),
        );
      }
      return;
    }

    final data = {
      'title': title,
      'body': body,
      'link': link.isNotEmpty ? link : null,
      'location': location.isNotEmpty ? location : null,
      'audience': audience,
      'notice_type': noticeType,
      'notice_date': noticeDate.isNotEmpty ? noticeDate : null,
      'notice_time': noticeTime.isNotEmpty ? noticeTime : null,
    };

    try {
      if (existing == null) {
        await Supabase.instance.client.from('notices').insert(data);
      } else {
        final id = existing['id'] as String;
        await Supabase.instance.client
            .from('notices')
            .update(data)
            .eq('id', id);
      }
      await _loadNotices();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  // ---- Delete a notice ----
  Future<void> _deleteNotice(Map<String, dynamic> notice) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Notice?'),
        content: Text('Remove "${notice['title']}"?'),
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

    if (confirm != true) return;

    try {
      await Supabase.instance.client
          .from('notices')
          .delete()
          .eq('id', notice['id'] as String);
      await _loadNotices();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  // ======================== BUILD ========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Notices',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 30, 111, 168),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoticeDialog(),
        backgroundColor: const Color.fromARGB(255, 30, 111, 168),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notices.isEmpty
          ? const Center(
              child: Text(
                'No notices yet.\nTap + to add one.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _notices.length,
              itemBuilder: (context, index) {
                final notice = _notices[index];
                return _noticeCard(notice);
              },
            ),
    );
  }

  // ======================== Notice Card ========================
  Widget _noticeCard(Map<String, dynamic> notice) {
    final title = notice['title'] as String? ?? '';
    final body = notice['body'] as String? ?? '';
    final link = notice['link'] as String? ?? '';
    final location = notice['location'] as String? ?? '';
    final audience = notice['audience'] as String? ?? 'club';
    final createdAt = notice['created_at'] as String? ?? '';
    // Get notice type info
    final nType = getNoticeType(notice['notice_type'] as String?);

    // Format date
    String dateText = '';
    if (createdAt.isNotEmpty) {
      final dt = DateTime.tryParse(createdAt);
      if (dt != null) {
        final local = dt.toLocal();
        dateText =
            '${local.day}/${local.month}/${local.year}  ${local.hour}:${local.minute.toString().padLeft(2, '0')}';
      }
    }

    final isClub = audience == 'club';
    final audColor = isClub ? Colors.blue : Colors.green;
    final audText = isClub ? 'CLUB' : 'MEMBER';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row: notice type tag + audience tag + actions
            Row(
              children: [
                // Notice type tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: nType.color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(nType.icon, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        nType.label.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                // Audience tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: audColor.withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: audColor, width: 1),
                  ),
                  child: Text(
                    audText,
                    style: TextStyle(
                      color: audColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _showNoticeDialog(existing: notice),
                  icon: const Icon(Icons.edit, size: 20),
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: () => _deleteNotice(notice),
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  tooltip: 'Delete',
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Title
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),

            // Body
            Text(
              body,
              style: const TextStyle(color: Color.fromARGB(137, 0, 0, 0)),
            ),

            // Location
            if (location.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      location,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Link
            if (link.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.link, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      link,
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            // Date
            if (dateText.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.black45,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateText,
                    style: const TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
