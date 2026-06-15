import 'package:flutter/material.dart';
import '../models/ramo.dart';

class BloqueTemp {
  String dia = 'Lunes';
  TimeOfDay? horaInicio;
  TimeOfDay? horaFin;
}

class EvalTemp {
  String nombre = '';
  double porcentaje = 0.0;
  DateTime? fecha;
}

class GrupoRATemp {
  String nombre;
  double porcentaje;
  List<EvalTemp> evaluaciones;

  GrupoRATemp({this.nombre = 'RA 1', this.porcentaje = 0.0, List<EvalTemp>? evaluaciones}) : evaluaciones = evaluaciones ?? [EvalTemp()];
}

class AgregarRamoScreen extends StatefulWidget {
  final Ramo? ramoAEditar;

  const AgregarRamoScreen({super.key, this.ramoAEditar});

  @override
  State<AgregarRamoScreen> createState() => _AgregarRamoScreenState();
}

class _AgregarRamoScreenState extends State<AgregarRamoScreen> {
  final _formKey = GlobalKey<FormState>();
  String nombreRamo = '';
  final List<String> diasSemana = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];

  List<BloqueTemp> horariosTemp = [BloqueTemp()];
  
  bool usaSistemaRA = false;
  List<EvalTemp> evaluacionesTemp = [EvalTemp()];
  List<GrupoRATemp> gruposRATemp = [GrupoRATemp()];

  @override
  void initState() {
    super.initState();
    
    if (widget.ramoAEditar != null) {
      nombreRamo = widget.ramoAEditar!.nombre;
      usaSistemaRA = widget.ramoAEditar!.usaSistemaRA;

      horariosTemp = widget.ramoAEditar!.horarios.map((h) {
        final b = BloqueTemp();
        b.dia = h.dia;
        b.horaInicio = _parseTimeOfDay(h.horaInicio);
        b.horaFin = _parseTimeOfDay(h.horaFin);
        return b;
      }).toList();

      evaluacionesTemp = widget.ramoAEditar!.evaluaciones.map((e) {
        final ev = EvalTemp();
        ev.nombre = e.nombre;
        ev.porcentaje = e.porcentaje;
        ev.fecha = _parseDateTime(e.fecha);
        return ev;
      }).toList();

      gruposRATemp = widget.ramoAEditar!.gruposRA.map((g) {
        final gr = GrupoRATemp();
        gr.nombre = g.nombre;
        gr.porcentaje = g.porcentaje;
        gr.evaluaciones = g.evaluaciones.map((e) {
          final ev = EvalTemp();
          ev.nombre = e.nombre;
          ev.porcentaje = e.porcentaje;
          ev.fecha = _parseDateTime(e.fecha);
          return ev;
        }).toList();
        return gr;
      }).toList();

      if (evaluacionesTemp.isEmpty) evaluacionesTemp.add(EvalTemp());
      if (gruposRATemp.isEmpty) gruposRATemp.add(GrupoRATemp());
    }
  }

  TimeOfDay _parseTimeOfDay(String txt) {
    try {
      final parts = txt.split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      if (parts.length > 1 && parts[1].toLowerCase() == 'pm' && hour < 12) hour += 12;
      if (parts.length > 1 && parts[1].toLowerCase() == 'am' && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return TimeOfDay.now();
    }
  }

  DateTime? _parseDateTime(String? txt) {
    if (txt == null) return null;
    try {
      final parts = txt.split('/');
      return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    } catch (_) {
      return null;
    }
  }

  Future<void> _seleccionarHora(BuildContext context, BloqueTemp bloque, bool esInicio) async {
    final TimeOfDay? hora = await showTimePicker(context: context, initialTime: esInicio ? (bloque.horaInicio ?? TimeOfDay.now()) : (bloque.horaFin ?? TimeOfDay.now()));
    if (hora != null) setState(() { if (esInicio) bloque.horaInicio = hora; else bloque.horaFin = hora; });
  }

  Future<void> _seleccionarFecha(BuildContext context, EvalTemp eval) async {
    final DateTime? fecha = await showDatePicker(context: context, initialDate: eval.fecha ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
    if (fecha != null) setState(() => eval.fecha = fecha);
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.ramoAEditar != null;

    return Scaffold(
      appBar: AppBar(title: Text(esEdicion ? 'Editar Ramo' : 'Nuevo Ramo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Detalles del Ramo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              TextFormField(
                initialValue: nombreRamo,
                decoration: const InputDecoration(labelText: 'Nombre del Ramo', border: OutlineInputBorder(), prefixIcon: Icon(Icons.book)),
                validator: (value) => value!.isEmpty ? 'Ingresa un nombre' : null,
                onSaved: (value) => nombreRamo = value!,
              ),
              const SizedBox(height: 25),

              const Text('Horario de Clases', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...horariosTemp.asMap().entries.map((entry) {
                int index = entry.key;
                BloqueTemp bloque = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: DropdownButtonFormField<String>(value: bloque.dia, decoration: const InputDecoration(labelText: 'Día', border: OutlineInputBorder()), items: diasSemana.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(), onChanged: (val) => setState(() => bloque.dia = val!))),
                            if (horariosTemp.length > 1) IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => horariosTemp.removeAt(index))),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: OutlinedButton.icon(onPressed: () => _seleccionarHora(context, bloque, true), icon: const Icon(Icons.access_time), label: Text(bloque.horaInicio?.format(context) ?? 'Inicio'))),
                            const SizedBox(width: 10),
                            Expanded(child: OutlinedButton.icon(onPressed: () => _seleccionarHora(context, bloque, false), icon: const Icon(Icons.access_time_filled), label: Text(bloque.horaFin?.format(context) ?? 'Fin'))),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              TextButton.icon(onPressed: () => setState(() => horariosTemp.add(BloqueTemp())), icon: const Icon(Icons.add), label: const Text('Agregar otro día')),
              const Divider(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Evaluaciones / Syllabus', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  // EL INTERRUPTOR PARA ACTIVAR EL MODO RA
                  Row(
                    children: [
                      const Text('Modo RA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      Switch(
                        value: usaSistemaRA,
                        activeColor: Colors.blue,
                        onChanged: (val) => setState(() => usaSistemaRA = val),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 10),

              if (!usaSistemaRA) ...[
                ...evaluacionesTemp.asMap().entries.map((entry) {
                  int index = entry.key;
                  EvalTemp eval = entry.value;
                  return _construirTarjetaEvaluacion(eval, () => setState(() => evaluacionesTemp.removeAt(index)), evaluacionesTemp.length > 1);
                }),
                TextButton.icon(onPressed: () => setState(() => evaluacionesTemp.add(EvalTemp())), icon: const Icon(Icons.add), label: const Text('Agregar evaluación normal')),
              ] else ...[
                ...gruposRATemp.asMap().entries.map((entryRA) {
                  int indexRA = entryRA.key;
                  GrupoRATemp grupo = entryRA.value;
                  
                  return Card(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    margin: const EdgeInsets.only(bottom: 20),
                    shape: RoundedRectangleBorder(side: BorderSide(color: Colors.blue.withOpacity(0.5)), borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(flex: 2, child: TextFormField(initialValue: grupo.nombre, decoration: const InputDecoration(labelText: 'Nombre Grupo (Ej: RA1)', border: OutlineInputBorder()), onChanged: (val) => grupo.nombre = val)),
                              const SizedBox(width: 10),
                              Expanded(flex: 1, child: TextFormField(initialValue: grupo.porcentaje > 0 ? grupo.porcentaje.toStringAsFixed(0) : '', keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '% Final', border: OutlineInputBorder()), onChanged: (val) => grupo.porcentaje = double.tryParse(val) ?? 0.0)),
                              if (gruposRATemp.length > 1) IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => gruposRATemp.removeAt(indexRA))),
                            ],
                          ),
                          const SizedBox(height: 15),
                          const Text('  Evaluaciones dentro de este RA:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                          const SizedBox(height: 10),
                          
                          ...grupo.evaluaciones.asMap().entries.map((entryEv) {
                            int indexEv = entryEv.key;
                            EvalTemp evalHija = entryEv.value;
                            return _construirTarjetaEvaluacion(evalHija, () => setState(() => grupo.evaluaciones.removeAt(indexEv)), grupo.evaluaciones.length > 1);
                          }),
                          Center(child: TextButton.icon(onPressed: () => setState(() => grupo.evaluaciones.add(EvalTemp())), icon: const Icon(Icons.add, size: 18), label: const Text('Sub-Evaluación'))),
                        ],
                      ),
                    ),
                  );
                }),
                TextButton.icon(onPressed: () => setState(() => gruposRATemp.add(GrupoRATemp(nombre: 'RA ${gruposRATemp.length + 1}'))), icon: const Icon(Icons.create_new_folder), label: const Text('Agregar Grupo RA')),
              ],

              const SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      
                      if (horariosTemp.any((h) => h.horaInicio == null || h.horaFin == null)) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan horas por seleccionar')));
                        return;
                      }

                      List<BloqueHorario> horariosFinales = horariosTemp.map((h) => BloqueHorario(dia: h.dia, horaInicio: h.horaInicio!.format(context), horaFin: h.horaFin!.format(context))).toList();

                      List<Evaluacion> evalFinales = evaluacionesTemp.asMap().entries.map((entry) {
                        double? notaAnterior;
                        if (esEdicion && !widget.ramoAEditar!.usaSistemaRA && entry.key < widget.ramoAEditar!.evaluaciones.length) notaAnterior = widget.ramoAEditar!.evaluaciones[entry.key].notaObtenida;
                        return Evaluacion(nombre: entry.value.nombre, porcentaje: entry.value.porcentaje, fecha: entry.value.fecha != null ? "${entry.value.fecha!.day}/${entry.value.fecha!.month}/${entry.value.fecha!.year}" : null, notaObtenida: notaAnterior);
                      }).toList();

                      List<GrupoRA> raFinales = gruposRATemp.asMap().entries.map((entryRA) {
                        List<Evaluacion> evalsRA = entryRA.value.evaluaciones.asMap().entries.map((entryEv) {
                          double? notaAnterior;
                          if (esEdicion && widget.ramoAEditar!.usaSistemaRA && entryRA.key < widget.ramoAEditar!.gruposRA.length && entryEv.key < widget.ramoAEditar!.gruposRA[entryRA.key].evaluaciones.length) {
                            notaAnterior = widget.ramoAEditar!.gruposRA[entryRA.key].evaluaciones[entryEv.key].notaObtenida;
                          }
                          return Evaluacion(nombre: entryEv.value.nombre, porcentaje: entryEv.value.porcentaje, fecha: entryEv.value.fecha != null ? "${entryEv.value.fecha!.day}/${entryEv.value.fecha!.month}/${entryEv.value.fecha!.year}" : null, notaObtenida: notaAnterior);
                        }).toList();
                        return GrupoRA(nombre: entryRA.value.nombre, porcentaje: entryRA.value.porcentaje, evaluaciones: evalsRA);
                      }).toList();

                      if (esEdicion) {
                        widget.ramoAEditar!.nombre = nombreRamo;
                        widget.ramoAEditar!.horarios = horariosFinales;
                        widget.ramoAEditar!.usaSistemaRA = usaSistemaRA;
                        widget.ramoAEditar!.evaluaciones = usaSistemaRA ? [] : evalFinales;
                        widget.ramoAEditar!.gruposRA = usaSistemaRA ? raFinales : [];
                        await widget.ramoAEditar!.save();
                        if (context.mounted) Navigator.pop(context);
                      } else {
                        Ramo nuevoRamo = Ramo(
                          nombre: nombreRamo, horarios: horariosFinales, usaSistemaRA: usaSistemaRA,
                          evaluaciones: usaSistemaRA ? [] : evalFinales, gruposRA: usaSistemaRA ? raFinales : [],
                        );
                        Navigator.pop(context, nuevoRamo);
                      }
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: Text(esEdicion ? 'Guardar Cambios' : 'Guardar Ramo', style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirTarjetaEvaluacion(EvalTemp eval, VoidCallback onBorrar, bool mostrarBorrar) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(flex: 2, child: TextFormField(initialValue: eval.nombre, decoration: const InputDecoration(labelText: 'Nombre Eval.', border: OutlineInputBorder(), isDense: true), onChanged: (val) => eval.nombre = val)),
                const SizedBox(width: 8),
                Expanded(flex: 1, child: TextFormField(initialValue: eval.porcentaje > 0 ? eval.porcentaje.toStringAsFixed(0) : '', keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '%', border: OutlineInputBorder(), isDense: true), onChanged: (val) => eval.porcentaje = double.tryParse(val) ?? 0.0)),
                if (mostrarBorrar) IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: onBorrar),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => _seleccionarFecha(context, eval), icon: const Icon(Icons.calendar_month, size: 18), label: Text(eval.fecha != null ? "${eval.fecha!.day}/${eval.fecha!.month}/${eval.fecha!.year}" : 'Fecha (Opcional)', style: const TextStyle(fontSize: 12)))),
          ],
        ),
      ),
    );
  }
}