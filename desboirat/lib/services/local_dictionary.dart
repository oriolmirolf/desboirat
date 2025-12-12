class LocalDictionary {
  // A simple, robust list for the Hackathon demo. 
  // You can expand this with ChatGPT by asking "Give me 100 common animals in Catalan"
  
  static final Map<String, Set<String>> categories = {
    'Animals': {
      'gat', 'gos', 'cavall', 'elefant', 'lleó', 'tigre', 'ocell', 'peix', 
      'ratolí', 'mico', 'vaca', 'porc', 'ovella', 'cabra', 'conill', 'tortuga',
      'girafa', 'zebra', 'llop', 'guineu', 'ós', 'serp', 'granota', 'dofí',
      'balena', 'tauró', 'àliga', 'colom', 'gallina', 'pollastre'
    },
    'Fruites': {
      'poma', 'pera', 'plàtan', 'taronja', 'llimona', 'maduixa', 'cirera', 
      'meló', 'síndria', 'raïm', 'préssec', 'albercoc', 'pinya', 'kiwi', 
      'mango', 'figa', 'pruna', 'mandarina', 'coco', 'gerds'
    },
    'Colors': {
      'vermell', 'blau', 'verd', 'groc', 'negre', 'blanc', 'lila', 'rosa', 
      'taronja', 'gris', 'marró', 'turquesa', 'beix', 'daurat', 'platejat'
    },
    'Ciutats': {
      'barcelona', 'girona', 'lleida', 'tarragona', 'madrid', 'parís', 'londres',
      'roma', 'berlin', 'nova york', 'tòquio', 'pequín', 'moscou', 'valència',
      'sevilla', 'bilbao', 'lisboa', 'atenes', 'dublin'
    },
    'Roba': {
      'samarreta', 'pantalons', 'jersei', 'jaqueta', 'abric', 'sabates', 
      'mitjons', 'bufanda', 'barret', 'gorra', 'vestit', 'faldilla', 'camisa',
      'botes', 'guants', 'cinturó'
    }
  };

  static bool isValidCategory(String word, String category) {
    // Normalize: lowercase and trim
    String cleanWord = word.toLowerCase().trim();
    // Remove accents for easier matching if needed (optional optimization)
    return categories[category]?.contains(cleanWord) ?? false;
  }

  static bool isValidLetter(String word, String letter) {
    String cleanWord = word.trim();
    if (cleanWord.isEmpty) return false;
    return cleanWord.toUpperCase().startsWith(letter.toUpperCase());
  }
}