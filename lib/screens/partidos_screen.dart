import 'package:flutter/material.dart';

import '../models/equipo.dart';
import '../models/partido.dart';
import '../services/equipo_service.dart';
import '../services/partido_service.dart';

class PartidosScreen extends StatefulWidget {
  const PartidosScreen({super.key});

  @override
  State<PartidosScreen> createState() => _PartidosScreenState();
}

class _PartidosScreenState extends State<PartidosScreen> {
  final EquipoService _equipoService = EquipoService();
  final PartidoService _partidoService = PartidoService();

  String? _equipoLocalId;
  String? _equipoVisitanteId;

  DateTime _fechaSeleccionada = DateTime.now();

  bool _guardando = false;

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Selecciona la fecha del partido',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (fecha != null && mounted) {
      setState(() {
        _fechaSeleccionada = DateTime(fecha.year, fecha.month, fecha.day, 15);
      });
    }
  }

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }

  Future<void> _registrarPartido(List<Equipo> equipos) async {
    if (_equipoLocalId == null || _equipoVisitanteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona los dos equipos.')),
      );
      return;
    }

    if (_equipoLocalId == _equipoVisitanteId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Un equipo no puede jugar contra sí mismo.'),
        ),
      );
      return;
    }

    final local = equipos.firstWhere((equipo) => equipo.id == _equipoLocalId);

    final visitante = equipos.firstWhere(
      (equipo) => equipo.id == _equipoVisitanteId,
    );

    setState(() {
      _guardando = true;
    });

    try {
      final partido = Partido(
        id: '',
        equipoLocalId: local.id,
        equipoLocalNombre: local.nombre,
        equipoVisitanteId: visitante.id,
        equipoVisitanteNombre: visitante.nombre,
        fecha: _fechaSeleccionada,
        golesLocal: 0,
        golesVisitante: 0,
        estado: 'Programado',
      );

      await _partidoService.registrarPartido(partido);

      if (!mounted) return;

      setState(() {
        _equipoLocalId = null;
        _equipoVisitanteId = null;
        _fechaSeleccionada = DateTime.now();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Partido programado correctamente.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar el partido: $e'),
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

  Future<void> _registrarResultado(Partido partido) async {
    final golesLocalController = TextEditingController(
      text: '${partido.golesLocal}',
    );

    final golesVisitanteController = TextEditingController(
      text: '${partido.golesVisitante}',
    );

    String estadoSeleccionado = partido.estado;

    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, actualizarDialogo) {
            return AlertDialog(
              title: const Text('Registrar resultado'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${partido.equipoLocalNombre} '
                      'vs. ${partido.equipoVisitanteNombre}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: golesLocalController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              labelText: 'Local',
                              border: const OutlineInputBorder(),
                              helperText: partido.equipoLocalNombre,
                            ),
                          ),
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('-', style: TextStyle(fontSize: 24)),
                        ),

                        Expanded(
                          child: TextField(
                            controller: golesVisitanteController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              labelText: 'Visitante',
                              border: const OutlineInputBorder(),
                              helperText: partido.equipoVisitanteNombre,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      value: estadoSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Estado del partido',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Programado',
                          child: Text('Programado'),
                        ),
                        DropdownMenuItem(
                          value: 'En juego',
                          child: Text('En juego'),
                        ),
                        DropdownMenuItem(
                          value: 'Finalizado',
                          child: Text('Finalizado'),
                        ),
                      ],
                      onChanged: (valor) {
                        if (valor != null) {
                          actualizarDialogo(() {
                            estadoSeleccionado = valor;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    final golesLocal = int.tryParse(
                      golesLocalController.text.trim(),
                    );

                    final golesVisitante = int.tryParse(
                      golesVisitanteController.text.trim(),
                    );

                    if (golesLocal == null ||
                        golesVisitante == null ||
                        golesLocal < 0 ||
                        golesVisitante < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Introduce goles válidos, iguales o mayores que cero.',
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(dialogContext, {
                      'golesLocal': golesLocal,
                      'golesVisitante': golesVisitante,
                      'estado': estadoSeleccionado,
                    });
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    golesLocalController.dispose();
    golesVisitanteController.dispose();

    if (resultado == null || !mounted) return;

    try {
      await _partidoService.actualizarResultado(
        partidoId: partido.id,
        golesLocal: resultado['golesLocal'] as int,
        golesVisitante: resultado['golesVisitante'] as int,
        estado: resultado['estado'] as String,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resultado actualizado correctamente.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar el resultado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _eliminarPartido(Partido partido) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar partido'),
          content: Text(
            '¿Deseas eliminar el partido entre '
            '${partido.equipoLocalNombre} y '
            '${partido.equipoVisitanteNombre}?',
          ),
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
        );
      },
    );

    if (confirmar != true || !mounted) return;

    try {
      await _partidoService.eliminarPartido(partido.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Partido eliminado correctamente.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el partido: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administrar partidos')),
      body: StreamBuilder<List<Equipo>>(
        stream: _equipoService.obtenerEquipos(),
        builder: (context, snapshotEquipos) {
          if (snapshotEquipos.hasError) {
            return const Center(
              child: Text('No se pudieron cargar los equipos.'),
            );
          }

          if (snapshotEquipos.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final equipos = snapshotEquipos.data ?? [];

          if (equipos.length < 2) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Necesitas registrar al menos dos equipos '
                  'antes de programar un partido.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17),
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Programar nuevo partido',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: _equipoLocalId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Equipo local',
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
                    _equipoLocalId = valor;

                    if (_equipoLocalId == _equipoVisitanteId) {
                      _equipoVisitanteId = null;
                    }
                  });
                },
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: _equipoVisitanteId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Equipo visitante',
                  prefixIcon: Icon(Icons.shield_outlined),
                  border: OutlineInputBorder(),
                ),
                items: equipos
                    .where((equipo) => equipo.id != _equipoLocalId)
                    .map((equipo) {
                      return DropdownMenuItem<String>(
                        value: equipo.id,
                        child: Text(equipo.nombre),
                      );
                    })
                    .toList(),
                onChanged: (valor) {
                  setState(() {
                    _equipoVisitanteId = valor;
                  });
                },
              ),

              const SizedBox(height: 15),

              OutlinedButton.icon(
                onPressed: _seleccionarFecha,
                icon: const Icon(Icons.calendar_month),
                label: Text(
                  'Fecha del partido: '
                  '${_formatearFecha(_fechaSeleccionada)}',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: _guardando
                      ? null
                      : () => _registrarPartido(equipos),
                  icon: _guardando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add),
                  label: Text(
                    _guardando ? 'Guardando...' : 'Programar partido',
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Calendario de partidos',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              StreamBuilder<List<Partido>>(
                stream: _partidoService.obtenerPartidos(),
                builder: (context, snapshotPartidos) {
                  if (snapshotPartidos.hasError) {
                    return const Text(
                      'No se pudieron cargar los partidos. '
                      'Comprueba las reglas de Firestore.',
                    );
                  }

                  if (snapshotPartidos.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final partidos = snapshotPartidos.data ?? [];

                  if (partidos.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Todavía no hay partidos programados.',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return Column(
                    children: partidos.map((partido) {
                      final finalizado = partido.estado == 'Finalizado';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      partido.equipoLocalNombre,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  Text(
                                    '${partido.golesLocal} - '
                                    '${partido.golesVisitante}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  Expanded(
                                    child: Text(
                                      partido.equipoVisitanteNombre,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              Text(
                                'Fecha: '
                                '${_formatearFecha(partido.fecha)}',
                              ),

                              const SizedBox(height: 6),

                              Chip(
                                avatar: Icon(
                                  finalizado
                                      ? Icons.check_circle
                                      : partido.estado == 'En juego'
                                      ? Icons.sports
                                      : Icons.schedule,
                                  size: 18,
                                ),
                                label: Text(partido.estado),
                                backgroundColor: finalizado
                                    ? Colors.green.shade100
                                    : partido.estado == 'En juego'
                                    ? Colors.orange.shade100
                                    : Colors.blue.shade100,
                              ),

                              const SizedBox(height: 8),

                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 8,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        _registrarResultado(partido),
                                    icon: const Icon(Icons.edit),
                                    label: Text(
                                      finalizado
                                          ? 'Editar resultado'
                                          : 'Registrar resultado',
                                    ),
                                  ),

                                  IconButton(
                                    tooltip: 'Eliminar partido',
                                    onPressed: () => _eliminarPartido(partido),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
