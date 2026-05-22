import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:job_app/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Future.wait([
    initializeDateFormatting('fr_FR', null),
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
  ]);

  // Debug: Catch widget errors
  ErrorWidget.builder = (FlutterErrorDetails details) {
    debugPrint('WIDGET ERROR: ${details.exception}');
    debugPrint('STACK: ${details.stack}');
    return const SizedBox.shrink();
  };

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}