import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'equipos_screen.dart';
import '../services/auth_service.dart';
import 'jugadores_screen.dart';
import 'partidos_screen.dart';
import 'posiciones_screen.dart';
import 'goleadores_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? usuario = FirebaseAuth.instance.currentUser;

    final List<Map<String, dynamic>> opciones = [
      {
        'titulo': 'Equipos',
        'icono': Icons.shield,
        'color': const Color(0xFF146B3A),
      },
      {
        'titulo': 'Jugadores',
        'icono': Icons.groups,
        'color': const Color(0xFF2878B5),
      },
      {
        'titulo': 'Partidos',
        'icono': Icons.sports_soccer,
        'color': const Color(0xFFEF8B22),
      },
      {
        'titulo': 'Posiciones',
        'icono': Icons.leaderboard,
        'color': const Color(0xFF7546A8),
      },
      {
        'titulo': 'Goleadores',
        'icono': Icons.emoji_events,
        'color': const Color(0xFFBD8A00),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('FutbolManager'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await AuthService().cerrarSesion();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Panel principal',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Bienvenido${usuario?.displayName == null ? '' : ', ${usuario!.displayName}'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 25),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF146B3A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.emoji_events, color: Colors.white, size: 45),
                  SizedBox(height: 15),
                  Text(
                    'Gestión del torneo',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Administra equipos, jugadores y resultados.',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'Módulos',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: opciones.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.15,
              ),
              itemBuilder: (context, index) {
                final opcion = opciones[index];

                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    final titulo = opcion['titulo'] as String;

                    if (titulo == 'Equipos') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EquiposScreen(),
                        ),
                      );
                    } else if (titulo == 'Jugadores') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const JugadoresScreen(),
                        ),
                      );
                    } else if (titulo == 'Partidos') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PartidosScreen(),
                        ),
                      );
                    } else if (titulo == 'Posiciones') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PosicionesScreen(),
                        ),
                      );
                    } else if (titulo == 'Goleadores') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GoleadoresScreen(),
                        ),
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8E2)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          opcion['icono'] as IconData,
                          color: opcion['color'] as Color,
                          size: 38,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          opcion['titulo'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
