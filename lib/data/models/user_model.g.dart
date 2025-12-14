// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 1;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String,
      name: fields[1] as String,
      avatarEmoji: fields[2] as String,
      avatarIndex: fields[11] as int?,
      totalXP: fields[3] as int,
      createdAt: fields[4] as DateTime?,
      hasCompletedOnboarding: fields[5] as bool,
      isDarkMode: fields[6] as bool,
      accentColorIndex: fields[7] as int,
      notificationsEnabled: fields[8] as bool,
      unlockedAchievements: (fields[9] as List?)?.cast<String>(),
      unlockedStones: (fields[10] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.avatarEmoji)
      ..writeByte(11)
      ..write(obj.avatarIndex)
      ..writeByte(3)
      ..write(obj.totalXP)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.hasCompletedOnboarding)
      ..writeByte(6)
      ..write(obj.isDarkMode)
      ..writeByte(7)
      ..write(obj.accentColorIndex)
      ..writeByte(8)
      ..write(obj.notificationsEnabled)
      ..writeByte(9)
      ..write(obj.unlockedAchievements)
      ..writeByte(10)
      ..write(obj.unlockedStones);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
