import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeeklyAppointmentsScreen extends StatelessWidget {
  const WeeklyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda Semanal'),
        backgroundColor: const Color(0xFFF2F2F2),
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF2F2F2),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
            .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfWeek))
            .orderBy('createdAt')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 48, color: Colors.pink),
                  SizedBox(height: 12),
                  Text(
                    'Nenhum agendamento essa semana',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final status = data['status'] ?? 'PENDENTE';
              final statusColor = {
                'PENDENTE': Colors.orange,
                'CONFIRMADO': Colors.green,
                'CANCELADO': Colors.red,
              }[status.toUpperCase()] ?? Colors.black;

              final Timestamp? dateTimestamp = data['date'] is Timestamp
                  ? data['date']
                  : null;

              final formattedDate = dateTimestamp != null
                  ? DateFormat('dd/MM/yyyy').format(dateTimestamp.toDate())
                  : (data['date'] ?? '');

              final hour = data['hour'] ?? '';
              final service = data['serviceName'] ?? '';
              final name = data['nome'] ?? '';
              final phone = data['telefone'] ?? '';
              final instagram = data['instagram'] ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.pink, size: 18),
                          const SizedBox(width: 8),
                          Text('$formattedDate às $hour'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.person, color: Colors.pink, size: 18),
                          const SizedBox(width: 8),
                          Text(name),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.phone, color: Colors.pink, size: 18),
                          const SizedBox(width: 8),
                          Text(phone),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.camera_alt_outlined, color: Colors.pink, size: 18),
                          const SizedBox(width: 8),
                          Text('@$instagram'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('Status: ', style: TextStyle(fontWeight: FontWeight.w500)),
                          Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
