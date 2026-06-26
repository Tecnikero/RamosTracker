import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'ramo.g.dart';

@HiveType(typeId: 0)
class BloqueHorario {
  @HiveField(0)
  String dia;
  @HiveField(1)
  String horaInicio;
  @HiveField(2)
  String horaFin;

  BloqueHorario({required this.dia, required this.horaInicio, required this.horaFin});
}

@HiveType(typeId: 1)
class Evaluacion {
  @HiveField(0)
  String nombre;
  @HiveField(1)
  double porcentaje;
  @HiveField(2)
  String? fecha;
  @HiveField(3)
  double? notaObtenida;

  Evaluacion({required this.nombre, required this.porcentaje, this.fecha, this.notaObtenida});
}

@HiveType(typeId: 3)
class MaterialEstudio {
  @HiveField(0)
  String nombre;
  @HiveField(1)
  String rutaArchivo;
  @HiveField(2)
  String extension;

  MaterialEstudio({required this.nombre, required this.rutaArchivo, required this.extension});
}

@HiveType(typeId: 4)
class GrupoRA {
  @HiveField(0)
  String nombre;
  @HiveField(1)
  double porcentaje;
  @HiveField(2)
  List<Evaluacion> evaluaciones;

  GrupoRA({required this.nombre, required this.porcentaje, required this.evaluaciones});
}

@HiveType(typeId: 2)
class Ramo extends HiveObject {
  @HiveField(0)
  String nombre;
  @HiveField(1)
  List<BloqueHorario> horarios;

  @HiveField(2)
  List<Evaluacion> evaluaciones;

  @HiveField(3)
  List<MaterialEstudio> materiales;

  @HiveField(4)
  bool usaSistemaRA;

  @HiveField(5)
  List<GrupoRA> gruposRA;

  @HiveField(6)
  int? colorValue;

  Ramo({
    required this.nombre,
    required this.horarios,
    required this.evaluaciones,
    List<MaterialEstudio>? materiales,
    this.usaSistemaRA = false,
    List<GrupoRA>? gruposRA,
    this.colorValue,
  })  : materiales = materiales ?? [],
        gruposRA = gruposRA ?? [];

  Color get color => colorValue != null ? Color(colorValue!) : Colors.blue;
}