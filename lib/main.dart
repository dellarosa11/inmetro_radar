import 'package:flutter/material.dart';

import 'screens/consulta_page.dart';
import 'services/inmetro_service.dart';

void main() {
  runApp(const ConsultaInmetroApp());
}

class ConsultaInmetroApp extends StatelessWidget {
  const ConsultaInmetroApp({super.key, this.service});

  final ConsultaService? service;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Consulta Inmetro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006B5F),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F8F7),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD4DDD9)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD4DDD9)),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFFDDE5E1)),
          ),
        ),
      ),
      home: ConsultaPage(service: service),
    );
  }
}
