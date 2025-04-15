import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentCreateModal extends StatefulWidget {
  const AppointmentCreateModal({super.key});

  @override
  State<AppointmentCreateModal> createState() => _AppointmentCreateModalState();
}

class _AppointmentCreateModalState extends State<AppointmentCreateModal> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final instagramController = TextEditingController();
  final dateController = TextEditingController();

  String? selectedHour;
  List<String> availableHours = [];

  List<Map<String, dynamic>> services = [];
  Map<String, dynamic>? selectedService;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    instagramController.dispose();
    dateController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    final snapshot = await FirebaseFirestore.instance.collection('services').get();
    setState(() {
      services = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'nome': doc['nome'],
                'valor': doc['valor'],
              })
          .toList();
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        dateController.text = DateFormat('dd/MM/yyyy').format(picked);
        selectedHour = null;
        availableHours = [];
      });
      _loadAvailableHours(picked);
    }
  }

  Future<void> _loadAvailableHours(DateTime date) async {
    final formatted = DateFormat('yyyy-MM-dd').format(date);
    final snapshot = await FirebaseFirestore.instance
        .collection('available_slots')
        .where('data', isEqualTo: formatted)
        .where('available', isEqualTo: true)
        .orderBy('hora')
        .get();

    setState(() {
      availableHours = snapshot.docs.map((doc) => doc['hora'] as String).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFF2F2F2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Novo Agendamento',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            _buildTextField(nameController, 'Nome'),
            _buildTextField(emailController, 'E-mail'),
            _buildTextField(phoneController, 'Telefone'),
            _buildTextField(instagramController, 'Instagram'),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DropdownButtonFormField<Map<String, dynamic>>(
                isExpanded: true,
                value: selectedService,
                items: services.map((service) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: service,
                    child: Text('${service['nome']} - R\$${service['valor']}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedService = value;
                  });
                },
                decoration: _dropdownDecoration('Serviço'),
              ),
            ),
            GestureDetector(
              onTap: _selectDate,
              child: AbsorbPointer(
                child: _buildTextField(dateController, 'Data do atendimento'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: selectedHour,
                items: availableHours.map((hora) {
                  return DropdownMenuItem<String>(
                    value: hora,
                    child: Text(hora),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedHour = value;
                  });
                },
                decoration: _dropdownDecoration('Horário disponível'),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveAppointment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Salvar'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _saveAppointment() async {
    try {
      final parsedDate = DateFormat('dd/MM/yyyy').parse(dateController.text);
      final formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
      final slotId = 'slot_${parsedDate.year}_${parsedDate.month}_${parsedDate.day}_$selectedHour';

      if (selectedService == null || selectedHour == null) {
        throw Exception('Serviço e horário devem ser selecionados.');
      }

      await FirebaseFirestore.instance.collection('appointments').add({
        'nome': nameController.text,
        'email': emailController.text,
        'telefone': phoneController.text,
        'instagram': instagramController.text,
        'serviceId': selectedService!['id'],
        'serviceName': '${selectedService!['nome']} - R\$${selectedService!['valor']}',
        'date': Timestamp.fromDate(parsedDate),
        'hour': selectedHour,
        'status': 'CONFIRMADO',
        'createdAt': Timestamp.now(),
      });

      await FirebaseFirestore.instance.collection('available_slots').doc(slotId).update({
        'available': false,
      });

      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    }
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
