import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'widgets/calendar_day_slot.dart';

class SlotsManagementScreen extends StatefulWidget {
  const SlotsManagementScreen({super.key});

  @override
  State<SlotsManagementScreen> createState() => _SlotsManagementScreenState();
}

class _SlotsManagementScreenState extends State<SlotsManagementScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(selectedDate);
    final db = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Horários'),
        backgroundColor: const Color(0xFFFFF2F2),
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFFFF2F2),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null && picked != selectedDate) {
                  setState(() => selectedDate = picked);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Selecionar data ($formattedDate)',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: db
                  .collection('available_slots')
                  .where('data', isEqualTo: DateFormat('yyyy-MM-dd').format(selectedDate))
                  .orderBy('hora')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhum horário disponível para essa data.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    return CalendarDaySlot(
                      slotId: doc.id,
                      hora: doc['hora'],
                      isAvailable: doc['available'],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
