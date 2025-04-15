import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();

  String? _originalEmail;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    instagramController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = doc.data();

    if (data != null) {
      setState(() {
        nameController.text = data['nome'] ?? '';
        emailController.text = data['email'] ?? '';
        phoneController.text = data['telefone'] ?? '';
        instagramController.text = data['instagram'] ?? '';
        _originalEmail = data['email'];
      });
    }
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_formKey.currentState?.validate() ?? false) {
      final emailChanged = emailController.text != _originalEmail;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Confirmar alterações'),
          content: const Text('Deseja realmente salvar as alterações feitas no perfil?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                try {
                  if (emailChanged) {
                    final senha = await _solicitarSenha();
                    if (senha == null) return;
                    await _migrarContaParaNovoEmail(senha);
                    return;
                  }

                  // Caso apenas nome/telefone/instagram foram alterados
                  await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                    'nome': nameController.text,
                    'telefone': phoneController.text,
                    'instagram': instagramController.text,
                  });

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Perfil atualizado com sucesso!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao atualizar perfil: $e')),
                    );
                  }
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _migrarContaParaNovoEmail(String senha) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final newEmail = emailController.text;

    if (currentUser == null || _originalEmail == null) return;

    final uidAntigo = currentUser.uid;
    final snapshot = await FirebaseFirestore.instance.collection('users').doc(uidAntigo).get();
    final dadosAntigos = snapshot.data() ?? {};

    try {
      // 1. Cria novo usuário
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: newEmail,
        password: senha,
      );
      final uidNovo = userCredential.user?.uid;

      if (uidNovo == null) throw Exception('Erro ao criar novo usuário.');

      // 2. Copia os dados para o novo usuário
      await FirebaseFirestore.instance.collection('users').doc(uidNovo).set({
        'nome': nameController.text,
        'email': newEmail,
        'telefone': phoneController.text,
        'instagram': instagramController.text,
        'createdAt': dadosAntigos['createdAt'] ?? FieldValue.serverTimestamp(),
      });

      // 3. Deleta Firestore e Auth do antigo
      await FirebaseFirestore.instance.collection('users').doc(uidAntigo).delete();
      await currentUser.delete();

      // 4. Login automático com novo e-mail
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: newEmail,
        password: senha,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-mail alterado com sucesso! Conta migrada.')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao migrar conta: $e')),
        );
      }
    }
  }

  Future<String?> _solicitarSenha() async {
    String senha = '';
    final formKey = GlobalKey<FormState>();

    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Confirme sua senha'),
        content: Form(
          key: formKey,
          child: TextFormField(
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Senha atual'),
            validator: (value) => value == null || value.isEmpty ? 'Digite sua senha' : null,
            onChanged: (value) => senha = value,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(context).pop(senha);
              }
            },
            child: const Text('Confirmar'),
          ),
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
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: const Color(0xFFF2F2F2),
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      backgroundColor: const Color(0xFFF2F2F2),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: _inputDecoration("Nome"),
                validator: (value) => value == null || value.isEmpty ? 'Digite seu nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: _inputDecoration("E-mail"),
                validator: (value) => value == null || value.isEmpty ? 'Digite seu e-mail' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: _inputDecoration("Telefone"),
                validator: (value) => value == null || value.isEmpty ? 'Digite seu telefone' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: instagramController,
                decoration: _inputDecoration("Instagram"),
                validator: (value) => value == null || value.isEmpty ? 'Digite seu Instagram' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
