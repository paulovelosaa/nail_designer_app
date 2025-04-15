import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserCreateModal extends StatefulWidget {
  const UserCreateModal({super.key});

  @override
  State<UserCreateModal> createState() => _UserCreateModalState();
}

class _UserCreateModalState extends State<UserCreateModal> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _instagramController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Novo Usuário', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInput(_nomeController, 'Nome'),
              _buildInput(_emailController, 'E-mail'),
              _buildInput(_telefoneController, 'Telefone'),
              _buildInput(_instagramController, 'Instagram'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.pinkAccent)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pinkAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: _salvarUsuario,
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  Widget _buildInput(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Future<void> _salvarUsuario() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('users').add({
        'nome': _nomeController.text,
        'email': _emailController.text,
        'telefone': _telefoneController.text,
        'instagram': _instagramController.text,
        'tipo': 'cliente',
      });
      if (context.mounted) Navigator.pop(context);
    }
  }
}
