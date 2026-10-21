class Jugador {
  final String id;
  final String nombre;
  final int numeroCamiseta;
  final String posicion;
  final int edad;
  final String equipoId;
  final String equipoNombre;

  Jugador({
    required this.id,
    required this.nombre,
    required this.numeroCamiseta,
    required this.posicion,
    required this.edad,
    required this.equipoId,
    required this.equipoNombre,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'numeroCamiseta': numeroCamiseta,
      'posicion': posicion,
      'edad': edad,
      'equipoId': equipoId,
      'equipoNombre': equipoNombre,
    };
  }

  factory Jugador.fromMap(String id, Map<String, dynamic> mapa) {
    return Jugador(
      id: id,
      nombre: mapa['nombre'] ?? '',
      numeroCamiseta: mapa['numeroCamiseta'] ?? 0,
      posicion: mapa['posicion'] ?? '',
      edad: mapa['edad'] ?? 0,
      equipoId: mapa['equipoId'] ?? '',
      equipoNombre: mapa['equipoNombre'] ?? '',
    );
  }
}
