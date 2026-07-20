import 'package:flutter/material.dart';

import '../models/radar.dart';

class RadarCard extends StatelessWidget {
  const RadarCard({required this.radar, super.key});

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
            if (radar.dataDeclaracao.isNotEmpty)
              _InfoLinha(
                icon: Icons.fact_check_outlined,
                texto: 'Última verificação: ${radar.dataDeclaracao}',
              ),
            _InfoLinha(icon: Icons.route_outlined, texto: _valor(radar.local)),
            _InfoLinha(
              icon: Icons.business_outlined,
              texto: 'Responsável: ${_valor(radar.responsavel)}',
            ),
            if (radar.marcaModelo.isNotEmpty)
              _InfoLinha(
                icon: Icons.precision_manufacturing_outlined,
                texto: 'Marca/Modelo: ${radar.marcaModelo}',
              ),
            if (radar.portariaAprovacao.isNotEmpty)
              _InfoLinha(
                icon: Icons.rule_folder_outlined,
                texto: 'Portaria: ${radar.portariaAprovacao}',
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
