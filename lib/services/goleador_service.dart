import '../models/partido.dart';

class GoleadorService {
  List<Map<String, dynamic>> calcularGoleadores(List<Partido> partidos) {
    final Map<String, Map<String, dynamic>> acumulado = {};

    for (final partido in partidos) {
      // Solo cuentan los partidos finalizados.
      if (partido.estado != 'Finalizado') {
        continue;
      }

      for (final goleador in partido.goleadores) {
        final jugadorId = goleador['jugadorId']?.toString() ?? '';

        final goles = (goleador['goles'] as num?)?.toInt() ?? 0;

        if (jugadorId.isEmpty || goles <= 0) {
          continue;
        }

        // Validar que el jugador pertenezca a uno de los equipos.
        final equipoId = goleador['equipoId']?.toString() ?? '';

        if (equipoId != partido.equipoLocalId &&
            equipoId != partido.equipoVisitanteId) {
          continue;
        }

        if (!acumulado.containsKey(jugadorId)) {
          acumulado[jugadorId] = {
            'jugadorId': jugadorId,
            'jugadorNombre': goleador['jugadorNombre']?.toString() ?? '',
            'equipoId': equipoId,
            'equipoNombre': goleador['equipoNombre']?.toString() ?? '',
            'goles': 0,
          };
        }

        // Acumular los goles del jugador.
        acumulado[jugadorId]!['goles'] =
            (acumulado[jugadorId]!['goles'] as int) + goles;
      }
    }

    final resultado = acumulado.values.toList();

    // Ordenar de mayor a menor cantidad de goles.
    resultado.sort((a, b) {
      final comparacion = (b['goles'] as int).compareTo(a['goles'] as int);

      if (comparacion != 0) {
        return comparacion;
      }

      return (a['jugadorNombre'] as String).compareTo(
        b['jugadorNombre'] as String,
      );
    });

    return resultado;
  }
}
