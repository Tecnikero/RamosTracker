import 'package:flutter/material.dart';
import 'screens/agregar_ramo_screen.dart';
import 'models/ramo.dart';
import 'screens/detalle_ramo_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/horario_screen.dart';



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

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  List<Ramo> misRamos = [];

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
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HorarioScreen()),
                );
              },
              icon: const Icon(Icons.calendar_month),
              label: const Text('Ver Horario'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
            const SizedBox(height: 20),
            
            const Text(
              'Mis Ramos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            Expanded(
              child: ValueListenableBuilder( valueListenable: Hive.box<Ramo>('ramosBox').listenable(),
                builder: (context, box, _) {
                  if (box.isEmpty) {
                    return const Center(child: Text('No hay ramos guardados aún.'));
                  }
                  
                  return ListView.builder(
                    itemCount: box.length,
                    itemBuilder: (context, index) {
                      final ramoActual = box.getAt(index) as Ramo;
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.menu_book)),
                          title: Text(ramoActual.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${ramoActual.horarios.length} bloques a la semana'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                             Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetalleRamoScreen(ramo: ramoActual),
                                ),
                              );
                          },
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
            MaterialPageRoute(builder: (context) => const AgregarRamoScreen()),
          );

          if (nuevoRamo != null) {
            final box = Hive.box<Ramo>('ramosBox');
            box.add(nuevoRamo);
            setState(() {});
}
        },
        label: const Text('Agrega tu ramo'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}