import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentEditModal extends StatefulWidget {
  final String appointmentId;
  final Map<String, dynamic> data;

  const AppointmentEditModal({
    super.key,
    required this.appointmentId,
    required this.data,
  });

  @override
  State<AppointmentEditModal> createState() => _AppointmentEditModalState();
}

class _AppointmentEditModalState extends State<AppointmentEditModal> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController instagramController;
  late TextEditingController serviceController;
  late TextEditingController dateController;

  String? selectedHour;
  List<String> availableHours = [];

  @override
  void initState() {
    super.initState();

    String formatDate(dynamic date) {
      if (date is Timestamp) {
        return DateFormat('dd/MM/yyyy').format(date.toDate());
      }
      return date?.toString() ?? '';
    }

    nameController = TextEditingController(text: widget.data['nome']);
    emailController = TextEditingController(text: widget.data['email']);
    phoneController = TextEditingController(text: widget.data['telefone']);
    instagramController = TextEditingController(text: widget.data['instagram']);
    serviceController = TextEditingController(text: widget.data['serviceName']);
    dateController = TextEditingController(text: formatDate(widget.data['date']));
    selectedHour = widget.data['hour'];
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
              'Editar Agendamento',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            _buildTextField(nameController, 'Nome'),
            _buildTextField(emailController, 'E-mail'),
            _buildTextField(phoneController, 'Telefone'),
            _buildTextField(instagramController, 'Instagram'),
            _buildTextField(serviceController, 'Serviço'),
            GestureDetector(
              onTap: _selectDate,
              child: AbsorbPointer(
                child: _buildTextField(dateController, 'Data do atendimento'),
              ),
            ),
            DropdownButtonFormField<String>(
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
              decoration: InputDecoration(
                labelText: 'Horário disponível',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  DateTime? parsedDate = DateFormat('dd/MM/yyyy').parse(dateController.text);
                  await FirebaseFirestore.instance
                      .collection('appointments')
                      .doc(widget.appointmentId)
                      .update({
                    'nome': nameController.text,
                    'email': emailController.text,
                    'telefone': phoneController.text,
                    'instagram': instagramController.text,
                    'serviceName': serviceController.text,
                    'date': Timestamp.fromDate(parsedDate),
                    'hour': selectedHour ?? '',
                  });

                  if (context.mounted) Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao salvar: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Salvar'),
            )
          ],
        ),
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
