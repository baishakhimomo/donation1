import 'package:donation_app/after_join_event.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ============ ICON MAPPING ============
// Convert IconData to string (to save in Supabase)
String iconToKey(IconData icon) {
  if (icon == Icons.food_bank) return 'food_bank';
  if (icon == Icons.checkroom) return 'checkroom';
  if (icon == Icons.monetization_on) return 'monetization_on';
  if (icon == Icons.bloodtype) return 'bloodtype';
  if (icon == Icons.storefront) return 'storefront';
  if (icon == Icons.set_meal) return 'set_meal';
  if (icon == Icons.restaurant) return 'restaurant';
  if (icon == Icons.palette) return 'palette';
  return 'event';
}

// Convert string back to IconData (when reading from Supabase)
IconData keyToIcon(String key) {
  if (key == 'food_bank') return Icons.food_bank;
  if (key == 'checkroom') return Icons.checkroom;
  if (key == 'monetization_on') return Icons.monetization_on;
  if (key == 'bloodtype') return Icons.bloodtype;
  if (key == 'storefront') return Icons.storefront;
  if (key == 'set_meal') return Icons.set_meal;
  if (key == 'restaurant') return Icons.restaurant;
  if (key == 'palette') return Icons.palette;
  return Icons.event;
}

// ============ DATE HELPERS ============
final _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

// "2026-03-10" → "Mar 10, 2026"
String formatDate(String isoDate) {
  final parts = isoDate.split('-');
  if (parts.length != 3) return isoDate;
  final year = parts[0];
  final month = int.tryParse(parts[1]) ?? 1;
  final day = int.tryParse(parts[2]) ?? 1;
  return '${_months[month - 1]} $day, $year';
}

// "Mar 10, 2026" → "2026-03-10"
String toIsoDate(String displayDate) {
  final clean = displayDate.replaceAll(',', '').split(' ');
  if (clean.length != 3) return displayDate;
  final month = _months.indexOf(clean[0]) + 1;
  if (month == 0) return displayDate;
  final day = clean[1].padLeft(2, '0');
  final year = clean[2];
  return '$year-${month.toString().padLeft(2, '0')}-$day';
}

// ============ ACTION TEMPLATES (shared) ============
final List<Map<String, dynamic>> actionTemplates = [
  {
    'key': 'Donate Food',
    'title': 'Donate Food',
    'subtitle': 'Contribute fresh meals for iftar.',
    'icon': Icons.restaurant,
    'color': const Color.fromARGB(255, 113, 160, 118),
  },
  {
    'key': 'Donate Clothes',
    'title': 'Donate Clothes',
    'subtitle': 'Support with clothes for those in need.',
    'icon': Icons.checkroom,
    'color': const Color.fromARGB(255, 144, 202, 249),
  },
  {
    'key': 'Donate Money',
    'title': 'Donate Money',
    'subtitle': 'Make a monetary donation to support the event.',
    'icon': Icons.monetization_on,
    'color': const Color.fromARGB(255, 113, 160, 118),
  },
  {
    'key': 'Pay Registration Fee',
    'title': 'Pay Registration Fee',
    'subtitle': 'Registration fee will be applied.',
    'icon': Icons.palette,
    'color': const Color.fromARGB(255, 195, 150, 70),
  },
];

// ============ CONVERT SUPABASE ROW → FLUTTER MAP ============
Map<String, dynamic> rowToEvent(Map<String, dynamic> row) {
  // Build actions list from jsonb stored in Supabase
  final List<dynamic> stored = row['actions'] ?? [];
  final List<Map<String, dynamic>> actions = [];

  for (final item in stored) {
    if (item is Map) {
      final String key = (item['key'] ?? '') as String;
      final String customSub = (item['subtitle'] ?? '') as String;

      // Find matching template
      Map<String, dynamic> tmpl = {};
      for (final t in actionTemplates) {
        if (t['key'] == key) {
          tmpl = t;
          break;
        }
      }

      if (tmpl.isNotEmpty) {
        actions.add({
          'title': tmpl['title'],
          'subtitle': customSub.isNotEmpty ? customSub : tmpl['subtitle'],
          'icon': tmpl['icon'],
          'color': tmpl['color'],
        });
      }
    }
  }

  // Convert color int back to Color
  final int colorVal = (row['card_color'] as num?)?.toInt() ?? 0xFF71A076;
  final Color color = Color(colorVal);

  return {
    'id': row['id'],
    'title': row['title'] ?? '',
    'date': formatDate(row['event_date'] ?? ''),
    'timeDisplay': row['event_time'] ?? '',
    'location': row['location'] ?? '',
    'description': row['description'] ?? '',
    'notice': row['notice_text'] ?? '',
    'status': (row['is_active'] == true) ? 'Active' : 'Closed',
    'icon': keyToIcon((row['icon_key'] ?? 'event') as String),
    'cardColor': color,
    'iconColor': color,
    'actions': actions,
  };
}

// ============ FETCH FUNCTIONS (used by Home, Notice, About) ============

// Fetch only active events (public — works without login)
Future<List<Map<String, dynamic>>> fetchActiveEvents() async {
  final data = await Supabase.instance.client
      .from('events')
      .select()
      .eq('is_active', true)
      .order('created_at', ascending: false);

  return data.map<Map<String, dynamic>>((row) => rowToEvent(row)).toList();
}

// Fetch all events (admin sees active + closed)
Future<List<Map<String, dynamic>>> fetchAllEvents() async {
  final data = await Supabase.instance.client
      .from('events')
      .select()
      .order('created_at', ascending: false);

  return data.map<Map<String, dynamic>>((row) => rowToEvent(row)).toList();
}

class EventManagementPage extends StatefulWidget {
  const EventManagementPage({super.key});

  @override
  State<EventManagementPage> createState() => _EventManagementPageState();
}

class _EventManagementPageState extends State<EventManagementPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _noticeController = TextEditingController();
  final TextEditingController _feeController = TextEditingController();

  String _status = 'Active';
  IconData _selectedIcon = Icons.event;
  Color _selectedColor = const Color.fromARGB(255, 113, 160, 118);

  // Events loaded from Supabase
  List<Map<String, dynamic>> _events = [];
  bool _loading = true;

  final List<Map<String, dynamic>> _iconOptions = [
    {'label': 'Food', 'icon': Icons.food_bank},
    {'label': 'Clothes', 'icon': Icons.checkroom},
    {'label': 'Money', 'icon': Icons.monetization_on},
    {'label': 'Blood', 'icon': Icons.bloodtype},
    {'label': 'Event', 'icon': Icons.event},
    {'label': 'Stall', 'icon': Icons.storefront},
  ];

  final List<Map<String, dynamic>> _colorOptions = [
    {'label': 'Green', 'color': const Color.fromARGB(255, 113, 160, 118)},
    {'label': 'Purple', 'color': const Color.fromARGB(255, 164, 73, 160)},
    {'label': 'Red', 'color': const Color.fromARGB(255, 224, 79, 69)},
    {'label': 'Blue', 'color': const Color.fromARGB(255, 144, 202, 249)},
    {'label': 'Orange', 'color': const Color.fromARGB(255, 248, 165, 140)},
    {'label': 'Gray', 'color': const Color.fromARGB(255, 144, 164, 174)},
  ];

  static const Map<String, bool> _initialActionStates = {
    'Donate Food': false,
    'Donate Clothes': false,
    'Donate Money': true,
    'Pay Registration Fee': false,
  };

  final Map<String, bool> _actionEnabled = Map.from(_initialActionStates);

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    _dateController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _noticeController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  // Load all events from Supabase
  Future<void> _loadEvents() async {
    setState(() => _loading = true);
    try {
      final events = await fetchAllEvents();
      setState(() {
        _events = events;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading: $e')));
      }
    }
  }

  // Save event to Supabase
  Future<void> _saveEvent() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a title.')));
      return;
    }

    // Build actions list for Supabase jsonb
    final List<Map<String, dynamic>> actions = [];
    for (final template in actionTemplates) {
      final String key = template['key'] as String;
      if (_actionEnabled[key] != true) continue;

      String subtitle = template['subtitle'] as String;
      if (key == 'Pay Registration Fee' &&
          _feeController.text.trim().isNotEmpty) {
        subtitle = 'Registration fee - ${_feeController.text.trim()}';
      }
      actions.add({'key': key, 'subtitle': subtitle});
    }

    try {
      // Insert into Supabase
      final row = await Supabase.instance.client
          .from('events')
          .insert({
            'title': _titleController.text.trim(),
            'event_date': toIsoDate(_dateController.text.trim()),
            'event_time': _timeController.text.trim(),
            'location': _locationController.text.trim(),
            'description': _descriptionController.text.trim(),
            'notice_text': _noticeController.text.trim(),
            'card_color': _selectedColor.value,
            'icon_key': iconToKey(_selectedIcon),
            'actions': actions,
            'is_active': _status == 'Active',
          })
          .select()
          .single();

      final newEvent = rowToEvent(row);

      _clearForm();
      await _loadEvents();

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AfterJoinEventPage(
              event: newEvent,
              onEventUpdated: (updatedEvent) {
                _loadEvents();
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving: $e')));
      }
    }
  }

  void _clearForm() {
    _titleController.clear();
    _timeController.clear();
    _dateController.clear();
    _locationController.clear();
    _descriptionController.clear();
    _noticeController.clear();
    _feeController.clear();
    _status = 'Active';
    _selectedIcon = Icons.event;
    _selectedColor = const Color.fromARGB(255, 113, 160, 118);
    _actionEnabled.updateAll(
      (key, value) => _initialActionStates[key] ?? false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Management')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Event Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Event Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<IconData>(
              value: _selectedIcon,
              decoration: const InputDecoration(
                labelText: 'Card Icon',
                border: OutlineInputBorder(),
              ),
              items: _iconOptions.map((option) {
                return DropdownMenuItem<IconData>(
                  value: option['icon'] as IconData,
                  child: Row(
                    children: [
                      Icon(option['icon'] as IconData),
                      const SizedBox(width: 8),
                      Text(option['label'] as String),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _selectedIcon = value;
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Color>(
              value: _selectedColor,
              decoration: const InputDecoration(
                labelText: 'Card Color',
                border: OutlineInputBorder(),
              ),
              items: _colorOptions.map((option) {
                return DropdownMenuItem<Color>(
                  value: option['color'] as Color,
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: option['color'] as Color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(option['label'] as String),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _selectedColor = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Event Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Event Date',
                hintText: 'Tap to pick a date',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  final months = [
                    'Jan',
                    'Feb',
                    'Mar',
                    'Apr',
                    'May',
                    'Jun',
                    'Jul',
                    'Aug',
                    'Sep',
                    'Oct',
                    'Nov',
                    'Dec',
                  ];
                  _dateController.text =
                      '${months[picked.month - 1]} ${picked.day}, ${picked.year}';
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _timeController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Event Time',
                hintText: 'Tap to pick a time',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.access_time),
              ),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  final hour = picked.hourOfPeriod == 0
                      ? 12
                      : picked.hourOfPeriod;
                  final minute = picked.minute.toString().padLeft(2, '0');
                  final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
                  _timeController.text = '$hour:$minute $period';
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Event Location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Event Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Active', child: Text('Active')),
                DropdownMenuItem(value: 'Closed', child: Text('Closed')),
              ],
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _status = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Notice',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noticeController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Write notice for this event',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Allowed Actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...actionTemplates.map((template) {
              final String key = template['key'] as String;
              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(template['title'] as String),
                value: _actionEnabled[key] ?? false,
                onChanged: (value) {
                  setState(() {
                    _actionEnabled[key] = value ?? false;
                  });
                },
              );
            }),
            if (_actionEnabled['Pay Registration Fee'] == true)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: _feeController,
                  decoration: const InputDecoration(
                    labelText: 'Registration Fee (example: 100 BDT)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveEvent,
                    child: const Text('Save Event'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Created Events',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Show loading or event list from Supabase
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_events.isEmpty)
              const Text(
                'No events created yet.',
                style: TextStyle(color: Colors.black54),
              )
            else
              ..._events.map((event) {
                final Color badgeColor =
                    event['cardColor'] as Color? ?? Colors.green;
                final String status = event['status'] as String? ?? 'Active';
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
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
                      CircleAvatar(
                        backgroundColor: badgeColor,
                        child: Icon(
                          event['icon'] as IconData? ?? Icons.event,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event['title'] as String? ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              status,
                              style: TextStyle(
                                color: status == 'Active'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AfterJoinEventPage(
                                event: event,
                                onEventUpdated: (updatedEvent) {
                                  _loadEvents();
                                },
                              ),
                            ),
                          );
                        },
                        child: const Text('Preview'),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
