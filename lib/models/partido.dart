import 'package:cloud_firestore/cloud_firestore.dart';

class Partido {
  final String id;
  final String equipoLocalId;
  final String equipoLocalNombre;
  final String equipoVisitanteId;
  final String equipoVisitanteNombre;
  final DateTime fecha;
  final int golesLocal;
  final int golesVisitante;
  final String estado;

  // Nuevo: jugadores que anotaron en el partido.
  final List<Map<String, dynamic>> goleadores;

  Partido({
    required this.id,
    required this.equipoLocalId,
    required this.equipoLocalNombre,
    required this.equipoVisitanteId,
    required this.equipoVisitanteNombre,
    required this.fecha,
    required this.golesLocal,
    required this.golesVisitante,
    required this.estado,
    this.goleadores = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'equipoLocalId': equipoLocalId,
      'equipoLocalNombre': equipoLocalNombre,
      'equipoVisitanteId': equipoVisitanteId,
      'equipoVisitanteNombre': equipoVisitanteNombre,
      'fecha': Timestamp.fromDate(fecha),
      'golesLocal': golesLocal,
      'golesVisitante': golesVisitante,
      'estado': estado,
      'goleadores': goleadores,
    };
  }

  factory Partido.fromMap(String id, Map<String, dynamic> mapa) {
    final fechaGuardada = mapa['fecha'];

    DateTime fecha;

    if (fechaGuardada is Timestamp) {
      fecha = fechaGuardada.toDate();
    } else if (fechaGuardada is String) {
      fecha = DateTime.tryParse(fechaGuardada) ?? DateTime.now();
    } else {
      fecha = DateTime.now();
    }

    final goleadoresGuardados = mapa['goleadores'];

    final List<Map<String, dynamic>> goleadores = [];

    if (goleadoresGuardados is List) {
      for (final elemento in goleadoresGuardados) {
        if (elemento is Map) {
          goleadores.add(Map<String, dynamic>.from(elemento));
        }
      }
    }

    return Partido(
      id: id,
      equipoLocalId: mapa['equipoLocalId'] ?? '',
      equipoLocalNombre: mapa['equipoLocalNombre'] ?? '',
      equipoVisitanteId: mapa['equipoVisitanteId'] ?? '',
      equipoVisitanteNombre: mapa['equipoVisitanteNombre'] ?? '',
      fecha: fecha,
      golesLocal: (mapa['golesLocal'] as num?)?.toInt() ?? 0,
      golesVisitante: (mapa['golesVisitante'] as num?)?.toInt() ?? 0,
      estado: mapa['estado'] ?? 'Programado',
      goleadores: goleadores,
    );
  }
}
