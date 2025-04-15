import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nail_designer_app/features/admin/presentation/admin_home_screen.dart';
import 'package:nail_designer_app/features/client/presentation/client_home_screen.dart';
import 'package:nail_designer_app/features/auth/presentation/login_screen.dart';
import 'package:nail_designer_app/features/auth/presentation/register_screen.dart';
import 'package:nail_designer_app/features/auth/presentation/forgot_password_screen.dart';
import 'package:nail_designer_app/features/auth/presentation/auth_checker.dart';
import 'package:nail_designer_app/features/splash/presentation/splash_screen.dart';

// Client
import 'package:nail_designer_app/features/client/presentation/appointments_screen.dart';
import 'package:nail_designer_app/features/client/presentation/schedule_appointment_screen.dart'; // Nova tela
import 'package:nail_designer_app/features/client/presentation/profile_screen.dart'; // Substituindo o Placeholder

// Admin
import 'package:nail_designer_app/features/admin/presentation/weekly_appointments_screen.dart';
import 'package:nail_designer_app/features/admin/presentation/full_appointments_screen.dart';
import 'package:nail_designer_app/features/manage/services_management/presentation/services_management_screen.dart';
import 'package:nail_designer_app/features/manage/slots_management/presentation/slots_management_screen.dart';
import 'package:nail_designer_app/features/manage/users_management/presentation/users_management_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/auth-check',
      builder: (context, state) => const AuthChecker(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/home-client',
      builder: (context, state) => const ClientHomeScreen(),
    ),
    GoRoute(
      path: '/home-admin',
      builder: (context, state) => const AdminHomeScreen(),
    ),

    // ✅ Novas rotas adicionadas abaixo:
    GoRoute(
      path: '/agendar',
      builder: (context, state) => const ScheduleAppointmentScreen(), // Atualizando para a classe correta
    ),
    GoRoute(
      path: '/meus-agendamentos',
      builder: (context, state) => const AppointmentsScreen(),
    ),
    GoRoute(
      path: '/perfil',
      builder: (context, state) => const ProfileScreen(), // Atualizando para a classe real
    ),
    GoRoute(
      path: '/agenda-semanal',
      builder: (context, state) => const WeeklyAppointmentsScreen(),
    ),
    GoRoute(
      path: '/agenda-completa',
      builder: (context, state) => const FullAppointmentsScreen(),
    ),
    GoRoute(
      path: '/gestao-servicos',
      name: 'gestao-servicos',
      builder: (context, state) => const ServicesManagementScreen(),
    ),
    GoRoute(
      path: '/gestao-horarios',
      name: 'gestao-horarios',
      builder: (context, state) => const SlotsManagementScreen(),
    ),
    GoRoute(
      path: '/gestao-usuarios',
      name: 'gestao-usuarios',
      builder: (context, state) => const UsersManagementScreen(),
    ),
  ],
);
