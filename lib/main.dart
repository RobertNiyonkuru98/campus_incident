import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'cubits/auth/auth_cubit.dart';
import 'cubits/reports/report_cubit.dart';
import 'cubits/staff/staff_cubit.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/report_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error) {
    // Almost always means firebase_options.dart still holds the placeholder
    // values. Failing with an instruction beats a cryptic red screen.
    runApp(_SetupApp(message: '$error'));
    return;
  }

  runApp(const CampusCareRoot());
}

class CampusCareRoot extends StatelessWidget {
  const CampusCareRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(AuthService())..restoreSession(),
        ),
        BlocProvider<ReportCubit>(
          create: (_) => ReportCubit(ReportService()),
        ),
        BlocProvider<StaffCubit>(
          create: (_) => StaffCubit(ReportService()),
        ),
      ],
      child: const CampusCareApp(),
    );
  }
}

/// Shown only when Firebase could not start, so the fix is on screen.
class _SetupApp extends StatelessWidget {
  const _SetupApp({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF8F7FC),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.settings_suggest_outlined, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Firebase is not configured yet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Run this once in the project folder:\n'
                  'flutterfire configure --project=<your-firebase-project-id>',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
