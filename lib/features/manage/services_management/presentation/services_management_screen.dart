import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'widgets/service_create_modal.dart';
import 'widgets/service_edit_modal.dart';

class ServicesManagementScreen extends StatelessWidget {
  const ServicesManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Serviços'),
        backgroundColor: const Color(0xFFF2F2F2),
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF2F2F2),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          showDialog(context: context, builder: (_) => const ServiceCreateModal());
        },
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('services').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final services = snapshot.data!.docs;
          if (services.isEmpty) {
            return const Center(child: Text("Nenhum serviço cadastrado."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final s = services[index];
              final nome = s['nome'] ?? 'Sem nome';
              final descricao = s['descricao'] ?? '';
              final valor = s['valor'] ?? 0.0;
              final duracao = s['duracao'] ?? 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: ListTile(
                  title: Text(nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('R\$${valor.toStringAsFixed(2)}'),
                        if (descricao.isNotEmpty) Text(descricao),
                        Text('Duração: ${duracao} min'),
                      ],
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.pink),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => ServiceEditModal(serviceId: s.id),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
