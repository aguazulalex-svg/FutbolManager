import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/equipo.dart';

class EquipoService {
  final CollectionReference<Map<String, dynamic>> _equipos = FirebaseFirestore
      .instance
      .collection('equipos');

  // Registrar un equipo.
  Future<void> registrarEquipo(Equipo equipo) async {
    await _equipos.add(equipo.toMap());
  }

  // Obtener los equipos en tiempo real.
  Stream<List<Equipo>> obtenerEquipos() {
    return _equipos.orderBy('nombre').snapshots().map((snapshot) {
      return snapshot.docs.map((documento) {
        return Equipo.fromMap(documento.id, documento.data());
      }).toList();
    });
  }

  // Actualizar un equipo.
  Future<void> actualizarEquipo(Equipo equipo) async {
    await _equipos.doc(equipo.id).update(equipo.toMap());
  }

  // Eliminar un equipo.
  Future<void> eliminarEquipo(String id) async {
    await _equipos.doc(id).delete();
  }
}
