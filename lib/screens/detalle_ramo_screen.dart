import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Importante para que escuche la base de datos
import '../models/ramo.dart';
import 'materiales_screen.dart';
import 'package:open_filex/open_filex.dart';
import 'calculadora_notas_screen.dart';
import 'agregar_ramo_screen.dart';
import 'evaluaciones_screen.dart';

class DetalleRamoScreen extends StatefulWidget {
  final Ramo ramo;

  const DetalleRamoScreen({super.key, required this.ramo});

  @override
  State<DetalleRamoScreen> createState() => _DetalleRamoScreenState();
}

class _DetalleRamoScreenState extends State<DetalleRamoScreen> {
  
  Icon _obtenerIcono(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf': return const Icon(Icons.picture_as_pdf, color: Colors.red);
      case 'doc':
      case 'docx': return const Icon(Icons.description, color: Colors.blue);
      case 'ppt':
      case 'pptx': return const Icon(Icons.slideshow, color: Colors.orange);
      default: return const Icon(Icons.insert_drive_file, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ramo.nombre),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.book, size: 40),
                  const SizedBox(height: 10),
                  Text(
                    widget.ramo.nombre,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Material y PDFs'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MaterialesScreen(ramo: widget.ramo),
                  ),
                );
              },
            ),
            ListTile(
           leading: const Icon(Icons.calendar_today),
           title: const Text('Evaluaciones'),
           onTap: () {
             Navigator.pop(context);
             Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (context) => EvaluacionesScreen(ramo: widget.ramo),
               ),
             );
           },
         ),
            ListTile(
              leading: const Icon(Icons.calculate),
              title: const Text('Ponderación / Notas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CalculadoraNotasScreen(ramo: widget.ramo),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar Ramo'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AgregarRamoScreen(ramoAEditar: widget.ramo), 
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_back),
              title: const Text('Volver al inicio'),
              onTap: () {
                Navigator.pop(context); 
                Navigator.pop(context); 
              },
            ),

            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Eliminar Ramo', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                
                showDialog(
                  context: context,
                  builder: (BuildContext ctx) {
                    return AlertDialog(
                      title: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.red),
                          SizedBox(width: 10),
                          Text('¿Eliminar Ramo?'),
                        ],
                      ),
                      content: Text('¿Estás seguro de que deseas eliminar "${widget.ramo.nombre}"?\n\nEsta acción no se puede deshacer y borrará todo su material, horarios y notas.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () async {
                            await widget.ramo.delete();
                            
                            if (context.mounted) {
                              Navigator.pop(ctx);
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      
      body: ValueListenableBuilder<Box<Ramo>>(
        valueListenable: Hive.box<Ramo>('ramosBox').listenable(),
        builder: (context, box, _) {
          final ramoActualizado = box.get(widget.ramo.key);
          final materiales = ramoActualizado?.materiales ?? [];

          if (materiales.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'No hay material guardado.\n\nAbre el menú lateral (arriba a la izquierda) y entra a "Material y PDFs" para agregar archivos.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: materiales.length,
            itemBuilder: (context, index) {
              final archivo = materiales[index];
              
              Color colorFondo;
              Color colorIcono;
              if (archivo.extension.toLowerCase() == 'pdf') {
                colorFondo = Colors.red.withOpacity(0.1);
                colorIcono = Colors.redAccent;
              } else if (archivo.extension.toLowerCase().startsWith('doc')) {
                colorFondo = Colors.blue.withOpacity(0.1);
                colorIcono = Colors.blueAccent;
              } else {
                colorFondo = Colors.grey.withOpacity(0.2);
                colorIcono = Colors.white70;
              }

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () async {
                    final result = await OpenFilex.open(archivo.rutaArchivo);
                    
                    if (result.type != ResultType.done && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('No se pudo abrir: ${result.message}')),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Container(
                          width: 70,
                          height: 90,
                          decoration: BoxDecoration(
                            color: colorFondo,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: colorIcono.withOpacity(0.3), width: 1),
                          ),
                          child: Center(
                            child: _obtenerIcono(archivo.extension),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                archivo.nombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 16,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      archivo.extension.toUpperCase(),
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.open_in_new, size: 18, color: Colors.grey),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}