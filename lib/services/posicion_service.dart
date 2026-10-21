import '../models/equipo.dart';
import '../models/partido.dart';
import '../models/posicion.dart';

class PosicionService {
  List<Posicion> calcularPosiciones({
    required List<Equipo> equipos,
    required List<Partido> partidos,
  }) {
    // Crear una posición inicial para cada equipo.
    final Map<String, Posicion> posiciones = {};

    for (final equipo in equipos) {
      posiciones[equipo.id] = Posicion(
        equipoId: equipo.id,
        nombreEquipo: equipo.nombre,
      );
    }

    // Analizar únicamente los partidos finalizados.
    for (final partido in partidos) {
      if (partido.estado != 'Finalizado') {
        continue;
      }

      final local = posiciones[partido.equipoLocalId];
      final visitante = posiciones[partido.equipoVisitanteId];

      // Ignorar encuentros cuyos equipos ya no existen.
      if (local == null || visitante == null) {
        continue;
      }

      final golesLocal = partido.golesLocal;
      final golesVisitante = partido.golesVisitante;

      // Estadísticas de goles.
      local.golesFavor += golesLocal;
      local.golesContra += golesVisitante;

      visitante.golesFavor += golesVisitante;
      visitante.golesContra += golesLocal;

      // Resultado del partido.
      if (golesLocal > golesVisitante) {
        local.registrarVictoria();
        visitante.registrarDerrota();
      } else if (golesLocal < golesVisitante) {
        visitante.registrarVictoria();
        local.registrarDerrota();
      } else {
        local.registrarEmpate();
        visitante.registrarEmpate();
      }
    }

    final resultado = posiciones.values.toList();

    // Ordenar por puntos, diferencia de goles y goles a favor.
    resultado.sort((a, b) {
      final comparacionPuntos = b.puntos.compareTo(a.puntos);

      if (comparacionPuntos != 0) {
        return comparacionPuntos;
      }

      final comparacionDiferencia = b.diferenciaGoles.compareTo(
        a.diferenciaGoles,
      );

      if (comparacionDiferencia != 0) {
        return comparacionDiferencia;
      }

      final comparacionGoles = b.golesFavor.compareTo(a.golesFavor);

      if (comparacionGoles != 0) {
        return comparacionGoles;
      }

      return a.nombreEquipo.compareTo(b.nombreEquipo);
    });

    return resultado;
  }
}
