import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const ConsultaInmetroApp());
}

class ConsultaInmetroApp extends StatelessWidget {
  const ConsultaInmetroApp({super.key});

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
      home: const ConsultaPage(),
    );
  }
}

class ConsultaPage extends StatefulWidget {
  const ConsultaPage({super.key});

  @override
  State<ConsultaPage> createState() => _ConsultaPageState();
}

class _ConsultaPageState extends State<ConsultaPage> {
  static const _ufs = [
    'AC',
    'AL',
    'AP',
    'AM',
    'BA',
    'CE',
    'DF',
    'ES',
    'GO',
    'MA',
    'MT',
    'MS',
    'MG',
    'PA',
    'PB',
    'PR',
    'PE',
    'PI',
    'RJ',
    'RN',
    'RS',
    'RO',
    'RR',
    'SC',
    'SP',
    'SE',
    'TO',
  ];

  final _service = InmetroService();
  final _municipioController = TextEditingController();
  final _serieController = TextEditingController();
  final _inmetroController = TextEditingController();
  final _localController = TextEditingController();

  String _uf = 'SP';
  bool _carregando = false;
  String? _erro;
  ResultadoConsulta? _resultado;

  @override
  void dispose() {
    _municipioController.dispose();
    _serieController.dispose();
    _inmetroController.dispose();
    _localController.dispose();
    super.dispose();
  }

  Future<void> _consultar() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final resultado = await _service.consultar(
        FiltrosConsulta(
          uf: _uf,
          municipio: _municipioController.text,
          numeroSerie: _serieController.text,
          numeroInmetro: _inmetroController.text,
          local: _localController.text,
        ),
      );

      if (!mounted) return;
      setState(() {
        _resultado = resultado;
        _carregando = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _erro =
            'Não foi possível consultar o PSIE agora. Verifique sua internet e tente novamente.';
        _carregando = false;
      });
    }
  }

  void _limpar() {
    _municipioController.clear();
    _serieController.clear();
    _inmetroController.clear();
    _localController.clear();
    setState(() {
      _uf = 'SP';
      _resultado = null;
      _erro = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta Inmetro'),
        actions: [
          IconButton(
            tooltip: 'Limpar filtros',
            onPressed: _limpar,
            icon: const Icon(Icons.cleaning_services_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _FiltrosSection(
              uf: _uf,
              ufs: _ufs,
              municipioController: _municipioController,
              serieController: _serieController,
              inmetroController: _inmetroController,
              localController: _localController,
              carregando: _carregando,
              onUfChanged: (valor) => setState(() => _uf = valor),
              onConsultar: _consultar,
            ),
            Expanded(
              child: _ResultadoSection(
                carregando: _carregando,
                erro: _erro,
                resultado: _resultado,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FiltrosSection extends StatelessWidget {
  const _FiltrosSection({
    required this.uf,
    required this.ufs,
    required this.municipioController,
    required this.serieController,
    required this.inmetroController,
    required this.localController,
    required this.carregando,
    required this.onUfChanged,
    required this.onConsultar,
  });

  final String uf;
  final List<String> ufs;
  final TextEditingController municipioController;
  final TextEditingController serieController;
  final TextEditingController inmetroController;
  final TextEditingController localController;
  final bool carregando;
  final ValueChanged<String> onUfChanged;
  final VoidCallback onConsultar;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFDDE5E1))),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Radares vistoriados pelo Inmetro',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Busque medidores de velocidade no Portal de Serviços do Inmetro nos Estados.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF53645F)),
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final compacto = constraints.maxWidth < 720;
                final larguraCampo = compacto
                    ? constraints.maxWidth
                    : (constraints.maxWidth - 16) / 2;

                return Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: compacto ? constraints.maxWidth : 150,
                      child: DropdownButtonFormField<String>(
                        initialValue: uf,
                        decoration: const InputDecoration(
                          labelText: 'UF',
                          prefixIcon: Icon(Icons.map_outlined),
                        ),
                        items: [
                          for (final item in ufs)
                            DropdownMenuItem(value: item, child: Text(item)),
                        ],
                        onChanged: carregando
                            ? null
                            : (valor) {
                                if (valor != null) onUfChanged(valor);
                              },
                      ),
                    ),
                    _CampoBusca(
                      width: compacto
                          ? constraints.maxWidth
                          : larguraCampo - 75,
                      controller: municipioController,
                      label: 'Município',
                      icon: Icons.location_city_outlined,
                    ),
                    _CampoBusca(
                      width: compacto ? constraints.maxWidth : larguraCampo,
                      controller: localController,
                      label: 'Local/Via',
                      icon: Icons.route_outlined,
                    ),
                    _CampoBusca(
                      width: compacto ? constraints.maxWidth : larguraCampo,
                      controller: serieController,
                      label: 'Número de série',
                      icon: Icons.confirmation_number_outlined,
                    ),
                    _CampoBusca(
                      width: compacto ? constraints.maxWidth : larguraCampo,
                      controller: inmetroController,
                      label: 'Número do Inmetro',
                      icon: Icons.verified_outlined,
                    ),
                    SizedBox(
                      width: compacto ? constraints.maxWidth : larguraCampo,
                      height: 56,
                      child: FilledButton.icon(
                        onPressed: carregando ? null : onConsultar,
                        icon: carregando
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.search),
                        label: Text(
                          carregando ? 'Consultando...' : 'Consultar',
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CampoBusca extends StatelessWidget {
  const _CampoBusca({
    required this.width,
    required this.controller,
    required this.label,
    required this.icon,
  });

  final double width;
  final TextEditingController controller;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        onSubmitted: (_) => FocusScope.of(context).nextFocus(),
      ),
    );
  }
}

class _ResultadoSection extends StatelessWidget {
  const _ResultadoSection({
    required this.carregando,
    required this.erro,
    required this.resultado,
  });

  final bool carregando;
  final String? erro;
  final ResultadoConsulta? resultado;

  @override
  Widget build(BuildContext context) {
    if (carregando && resultado == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (erro != null) {
      return _MensagemEstado(
        icon: Icons.wifi_off_outlined,
        titulo: 'Consulta indisponível',
        texto: erro!,
      );
    }

    if (resultado == null) {
      return const _MensagemEstado(
        icon: Icons.speed_outlined,
        titulo: 'Informe os filtros',
        texto:
            'Escolha uma UF e toque em Consultar para buscar os radares vistoriados.',
      );
    }

    if (resultado!.radares.isEmpty) {
      return const _MensagemEstado(
        icon: Icons.search_off_outlined,
        titulo: 'Nenhum resultado',
        texto:
            'Revise a UF, cidade, local ou número informado e tente novamente.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: resultado!.radares.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _ResumoConsulta(resultado: resultado!);
        }
        return _RadarCard(radar: resultado!.radares[index - 1]);
      },
    );
  }
}

class _ResumoConsulta extends StatelessWidget {
  const _ResumoConsulta({required this.resultado});

  final ResultadoConsulta resultado;

  @override
  Widget build(BuildContext context) {
    final total = resultado.totalEncontrado >= 0
        ? '${resultado.totalEncontrado} registro(s) no PSIE'
        : '${resultado.radares.length} registro(s) exibido(s)';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              total,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Tooltip(
            message: resultado.url,
            child: const Icon(Icons.link, color: Color(0xFF53645F)),
          ),
        ],
      ),
    );
  }
}

class _RadarCard extends StatelessWidget {
  const _RadarCard({required this.radar});

  final Radar radar;

  @override
  Widget build(BuildContext context) {
    final aprovado = radar.resultado.toLowerCase().contains('aprovado');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    radar.municipio.isEmpty
                        ? 'Município não informado'
                        : radar.municipio,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _StatusChip(
                  texto: radar.resultado.isEmpty
                      ? 'Sem status'
                      : radar.resultado,
                  aprovado: aprovado,
                ),
              ],
            ),
            const SizedBox(height: 10),
            _InfoLinha(
              icon: Icons.event_available_outlined,
              texto: 'Validade: ${_valor(radar.dataValidade)}',
            ),
            _InfoLinha(icon: Icons.route_outlined, texto: _valor(radar.local)),
            _InfoLinha(
              icon: Icons.business_outlined,
              texto: 'Responsável: ${_valor(radar.responsavel)}',
            ),
            _InfoLinha(
              icon: Icons.precision_manufacturing_outlined,
              texto: 'Marca/Modelo: ${_valor(radar.marcaModelo)}',
            ),
            _InfoLinha(
              icon: Icons.rule_folder_outlined,
              texto: 'Portaria: ${_valor(radar.portariaAprovacao)}',
            ),
            if (radar.faixas.isNotEmpty)
              _InfoLinha(
                icon: Icons.speed_outlined,
                texto: 'Faixas: ${radar.faixas}',
              ),
          ],
        ),
      ),
    );
  }

  static String _valor(String valor) => valor.isEmpty ? '-' : valor;
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.texto, required this.aprovado});

  final String texto;
  final bool aprovado;

  @override
  Widget build(BuildContext context) {
    final cor = aprovado ? const Color(0xFF147A4D) : const Color(0xFF8A5B00);
    final fundo = aprovado ? const Color(0xFFE8F5EE) : const Color(0xFFFFF4D8);

    return Container(
      constraints: const BoxConstraints(maxWidth: 130),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        texto,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: cor, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

class _InfoLinha extends StatelessWidget {
  const _InfoLinha({required this.icon, required this.texto});

  final IconData icon;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF53645F)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(texto, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _MensagemEstado extends StatelessWidget {
  const _MensagemEstado({
    required this.icon,
    required this.titulo,
    required this.texto,
  });

  final IconData icon;
  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 46, color: const Color(0xFF53645F)),
            const SizedBox(height: 12),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF53645F)),
            ),
          ],
        ),
      ),
    );
  }
}

class InmetroService {
  static const _baseUrl = 'https://servicos.rbmlq.gov.br/Instrumento';
  static const _tipoMedidorVelocidade = '322';

  final http.Client _client;

  InmetroService({http.Client? client}) : _client = client ?? http.Client();

  Future<ResultadoConsulta> consultar(FiltrosConsulta filtros) async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'tipo': _tipoMedidorVelocidade,
        'uf': filtros.uf,
        if (filtros.municipio.trim().isNotEmpty)
          'municipio': filtros.municipio.trim(),
        if (filtros.numeroSerie.trim().isNotEmpty)
          'numeroSerie': filtros.numeroSerie.trim(),
        if (filtros.numeroInmetro.trim().isNotEmpty)
          'numeroInmetro': filtros.numeroInmetro.trim(),
        if (filtros.local.trim().isNotEmpty) 'local': filtros.local.trim(),
      },
    );

    final response = await _client
        .get(
          uri,
          headers: const {
            'Accept': 'text/html',
            'User-Agent': 'ConsultaInmetroFlutter/1.0',
          },
        )
        .timeout(const Duration(seconds: 45));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Resposta HTTP ${response.statusCode}');
    }

    final texto = _limparHtml(response.body);
    return ResultadoConsulta(
      url: uri.toString(),
      totalEncontrado: _extrairTotal(texto),
      radares: _extrairRadares(texto),
    );
  }

  int _extrairTotal(String texto) {
    final match = RegExp(
      r'Total de\s+(\d+)\s+itens',
      caseSensitive: false,
    ).firstMatch(texto);
    return match == null ? -1 : int.parse(match.group(1)!);
  }

  List<Radar> _extrairRadares(String texto) {
    final regex = RegExp(
      r'Responsável:\s*(.*?)\s*'
      r'Município:\s*(.*?)\s*'
      r'(?:Data da Declaração:\s*(.*?)\s*)?'
      r'Data Validade:\s*(.*?)\s*'
      r'Resultado:\s*(.*?)\s*'
      r'Local:\s*(.*?)\s*'
      r'Marca/Modelo:\s*(.*?)\s*'
      r'Portaria de Aprovação:\s*(.*?)\s*'
      r'Faixas do Medidor\s*(.*?)(?=\s*Ver Histórico de Verificações|\s*Responsável:|\s*Total de|$)',
      caseSensitive: false,
      dotAll: true,
    );

    return [
      for (final match in regex.allMatches(texto))
        Radar(
          responsavel: _limparCampo(match.group(1)),
          municipio: _limparCampo(match.group(2)),
          dataDeclaracao: _limparCampo(match.group(3)),
          dataValidade: _limparCampo(match.group(4)),
          resultado: _limparCampo(match.group(5)),
          local: _limparCampo(match.group(6)),
          marcaModelo: _limparCampo(match.group(7)),
          portariaAprovacao: _limparCampo(match.group(8)),
          faixas: _limparCampo(match.group(9)),
        ),
    ];
  }

  String _limparHtml(String html) {
    return _decodificarEntidadesNumericas(html)
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(
          RegExp(r'<script.*?</script>', caseSensitive: false, dotAll: true),
          ' ',
        )
        .replaceAll(
          RegExp(r'<style.*?</style>', caseSensitive: false, dotAll: true),
          ' ',
        )
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(
          RegExp(r'</(p|div|li|tr|h[1-6])>', caseSensitive: false),
          '\n',
        )
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'[ \t\x0B\f\r]+'), ' ')
        .replaceAll(RegExp(r'\n\s+'), '\n')
        .replaceAll(RegExp(r'\s+\n'), '\n')
        .replaceAll(RegExp(r'\n{2,}'), '\n')
        .trim();
  }

  String _limparCampo(String? valor) {
    if (valor == null) return '';
    return valor
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(
          RegExp(
            r'N.? da Faixa Descri..o N.? do Inmetro N.? de S.rie Sentido Vel\. Nominal',
          ),
          '',
        )
        .trim();
  }

  String _decodificarEntidadesNumericas(String texto) {
    return texto.replaceAllMapped(RegExp(r'&#(x?[0-9A-Fa-f]+);'), (match) {
      final codigo = match.group(1)!;
      final hexadecimal = codigo.startsWith('x') || codigo.startsWith('X');
      final numero = hexadecimal ? codigo.substring(1) : codigo;
      final valor = int.tryParse(numero, radix: hexadecimal ? 16 : 10);
      return valor == null ? match.group(0)! : String.fromCharCode(valor);
    });
  }
}

class FiltrosConsulta {
  const FiltrosConsulta({
    required this.uf,
    required this.municipio,
    required this.numeroSerie,
    required this.numeroInmetro,
    required this.local,
  });

  final String uf;
  final String municipio;
  final String numeroSerie;
  final String numeroInmetro;
  final String local;
}

class ResultadoConsulta {
  const ResultadoConsulta({
    required this.url,
    required this.totalEncontrado,
    required this.radares,
  });

  final String url;
  final int totalEncontrado;
  final List<Radar> radares;
}

class Radar {
  const Radar({
    required this.responsavel,
    required this.municipio,
    required this.dataDeclaracao,
    required this.dataValidade,
    required this.resultado,
    required this.local,
    required this.marcaModelo,
    required this.portariaAprovacao,
    required this.faixas,
  });

  final String responsavel;
  final String municipio;
  final String dataDeclaracao;
  final String dataValidade;
  final String resultado;
  final String local;
  final String marcaModelo;
  final String portariaAprovacao;
  final String faixas;
}
