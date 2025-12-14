// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitModelAdapter extends TypeAdapter<HabitModel> {
  @override
  final int typeId = 0;

  @override
  HabitModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      iconIndex: fields[3] as int,
      colorIndex: fields[4] as int,
      category: fields[5] as String,
      scheduledDays: (fields[6] as List).cast<int>(),
      targetDaysPerWeek: fields[7] as int,
      createdAt: fields[8] as DateTime,
      reminderTime: fields[9] as String?,
      isArchived: fields[10] as bool,
      currentStreak: fields[11] as int,
      longestStreak: fields[12] as int,
      totalCompletions: fields[13] as int,
      completedDates: (fields[14] as List?)?.cast<String>(),
      isQuitHabit: fields[15] as bool,
      quitStartDate: fields[16] as DateTime?,
      moneySavedPerDay: fields[17] as double?,
      relapses: (fields[18] as List?)?.cast<DateTime>(),
    );
  }

  @override
  void write(BinaryWriter writer, HabitModel obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.iconIndex)
      ..writeByte(4)
      ..write(obj.colorIndex)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.scheduledDays)
      ..writeByte(7)
      ..write(obj.targetDaysPerWeek)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.reminderTime)
      ..writeByte(10)
      ..write(obj.isArchived)
      ..writeByte(11)
      ..write(obj.currentStreak)
      ..writeByte(12)
      ..write(obj.longestStreak)
      ..writeByte(13)
      ..write(obj.totalCompletions)
      ..writeByte(14)
      ..write(obj.completedDates)
      ..writeByte(15)
      ..write(obj.isQuitHabit)
      ..writeByte(16)
      ..write(obj.quitStartDate)
      ..writeByte(17)
      ..write(obj.moneySavedPerDay)
      ..writeByte(18)
      ..write(obj.relapses);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
