import 'package:flutter/material.dart';

import '../models/equipo.dart';
import '../models/partido.dart';
import '../models/posicion.dart';

import '../services/equipo_service.dart';
import '../services/partido_service.dart';
import '../services/posicion_service.dart';

class PosicionesScreen extends StatelessWidget {
  const PosicionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final equipoService = EquipoService();
    final partidoService = PartidoService();
    final posicionService = PosicionService();

    return Scaffold(
      appBar: AppBar(title: const Text('Tabla de posiciones')),
      body: StreamBuilder<List<Equipo>>(
        stream: equipoService.obtenerEquipos(),
        builder: (context, equiposSnapshot) {
          if (equiposSnapshot.hasError) {
            return const Center(child: Text('Error al cargar los equipos.'));
          }

          if (equiposSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final equipos = equiposSnapshot.data ?? [];

          return StreamBuilder<List<Partido>>(
            stream: partidoService.obtenerPartidos(),
            builder: (context, partidosSnapshot) {
              if (partidosSnapshot.hasError) {
                return const Center(
                  child: Text('Error al cargar los partidos.'),
                );
              }

              if (partidosSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final partidos = partidosSnapshot.data ?? [];

              final List<Posicion> posiciones = posicionService
                  .calcularPosiciones(equipos: equipos, partidos: partidos);

              if (posiciones.isEmpty) {
                return const Center(
                  child: Text('Todavía no hay equipos registrados.'),
                );
              }

              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    color: const Color(0xFF146B3A),
                    child: const Column(
                      children: [
                        Icon(Icons.emoji_events, color: Colors.white, size: 45),
                        SizedBox(height: 8),
                        Text(
                          'CLASIFICACIÓN GENERAL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Los resultados se actualizan automáticamente',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            const Color(0xFFE3F1E8),
                          ),
                          columns: const [
                            DataColumn(label: Text('Pos.')),
                            DataColumn(label: Text('Equipo')),
                            DataColumn(label: Text('PJ')),
                            DataColumn(label: Text('PG')),
                            DataColumn(label: Text('PE')),
                            DataColumn(label: Text('PP')),
                            DataColumn(label: Text('GF')),
                            DataColumn(label: Text('GC')),
                            DataColumn(label: Text('DG')),
                            DataColumn(label: Text('Pts.')),
                          ],
                          rows: List.generate(posiciones.length, (index) {
                            final posicion = posiciones[index];

                            return DataRow(
                              color: WidgetStateProperty.resolveWith((estados) {
                                if (index == 0) {
                                  return const Color(0xFFDFF3E4);
                                }

                                return null;
                              }),
                              cells: [
                                DataCell(
                                  Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontWeight: index == 0
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),

                                DataCell(
                                  SizedBox(
                                    width: 150,
                                    child: Text(
                                      posicion.nombreEquipo,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: index == 0
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),

                                DataCell(Text('${posicion.partidosJugados}')),

                                DataCell(Text('${posicion.partidosGanados}')),

                                DataCell(Text('${posicion.partidosEmpatados}')),

                                DataCell(Text('${posicion.partidosPerdidos}')),

                                DataCell(Text('${posicion.golesFavor}')),

                                DataCell(Text('${posicion.golesContra}')),

                                DataCell(
                                  Text(
                                    posicion.diferenciaGoles > 0
                                        ? '+${posicion.diferenciaGoles}'
                                        : '${posicion.diferenciaGoles}',
                                  ),
                                ),

                                DataCell(
                                  Text(
                                    '${posicion.puntos}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF146B3A),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'PJ: jugados · PG: ganados · PE: empatados · '
                      'PP: perdidos · GF: goles a favor · '
                      'GC: goles en contra · DG: diferencia · '
                      'Pts.: puntos',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
