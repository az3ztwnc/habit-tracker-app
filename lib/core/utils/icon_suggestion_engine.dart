/// Smart Icon Suggestion Engine
/// Analyzes habit names and suggests the most appropriate icons
class IconSuggestionEngine {
  // Clean keyword to icon mapping without duplicates (200+ mappings)
  static const Map<String, List<int>> _keywordToIconMap = {
    // Fitness & Exercise (0-19)
    'exercise': [0, 1, 2],
    'workout': [0, 1, 2],
    'fitness': [0, 1, 2], 
    'gym': [0],
    'run': [1],
    'running': [1],
    'jog': [1],
    'walk': [2],
    'walking': [2],
    'swim': [3],
    'swimming': [3],
    'cycle': [4],
    'cycling': [4],
    'bike': [4],
    'stretch': [5],
    'stretching': [5],
    'yoga': [6],
    'strength': [7],
    'weights': [7],
    'cardio': [8],
    'sports': [9],
    'basketball': [10],
    'football': [11],
    'tennis': [12],
    'golf': [13],
    'martial': [14],
    'karate': [14],
    'boxing': [15],
    'volleyball': [16],
    'baseball': [17],
    'soccer': [18],
    'badminton': [19],
    
    // Health & Wellness (20-39)
    'health': [20, 21, 22],
    'medicine': [20],
    'doctor': [20],
    'meditation': [21],
    'mindfulness': [21],
    'sleep': [22],
    'rest': [22],
    'water': [23],
    'hydrate': [23],
    'drink_water': [23],
    'vitamin': [24],
    'supplement': [24],
    'therapy': [25],
    'massage': [25],
    'skincare': [26],
    'dental': [27],
    'teeth': [27],
    'brush_teeth': [27],
    'vision': [28],
    'eye_care': [28],
    'heart': [29],
    'blood_pressure': [30],
    'checkup': [31],
    'weight_management': [32],
    'diet_health': [33],
    'mental_health': [34],
    'breathe': [35],
    'breathing': [35],
    'posture': [36],
    'ergonomics': [37],
    'sunscreen': [38],
    'first_aid': [39],
    
    // Food & Nutrition (40-59)
    'eat': [40, 41, 42],
    'food': [40, 41, 42],
    'nutrition': [40, 41, 42],
    'vegetables': [41],
    'veggie': [41],
    'fruit': [42],
    'fruits': [42],
    'apple': [42],
    'healthy_eating': [43],
    'meal_prep': [44],
    'cooking': [45],
    'cook': [45],
    'recipe': [45],
    'breakfast': [46],
    'lunch': [47],
    'dinner': [48],
    'snack': [49],
    'protein': [50],
    'fiber': [51],
    'organic': [52],
    'dessert': [53],
    'sweet': [53],
    'dairy': [54],
    'milk': [54],
    'grain': [55],
    'bread': [55],
    'salad': [56],
    'soup': [57],
    'juice': [58],
    'smoothie': [59],
    
    // Learning & Education (60-79)
    'learn': [60, 61, 62],
    'study': [60, 61, 62],
    'education': [60, 61, 62],
    'read': [61],
    'reading': [61],
    'book': [61],
    'research': [62],
    'language': [63],
    'speak': [63],
    'english': [63],
    'spanish': [63],
    'french': [63],
    'math': [64],
    'mathematics': [64],
    'calculate': [64],
    'science': [65],
    'physics': [65],
    'chemistry': [65],
    'biology': [65],
    'history': [66],
    'geography': [67],
    'writing': [68],
    'write': [68],
    'journal': [68],
    'notes': [69],
    'note_taking': [69],
    'course': [70],
    'class': [70],
    'lecture': [71],
    'seminar': [71],
    'quiz': [72],
    'test': [72],
    'exam': [72],
    'homework': [73],
    'assignment': [73],
    'practice': [74],
    'memory_training': [75],
    'remember': [75],
    'think': [76],
    'idea': [76, 78],
    'creativity': [78],
    'innovation': [77],
    
    // Technology & Digital (80-99)
    'code': [80],
    'coding': [80],
    'program': [80],
    'programming': [80],
    'software': [80],
    'computer': [81],
    'laptop': [81],
    'internet': [82],
    'web': [82],
    'website': [82],
    'email': [83],
    'social_media': [84],
    'facebook': [84],
    'instagram': [84],
    'twitter': [84],
    'phone': [85],
    'mobile': [85],
    'smartphone': [85],
    'app': [86],
    'application': [86],
    'game_video': [87],
    'gaming': [87],
    'video_game': [87],
    'tech': [88],
    'technology': [88],
    'digital': [89],
    'online': [90],
    'backup': [91],
    'cloud': [92],
    'security': [93],
    'password': [93],
    'update': [94],
    'upgrade': [94],
    'ai': [95],
    'artificial_intelligence': [95],
    'data': [96],
    'database': [96],
    'network': [97],
    'wifi': [97],
    'bluetooth': [98],
    'smart_home': [99],
    
    // Creative Arts (100-119)
    'art': [100, 102],
    'creative_arts': [100, 118],
    'paint': [100, 117],
    'painting': [100, 117],
    'music': [101],
    'instrument': [101],
    'design': [102, 116],
    'graphic_design': [102],
    'photo': [103],
    'photography': [103],
    'camera': [103],
    'video': [104],
    'film': [104],
    'movie': [104],
    'craft': [105],
    'crafting': [105],
    'diy': [105],
    'sewing': [106],
    'knitting': [106],
    'pottery': [107],
    'sculpture': [108],
    'drawing': [109],
    'sketch': [109],
    'piano': [110],
    'guitar': [111],
    'sing': [101, 112],
    'singing': [101, 112],
    'dance': [113],
    'dancing': [113],
    'audio': [114],
    'sound': [114],
    'record': [115],
    'album': [115],
    'color': [116],
    'palette': [102],
    'brush': [117],
    'illustration': [118],
    'animation': [119],
    
    // Work & Professional (120-139)
    'work': [120, 121, 122],
    'job': [120, 121, 122],
    'career': [120, 121, 122],
    'office': [121],
    'business': [122],
    'meeting': [123],
    'conference': [123],
    'presentation': [124],
    'project': [125],
    'task': [126],
    'deadline': [127],
    'goal': [128],
    'target': [128],
    'achievement': [128],
    'skill': [129],
    'training_work': [129],
    'leadership': [130],
    'manage': [130],
    'management': [130],
    'team': [131],
    'collaborate': [131],
    'communication': [132],
    'email_work': [133],
    'report': [134],
    'document': [134],
    'spreadsheet': [135],
    'analysis': [136],
    'strategy': [137],
    'planning': [137],
    'networking': [138],
    'professional': [139],
    
    // Social & Relationships (140-159)
    'social_life': [140, 141, 142],
    'friends': [140, 141, 142],
    'family': [141],
    'relationship': [142],
    'date': [142],
    'call': [143],
    'text': [144],
    'chat': [144],
    'message': [144],
    'party': [145],
    'celebration': [145],
    'gift': [146],
    'birthday': [147],
    'wedding': [148],
    'community': [149],
    'volunteer': [149],
    'help': [150],
    'charity': [150],
    'support': [151],
    'care': [151],
    'love': [152],
    'kindness': [152],
    'empathy': [153],
    'listen': [154],
    'talk': [154],
    'share': [155],
    'connect': [156],
    'bond': [157],
    'trust': [158],
    'respect': [159],
    
    // Finance & Money (160-179)
    'money': [160, 161, 162],
    'finance': [160, 161, 162],
    'budget': [161],
    'save_money': [162],
    'saving': [162],
    'invest': [163],
    'investment': [163],
    'stock': [164],
    'bank': [165],
    'banking': [165],
    'credit': [166],
    'debt': [167],
    'loan': [167],
    'pay': [168],
    'payment': [168],
    'bill': [168],
    'expense': [169],
    'cost': [169],
    'income': [170],
    'salary': [170],
    'wage': [170],
    'tax': [171],
    'receipt': [172],
    'purchase': [173],
    'buy': [173],
    'sell': [174],
    'trade': [175],
    'currency': [176],
    'exchange': [176],
    'insurance': [177],
    'pension': [178],
    'retirement': [179],
    
    // Nature & Environment (180-199)
    'nature': [180, 181, 182],
    'environment': [180, 181, 182],
    'tree': [181],
    'plant': [182],
    'flower': [183],
    'garden': [184],
    'gardening': [184],
    'outdoor': [185],
    'hiking': [185],
    'camping': [186],
    'beach': [187],
    'mountain': [188],
    'forest': [189],
    'lake': [190],
    'river': [191],
    'ocean': [192],
    'weather': [193],
    'rain': [194],
    'sun': [195],
    'snow': [196],
    'wind': [197],
    'earth': [198],
    'planet': [198],
    'eco': [199],
    'recycle': [199],
    
    // Hobbies & Recreation (200-219)
    'hobby': [200, 201, 202],
    'fun': [200, 201, 202],
    'recreation': [200, 201, 202],
    'game_hobby': [201],
    'puzzle': [202],
    'board_game': [203],
    'card_game': [204],
    'chess': [205],
    'checkers': [206],
    'collect': [207],
    'collection': [207],
    'stamp': [208],
    'coin': [209],
    'antique': [210],
    'vintage': [210],
    'model': [211],
    'building': [211],
    'lego': [211],
    'fishing': [212],
    'hunting': [213],
    'bird_watching': [214],
    'amusement': [215],
    'roller_coaster': [216],
    'ferris_wheel': [217],
    'carnival': [218],
    'circus': [219],
    
    // Transportation (220-239)
    'transport': [220, 221, 222],
    'travel': [220, 221, 222],
    'car': [221],
    'drive': [221],
    'driving': [221],
    'bus': [222],
    'train': [223],
    'subway': [224],
    'plane': [225],
    'flight': [225],
    'ship': [226],
    'boat': [227],
    'motorcycle': [228],
    'bicycle_transport': [229],
    'scooter': [230],
    'taxi': [231],
    'uber': [231],
    'lyft': [231],
    'commute': [232],
    'traffic': [233],
    'parking': [234],
    'gas': [235],
    'fuel': [235],
    'maintenance': [236],
    'repair': [237],
    'road_trip': [238],
    'vacation': [239],
    
    // Miscellaneous (240+)
    'time': [240],
    'clock': [240],
    'schedule': [241],
    'calendar': [241],
    'alarm': [242],
    'reminder': [243],
    'notify': [243],
    'clean': [244],
    'cleaning': [244],
    'organize': [245],
    'tidy': [245],
    'laundry': [246],
    'wash': [246],
    'iron': [247],
    'vacuum': [248],
    'dust': [249],
    'garbage': [250],
    'trash': [250],
    'recycle_misc': [251],
    'repair_misc': [252],
    'fix': [252],
    'tool': [253],
    'hammer': [253],
    'screwdriver': [254],
    'wrench': [255],
    'nail': [255],
    'screw': [255],
  };

  // Category mappings for broader suggestions
  static const Map<String, int> categoryMappings = {
    'Fitness': 0, 'Exercise': 0, 'Running': 1, 'Walking': 2,
    'Health': 20, 'Medicine': 20, 'Meditation': 21, 'Sleep': 22,
    'Nutrition': 40, 'Cooking': 45, 'Learning': 60, 'Reading': 61,
    'Technology': 80, 'Coding': 80, 'Creative': 100, 'Art': 100,
    'Work': 120, 'Business': 122, 'Social': 140, 'Finance': 160,
    'Nature': 180, 'Hobby': 200, 'Travel': 220, 'Organization': 245,
  };

  /// Suggests icons based on habit name with confidence scoring
  static List<MapEntry<int, double>> suggestIcon(String habitName) {
    if (habitName.isEmpty) return [];
    
    final normalizedInput = habitName.toLowerCase().trim();
    final words = normalizedInput.split(RegExp(r'[\s,.-]+'));
    
    Map<int, double> iconScores = {};
    
    // Direct keyword matching
    for (String word in words) {
      if (_keywordToIconMap.containsKey(word)) {
        for (int iconIndex in _keywordToIconMap[word]!) {
          iconScores[iconIndex] = (iconScores[iconIndex] ?? 0.0) + 1.0;
        }
      }
    }
    
    // Partial matching for compound words
    for (String key in _keywordToIconMap.keys) {
      for (String word in words) {
        if (word.contains(key) || key.contains(word)) {
          if (word != key) { // Avoid duplicate scoring
            double partialScore = 0.5;
            for (int iconIndex in _keywordToIconMap[key]!) {
              iconScores[iconIndex] = (iconScores[iconIndex] ?? 0.0) + partialScore;
            }
          }
        }
      }
    }
    
    // Category matching
    for (String category in categoryMappings.keys) {
      if (normalizedInput.contains(category.toLowerCase())) {
        int iconIndex = categoryMappings[category]!;
        iconScores[iconIndex] = (iconScores[iconIndex] ?? 0.0) + 0.7;
      }
    }
    
    // Convert to sorted list with confidence scores
    var sortedIcons = iconScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Normalize confidence scores to 0.0-1.0 range
    if (sortedIcons.isNotEmpty) {
      double maxScore = sortedIcons.first.value;
      for (int i = 0; i < sortedIcons.length; i++) {
        sortedIcons[i] = MapEntry(
          sortedIcons[i].key,
          sortedIcons[i].value / maxScore,
        );
      }
    }
    
    return sortedIcons.take(10).toList(); // Return top 10 suggestions
  }

  /// Gets the top N icon suggestions with their confidence scores
  static List<MapEntry<int, double>> getTopSuggestions(String habitName, {int count = 5}) {
    return suggestIcon(habitName).take(count).toList();
  }

  /// Gets just the icon indices without confidence scores
  static List<int> getIconIndices(String habitName, {int count = 5}) {
    return suggestIcon(habitName)
        .take(count)
        .map((entry) => entry.key)
        .toList();
  }
}