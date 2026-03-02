import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NoticeType {
  final String value;
  final String label;
  final Color color;
  final IconData icon;
  const NoticeType(this.value, this.label, this.color, this.icon);
}

const List<NoticeType> noticeTypes = [
  NoticeType('meeting', 'Meeting', Colors.indigo, Icons.groups),
  NoticeType('blood_urgent', 'Blood Urgent', Colors.red, Icons.bloodtype),
  NoticeType('announcement', 'Announcement', Colors.deepPurple, Icons.campaign),
  NoticeType('general', 'General', Colors.blueGrey, Icons.info),
];

NoticeType getNoticeType(String? value) {
  return noticeTypes.firstWhere(
    (t) => t.value == value,
    orElse: () => noticeTypes.last,
  );
}

class NoticeManagePage extends StatefulWidget {
  const NoticeManagePage({super.key});

  @override
  State<NoticeManagePage> createState() => _NoticeManagePageState();
}

class _NoticeFormData {
  final String title;
  final String body;
  final String link;
  final String location;
  final String noticeDate;
  final String noticeTime;
  final String audience;
  final String noticeType;

  const _NoticeFormData({
    required this.title,
    required this.body,
    required this.link,
    required this.location,
    required this.noticeDate,
    required this.noticeTime,
    required this.audience,
    required this.noticeType,
  });
}

class _NoticeDialog extends StatefulWidget {
  final Map<String, dynamic>? existing;

  const _NoticeDialog({this.existing});

  @override
  State<_NoticeDialog> createState() => _NoticeDialogState();
}

class _NoticeDialogState extends State<_NoticeDialog> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;
  late final TextEditingController _linkCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _dateCtrl;
  late final TextEditingController _timeCtrl;

  late String _audience;
  late String _noticeType;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(
      text: widget.existing?['title']?.toString() ?? '',
    );
    _bodyCtrl = TextEditingController(
      text: widget.existing?['body']?.toString() ?? '',
    );
    _linkCtrl = TextEditingController(
      text: widget.existing?['link']?.toString() ?? '',
    );
    _locationCtrl = TextEditingController(
      text: widget.existing?['location']?.toString() ?? '',
    );
    _dateCtrl = TextEditingController(
      text: widget.existing?['notice_date']?.toString() ?? '',
    );
    _timeCtrl = TextEditingController(
      text: widget.existing?['notice_time']?.toString() ?? '',
    );

    _audience = widget.existing?['audience']?.toString() ?? 'club';
    _noticeType = widget.existing?['notice_type']?.toString() ?? 'general';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _linkCtrl.dispose();
    _locationCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Text(widget.existing == null ? 'New Notice' : 'Edit Notice'),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: size.width * 0.9,
          maxHeight: size.height * 0.7,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notice Type',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _noticeType,
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
                  if (val != null) {
                    setState(() => _noticeType = val);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Notice title',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _bodyCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Write the notice details here...',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _locationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Location (optional)',
                  hintText: 'e.g. Room 201, Main Hall, Online...',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _linkCtrl,
                decoration: const InputDecoration(
                  labelText: 'Link (optional)',
                  hintText: 'Google Meet / Zoom / Facebook post link...',
                  prefixIcon: Icon(Icons.link),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _dateCtrl,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date (optional)',
                  hintText: 'Pick a date...',
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: _dateCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            setState(() => _dateCtrl.clear());
                          },
                        )
                      : null,
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null && mounted) {
                    setState(() {
                      _dateCtrl.text =
                          '${picked.day}/${picked.month}/${picked.year}';
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _timeCtrl,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Time (optional)',
                  hintText: 'Pick a time...',
                  prefixIcon: const Icon(Icons.access_time),
                  suffixIcon: _timeCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            setState(() => _timeCtrl.clear());
                          },
                        )
                      : null,
                ),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null && mounted) {
                    setState(() {
                      _timeCtrl.text = picked.format(context);
                    });
                  }
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Text(
                    'Audience: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Club'),
                    selected: _audience == 'club',
                    selectedColor: Colors.blue.shade200,
                    onSelected: (_) {
                      setState(() => _audience = 'club');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Member'),
                    selected: _audience == 'member',
                    selectedColor: Colors.green.shade200,
                    onSelected: (_) {
                      setState(() => _audience = 'member');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(
              context,
              _NoticeFormData(
                title: _titleCtrl.text,
                body: _bodyCtrl.text,
                link: _linkCtrl.text,
                location: _locationCtrl.text,
                noticeDate: _dateCtrl.text,
                noticeTime: _timeCtrl.text,
                audience: _audience,
                noticeType: _noticeType,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _NoticeManagePageState extends State<NoticeManagePage> {
  List<Map<String, dynamic>> _notices = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

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

  Future<void> _showNoticeDialog({Map<String, dynamic>? existing}) async {
    final result = await showDialog<_NoticeFormData>(
      context: context,
      builder: (dialogCtx) => _NoticeDialog(existing: existing),
    );

    if (!mounted || result == null) return;

    final title = result.title.trim();
    final body = result.body.trim();
    final link = result.link.trim();
    final location = result.location.trim();
    final noticeDate = result.noticeDate.trim();
    final noticeTime = result.noticeTime.trim();
    final audience = result.audience;
    final noticeType = result.noticeType;

    if (title.isEmpty || body.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and description are required.')),
      );
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
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

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
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

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
              itemBuilder: (_, i) {
                final n = _notices[i];
                final type = getNoticeType(n['notice_type']?.toString());
                final title = n['title']?.toString() ?? '';
                final body = n['body']?.toString() ?? '';
                final audience = n['audience']?.toString() ?? 'club';
                final date = n['notice_date']?.toString() ?? '';
                final time = n['notice_time']?.toString() ?? '';
                final location = n['location']?.toString() ?? '';
                final link = n['link']?.toString() ?? '';

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(type.icon, color: type.color),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Edit',
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showNoticeDialog(existing: n),
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteNotice(n),
                            ),
                          ],
                        ),
                        if (body.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(body),
                        ],
                        const SizedBox(height: 6),
                        Text('Audience: $audience'),
                        if (date.isNotEmpty || time.isNotEmpty)
                          Text('Time: $date $time'),
                        if (location.isNotEmpty) Text('Location: $location'),
                        if (link.isNotEmpty) Text('Link: $link'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
