import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nail_designer_app/features/auth/data/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();

  final Color accentPink = const Color(0xFFE91E63);
  final Color background = const Color(0xFFF2F2F2);
  bool _loading = false;

  Future<void> _onRegisterPressed() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não coincidem.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final user = await AuthService().register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        instagram: _instagramController.text.trim(),
      );

      if (user != null) {
        context.go('/home-client');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Criar Conta',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 32),
                _InputField(label: 'Nome', controller: _nameController),
                const SizedBox(height: 16),
                _InputField(label: 'Telefone', controller: _phoneController),
                const SizedBox(height: 16),
                _InputField(label: 'Instagram', controller: _instagramController),
                const SizedBox(height: 16),
                _InputField(label: 'E-mail', controller: _emailController),
                const SizedBox(height: 16),
                _InputField(label: 'Senha', controller: _passwordController, obscure: true),
                const SizedBox(height: 16),
                _InputField(label: 'Confirmar Senha', controller: _confirmPasswordController, obscure: true),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _onRegisterPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentPink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Cadastrar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Já tenho uma conta'),
                    style: TextButton.styleFrom(foregroundColor: accentPink),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final bool obscure;
  final TextEditingController controller;

  const _InputField({
    required this.label,
    required this.controller,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    const accentPink = Color(0xFFE91E63);
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentPink, width: 2),
        ),
      ),
    );
  }
}
