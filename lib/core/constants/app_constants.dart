import 'package:flutter/material.dart';

class AppConstants {
  // App info
  static const String appName = 'Habit Tracker';
  static const String appVersion = '1.0.0';

  // XP System
  static const int baseXP = 10;
  static const int streakBonus7Days = 50;
  static const int streakBonus30Days = 200;
  static const int streakBonus100Days = 500;
  static const int xpPerLevel = 100;

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  static const Duration pageTransition = Duration(milliseconds: 300);

  // Hive box names
  static const String habitsBox = 'habits';
  static const String userBox = 'user';
  static const String achievementsBox = 'achievements';
  static const String completionsBox = 'completions';
  static const String settingsBox = 'settings';

  // Default avatar emojis
  static const List<String> avatarEmojis = [
    '😊', '🚀', '⭐', '🔥', '💪', '🎯', '✨', '🌟',
    '💫', '🌈', '🎨', '🎵', '📚', '💡', '🌿', '🦋',
    '🐱', '🐶', '🦊', '🐼', '🐨', '🦁', '🐯', '🐸',
  ];

  // Avatar image paths from assets
  static const List<String> avatarImages = [
    'assets/avatars/Gemini_Generated_Image_1d8gtw1d8gtw1d8g.png',
    'assets/avatars/Gemini_Generated_Image_3wzusr3wzusr3wzu.png',
    'assets/avatars/Gemini_Generated_Image_6yaeg6yaeg6yaeg6.png',
    'assets/avatars/Gemini_Generated_Image_73wn1j73wn1j73wn.png',
    'assets/avatars/Gemini_Generated_Image_7ro6yx7ro6yx7ro6.png',
    'assets/avatars/Gemini_Generated_Image_he1ml7he1ml7he1m.png',
    'assets/avatars/Gemini_Generated_Image_kzsyvkzsyvkzsyvk.png',
    'assets/avatars/Gemini_Generated_Image_v27t6wv27t6wv27t.png',
    'assets/avatars/Gemini_Generated_Image_v4c5stv4c5stv4c5.png',
  ];

  // Comprehensive habit icons (120+ icons covering all possible habits)
  static const List<IconData> habitIcons = [
    // Fitness & Exercise (0-19)
    Icons.fitness_center, // 0
    Icons.directions_run, // 1
    Icons.directions_walk, // 2
    Icons.directions_bike, // 3
    Icons.pool, // 4
    Icons.sports_tennis, // 5
    Icons.sports_soccer, // 6
    Icons.sports_basketball, // 7
    Icons.sports_gymnastics, // 8
    Icons.sports_martial_arts, // 9
    Icons.sports_volleyball, // 10
    Icons.sports_golf, // 11
    Icons.sports_baseball, // 12
    Icons.sports_football, // 13
    Icons.sports_hockey, // 14
    Icons.hiking, // 15
    Icons.downhill_skiing, // 16
    Icons.snowboarding, // 17
    Icons.kayaking, // 18
    Icons.surfing, // 19

    // Health & Wellness (20-39)
    Icons.water_drop, // 20
    Icons.bedtime, // 21
    Icons.spa, // 22
    Icons.self_improvement, // 23
    Icons.psychology, // 24
    Icons.healing, // 25
    Icons.medical_services, // 26
    Icons.medication, // 27
    Icons.heart_broken, // 28
    Icons.favorite, // 29
    Icons.air, // 30
    Icons.wb_sunny, // 31
    Icons.nightlight, // 32
    Icons.thermostat, // 33
    Icons.sanitizer, // 34
    Icons.masks, // 35
    Icons.monitor_weight, // 36
    Icons.scale, // 37
    Icons.bloodtype, // 38
    Icons.vaccines, // 39

    // Food & Nutrition (40-59)
    Icons.restaurant, // 40
    Icons.local_cafe, // 41
    Icons.local_bar, // 42
    Icons.local_dining, // 43
    Icons.local_pizza, // 44
    Icons.coffee, // 45
    Icons.wine_bar, // 46
    Icons.lunch_dining, // 47
    Icons.dinner_dining, // 48
    Icons.breakfast_dining, // 49
    Icons.kitchen, // 50
    Icons.soup_kitchen, // 51
    Icons.bakery_dining, // 52
    Icons.icecream, // 53
    Icons.cake, // 54
    Icons.apple, // 55
    Icons.set_meal, // 56
    Icons.takeout_dining, // 57
    Icons.ramen_dining, // 58
    Icons.fastfood, // 59

    // Learning & Education (60-79)
    Icons.book, // 60
    Icons.school, // 61
    Icons.library_books, // 62
    Icons.auto_stories, // 63
    Icons.quiz, // 64
    Icons.calculate, // 65
    Icons.science, // 66
    Icons.psychology, // 67
    Icons.translate, // 68
    Icons.language, // 69
    Icons.history_edu, // 70
    Icons.biotech, // 71
    Icons.engineering, // 72
    Icons.architecture, // 73
    Icons.construction, // 74
    Icons.memory, // 75
    Icons.lightbulb, // 76
    Icons.tips_and_updates, // 77
    Icons.emoji_objects, // 78
    Icons.school_outlined, // 79

    // Technology & Digital (80-99)
    Icons.code, // 80
    Icons.computer, // 81
    Icons.phone_android, // 82
    Icons.tablet, // 83
    Icons.laptop, // 84
    Icons.desktop_windows, // 85
    Icons.keyboard, // 86
    Icons.mouse, // 87
    Icons.developer_mode, // 88
    Icons.bug_report, // 89
    Icons.web, // 90
    Icons.cloud, // 91
    Icons.storage, // 92
    Icons.security, // 93
    Icons.wifi, // 94
    Icons.bluetooth, // 95
    Icons.usb, // 96
    Icons.memory, // 97
    Icons.smart_toy, // 98
    Icons.videogame_asset, // 99

    // Creative Arts (100-119)
    Icons.brush, // 100
    Icons.music_note, // 101
    Icons.palette, // 102
    Icons.draw, // 103
    Icons.edit, // 104
    Icons.camera, // 105
    Icons.photo_camera, // 106
    Icons.video_camera_back, // 107
    Icons.movie, // 108
    Icons.theater_comedy, // 109
    Icons.piano, // 110
    Icons.music_note, // 111
    Icons.mic, // 112
    Icons.headphones, // 113
    Icons.audio_file, // 114
    Icons.album, // 115
    Icons.color_lens, // 116
    Icons.format_paint, // 117
    Icons.auto_awesome, // 118
    Icons.photo_filter, // 119

    // Work & Productivity (120-139)
    Icons.work, // 120
    Icons.business, // 121
    Icons.timer, // 122
    Icons.schedule, // 123
    Icons.today, // 124
    Icons.event, // 125
    Icons.calendar_today, // 126
    Icons.alarm, // 127
    Icons.access_time, // 128
    Icons.hourglass_empty, // 129
    Icons.pending_actions, // 130
    Icons.task_alt, // 131
    Icons.check_circle, // 132
    Icons.done_all, // 133
    Icons.assignment, // 134
    Icons.description, // 135
    Icons.note_add, // 136
    Icons.sticky_note_2, // 137
    Icons.folder, // 138
    Icons.archive, // 139

    // Social & Communication (140-159)
    Icons.people, // 140
    Icons.person, // 141
    Icons.group, // 142
    Icons.family_restroom, // 143
    Icons.child_friendly, // 144
    Icons.elderly, // 145
    Icons.sentiment_satisfied, // 146
    Icons.mood, // 147
    Icons.sentiment_very_satisfied, // 148
    Icons.tag_faces, // 149
    Icons.phone, // 150
    Icons.call, // 151
    Icons.video_call, // 152
    Icons.chat, // 153
    Icons.message, // 154
    Icons.email, // 155
    Icons.forum, // 156
    Icons.comment, // 157
    Icons.feedback, // 158
    Icons.support_agent, // 159

    // Finance & Money (160-179)
    Icons.savings, // 160
    Icons.account_balance_wallet, // 161
    Icons.account_balance, // 162
    Icons.credit_card, // 163
    Icons.payment, // 164
    Icons.money, // 165
    Icons.currency_exchange, // 166
    Icons.attach_money, // 167
    Icons.local_atm, // 168
    Icons.point_of_sale, // 169
    Icons.receipt, // 170
    Icons.shopping_cart, // 171
    Icons.shopping_bag, // 172
    Icons.store, // 173
    Icons.storefront, // 174
    Icons.inventory, // 175
    Icons.calculate, // 176
    Icons.trending_up, // 177
    Icons.trending_down, // 178
    Icons.show_chart, // 179

    // Nature & Environment (180-199)
    Icons.eco, // 180
    Icons.local_florist, // 181
    Icons.forest, // 182
    Icons.park, // 183
    Icons.grass, // 184
    Icons.yard, // 185
    Icons.nature, // 186
    Icons.landscape, // 187
    Icons.landscape, // 188
    Icons.terrain, // 189
    Icons.waves, // 190
    Icons.beach_access, // 191
    Icons.wb_cloudy, // 192
    Icons.wb_sunny, // 193
    Icons.nights_stay, // 194
    Icons.star, // 195
    Icons.pets, // 196
    Icons.cruelty_free, // 197
    Icons.recycling, // 198
    Icons.energy_savings_leaf, // 199

    // Hobbies & Entertainment (200-219)
    Icons.games, // 200
    Icons.casino, // 201
    Icons.extension, // 202
    Icons.extension, // 203
    Icons.sports_esports, // 204
    Icons.toys, // 205
    Icons.rocket_launch, // 206
    Icons.celebration, // 207
    Icons.party_mode, // 208
    Icons.cake, // 209
    Icons.weekend, // 210
    Icons.holiday_village, // 211
    Icons.festival, // 212
    Icons.local_activity, // 213
    Icons.attractions, // 214
    Icons.attractions, // 215
    Icons.roller_skating, // 216
    Icons.ice_skating, // 217
    Icons.skateboarding, // 218
    Icons.snowshoeing, // 219

    // Transportation & Travel (220-239)
    Icons.directions_car, // 220
    Icons.train, // 221
    Icons.flight, // 222
    Icons.directions_bus, // 223
    Icons.directions_subway, // 224
    Icons.motorcycle, // 225
    Icons.electric_scooter, // 226
    Icons.pedal_bike, // 227
    Icons.sailing, // 228
    Icons.directions_boat, // 229
    Icons.map, // 230
    Icons.navigation, // 231
    Icons.explore, // 232
    Icons.travel_explore, // 233
    Icons.luggage, // 234
    Icons.hotel, // 235
    Icons.apartment, // 236
    Icons.home, // 237
    Icons.location_city, // 238
    Icons.public, // 239

    // Miscellaneous (240+)
    Icons.cleaning_services, // 240
    Icons.build, // 241
    Icons.handyman, // 242
    Icons.plumbing, // 243
    Icons.electrical_services, // 244
    Icons.carpenter, // 245
    Icons.hardware, // 246
    Icons.agriculture, // 247
    Icons.volunteer_activism, // 248
    Icons.favorite_border, // 249
    Icons.star_border, // 250
    Icons.bookmark, // 251
    Icons.flag, // 252
    Icons.lightbulb_outline, // 253
    Icons.emoji_nature, // 254
    Icons.emoji_food_beverage, // 255
  ];

  // Get avatar by index (image or emoji fallback)
  static String getAvatar(int index, {bool forceEmoji = false}) {
    if (forceEmoji || index >= avatarImages.length) {
      return avatarEmojis[index % avatarEmojis.length];
    }
    return avatarImages[index % avatarImages.length];
  }

  // Days of week
  static const List<String> daysOfWeek = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  static const List<String> fullDaysOfWeek = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  // Quit habit milestones (in days)
  static const List<int> quitHabitMilestones = [
    1, 3, 7, 14, 30, 60, 90, 180, 365
  ];

  // Habit categories
  static const List<String> habitCategories = [
    'Health',
    'Fitness',
    'Productivity',
    'Learning',
    'Mindfulness',
    'Finance',
    'Social',
    'Creative',
    'Other',
  ];

  // Smart habit suggestions
  static const List<Map<String, dynamic>> habitSuggestions = [
    {'name': 'Drink Water', 'icon': 1, 'category': 'Health', 'description': 'Stay hydrated throughout the day'},
    {'name': 'Morning Exercise', 'icon': 0, 'category': 'Fitness', 'description': 'Start your day with movement'},
    {'name': 'Read 30 Minutes', 'icon': 1, 'category': 'Learning', 'description': 'Expand your knowledge daily'},
    {'name': 'Meditate', 'icon': 5, 'category': 'Mindfulness', 'description': 'Find inner peace'},
    {'name': 'Sleep 8 Hours', 'icon': 3, 'category': 'Health', 'description': 'Rest well for better performance'},
    {'name': 'Practice Coding', 'icon': 7, 'category': 'Learning', 'description': 'Improve your programming skills'},
    {'name': 'Healthy Breakfast', 'icon': 4, 'category': 'Health', 'description': 'Fuel your body right'},
    {'name': 'Journaling', 'icon': 1, 'category': 'Mindfulness', 'description': 'Reflect on your thoughts'},
    {'name': 'No Phone Before Bed', 'icon': 18, 'category': 'Health', 'description': 'Better sleep quality'},
    {'name': 'Save Money', 'icon': 17, 'category': 'Finance', 'description': 'Build financial security'},
  ];

  // Greeting messages based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  // Motivational quotes
  static const List<String> motivationalQuotes = [
    'Small steps lead to big changes.',
    'Consistency is the key to success.',
    'You are stronger than you think.',
    'Every day is a fresh start.',
    'Believe in yourself and all that you are.',
    'Your habits shape your future.',
    'Progress, not perfection.',
    'One day at a time.',
    'You are capable of amazing things.',
    'Make today count!',
    'The secret of getting ahead is getting started.',
    'Success is the sum of small efforts repeated day in and day out.',
    'Your only limit is you.',
    'Don\'t watch the clock; do what it does. Keep going.',
    'The best time to plant a tree was 20 years ago. The second best time is now.',
  ];

  // Habit Templates
  static const Map<String, List<Map<String, dynamic>>> habitTemplates = {
    'Morning Routine': [
      {'name': 'Drink Water', 'icon': 2, 'category': 'Health', 'description': 'Start your day hydrated'},
      {'name': 'Morning Exercise', 'icon': 0, 'category': 'Fitness', 'description': 'Get your body moving'},
      {'name': 'Healthy Breakfast', 'icon': 4, 'category': 'Health', 'description': 'Fuel your body right'},
      {'name': 'Meditate', 'icon': 5, 'category': 'Mindfulness', 'description': 'Clear your mind'},
      {'name': 'Plan Your Day', 'icon': 10, 'category': 'Productivity', 'description': 'Set daily goals'},
    ],
    'Fitness Pack': [
      {'name': 'Morning Run', 'icon': 6, 'category': 'Fitness', 'description': 'Cardio workout'},
      {'name': 'Strength Training', 'icon': 0, 'category': 'Fitness', 'description': 'Build muscle'},
      {'name': 'Stretching', 'icon': 16, 'category': 'Fitness', 'description': 'Improve flexibility'},
      {'name': 'Track Calories', 'icon': 4, 'category': 'Health', 'description': 'Monitor nutrition'},
    ],
    'Mindfulness': [
      {'name': 'Morning Meditation', 'icon': 5, 'category': 'Mindfulness', 'description': 'Start peacefully'},
      {'name': 'Gratitude Journal', 'icon': 1, 'category': 'Mindfulness', 'description': 'Count your blessings'},
      {'name': 'Evening Reflection', 'icon': 21, 'category': 'Mindfulness', 'description': 'End with awareness'},
    ],
    'Productivity': [
      {'name': 'Deep Work Session', 'icon': 10, 'category': 'Productivity', 'description': 'Focus time'},
      {'name': 'Check Emails', 'icon': 18, 'category': 'Productivity', 'description': 'Stay organized'},
      {'name': 'Daily Planning', 'icon': 19, 'category': 'Productivity', 'description': 'Time management'},
      {'name': 'Learn Something New', 'icon': 11, 'category': 'Learning', 'description': 'Continuous growth'},
    ],
    'Learning': [
      {'name': 'Read 30 Minutes', 'icon': 1, 'category': 'Learning', 'description': 'Expand knowledge'},
      {'name': 'Practice Coding', 'icon': 7, 'category': 'Learning', 'description': 'Improve skills'},
      {'name': 'Watch Tutorial', 'icon': 13, 'category': 'Learning', 'description': 'Learn visually'},
    ],
  };

  // Completion messages (emojis removed - use PremiumIcons.completionIcons for icons)
  static const List<String> completionMessages = [
    'Amazing! Keep it up!',
    'You\'re crushing it!',
    'Fantastic work!',
    'On fire today!',
    'Excellent progress!',
    'You\'re a star!',
    'Diamond performance!',
    'Champion mindset!',
    'To the moon!',
    'Well done!',
  ];

  // Streak milestone messages (emojis removed - use Iconsax.flame for icon)
  static Map<int, String> streakMilestones = {
    3: '3-day streak! Building momentum!',
    7: 'Week streak! You\'re on fire!',
    14: '2-week streak! Unstoppable!',
    21: '21 days! Habit formed!',
    30: 'Month streak! Legendary!',
    50: '50 days! Incredible dedication!',
    100: 'Century! You\'re a master!',
  };
}
