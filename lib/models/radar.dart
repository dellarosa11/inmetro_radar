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
    required this.numerosSerie,
    required this.numerosInmetro,
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
  final List<String> numerosSerie;
  final List<String> numerosInmetro;
}
