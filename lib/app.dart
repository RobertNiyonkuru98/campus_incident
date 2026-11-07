import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/app_theme.dart';
import 'cubits/auth/auth_cubit.dart';
import 'cubits/auth/auth_state.dart';
import 'cubits/reports/report_cubit.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/home/home_screen.dart';

class CampusCareApp extends StatelessWidget {
  const CampusCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusCare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthGate(),
    );
  }
}

/// Decides what the app shows, based purely on the AuthCubit state.
///
/// The BlocListener is what keeps the report stream honest: it only subscribes
/// once someone is signed in, so we never trigger a permission-denied read, and
/// it tears the subscription down on sign-out.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (AuthState previous, AuthState current) =>
          previous.runtimeType != current.runtimeType,
      listener: (BuildContext context, AuthState state) {
        final ReportCubit reports = context.read<ReportCubit>();
        if (state is AuthAuthenticated) {
          reports.watch();
        } else if (state is AuthUnauthenticated || state is AuthFailure) {
          reports.stop();
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (BuildContext context, AuthState state) {
          if (state is AuthAuthenticated) {
            return const HomeScreen();
          }
          if (state is AuthInitial ||
              state is AuthLoading ||
              state is AuthUnauthenticated ||
              state is AuthFailure) {
            return const AuthScreen();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}
