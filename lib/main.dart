import 'package:flutter/material.dart';
import 'screens/agregar_ramo_screen.dart';
import 'models/ramo.dart';
import 'screens/detalle_ramo_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/horario_screen.dart';
import 'screens/evaluaciones_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(RamoAdapter());
  Hive.registerAdapter(BloqueHorarioAdapter());
  Hive.registerAdapter(EvaluacionAdapter());
  Hive.registerAdapter(MaterialEstudioAdapter());
  Hive.registerAdapter(GrupoRAAdapter());

  if (!Hive.isBoxOpen('ramosBox')) {
    await Hive.openBox<Ramo>('ramosBox');
  }

  runApp(const RamoTrackerApp());
}

class RamoTrackerApp extends StatelessWidget {
  const RamoTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ramo Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const PantallaPrincipal(),
    );
  }
}

class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RamosTracker'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                        context, MaterialPageRoute(builder: (_) => const HorarioScreen())),
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('Horario'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(14)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                        context, MaterialPageRoute(builder: (_) => const EvaluacionesScreen())),
                    icon: const Icon(Icons.event_note),
                    label: const Text('Evaluaciones'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(14)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text('Mis Ramos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box<Ramo>('ramosBox').listenable(),
                builder: (context, box, _) {
                  if (box.isEmpty) {
                    return const Center(child: Text('No hay ramos guardados aún.'));
                  }

                  return ListView.builder(
                    itemCount: box.length,
                    itemBuilder: (context, index) {
                      final ramo = box.getAt(index) as Ramo;
                      final color = ramo.color;

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: color.withOpacity(0.4), width: 1.5),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => DetalleRamoScreen(ramo: ramo)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: color,
                                  child: Text(
                                    ramo.nombre.isNotEmpty ? ramo.nombre[0].toUpperCase() : '?',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(ramo.nombre,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text('${ramo.horarios.length} bloques a la semana',
                                          style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios, size: 16, color: color),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final nuevoRamo = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AgregarRamoScreen()),
          );
          if (nuevoRamo != null) {
            Hive.box<Ramo>('ramosBox').add(nuevoRamo);
          }
        },
        label: const Text('Agrega tu ramo'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}