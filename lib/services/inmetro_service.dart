import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/filtros_consulta.dart';
import '../models/radar.dart';
import '../models/resultado_consulta.dart';

abstract interface class ConsultaService {
  Future<ResultadoConsulta> consultar(FiltrosConsulta filtros);
}

class InmetroService implements ConsultaService {
  static const _portalUrl = 'https://servicos.rbmlq.gov.br/Instrumento';
  static const _downloadUrl =
      'https://servicos.rbmlq.gov.br/Instrumento/Download';
  static const _tipoMedidorVelocidade = '322';

  final http.Client _client;
  final Map<String, Future<List<Radar>>> _cachePorUf = {};

  InmetroService({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<ResultadoConsulta> consultar(FiltrosConsulta filtros) async {
    final radaresDaUf = await _carregarUf(filtros.uf);
    final radares = radaresDaUf
        .where((radar) {
          return _contem(radar.municipio, filtros.municipio) &&
              _contem(radar.local, filtros.local) &&
              _algumContem(radar.numerosSerie, filtros.numeroSerie) &&
              _algumContem(radar.numerosInmetro, filtros.numeroInmetro);
        })
        .toList(growable: false);

    return ResultadoConsulta(
      url: '$_portalUrl?tipo=$_tipoMedidorVelocidade&uf=${filtros.uf}',
      totalEncontrado: radares.length,
      radares: radares,
    );
  }

  Future<List<Radar>> _carregarUf(String uf) {
    return _cachePorUf.putIfAbsent(uf, () async {
      try {
        final response = await _client
            .post(
              Uri.parse(_downloadUrl),
              headers: const {'Accept': 'application/zip'},
              body: {
                'SelectedTipoClassificacaoInstrumento': _tipoMedidorVelocidade,
                'SelectedEstados': uf,
                'extensao': 'json',
              },
            )
            .timeout(const Duration(seconds: 45));

        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw Exception('Resposta HTTP ${response.statusCode}');
        }

        return compute(_decodificarDataset, response.bodyBytes);
      } catch (_) {
        _cachePorUf.remove(uf);
        rethrow;
      }
    });
  }

  bool _algumContem(List<String> valores, String filtro) {
    if (filtro.trim().isEmpty) return true;
    return valores.any((valor) => _contem(valor, filtro));
  }

  bool _contem(String valor, String filtro) {
    final termo = _normalizar(filtro);
    return termo.isEmpty || _normalizar(valor).contains(termo);
  }
}

List<Radar> _decodificarDataset(List<int> bytes) {
  final arquivo = ZipDecoder()
      .decodeBytes(bytes, verify: true)
      .files
      .firstWhere((item) => item.isFile && item.name.endsWith('.json'));
  final dados = jsonDecode(utf8.decode(arquivo.content)) as List<dynamic>;

  return dados
      .map((item) {
        final medidor = item as Map<String, dynamic>;
        final faixas = (medidor['Faixas'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>();
        final proprietario =
            medidor['Proprietario'] as Map<String, dynamic>? ?? const {};
        final numerosSerie = faixas
            .map((faixa) => _texto(faixa['NumeroSerie']))
            .where((valor) => valor.isNotEmpty)
            .toList(growable: false);
        final numerosInmetro = faixas
            .map((faixa) => _texto(faixa['NumeroInmetro']))
            .where((valor) => valor.isNotEmpty)
            .toList(growable: false);

        return Radar(
          responsavel: _texto(proprietario['Nome']),
          municipio: _texto(medidor['Municipio']),
          dataDeclaracao: _texto(medidor['DataUltimaVerificacao']),
          dataValidade: _texto(medidor['DataValidade']),
          resultado: _texto(medidor['UltimoResultado']),
          local: _texto(medidor['LocalVerificacao']),
          marcaModelo: '',
          portariaAprovacao: '',
          faixas: faixas.map(_formatarFaixa).join(' | '),
          numerosSerie: numerosSerie,
          numerosInmetro: numerosInmetro,
        );
      })
      .toList(growable: false);
}

String _formatarFaixa(Map<String, dynamic> faixa) {
  final partes = <String>[
    if (_texto(faixa['NumeroFaixa']).isNotEmpty)
      'Faixa ${_texto(faixa['NumeroFaixa'])}',
    if (_texto(faixa['NumeroInmetro']).isNotEmpty)
      'Inmetro ${_texto(faixa['NumeroInmetro'])}',
    if (_texto(faixa['NumeroSerie']).isNotEmpty)
      'Série ${_texto(faixa['NumeroSerie'])}',
    if (_texto(faixa['Sentido']).isNotEmpty) _texto(faixa['Sentido']),
    if (_texto(faixa['VelocidadeNominal']).isNotEmpty)
      '${_texto(faixa['VelocidadeNominal'])} km/h',
  ];
  return partes.join(' • ');
}

String _texto(Object? valor) => valor?.toString().trim() ?? '';

String _normalizar(String valor) {
  const comAcento = 'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ';
  const semAcento = 'AAAAAEEEEIIIIOOOOOUUUUC';
  var resultado = valor.trim().toUpperCase();
  for (var index = 0; index < comAcento.length; index++) {
    resultado = resultado.replaceAll(comAcento[index], semAcento[index]);
  }
  return resultado.replaceAll(RegExp(r'\s+'), ' ');
}
