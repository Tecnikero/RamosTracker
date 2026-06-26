
part of 'ramo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BloqueHorarioAdapter extends TypeAdapter<BloqueHorario> {
  @override
  final int typeId = 0;

  @override
  BloqueHorario read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BloqueHorario(
      dia: fields[0] as String,
      horaInicio: fields[1] as String,
      horaFin: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BloqueHorario obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.dia)
      ..writeByte(1)
      ..write(obj.horaInicio)
      ..writeByte(2)
      ..write(obj.horaFin);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BloqueHorarioAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EvaluacionAdapter extends TypeAdapter<Evaluacion> {
  @override
  final int typeId = 1;

  @override
  Evaluacion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Evaluacion(
      nombre: fields[0] as String,
      porcentaje: fields[1] as double,
      fecha: fields[2] as String?,
      notaObtenida: fields[3] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Evaluacion obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.nombre)
      ..writeByte(1)
      ..write(obj.porcentaje)
      ..writeByte(2)
      ..write(obj.fecha)
      ..writeByte(3)
      ..write(obj.notaObtenida);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvaluacionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MaterialEstudioAdapter extends TypeAdapter<MaterialEstudio> {
  @override
  final int typeId = 3;

  @override
  MaterialEstudio read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MaterialEstudio(
      nombre: fields[0] as String,
      rutaArchivo: fields[1] as String,
      extension: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MaterialEstudio obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.nombre)
      ..writeByte(1)
      ..write(obj.rutaArchivo)
      ..writeByte(2)
      ..write(obj.extension);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaterialEstudioAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GrupoRAAdapter extends TypeAdapter<GrupoRA> {
  @override
  final int typeId = 4;

  @override
  GrupoRA read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GrupoRA(
      nombre: fields[0] as String,
      porcentaje: fields[1] as double,
      evaluaciones: (fields[2] as List).cast<Evaluacion>(),
    );
  }

  @override
  void write(BinaryWriter writer, GrupoRA obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.nombre)
      ..writeByte(1)
      ..write(obj.porcentaje)
      ..writeByte(2)
      ..write(obj.evaluaciones);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GrupoRAAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RamoAdapter extends TypeAdapter<Ramo> {
  @override
  final int typeId = 2;

  @override
  Ramo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Ramo(
      nombre: fields[0] as String,
      horarios: (fields[1] as List).cast<BloqueHorario>(),
      evaluaciones: (fields[2] as List).cast<Evaluacion>(),
      materiales: (fields[3] as List?)?.cast<MaterialEstudio>(),
      usaSistemaRA: fields[4] as bool? ?? false,
      gruposRA: (fields[5] as List?)?.cast<GrupoRA>(),
      colorValue: fields[6] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Ramo obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.nombre)
      ..writeByte(1)
      ..write(obj.horarios)
      ..writeByte(2)
      ..write(obj.evaluaciones)
      ..writeByte(3)
      ..write(obj.materiales)
      ..writeByte(4)
      ..write(obj.usaSistemaRA)
      ..writeByte(5)
      ..write(obj.gruposRA)
      ..writeByte(6)
      ..write(obj.colorValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RamoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}