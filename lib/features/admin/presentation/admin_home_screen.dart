import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nail_designer_app/features/auth/data/auth_service.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  final Color accentPink = const Color(0xFFE91E63);
  final Color background = const Color(0xFFF2F2F2);

  Future<String> _getFirstName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final fullName = doc.data()?['nome'] ?? 'Admin';
      return fullName.toString().split(' ').first;
    }
    return 'Admin';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: FutureBuilder<String>(
          future: _getFirstName(),
          builder: (context, snapshot) {
            final name = snapshot.data ?? 'Admin';
            return Text(
              'Bem-vinda, $name ❤️',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PopupMenuButton<String>(
              offset: const Offset(0, 50),
              color: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFF2F2F2)),
              ),
              elevation: 6,
              icon: const Icon(Icons.more_vert, color: Colors.black87),
              onSelected: (value) async {
                if (value == 'logout') {
                  await AuthService().logout();
                  context.go('/login');
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: const [
                      Icon(Icons.logout, size: 18, color: Colors.black54),
                      SizedBox(width: 10),
                      Text('Sair'),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Painel da Nail',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            Expanded(child: _AdminMenuGrid()),
          ],
        ),
      ),
    );
  }
}

class _AdminMenuGrid extends StatelessWidget {
  const _AdminMenuGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _MenuCard(
          icon: Icons.calendar_today,
          label: 'Agenda Semanal',
          onTap: () => context.push('/agenda-semanal'),
        ),
        _MenuCard(
          icon: Icons.event_note,
          label: 'Agenda Completa',
          onTap: () => context.push('/agenda-completa'),
        ),
        _MenuCard(
          icon: Icons.design_services_outlined,
          label: 'Serviços',
          onTap: () => context.push('/gestao-servicos'),
        ),
        _MenuCard(
          icon: Icons.access_time_outlined,
          label: 'Horários',
          onTap: () => context.push('/gestao-horarios'),
        ),
        _MenuCard(
          icon: Icons.supervisor_account_outlined,
          label: 'Usuários',
          onTap: () => context.push('/gestao-usuarios'),
        ),
        _MenuCard(
          icon: Icons.person_outline,
          label: 'Perfil',
          onTap: () => context.push('/perfil'),
        ),
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const accentPink = Color(0xFFE91E63);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: accentPink, size: 36),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
