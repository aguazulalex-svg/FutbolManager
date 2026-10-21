import 'package:flutter/material.dart';

import '../models/equipo.dart';
import '../services/equipo_service.dart';

class EquiposScreen extends StatefulWidget {
  const EquiposScreen({super.key});

  @override
  State<EquiposScreen> createState() => _EquiposScreenState();
}

class _EquiposScreenState extends State<EquiposScreen> {
  final EquipoService _servicio = EquipoService();

  final TextEditingController _nombreController = TextEditingController();

  final TextEditingController _entrenadorController = TextEditingController();

  final TextEditingController _ciudadController = TextEditingController();

  bool _guardando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _entrenadorController.dispose();
    _ciudadController.dispose();
    super.dispose();
  }

  Future<void> _registrarEquipo() async {
    final nombre = _nombreController.text.trim();
    final entrenador = _entrenadorController.text.trim();
    final ciudad = _ciudadController.text.trim();

    if (nombre.isEmpty || entrenador.isEmpty || ciudad.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos.')),
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final equipo = Equipo(
        id: '',
        nombre: nombre,
        entrenador: entrenador,
        ciudad: ciudad,
        fechaRegistro: DateTime.now(),
      );

      await _servicio.registrarEquipo(equipo);

      _nombreController.clear();
      _entrenadorController.clear();
      _ciudadController.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Equipo registrado correctamente.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar el equipo: $e'),
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

  Future<void> _confirmarEliminacion(Equipo equipo) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar equipo'),
        content: Text('¿Deseas eliminar el equipo ${equipo.nombre}?'),
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
      await _servicio.eliminarEquipo(equipo.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Equipo eliminado correctamente.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar el equipo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administrar equipos')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Registrar nuevo equipo',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _nombreController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nombre del equipo',
              prefixIcon: Icon(Icons.shield),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: _entrenadorController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nombre del entrenador',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: _ciudadController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Ciudad o localidad',
              prefixIcon: Icon(Icons.location_city),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: _guardando ? null : _registrarEquipo,
              icon: _guardando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add),
              label: Text(_guardando ? 'Guardando...' : 'Registrar equipo'),
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            'Equipos registrados',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          StreamBuilder<List<Equipo>>(
            stream: _servicio.obtenerEquipos(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text(
                  'No se pudieron cargar los equipos. '
                  'Comprueba la conexión y las reglas de Firestore.',
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final equipos = snapshot.data ?? [];

              if (equipos.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Todavía no hay equipos registrados.',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return Column(
                children: equipos.map((equipo) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.shield)),
                      title: Text(equipo.nombre),
                      subtitle: Text(
                        'Entrenador: ${equipo.entrenador}\n'
                        'Localidad: ${equipo.ciudad}',
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        tooltip: 'Eliminar equipo',
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => _confirmarEliminacion(equipo),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
