class Posicion {
  final String equipoId;
  final String nombreEquipo;

  int partidosJugados;
  int partidosGanados;
  int partidosEmpatados;
  int partidosPerdidos;

  int golesFavor;
  int golesContra;
  int puntos;

  Posicion({
    required this.equipoId,
    required this.nombreEquipo,
    this.partidosJugados = 0,
    this.partidosGanados = 0,
    this.partidosEmpatados = 0,
    this.partidosPerdidos = 0,
    this.golesFavor = 0,
    this.golesContra = 0,
    this.puntos = 0,
  });

  int get diferenciaGoles => golesFavor - golesContra;

  void registrarVictoria() {
    partidosJugados++;
    partidosGanados++;
    puntos += 3;
  }

  void registrarEmpate() {
    partidosJugados++;
    partidosEmpatados++;
    puntos += 1;
  }

  void registrarDerrota() {
    partidosJugados++;
    partidosPerdidos++;
  }
}
