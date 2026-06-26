import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/ramo.dart';

class EvaluacionesScreen extends StatefulWidget {
  final Ramo? ramo;
  const EvaluacionesScreen({super.key, this.ramo});

  @override
  State<EvaluacionesScreen> createState() => _EvaluacionesScreenState();
}

class _EvaluacionesScreenState extends State<EvaluacionesScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  DateTime? _traducirFecha(String fechaStr) {
    try {
      final partes = fechaStr.split('/');
      return DateTime(int.parse(partes[2]), int.parse(partes[1]), int.parse(partes[0]));
    } catch (_) {
      return null;
    }
  }

  List<Map<String, dynamic>> _buildTodasEvals(List<Ramo> ramos) {
    List<Map<String, dynamic>> resultado = [];
    for (final ramo in ramos) {
      final color = ramo.color;
      List<Evaluacion> evals = [];
      if (ramo.usaSistemaRA) {
        for (var ra in ramo.gruposRA) evals.addAll(ra.evaluaciones);
      } else {
        evals.addAll(ramo.evaluaciones);
      }
      for (var eval in evals) {
        if (eval.fecha != null && eval.fecha!.isNotEmpty) {
          resultado.add({'eval': eval, 'ramoNombre': ramo.nombre, 'color': color});
        }
      }
    }
    return resultado;
  }

  List<Map<String, dynamic>> _evalDelDia(List<Map<String, dynamic>> todas, DateTime day) {
    return todas.where((item) {
      final fecha = _traducirFecha((item['eval'] as Evaluacion).fecha!);
      return fecha != null && isSameDay(fecha, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Ramo>>(
      valueListenable: Hive.box<Ramo>('ramosBox').listenable(),
      builder: (context, box, _) {
        final todosRamos = box.values.toList();
        final ramosActivos = widget.ramo != null
            ? todosRamos.where((r) => r.key == widget.ramo!.key).toList()
            : todosRamos;

        final todasEvals = _buildTodasEvals(ramosActivos);
        final evalDia = _evalDelDia(todasEvals, _selectedDay ?? _focusedDay);

        final colorAccent = widget.ramo?.color ?? Colors.blue;

        final leyenda = <String, Color>{};
        if (widget.ramo == null) {
          for (final ramo in todosRamos) {
            bool tieneEval = ramo.usaSistemaRA
                ? ramo.gruposRA.any((ra) => ra.evaluaciones.any((e) => e.fecha != null && e.fecha!.isNotEmpty))
                : ramo.evaluaciones.any((e) => e.fecha != null && e.fecha!.isNotEmpty);
            if (tieneEval) leyenda[ramo.nombre] = ramo.color;
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.ramo != null
                ? 'Calendario - ${widget.ramo!.nombre}'
                : 'Calendario de Evaluaciones'),
            backgroundColor: colorAccent.withOpacity(0.2),
          ),
          body: Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: TableCalendar<Map<String, dynamic>>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                        color: colorAccent.withOpacity(0.3), shape: BoxShape.circle),
                    selectedDecoration:
                        BoxDecoration(color: colorAccent, shape: BoxShape.circle),
                  ),
                  eventLoader: (day) => _evalDelDia(todasEvals, day),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      if (events.isEmpty) return const SizedBox.shrink();
                      final colores = events
                          .map((e) => (e as Map<String, dynamic>)['color'] as Color)
                          .toSet()
                          .take(3)
                          .toList();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: colores
                              .map((c) => Container(
                                    width: 7,
                                    height: 7,
                                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                    decoration:
                                        BoxDecoration(color: c, shape: BoxShape.circle),
                                  ))
                              .toList(),
                        ),
                      );
                    },
                  ),
                  onDaySelected: (sel, foc) {
                    if (!isSameDay(_selectedDay, sel)) {
                      setState(() { _selectedDay = sel; _focusedDay = foc; });
                    }
                  },
                ),
              ),

              if (leyenda.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: leyenda.entries
                        .map((e) => Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(color: e.value, shape: BoxShape.circle)),
                                const SizedBox(width: 5),
                                Text(e.key,
                                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ))
                        .toList(),
                  ),
                ),

              const Divider(height: 20),

              Expanded(
                child: evalDia.isEmpty
                    ? const Center(
                        child: Text('No hay evaluaciones para este día.',
                            style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: evalDia.length,
                        itemBuilder: (context, index) {
                          final item = evalDia[index];
                          final eval = item['eval'] as Evaluacion;
                          final color = item['color'] as Color;
                          final ramoNombre = item['ramoNombre'] as String;
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: color.withOpacity(0.3), width: 1),
                            ),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: color.withOpacity(0.15), shape: BoxShape.circle),
                                child: Icon(Icons.assignment, color: color),
                              ),
                              title: Text(eval.nombre,
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (widget.ramo == null)
                                    Text(ramoNombre,
                                        style: TextStyle(
                                            color: color,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12)),
                                  Text('Ponderación: ${eval.porcentaje}%'),
                                ],
                              ),
                              trailing: Container(
                                  width: 12,
                                  height: 12,
                                  decoration:
                                      BoxDecoration(color: color, shape: BoxShape.circle)),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}