import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DeliverySlotPicker extends StatefulWidget {
  final Function(DateTime, String) onSlotSelected;
  const DeliverySlotPicker({super.key, required this.onSlotSelected});

  @override
  State<DeliverySlotPicker> createState() => _DeliverySlotPickerState();
}

class _DeliverySlotPickerState extends State<DeliverySlotPicker> {
  int      _selectedDay  = 0;
  String?  _selectedSlot;
  String   _deliveryMode = 'express';

  final List<Map<String, dynamic>> _timeSlots = [
    {'label':'8 AM - 10 AM',   'start':8,  'end':10},
    {'label':'10 AM - 12 PM',  'start':10, 'end':12},
    {'label':'12 PM - 2 PM',   'start':12, 'end':14},
    {'label':'2 PM - 4 PM',    'start':14, 'end':16},
    {'label':'4 PM - 6 PM',    'start':16, 'end':18},
    {'label':'6 PM - 8 PM',    'start':18, 'end':20},
    {'label':'8 PM - 10 PM',   'start':20, 'end':22},
  ];

  List<DateTime> get _availableDays {
    return List.generate(7, (i) => DateTime.now().add(Duration(days: i)));
  }

  bool _isSlotAvailable(int hour, int dayIndex) {
    if (dayIndex == 0) {
      final now = DateTime.now();
      return hour > now.hour + 1;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize:       MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('⏰ Delivery Schedule',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Delivery Mode
            const Text('Delivery Type',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _modeCard(
                    'express',
                    Icons.flash_on,
                    'Express',
                    '30-45 mins',
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _modeCard(
                    'schedule',
                    Icons.schedule,
                    'Schedule',
                    'Pick time',
                    Colors.blue,
                  ),
                ),
              ],
            ),

            if (_deliveryMode == 'schedule') ...[
              const SizedBox(height: 20),
              const Text('Select Date',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 10),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableDays.length,
                  itemBuilder: (context, index) {
                    final date       = _availableDays[index];
                    final isSelected = _selectedDay == index;
                    final isToday    = index == 0;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _selectedDay  = index;
                        _selectedSlot = null;
                      }),
                      child: Container(
                        width:  70,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color:        isSelected ? Colors.green : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.green : Colors.grey.shade300,
                            width: 2),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(isToday ? 'Today' : DateFormat('EEE').format(date),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(DateFormat('d').format(date),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                            Text(DateFormat('MMM').format(date),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey.shade600,
                                fontSize: 11)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text('Select Time Slot',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _timeSlots.map((slot) {
                  final available  = _isSlotAvailable(slot['start'], _selectedDay);
                  final isSelected = _selectedSlot == slot['label'];

                  return GestureDetector(
                    onTap: available
                        ? () => setState(() => _selectedSlot = slot['label'])
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: !available
                            ? Colors.grey.shade100
                            : isSelected
                                ? Colors.green
                                : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: !available
                              ? Colors.grey.shade300
                              : Colors.green,
                          width: isSelected ? 2 : 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            !available
                                ? Icons.block
                                : isSelected
                                    ? Icons.check_circle
                                    : Icons.access_time,
                            size:  16,
                            color: !available
                                ? Colors.grey
                                : isSelected
                                    ? Colors.white
                                    : Colors.green),
                          const SizedBox(width: 6),
                          Text(slot['label'],
                            style: TextStyle(
                              color: !available
                                  ? Colors.grey
                                  : isSelected
                                      ? Colors.white
                                      : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 20),

            // Selected Info Box
            if (_deliveryMode == 'express')
              Container(
                width:   double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.flash_on, color: Colors.orange, size: 30),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Express Delivery',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:   16,
                              color: Colors.orange)),
                          Text('We will deliver in 30-45 minutes',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else if (_selectedSlot != null)
              Container(
                width:   double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, color: Colors.blue, size: 30),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Scheduled Delivery',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:   16,
                              color: Colors.blue)),
                          Text(
                            '${DateFormat('EEE, MMM d').format(_availableDays[_selectedDay])} • $_selectedSlot',
                            style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),
            SizedBox(
              width:  double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle),
                label: const Text('Confirm Delivery Time',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: () {
                  if (_deliveryMode == 'express') {
                    widget.onSlotSelected(
                      DateTime.now().add(const Duration(minutes: 45)),
                      'Express (30-45 mins)',
                    );
                    Navigator.pop(context);
                  } else if (_selectedSlot != null) {
                    widget.onSlotSelected(
                      _availableDays[_selectedDay],
                      _selectedSlot!,
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Select a time slot'),
                        backgroundColor: Colors.red));
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _modeCard(String value, IconData icon, String title, String subtitle, Color color) {
    final isSelected = _deliveryMode == value;
    return GestureDetector(
      onTap: () => setState(() {
        _deliveryMode = value;
        _selectedSlot = null;
      }),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14)),
            Text(subtitle,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
