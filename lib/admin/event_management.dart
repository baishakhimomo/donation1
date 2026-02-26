import 'package:donation_app/after_join_event.dart';
import 'package:flutter/material.dart';

final List<Map<String, dynamic>> eventStore = [
  {
    'title': 'Iftar Sharing 2026',
    'timeDisplay': 'Jan 10 · 6:00 PM',
    'date': 'Jan 10, 2026',
    'location': 'New Hall, LU Campus',
    'description': 'Providing iftar meals to the needy during Ramadan.',
    'notice': 'New event created. Please check the details and join us!',
    'status': 'Active',
    'icon': Icons.food_bank,
    'cardColor': const Color.fromARGB(255, 113, 160, 118),
    'iconColor': const Color.fromARGB(255, 113, 160, 118),
    'actions': [
      {
        'title': 'Donate Food',
        'subtitle': 'Contribute fresh meals for iftar.',
        'icon': Icons.restaurant,
        'color': const Color.fromARGB(255, 113, 160, 118),
      },
      {
        'title': 'Donate Money',
        'subtitle': 'Make a monetary donation to support the event.',
        'icon': Icons.monetization_on,
        'color': const Color.fromARGB(255, 113, 160, 118),
      },
      {
        'title': 'Pay Registration Fee',
        'subtitle': 'Art Competition Entry - 100 BDT',
        'icon': Icons.palette,
        'color': const Color.fromARGB(255, 195, 150, 70),
      },
      {
        'title': 'Apply for Stall',
        'subtitle': 'Book a stall at our event.',
        'icon': Icons.storefront,
        'color': const Color.fromARGB(255, 140, 120, 200),
      },
    ],
  },
  {
    'title': 'Food Stalls',
    'timeDisplay': 'Feb 15 · 11:00 AM',
    'date': 'Feb 15, 2026',
    'location': 'Open Ground',
    'description': 'Local food stalls to support community funds.',
    'notice': 'Stall booking is open. Limited slots available.',
    'status': 'Active',
    'icon': Icons.set_meal,
    'cardColor': const Color.fromARGB(255, 113, 212, 116),
    'iconColor': const Color.fromARGB(255, 113, 212, 116),
    'actions': [
      {
        'title': 'Apply for Stall',
        'subtitle': 'Book a stall at our event.',
        'icon': Icons.storefront,
        'color': const Color.fromARGB(255, 113, 212, 116),
      },
    ],
  },
];

List<Map<String, dynamic>> getActiveEvents() {
  return eventStore.where((event) => event['status'] == 'Active').toList();
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
    'Donate Food': true,
    'Donate Clothes': false,
    'Donate Money': true,
    'Pay Registration Fee': false,
    'Apply for Stall': false,
  };

  final Map<String, bool> _actionEnabled = Map.from(_initialActionStates);

  final List<Map<String, dynamic>> _actionTemplates = [
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
    {
      'key': 'Apply for Stall',
      'title': 'Apply for Stall',
      'subtitle': 'Book a stall at our event.',
      'icon': Icons.storefront,
      'color': const Color.fromARGB(255, 140, 120, 200),
    },
  ];

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

  void _saveEvent() {
    final actions = _buildActions();

    final newEvent = {
      'title': _titleController.text.trim(),
      'timeDisplay': _timeController.text.trim(),
      'date': _dateController.text.trim(),
      'location': _locationController.text.trim(),
      'description': _descriptionController.text.trim(),
      'notice': _noticeController.text.trim(),
      'status': _status,
      'icon': _selectedIcon,
      'cardColor': _selectedColor,
      'iconColor': _selectedColor,
      'actions': actions,
    };

    setState(() {
      eventStore.insert(0, newEvent);
      _clearForm();
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AfterJoinEventPage(
          event: newEvent,
          onEventUpdated: (updatedEvent) {
            setState(() {});
          },
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _buildActions() {
    final List<Map<String, dynamic>> actions = [];

    for (final template in _actionTemplates) {
      final String key = template['key'] as String;
      final bool enabled = _actionEnabled[key] ?? false;

      if (!enabled) {
        continue;
      }

      String subtitle = template['subtitle'] as String;
      if (key == 'Pay Registration Fee' &&
          _feeController.text.trim().isNotEmpty) {
        subtitle = 'Registration fee - ${_feeController.text.trim()}';
      }

      actions.add({
        'title': template['title'],
        'subtitle': subtitle,
        'icon': template['icon'],
        'color': template['color'],
      });
    }

    return actions;
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
            ..._actionTemplates.map((template) {
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
            ...eventStore.map((event) {
              final Color badgeColor = event['cardColor'] as Color;
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
                        event['icon'] as IconData,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event['title'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            event['status'] as String,
                            style: const TextStyle(color: Colors.black54),
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
                                setState(() {});
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
