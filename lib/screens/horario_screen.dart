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
  
  final double _anchoColumna = 140.0;
  final double _altoHora = 70.0;
  final int _horaInicio = 8;
  final int _horaFin = 20;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      int diaActual = DateTime.now().weekday;
      double posicionDestino = (diaActual - 1) * _anchoColumna;
      
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          posicionDestino,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  double _traducirHoraADecimal(String timeStr) {
    try {
      String textoLimpio = timeStr.replaceAll('.', '').toLowerCase().trim();
      textoLimpio = textoLimpio.replaceAll('am', ' am').replaceAll('pm', ' pm').replaceAll('  ', ' ');
      
      final partes = textoLimpio.split(' ');
      final partesHora = partes[0].split(':');
      int h = int.parse(partesHora[0]);
      int m = int.parse(partesHora[1]);
      
      if (partes.length > 1) {
        if (partes[1].contains('pm') && h < 12) h += 12;
        if (partes[1].contains('am') && h == 12) h = 0;
      }
      return h + (m / 60.0);
    } catch (e) {
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
                            style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
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
                            color: esHoy ? Colors.blue.withOpacity(0.05) : null, // Resalta el fondo si es hoy
                            border: Border(right: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1)),
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 50,
                                width: double.infinity,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: esHoy ? Colors.blue.withOpacity(0.2) : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
                                  border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.5), width: esHoy ? 2 : 1)),
                                ),
                                child: Text(
                                  dia.toUpperCase(),
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: esHoy ? Colors.blue : null),
                                ),
                              ),
                              
                              SizedBox(
                                height: totalHoras * _altoHora,
                                child: Stack(
                                  children: [
                                    ...List.generate(totalHoras, (i) {
                                      return Positioned(
                                        top: i * _altoHora,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          height: _altoHora,
                                          decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1))),
                                        ),
                                      );
                                    }),
                                    
                                    ...clases.map((clase) {
                                      double inicioMatematico = _traducirHoraADecimal(clase['inicio']);
                                      double finMatematico = _traducirHoraADecimal(clase['fin']);
                                      
                                      if (inicioMatematico < _horaInicio) inicioMatematico = _horaInicio.toDouble();
                                      if (finMatematico > _horaFin) finMatematico = _horaFin.toDouble();
                                      if (finMatematico <= inicioMatematico) finMatematico = inicioMatematico + 1.0;

                                      double posicionTop = (inicioMatematico - _horaInicio) * _altoHora;
                                      double altoTarjeta = (finMatematico - inicioMatematico) * _altoHora;

                                      return Positioned(
                                        top: posicionTop,
                                        left: 2,
                                        right: 2,
                                        height: altoTarjeta,
                                        child: Card(
                                          color: Colors.blue.withOpacity(0.15),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            side: BorderSide(color: Colors.blue.withOpacity(0.6), width: 1.5),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(6.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  clase['ramo'],
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue),
                                                  maxLines: (altoTarjeta / 35).floor().clamp(1, 4), // Corta el texto si el bloque de clase es muy pequeño
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                if (altoTarjeta >= 50) ...[
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '${clase['inicio']} - ${clase['fin']}',
                                                    style: const TextStyle(fontSize: 10, color: Colors.blueGrey),
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