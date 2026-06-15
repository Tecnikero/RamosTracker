import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/ramo.dart';

class EvaluacionesScreen extends StatefulWidget {
  final Ramo ramo;
  const EvaluacionesScreen({super.key, required this.ramo});

  @override
  State<EvaluacionesScreen> createState() => _EvaluacionesScreenState();
}

class _EvaluacionesScreenState extends State<EvaluacionesScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  List<Evaluacion> _todasLasEvaluaciones = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _extraerEvaluaciones();
  }

  void _extraerEvaluaciones() {
    List<Evaluacion> temp = [];
    if (widget.ramo.usaSistemaRA) {
      for (var ra in widget.ramo.gruposRA) {
        temp.addAll(ra.evaluaciones);
      }
    } else {
      temp.addAll(widget.ramo.evaluaciones);
    }
    
    _todasLasEvaluaciones = temp.where((e) => e.fecha != null && e.fecha!.isNotEmpty).toList();
  }

  DateTime? _traducirFecha(String fechaStr) {
    try {
      final partes = fechaStr.split('/');
      return DateTime(int.parse(partes[2]), int.parse(partes[1]), int.parse(partes[0]));
    } catch (e) {
      return null;
    }
  }

  List<Evaluacion> _obtenerEvaluacionesDelDia(DateTime day) {
    return _todasLasEvaluaciones.where((eval) {
      DateTime? fechaEval = _traducirFecha(eval.fecha!);
      return fechaEval != null && isSameDay(fechaEval, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final evaluacionesDelDiaSeleccionado = _obtenerEvaluacionesDelDia(_selectedDay ?? _focusedDay);

    return Scaffold(
      appBar: AppBar(
        title: Text('Calendario - ${widget.ramo.nombre}'),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: TableCalendar<Evaluacion>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
              
              eventLoader: _obtenerEvaluacionesDelDia,
              
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },
            ),
          ),
          
          const Divider(height: 30),
          
          Expanded(
            child: evaluacionesDelDiaSeleccionado.isEmpty
                ? const Center(
                    child: Text(
                      'No hay evaluaciones para este día.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: evaluacionesDelDiaSeleccionado.length,
                    itemBuilder: (context, index) {
                      final eval = evaluacionesDelDiaSeleccionado[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.assignment, color: Colors.redAccent),
                          ),
                          title: Text(
                            eval.nombre,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Ponderación: ${eval.porcentaje}%'),
                          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}