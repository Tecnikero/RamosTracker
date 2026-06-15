import 'package:flutter/material.dart';
import '../models/ramo.dart';

class CalculadoraNotasScreen extends StatefulWidget {
  final Ramo ramo;
  const CalculadoraNotasScreen({super.key, required this.ramo});

  @override
  State<CalculadoraNotasScreen> createState() => _CalculadoraNotasScreenState();
}

class _CalculadoraNotasScreenState extends State<CalculadoraNotasScreen> {
  
  Map<String, dynamic> _calcularEstado() {
    double notaAcumulada = 0.0;
    double porcentajeEvaluado = 0.0;
    double porcentajeFaltante = 100.0;

    List<Map<String, dynamic>> evaluacionesGlobales = [];

    if (widget.ramo.usaSistemaRA) {
      for (var ra in widget.ramo.gruposRA) {
        for (var eval in ra.evaluaciones) {
          double pesoGlobal = (eval.porcentaje * ra.porcentaje) / 100; 
          evaluacionesGlobales.add({ 'eval': eval, 'pesoGlobal': pesoGlobal });
        }
      }
    } else {
      for (var eval in widget.ramo.evaluaciones) {
        evaluacionesGlobales.add({ 'eval': eval, 'pesoGlobal': eval.porcentaje });
      }
    }

    for (var item in evaluacionesGlobales) {
      Evaluacion eval = item['eval'];
      double peso = item['pesoGlobal'];

      if (eval.notaObtenida != null) {
        notaAcumulada += (eval.notaObtenida! * peso) / 100;
        porcentajeEvaluado += peso;
      }
    }

    porcentajeFaltante -= porcentajeEvaluado;
    
    double notaNecesaria = 0.0;
    if (porcentajeFaltante > 0) {
      notaNecesaria = (4.0 - notaAcumulada) / (porcentajeFaltante / 100);
    }

    double promedioParcial = porcentajeEvaluado > 0 ? (notaAcumulada / (porcentajeEvaluado / 100)) : 0.0;

    return {
      'notaAcumulada': notaAcumulada,
      'porcentajeFaltante': porcentajeFaltante,
      'notaNecesaria': notaNecesaria,
      'promedioParcial': promedioParcial,
    };
  }

  @override
  Widget build(BuildContext context) {
    final estado = _calcularEstado();
    final notaNecesaria = estado['notaNecesaria'];
    final porcentajeFaltante = estado['porcentajeFaltante'];

    return Scaffold(
      appBar: AppBar(title: Text('Notas - ${widget.ramo.nombre}')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _PanelEstadistica(titulo: 'Promedio Actual', valor: estado['promedioParcial'].toStringAsFixed(1), color: estado['promedioParcial'] >= 4.0 ? Colors.blue : Colors.red),
                    _PanelEstadistica(titulo: 'Nota a Presentación', valor: estado['notaAcumulada'].toStringAsFixed(1), color: Colors.white),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface.withOpacity(0.5), borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    porcentajeFaltante <= 0 ? '¡Semestre cerrado! Ya tienes el 100% de las notas.' : notaNecesaria <= 1.0 ? '¡Ya pasaste el ramo! Estás al otro lado.' : notaNecesaria > 7.0 ? 'Lo siento hermano ya fue' : 'Necesitas un ${notaNecesaria.toStringAsFixed(1)} en el ${porcentajeFaltante.toStringAsFixed(0)}% restante para el 4.0',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: widget.ramo.usaSistemaRA 
                ? (widget.ramo.gruposRA.isEmpty ? const Center(child: Text('No hay RAs registrados.')) : _construirListaRA(notaNecesaria))
                : (widget.ramo.evaluaciones.isEmpty ? const Center(child: Text('No hay evaluaciones registradas.')) : _construirListaNormal(notaNecesaria)),
          ),
        ],
      ),
    );
  }

  Widget _construirListaNormal(double notaNecesaria) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.ramo.evaluaciones.length,
      itemBuilder: (context, index) {
        return _tarjetaEvaluacion(widget.ramo.evaluaciones[index], notaNecesaria);
      },
    );
  }

  Widget _construirListaRA(double notaNecesaria) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.ramo.gruposRA.length,
      itemBuilder: (context, indexRA) {
        final ra = widget.ramo.gruposRA[indexRA];
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: const BorderRadius.vertical(top: Radius.circular(11))),
                child: Text('${ra.nombre} (Vale un ${ra.porcentaje}% final)', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: ra.evaluaciones.map((eval) => _tarjetaEvaluacion(eval, notaNecesaria, subtextoExtra: '% de este RA')).toList(),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _tarjetaEvaluacion(Evaluacion eval, double notaNecesaria, {String subtextoExtra = '%'}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(eval.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('Vale un ${eval.porcentaje}$subtextoExtra', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      if (eval.notaObtenida == null && notaNecesaria > 1.0 && notaNecesaria <= 7.0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.15), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.blue.withOpacity(0.3))),
                          child: Text('Meta: ${notaNecesaria.toStringAsFixed(1)}', style: TextStyle(fontSize: 12, color: Colors.blue.shade300, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: TextFormField(
                initialValue: eval.notaObtenida?.toString(),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Nota', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0)),
                onChanged: (valor) {
                  String valorLimpio = valor.replaceAll(',', '.');
                  setState(() {
                    if (valorLimpio.isEmpty) {
                      eval.notaObtenida = null;
                    } else {
                      eval.notaObtenida = double.tryParse(valorLimpio);
                    }
                  });
                  widget.ramo.save(); 
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanelEstadistica extends StatelessWidget {
  final String titulo;
  final String valor;
  final Color color;

  const _PanelEstadistica({required this.titulo, required this.valor, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(titulo, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 5),
        Text(valor, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}