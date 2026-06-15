import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/ramo.dart';

class MaterialesScreen extends StatefulWidget {
  final Ramo ramo;
  const MaterialesScreen({super.key, required this.ramo});

  @override
  State<MaterialesScreen> createState() => _MaterialesScreenState();
}

class _MaterialesScreenState extends State<MaterialesScreen> {
  
  Future<void> _adjuntarArchivo() async {
    FilePickerResult? resultado = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'txt'],
      withData: false,
    );

    if (resultado != null) {
      PlatformFile archivo = resultado.files.first;

      setState(() {
        widget.ramo.materiales = List.from(widget.ramo.materiales)
          ..add(
            MaterialEstudio(
              nombre: archivo.name,
              rutaArchivo: archivo.path ?? '',
              extension: archivo.extension ?? '',
            ),
          );
      });

      await widget.ramo.save(); 
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${archivo.name} guardado permanentemente')),
        );
      }
    }
  }

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
        title: Text('Material - ${widget.ramo.nombre}'),
      ),
      body: widget.ramo.materiales.isEmpty
          ? const Center(
              child: Text(
                'No hay archivos adjuntos.\nPresiona el botón + para agregar uno.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.ramo.materiales.length,
              itemBuilder: (context, index) {
                final archivo = widget.ramo.materiales[index];
                return Card(
                  child: ListTile(
                    leading: _obtenerIcono(archivo.extension),
                    title: Text(archivo.nombre),
                    subtitle: Text('Formato: .${archivo.extension}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        setState(() {
                          widget.ramo.materiales = List.from(widget.ramo.materiales)
                            ..removeAt(index);
                        });
                        await widget.ramo.save(); // Guardamos el cambio
                      },
                    ),
                    onTap: () {
                      // Aquí programaremos que se abra el PDF en la pantalla
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _adjuntarArchivo,
        icon: const Icon(Icons.upload_file),
        label: const Text('Adjuntar'),
      ),
    );
  }
}