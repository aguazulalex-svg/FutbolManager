import 'package:flutter/material.dart';

import '../models/equipo.dart';
import '../models/jugador.dart';
import '../services/equipo_service.dart';
import '../services/jugador_service.dart';

class JugadoresScreen extends StatefulWidget {
  const JugadoresScreen({super.key});

  @override
  State<JugadoresScreen> createState() => _JugadoresScreenState();
}

class _JugadoresScreenState extends State<JugadoresScreen> {
  final EquipoService _equipoService = EquipoService();
  final JugadorService _jugadorService = JugadorService();

  final TextEditingController _nombreController = TextEditingController();

  final TextEditingController _numeroController = TextEditingController();

  final TextEditingController _edadController = TextEditingController();

  final List<String> _posiciones = [
    'Portero',
    'Defensa',
    'Centrocampista',
    'Delantero',
  ];

  String? _equipoSeleccionado;
  String? _posicionSeleccionada;

  bool _guardando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _numeroController.dispose();
    _edadController.dispose();
    super.dispose();
  }

  Future<void> _registrarJugador(List<Equipo> equipos) async {
    final nombre = _nombreController.text.trim();
    final numero = int.tryParse(_numeroController.text.trim());
    final edad = int.tryParse(_edadController.text.trim());

    if (nombre.isEmpty ||
        numero == null ||
        numero < 1 ||
        numero > 99 ||
        edad == null ||
        edad < 1 ||
        edad > 100 ||
        _equipoSeleccionado == null ||
        _posicionSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Completa todos los campos con datos válidos. '
            'El número de camiseta debe estar entre 1 y 99.',
          ),
        ),
      );
      return;
    }

    final equipo = equipos.firstWhere(
      (elemento) => elemento.id == _equipoSeleccionado,
    );

    setState(() {
      _guardando = true;
    });

    try {
      final jugador = Jugador(
        id: '',
        nombre: nombre,
        numeroCamiseta: numero,
        posicion: _posicionSeleccionada!,
        edad: edad,
        equipoId: equipo.id,
        equipoNombre: equipo.nombre,
      );

      await _jugadorService.registrarJugador(jugador);

      _nombreController.clear();
      _numeroController.clear();
      _edadController.clear();

      setState(() {
        _equipoSeleccionado = null;
        _posicionSeleccionada = null;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jugador registrado correctamente.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar jugador: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  Future<void> _eliminarJugador(Jugador jugador) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar jugador'),
        content: Text('¿Deseas eliminar a ${jugador.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      await _jugadorService.eliminarJugador(jugador.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jugador eliminado correctamente.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al eliminar jugador: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administrar jugadores')),
      body: StreamBuilder<List<Equipo>>(
        stream: _equipoService.obtenerEquipos(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('No se pudieron cargar los equipos.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final equipos = snapshot.data ?? [];

          if (equipos.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Primero debes registrar al menos un equipo.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Registrar nuevo jugador',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _nombreController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: _numeroController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Número de camiseta (1-99)',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: _edadController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Edad',
                  prefixIcon: Icon(Icons.cake),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: _equipoSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Equipo',
                  prefixIcon: Icon(Icons.shield),
                  border: OutlineInputBorder(),
                ),
                items: equipos.map((equipo) {
                  return DropdownMenuItem<String>(
                    value: equipo.id,
                    child: Text(equipo.nombre),
                  );
                }).toList(),
                onChanged: (valor) {
                  setState(() {
                    _equipoSeleccionado = valor;
                  });
                },
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: _posicionSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Posición',
                  prefixIcon: Icon(Icons.sports_soccer),
                  border: OutlineInputBorder(),
                ),
                items: _posiciones.map((posicion) {
                  return DropdownMenuItem<String>(
                    value: posicion,
                    child: Text(posicion),
                  );
                }).toList(),
                onChanged: (valor) {
                  setState(() {
                    _posicionSeleccionada = valor;
                  });
                },
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: _guardando
                      ? null
                      : () => _registrarJugador(equipos),
                  icon: _guardando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.person_add),
                  label: Text(
                    _guardando ? 'Guardando...' : 'Registrar jugador',
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Jugadores registrados',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              StreamBuilder<List<Jugador>>(
                stream: _jugadorService.obtenerJugadores(),
                builder: (context, snapshotJugadores) {
                  if (snapshotJugadores.hasError) {
                    return const Text('No se pudieron cargar los jugadores.');
                  }

                  if (snapshotJugadores.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final jugadores = snapshotJugadores.data ?? [];

                  if (jugadores.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Todavía no hay jugadores registrados.',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return Column(
                    children: jugadores.map((jugador) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text('${jugador.numeroCamiseta}'),
                          ),
                          title: Text(jugador.nombre),
                          subtitle: Text(
                            '${jugador.posicion} · '
                            '${jugador.edad} años\n'
                            '${jugador.equipoNombre}',
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            tooltip: 'Eliminar jugador',
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => _eliminarJugador(jugador),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
