import 'package:flutter/material.dart';

import '../models/partido.dart';
import '../services/partido_service.dart';
import '../services/goleador_service.dart';

class GoleadoresScreen extends StatelessWidget {
  const GoleadoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final partidoService = PartidoService();
    final goleadorService = GoleadorService();

    return Scaffold(
      appBar: AppBar(title: const Text('Tabla de goleadores')),
      body: StreamBuilder<List<Partido>>(
        stream: partidoService.obtenerPartidos(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('No se pudieron cargar los goleadores.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final partidos = snapshot.data ?? [];

          final goleadores = goleadorService.calcularGoleadores(partidos);

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                color: const Color(0xFF146B3A),
                child: const Column(
                  children: [
                    Icon(Icons.sports_soccer, size: 48, color: Colors.white),
                    SizedBox(height: 10),
                    Text(
                      'MÁXIMOS GOLEADORES',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Clasificación oficial del torneo',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: goleadores.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'Todavía no hay goles registrados '
                            'por jugador en partidos finalizados.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: goleadores.length,
                        itemBuilder: (context, index) {
                          final goleador = goleadores[index];

                          final nombre = goleador['jugadorNombre'] as String;

                          final equipo = goleador['equipoNombre'] as String;

                          final goles = goleador['goles'] as int;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: index == 0
                                    ? const Color(0xFFFFD700)
                                    : const Color(0xFFE3F1E8),
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              title: Text(
                                nombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(equipo),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.sports_soccer,
                                    color: Color(0xFF146B3A),
                                  ),
                                  Text(
                                    '$goles',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Solo se contabilizan los goles de '
                  'partidos finalizados.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
