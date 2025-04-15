import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ScheduleAppointmentScreen extends StatefulWidget {
  const ScheduleAppointmentScreen({super.key});

  @override
  State<ScheduleAppointmentScreen> createState() => _ScheduleAppointmentScreenState();
}

class _ScheduleAppointmentScreenState extends State<ScheduleAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();

  String? selectedServiceId, selectedServiceLabel, selectedHour;
  DateTime? selectedDate;

  List<Map<String, dynamic>> services = [];
  List<String> availableHours = [];

  bool isLoading = false;

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final TextEditingController _dataController = TextEditingController();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadServices();
  }

  @override
  void dispose() {
    _dataController.dispose();
    nomeController.dispose();
    telefoneController.dispose();
    emailController.dispose();
    instagramController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final uid = _auth.currentUser?.uid;
      print("📌 UID logado: $uid");
      if (uid == null) return;

      final doc = await _firestore.collection('users').doc(uid).get();
      final data = doc.data();
      print("📄 Dados do usuário retornados: $data");

      if (data != null && mounted) {
        setState(() {
          nomeController.text = data['nome'] ?? '';
          telefoneController.text = data['telefone'] ?? '';
          emailController.text = data['email'] ?? '';
          instagramController.text = data['instagram'] ?? '';
        });
      }
    } catch (e) {
      print("❌ Erro ao carregar usuário: $e");
    }
  }

  Future<void> _loadServices() async {
    try {
      final snapshot = await _firestore.collection('services').get();
      final data = snapshot.docs.map((doc) {
        final d = doc.data();
        return {
          'id': doc.id,
          'label': '${d['nome']} - R\$${d['valor']}',
          'nome': d['nome'],
          'valor': d['valor'],
        };
      }).toList();

      if (mounted) {
        setState(() {
          services = data;
        });
      }
    } catch (e) {
      print("❌ Erro ao carregar serviços: $e");
    }
  }

  Future<void> _loadAvailableHours() async {
    try {
      if (selectedDate == null) return;

      final selectedDay = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
      );

      final snapshot = await _firestore
          .collection('available_slots')
          .where('available', isEqualTo: true)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(selectedDay))
          .where('timestamp', isLessThan: Timestamp.fromDate(selectedDay.add(const Duration(days: 1))))
          .get();

      final hours = snapshot.docs.map((doc) => doc['hora'].toString()).toList();

      print("🕐 Horários disponíveis para $selectedDay: $hours");

      if (mounted) {
        setState(() {
          availableHours = hours;
          selectedHour = null;
        });
      }
    } catch (e) {
      print("❌ Erro ao carregar horários: $e");
    }
  }

  Future<void> _submitAppointment() async {
    if (!_formKey.currentState!.validate() ||
        selectedServiceId == null ||
        selectedDate == null ||
        selectedHour == null) return;

    setState(() => isLoading = true);
    _formKey.currentState!.save();

    await _firestore.collection('appointments').add({
      'userId': _auth.currentUser!.uid,
      'nome': nomeController.text,
      'telefone': telefoneController.text,
      'email': emailController.text,
      'instagram': instagramController.text,
      'serviceId': selectedServiceId,
      'serviceName': selectedServiceLabel,
      'date': Timestamp.fromDate(selectedDate!),
      'hour': selectedHour,
      'status': 'PENDENTE',
      'createdAt': Timestamp.now(),
    });

    setState(() => isLoading = false);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Agendamento Confirmado"),
        content: const Text("Seu horário foi agendado com sucesso!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text("Agendar Horário"),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: nomeController, readOnly: true, decoration: _inputDecoration("Nome")),
              const SizedBox(height: 12),
              TextFormField(controller: telefoneController, readOnly: true, decoration: _inputDecoration("Telefone")),
              const SizedBox(height: 12),
              TextFormField(controller: emailController, readOnly: true, decoration: _inputDecoration("E-mail")),
              const SizedBox(height: 12),
              TextFormField(controller: instagramController, readOnly: true, decoration: _inputDecoration("Instagram")),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: _inputDecoration("Serviço"),
                items: services.map<DropdownMenuItem<String>>((s) {
                  return DropdownMenuItem<String>(
                    value: s['id'] as String,
                    child: Text(s['label']),
                  );
                }).toList(),
                onChanged: (value) {
                  final selected = services.firstWhere((s) => s['id'] == value);
                  setState(() {
                    selectedServiceId = selected['id'] as String;
                    selectedServiceLabel = selected['label'] as String;
                  });
                },
                value: selectedServiceId,
                validator: (value) => value == null ? 'Selecione um serviço' : null,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                      _dataController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                    });
                    _loadAvailableHours();
                  }
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dataController,
                    decoration: _inputDecoration("Data do atendimento"),
                    validator: (_) => selectedDate == null ? 'Selecione uma data' : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: _inputDecoration("Horário disponível"),
                items: availableHours.map<DropdownMenuItem<String>>((hour) {
                  return DropdownMenuItem<String>(
                    value: hour,
                    child: Text(hour),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedHour = value),
                value: selectedHour,
                validator: (value) => value == null ? 'Selecione um horário' : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: isLoading ? null : _submitAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text("Agendar", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
