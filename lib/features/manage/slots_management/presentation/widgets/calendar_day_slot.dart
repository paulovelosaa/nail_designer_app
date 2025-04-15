import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CalendarDaySlot extends StatefulWidget {
  final String slotId;
  final String hora;
  final bool isAvailable;

  const CalendarDaySlot({
    super.key,
    required this.slotId,
    required this.hora,
    required this.isAvailable,
  });

  @override
  State<CalendarDaySlot> createState() => _CalendarDaySlotState();
}

class _CalendarDaySlotState extends State<CalendarDaySlot> {
  late bool available;

  @override
  void initState() {
    super.initState();
    available = widget.isAvailable;
  }

  void _toggleAvailability() async {
    setState(() => available = !available);

    await FirebaseFirestore.instance
        .collection('available_slots')
        .doc(widget.slotId)
        .update({'available': available});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          widget.hora,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          available ? 'Disponível' : 'Indisponível',
          style: TextStyle(
            fontSize: 14,
            color: available ? Colors.green : Colors.redAccent,
          ),
        ),
        trailing: Switch(
          activeColor: Colors.green,
          inactiveThumbColor: Colors.grey,
          value: available,
          onChanged: (_) => _toggleAvailability(),
        ),
      ),
    );
  }
}
