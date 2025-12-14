import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String avatarEmoji;

  @HiveField(11)
  int? avatarIndex;

  @HiveField(3)
  int totalXP;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  bool hasCompletedOnboarding;

  @HiveField(6)
  bool isDarkMode;

  @HiveField(7)
  int accentColorIndex;

  @HiveField(8)
  bool notificationsEnabled;

  @HiveField(9)
  List<String> unlockedAchievements;

  @HiveField(10)
  List<String> unlockedStones;

  UserModel({
    required this.id,
    required this.name,
    this.avatarEmoji = '😊',
    this.avatarIndex,
    this.totalXP = 0,
    DateTime? createdAt,
    this.hasCompletedOnboarding = false,
    this.isDarkMode = true,
    this.accentColorIndex = 0,
    this.notificationsEnabled = true,
    List<String>? unlockedAchievements,
    List<String>? unlockedStones,
  })  : createdAt = createdAt ?? DateTime.now(),
        unlockedAchievements = unlockedAchievements ?? [],
        unlockedStones = unlockedStones ?? [];

  int get level => totalXP ~/ 100;

  double get levelProgress => (totalXP % 100) / 100;

  int get xpToNextLevel => 100 - (totalXP % 100);

  void addXP(int xp) {
    totalXP += xp;
  }

  void unlockAchievement(String achievementId) {
    if (!unlockedAchievements.contains(achievementId)) {
      unlockedAchievements.add(achievementId);
    }
  }

  bool hasAchievement(String achievementId) {
    return unlockedAchievements.contains(achievementId);
  }

  void unlockStone(String stoneId) {
    if (!unlockedStones.contains(stoneId)) {
      unlockedStones.add(stoneId);
    }
  }

  bool hasStone(String stoneId) {
    return unlockedStones.contains(stoneId);
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? avatarEmoji,
    int? avatarIndex,
    int? totalXP,
    DateTime? createdAt,
    bool? hasCompletedOnboarding,
    bool? isDarkMode,
    int? accentColorIndex,
    bool? notificationsEnabled,
    List<String>? unlockedAchievements,
    List<String>? unlockedStones,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      totalXP: totalXP ?? this.totalXP,
      createdAt: createdAt ?? this.createdAt,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      accentColorIndex: accentColorIndex ?? this.accentColorIndex,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      unlockedAchievements: unlockedAchievements ?? List.from(this.unlockedAchievements),
      unlockedStones: unlockedStones ?? List.from(this.unlockedStones),
    );
  }
}
