import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MassSlotGenerator {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> generateSlots() async {
    DateTime startDate = DateTime.now(); // Data de início (hoje)
    DateTime endDate = startDate.add(Duration(days: 365)); // Gerar slots para os próximos 365 dias (1 ano)
    int slotDuration = 30; // Duração dos slots em minutos

    // Loop pelos dias entre a data de início e a data final
    for (DateTime date = startDate; date.isBefore(endDate); date = date.add(Duration(days: 1))) {
      final dayOfWeek = date.weekday; // Segunda-feira = 1, ..., Sábado = 6

      // Define os horários para cada dia
      int startHour = (dayOfWeek == 6) ? 7 : 7; // Sábado começa às 7h, durante a semana também
      int endHour = (dayOfWeek == 6) ? 17 : 19; // Sábado vai até 17h, senão até 19h

      // Gerar slots de 30 minutos
      for (int hour = startHour; hour <= endHour; hour++) {
        for (int minute = 0; minute < 60; minute += slotDuration) {
          DateTime slotStartTime = DateTime(date.year, date.month, date.day, hour, minute);
          String slotId = _generateSlotId(slotStartTime);

          await _firestore.collection('available_slots').doc(slotId).set({
            'available': true,
            'data': DateFormat('yyyy-MM-dd').format(slotStartTime),
            'hora': DateFormat('HH:mm').format(slotStartTime),
            'id': slotId,
            'timestamp': Timestamp.fromDate(slotStartTime), // Usado para ordenação
          });
        }
      }
    }
  }

  // Função para gerar um ID único para cada slot
  String _generateSlotId(DateTime slotTime) {
    return 'slot_${slotTime.year}_${slotTime.month}_${slotTime.day}_${slotTime.hour}_${slotTime.minute}';
  }
}
