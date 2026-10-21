import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/jugador.dart';

class JugadorService {
  final CollectionReference<Map<String, dynamic>> _jugadores = FirebaseFirestore
      .instance
      .collection('jugadores');

  // Registrar un jugador.
  Future<void> registrarJugador(Jugador jugador) async {
    await _jugadores.add({
      ...jugador.toMap(),
      'fechaRegistro': FieldValue.serverTimestamp(),
    });
  }

  // Obtener todos los jugadores en tiempo real.
  Stream<List<Jugador>> obtenerJugadores() {
    return _jugadores.orderBy('nombre').snapshots().map((snapshot) {
      return snapshot.docs.map((documento) {
        return Jugador.fromMap(documento.id, documento.data());
      }).toList();
    });
  }

  // Consultar jugadores de un equipo.
  Stream<List<Jugador>> obtenerJugadoresPorEquipo(String equipoId) {
    return _jugadores
        .where('equipoId', isEqualTo: equipoId)
        .orderBy('nombre')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((documento) {
            return Jugador.fromMap(documento.id, documento.data());
          }).toList();
        });
  }

  // Eliminar un jugador.
  Future<void> eliminarJugador(String jugadorId) async {
    await _jugadores.doc(jugadorId).delete();
  }
}
