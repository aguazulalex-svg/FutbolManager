class Equipo {
  final String id;
  final String nombre;
  final String entrenador;
  final String ciudad;
  final DateTime fechaRegistro;

  Equipo({
    required this.id,
    required this.nombre,
    required this.entrenador,
    required this.ciudad,
    required this.fechaRegistro,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'entrenador': entrenador,
      'ciudad': ciudad,
      'fechaRegistro': fechaRegistro.toIso8601String(),
    };
  }

  factory Equipo.fromMap(String id, Map<String, dynamic> mapa) {
    return Equipo(
      id: id,
      nombre: mapa['nombre'] ?? '',
      entrenador: mapa['entrenador'] ?? '',
      ciudad: mapa['ciudad'] ?? '',
      fechaRegistro:
          DateTime.tryParse(mapa['fechaRegistro'] ?? '') ?? DateTime.now(),
    );
  }
}
