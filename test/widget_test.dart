import 'package:consulta_inmetro/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('mostra a tela inicial de consulta', (tester) async {
    await tester.pumpWidget(const ConsultaInmetroApp());

    expect(find.text('Consulta Inmetro'), findsOneWidget);
    expect(find.text('Radares vistoriados pelo Inmetro'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
  });
}
