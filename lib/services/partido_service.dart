import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/partido.dart';

class PartidoService {
  final CollectionReference<Map<String, dynamic>> _partidos = FirebaseFirestore
      .instance
      .collection('partidos');

  // Registrar un partido nuevo.
  Future<void> registrarPartido(Partido partido) async {
    await _partidos.add(partido.toMap());
  }

  // Consultar los partidos en tiempo real.
  Stream<List<Partido>> obtenerPartidos() {
    return _partidos.orderBy('fecha').snapshots().map((snapshot) {
      return snapshot.docs.map((documento) {
        return Partido.fromMap(documento.id, documento.data());
      }).toList();
    });
  }

  // Actualizar marcador, estado y goleadores.
  Future<void> actualizarResultado({
    required String partidoId,
    required int golesLocal,
    required int golesVisitante,
    required String estado,
    List<Map<String, dynamic>> goleadores = const [],
  }) async {
    await _partidos.doc(partidoId).update({
      'golesLocal': golesLocal,
      'golesVisitante': golesVisitante,
      'estado': estado,
      'goleadores': goleadores,
    });
  }

  // Eliminar un partido.
  Future<void> eliminarPartido(String partidoId) async {
    await _partidos.doc(partidoId).delete();
  }
}
