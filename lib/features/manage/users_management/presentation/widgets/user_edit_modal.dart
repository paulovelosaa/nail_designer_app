import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserEditModal extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const UserEditModal({
    super.key,
    required this.userId,
    required this.userData,
  });

  @override
  State<UserEditModal> createState() => _UserEditModalState();
}

class _UserEditModalState extends State<UserEditModal> {
  late final TextEditingController _nomeController;
  late final TextEditingController _emailController;
  late final TextEditingController _telefoneController;
  late final TextEditingController _instagramController;

  @override
  void initState() {
    _nomeController = TextEditingController(text: widget.userData['nome']);
    _emailController = TextEditingController(text: widget.userData['email']);
    _telefoneController = TextEditingController(text: widget.userData['telefone']);
    _instagramController = TextEditingController(text: widget.userData['instagram']);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Editar Usuário', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
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
          onPressed: _salvarAlteracoes,
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
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Future<void> _salvarAlteracoes() async {
    await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
      'nome': _nomeController.text,
      'email': _emailController.text,
      'telefone': _telefoneController.text,
      'instagram': _instagramController.text,
    });

    if (context.mounted) Navigator.pop(context);
  }
}
