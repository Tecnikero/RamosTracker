import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/ramo.dart';

class HorarioScreen extends StatefulWidget {
  const HorarioScreen({super.key});

  @override
  State<HorarioScreen> createState() => _HorarioScreenState();
}

class _HorarioScreenState extends State<HorarioScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<String> diasSemana = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];

  final double _anchoColumna = 110.0;
  final double _altoHora = 54.0;
  final int _horaInicio = 8;
  final int _horaFin = 20;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      int diaActual = DateTime.now().weekday;
      double posicionDestino = (diaActual - 1) * _anchoColumna;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(posicionDestino,
            duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
      }
    });
  }

  double _traducirHoraADecimal(String timeStr) {
    try {
      final s = timeStr.trim();

      final regex24 = RegExp(r'^(\d{1,2}):(\d{2})$');
      final match24 = regex24.firstMatch(s);
      if (match24 != null) {
        int h = int.parse(match24.group(1)!);
        int m = int.parse(match24.group(2)!);
        return h + m / 60.0;
      }

      final regex12 = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false);
      final match12 = regex12.firstMatch(s);
      if (match12 != null) {
        int h = int.parse(match12.group(1)!);
        int m = int.parse(match12.group(2)!);
        final period = match12.group(3)!.toUpperCase();
        if (period == 'PM' && h < 12) h += 12;
        if (period == 'AM' && h == 12) h = 0;
        return h + m / 60.0;
      }

      return _horaInicio.toDouble();
    } catch (_) {
      return _horaInicio.toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalHoras = _horaFin - _horaInicio;
    int diaActual = DateTime.now().weekday;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Horario')),
      body: ValueListenableBuilder<Box<Ramo>>(
        valueListenable: Hive.box<Ramo>('ramosBox').listenable(),
        builder: (context, box, _) {
          final ramos = box.values.toList();

          Map<String, List<Map<String, dynamic>>> horarioPorDia = {
            for (var dia in diasSemana) dia: []
          };

          for (var ramo in ramos) {
            for (var bloque in ramo.horarios) {
              if (horarioPorDia.containsKey(bloque.dia)) {
                horarioPorDia[bloque.dia]!.add({
                  'ramo': ramo.nombre,
                  'inicio': bloque.horaInicio,
                  'fin': bloque.horaFin,
                  'color': ramo.color,
                });
              }
            }
          }

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 50,
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      ...List.generate(totalHoras, (index) {
                        return Container(
                          height: _altoHora,
                          alignment: Alignment.topCenter,
                          padding: const EdgeInsets.only(top: 0),
                          child: Text(
                            '${_horaInicio + index}:00',
                            style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(diasSemana.length, (index) {
                        String dia = diasSemana[index];
                        List<Map<String, dynamic>> clases = horarioPorDia[dia]!;
                        bool esHoy = (index + 1) == diaActual;

                        return Container(
                          width: _anchoColumna,
                          decoration: BoxDecoration(
                            color: esHoy ? Colors.blue.withOpacity(0.05) : null,
                            border: Border(right: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1)),
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 50,
                                width: double.infinity,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: esHoy
                                      ? Colors.blue.withOpacity(0.2)
                                      : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
                                  border: Border(
                                      bottom: BorderSide(color: Colors.grey.withOpacity(0.5), width: esHoy ? 2 : 1)),
                                ),
                                child: Text(
                                  dia.toUpperCase(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: esHoy ? Colors.blue : null),
                                ),
                              ),

                              SizedBox(
                                height: totalHoras * _altoHora,
                                child: Stack(
                                  children: [
                                    // Líneas de hora
                                    ...List.generate(totalHoras, (i) {
                                      return Positioned(
                                        top: i * _altoHora,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          height: _altoHora,
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  top: BorderSide(
                                                      color: Colors.grey.withOpacity(0.2), width: 1))),
                                        ),
                                      );
                                    }),

                                    ...clases.map((clase) {
                                      double inicioM = _traducirHoraADecimal(clase['inicio']);
                                      double finM = _traducirHoraADecimal(clase['fin']);
                                      final Color ramoColor = clase['color'] as Color;

                                      if (inicioM < _horaInicio) inicioM = _horaInicio.toDouble();
                                      if (finM > _horaFin) finM = _horaFin.toDouble();
                                      if (finM <= inicioM) finM = inicioM + 1.0;

                                      double top = (inicioM - _horaInicio) * _altoHora;
                                      double alto = (finM - inicioM) * _altoHora;

                                      return Positioned(
                                        top: top,
                                        left: 2,
                                        right: 2,
                                        height: alto,
                                        child: Card(
                                          color: ramoColor.withOpacity(0.18),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            side: BorderSide(color: ramoColor.withOpacity(0.7), width: 1.5),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  clase['ramo'],
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 11,
                                                      color: ramoColor),
                                                  maxLines: (alto / 34).floor().clamp(1, 4),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                if (alto >= 46) ...[
                                                  const SizedBox(height: 3),
                                                  Text(
                                                    '${clase['inicio']} - ${clase['fin']}',
                                                    style: TextStyle(
                                                        fontSize: 9,
                                                        color: ramoColor.withOpacity(0.7)),
                                                  ),
                                                ]
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}