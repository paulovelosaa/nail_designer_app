import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceCreateModal extends StatefulWidget {
  const ServiceCreateModal({super.key});

  @override
  State<ServiceCreateModal> createState() => _ServiceCreateModalState();
}

class _ServiceCreateModalState extends State<ServiceCreateModal> {
  final _nomeController = TextEditingController();
  final _valorController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _duracaoController = TextEditingController();

  Future<void> _saveService() async {
    final nome = _nomeController.text.trim();
    final descricao = _descricaoController.text.trim();
    final valor = double.tryParse(_valorController.text.trim()) ?? 0.0;
    final duracao = int.tryParse(_duracaoController.text.trim()) ?? 0;

    if (nome.isEmpty || valor <= 0 || duracao <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todos os campos corretamente.")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('services').add({
      'nome': nome,
      'descricao': descricao,
      'valor': valor,
      'duracao': duracao,
      'id': 'servico_${DateTime.now().millisecondsSinceEpoch}',
    });

    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFFF2F2F2),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Novo Serviço", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 20),
              _input(_nomeController, "Nome"),
              _input(_descricaoController, "Descrição"),
              _input(_valorController, "Valor", number: true),
              _input(_duracaoController, "Duração (min)", number: true),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                    onPressed: _saveService,
                    child: const Text("Salvar"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(TextEditingController controller, String label, {bool number = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
