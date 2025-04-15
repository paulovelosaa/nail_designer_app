import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    print('👤 UID logado: $userId');

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day); // 00:00h

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Meus Agendamentos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('userId', isEqualTo: userId)
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
            .orderBy('date')
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
                  Icon(Icons.calendar_month_rounded, color: Color(0xFFE91E63), size: 48),
                  SizedBox(height: 12),
                  Text('Nenhum agendamento encontrado', style: TextStyle(color: Colors.black54)),
                  SizedBox(height: 4),
                  Text('A lista de D+0 em diante será exibida aqui.', style: TextStyle(color: Colors.black38)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final id = docs[index].id;

              final String service = data['serviceName'] ?? 'Serviço';
              final String hora = data['hour'] ?? '--:--';
              final String status = (data['status'] ?? 'PENDENTE').toUpperCase();

              final Timestamp ts = data['date'] ?? Timestamp.now();
              final DateTime date = ts.toDate();
              final formattedDate = DateFormat('dd/MM/yyyy').format(date);
              final dataHora = DateFormat('yyyy-MM-dd HH:mm').parse(
                '${DateFormat('yyyy-MM-dd').format(date)} $hora',
              );

              final podeCancelar = dataHora.isAfter(DateTime.now().add(const Duration(hours: 24)));

              Color statusColor;
              IconData statusIcon;

              switch (status) {
                case 'CANCELADO':
                  statusColor = Colors.red;
                  statusIcon = Icons.cancel;
                  break;
                case 'APROVADO':
                case 'CONFIRMADO':
                  statusColor = Colors.green;
                  statusIcon = Icons.check_circle;
                  break;
                default:
                  statusColor = Colors.orange;
                  statusIcon = Icons.hourglass_bottom;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, color: Color(0xFFE91E63)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            service,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 20, color: Colors.black54),
                        const SizedBox(width: 6),
                        Text('$formattedDate às $hora',
                            style: const TextStyle(fontSize: 14, color: Colors.black87)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text(
                          'Status: ',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                        ),
                        Icon(statusIcon, size: 18, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                    if (podeCancelar)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _confirmarCancelamento(context, id),
                          icon: const Icon(Icons.cancel_rounded, color: Colors.redAccent),
                          label: const Text(
                            "Cancelar",
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmarCancelamento(BuildContext context, String appointmentId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar agendamento?'),
        content: const Text('Tem certeza que deseja cancelar este agendamento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Voltar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await FirebaseFirestore.instance
                  .collection('appointments')
                  .doc(appointmentId)
                  .update({'status': 'CANCELADO'});
            },
            child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
