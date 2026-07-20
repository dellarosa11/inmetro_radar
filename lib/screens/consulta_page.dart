import 'package:flutter/material.dart';

import '../models/filtros_consulta.dart';
import '../models/resultado_consulta.dart';
import '../services/inmetro_service.dart';
import '../widgets/radar_card.dart';

class ConsultaPage extends StatefulWidget {
  const ConsultaPage({super.key, this.service});

  final ConsultaService? service;

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

  late final ConsultaService _service;
  final _municipioController = TextEditingController();
  final _serieController = TextEditingController();
  final _inmetroController = TextEditingController();
  final _localController = TextEditingController();

  String _uf = 'SP';
  bool _carregando = false;
  String? _erro;
  ResultadoConsulta? _resultado;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? InmetroService();
  }

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
    } catch (_) {
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
        return RadarCard(radar: resultado!.radares[index - 1]);
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
