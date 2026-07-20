import 'radar.dart';

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
