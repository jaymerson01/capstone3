// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incident_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IncidentModelAdapter extends TypeAdapter<IncidentModel> {
  @override
  final int typeId = 1;

  @override
  IncidentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IncidentModel(
      id: fields[0] as String,
      reporterId: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as String,
      photoUrl: fields[4] as String?,
      status: fields[5] as String,
      timestamp: fields[6] as DateTime,
      latitude: fields[7] as double,
      longitude: fields[8] as double,
      resolvedAddress: fields[9] as String?,
      upvoteCount: fields[10] as int,
      validatedUserIds: (fields[11] as List?)?.cast<String>() ?? const [],
      urgencyStatus: fields[12] as String?,
      areaSector: fields[13] as String?,
      isAnonymous: fields[14] as bool? ?? false,
      dispatcherNotes: fields[15] as String?,
      reporterName: fields[16] as String?,
      reporterEmail: fields[17] as String?,
      videoUrl: fields[18] as String?,
      isReportingOnBehalf: fields[19] as bool? ?? false,
      victimName: fields[20] as String?,
      victimPhone: fields[21] as String?,
      estimatedResponseTime: fields[22] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, IncidentModel obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.reporterId)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.photoUrl)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.timestamp)
      ..writeByte(7)
      ..write(obj.latitude)
      ..writeByte(8)
      ..write(obj.longitude)
      ..writeByte(9)
      ..write(obj.resolvedAddress)
      ..writeByte(10)
      ..write(obj.upvoteCount)
      ..writeByte(11)
      ..write(obj.validatedUserIds)
      ..writeByte(12)
      ..write(obj.urgencyStatus)
      ..writeByte(13)
      ..write(obj.areaSector)
      ..writeByte(14)
      ..write(obj.isAnonymous)
      ..writeByte(15)
      ..write(obj.dispatcherNotes)
      ..writeByte(16)
      ..write(obj.reporterName)
      ..writeByte(17)
      ..write(obj.reporterEmail)
      ..writeByte(18)
      ..write(obj.videoUrl)
      ..writeByte(19)
      ..write(obj.isReportingOnBehalf)
      ..writeByte(20)
      ..write(obj.victimName)
      ..writeByte(21)
      ..write(obj.victimPhone)
      ..writeByte(22)
      ..write(obj.estimatedResponseTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncidentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
