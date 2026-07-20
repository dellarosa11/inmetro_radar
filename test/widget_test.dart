import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:consulta_inmetro/main.dart';
import 'package:consulta_inmetro/models/filtros_consulta.dart';
import 'package:consulta_inmetro/models/radar.dart';
import 'package:consulta_inmetro/models/resultado_consulta.dart';
import 'package:consulta_inmetro/services/inmetro_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('mostra a tela inicial de consulta', (tester) async {
    await tester.pumpWidget(const ConsultaInmetroApp());

    expect(find.text('Consulta Inmetro'), findsOneWidget);
    expect(find.text('Radares vistoriados pelo Inmetro'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
  });

  testWidgets('aceita um serviço falso injetado pela tela', (tester) async {
    await tester.pumpWidget(
      ConsultaInmetroApp(service: _FakeConsultaService()),
    );

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    expect(find.text('CAMPINAS'), findsOneWidget);
    expect(find.text('1 registro(s) no PSIE'), findsOneWidget);
  });

  test('aplica todos os filtros sobre o dataset completo da UF', () async {
    var requisicoes = 0;
    final client = MockClient((request) async {
      requisicoes++;
      expect(request.method, 'POST');
      expect(request.url.path, '/Instrumento/Download');
      expect(request.bodyFields['SelectedTipoClassificacaoInstrumento'], '322');
      expect(request.bodyFields['SelectedEstados'], 'SP');
      expect(request.bodyFields['extensao'], 'json');
      return http.Response.bytes(_datasetZip(), 200);
    });
    final service = InmetroService(client: client);

    final todos = await service.consultar(_filtros());
    final porMunicipio = await service.consultar(
      _filtros(municipio: 'sao jose'),
    );
    final porLocal = await service.consultar(_filtros(local: 'km 90'));
    final porSerie = await service.consultar(
      _filtros(numeroSerie: 'serie-abc'),
    );
    final porInmetro = await service.consultar(
      _filtros(numeroInmetro: '123456'),
    );

    expect(todos.totalEncontrado, 2);
    expect(porMunicipio.radares.single.municipio, 'SÃO JOSÉ DOS CAMPOS');
    expect(porLocal.radares.single.local, contains('KM 90'));
    expect(porSerie.radares.single.numerosSerie, contains('SERIE-ABC'));
    expect(porInmetro.radares.single.numerosInmetro, contains('12345678'));
    expect(requisicoes, 1, reason: 'a UF deve permanecer em cache');
  });
}

class _FakeConsultaService implements ConsultaService {
  @override
  Future<ResultadoConsulta> consultar(FiltrosConsulta filtros) async {
    return const ResultadoConsulta(
      url: 'https://example.test',
      totalEncontrado: 1,
      radares: [
        Radar(
          responsavel: 'PREFEITURA',
          municipio: 'CAMPINAS',
          dataDeclaracao: '01/01/2026',
          dataValidade: '31/12/2026',
          resultado: 'Aprovado',
          local: 'AVENIDA CENTRAL',
          marcaModelo: '',
          portariaAprovacao: '',
          faixas: '',
          numerosSerie: [],
          numerosInmetro: [],
        ),
      ],
    );
  }
}

FiltrosConsulta _filtros({
  String municipio = '',
  String numeroSerie = '',
  String numeroInmetro = '',
  String local = '',
}) {
  return FiltrosConsulta(
    uf: 'SP',
    municipio: municipio,
    numeroSerie: numeroSerie,
    numeroInmetro: numeroInmetro,
    local: local,
  );
}

List<int> _datasetZip() {
  final dados = [
    {
      'Municipio': 'SÃO JOSÉ DOS CAMPOS',
      'LocalVerificacao': 'RODOVIA SP-065 KM 90',
      'DataUltimaVerificacao': '10/02/2026',
      'DataValidade': '09/02/2027',
      'UltimoResultado': 'Aprovado',
      'Faixas': [
        {
          'NumeroFaixa': '1',
          'NumeroInmetro': '12345678',
          'NumeroSerie': 'SERIE-ABC',
          'Sentido': 'NORTE',
          'VelocidadeNominal': '80',
        },
      ],
      'Proprietario': {'Nome': 'CONCESSIONÁRIA TESTE'},
    },
    {
      'Municipio': 'CAMPINAS',
      'LocalVerificacao': 'AVENIDA CENTRAL',
      'DataUltimaVerificacao': '01/01/2026',
      'DataValidade': '31/12/2026',
      'UltimoResultado': 'Aprovado',
      'Faixas': [
        {
          'NumeroFaixa': '1',
          'NumeroInmetro': '87654321',
          'NumeroSerie': 'OUTRA-SERIE',
          'Sentido': 'SUL',
          'VelocidadeNominal': '60',
        },
      ],
      'Proprietario': {'Nome': 'PREFEITURA'},
    },
  ];
  final archive = Archive()
    ..addFile(ArchiveFile.string('medidores-SP.json', jsonEncode(dados)));
  return ZipEncoder().encode(archive);
}
