class LocalDictionary {
  // A simple, robust list for the Hackathon demo. 
  // You can expand this with ChatGPT by asking "Give me 100 common animals in Catalan"
  
  static final Map<String, Set<String>> categories = {
    'Animals': {
      // --- ORIGINAL LIST ---
      'gat', 'gos', 'cavall', 'elefant', 'lleo', 'tigre', 'ocell', 'peix', 
      'ratoli', 'mico', 'vaca', 'porc', 'ovella', 'cabra', 'conill', 'tortuga',
      'girafa', 'zebra', 'llop', 'guineu', 'os', 'serp', 'granota', 'dofi',
      'balena', 'tauro', 'aliga', 'colom', 'gallina', 'pollastre',

      // --- FARM & DOMESTIC ---
      'ase', 'ruc', 'mul', 'bou', 'toro', 'gall', 'dindi', 'anec', 'oca', 
      'hamster', 'fura', 'poni',

      // --- FOREST & EUROPEAN WILD ---
      'senglar', 'cervol', 'cabirol', 'esquirol', 'erico', 'teixo', 'castor', 
      'linx', 'talp', 'ratpenat', 'os rentador', 'lludria', 'fagina',

      // --- JUNGLE, SAVANNA & EXOTIC ---
      'hipopotam', 'rinoceront', 'cocodril', 'caiman', 'cangur', 'koala', 
      'panda', 'goril·la', 'ximpanze', 'lemur', 'orangutan', 'mandril',
      'camell', 'dromedari', 'hiena', 'guepard', 'pantera', 'lleopard', 
      'jaguar', 'puma', 'antilop', 'bufal', 'gasela', 'suricata',

      // --- BIRDS ---
      'falco', 'mussol', 'oliba', 'pingüi', 'lloro', 'periquito', 'cigne', 
      'flamenc', 'voltor', 'gavina', 'corb', 'oreneta', 'rossinyol', 'canari',
      'tuca', 'cigonya', 'pao', 'guatlla', 'perdiu', 'faisa',

      // --- SEA & WATER ---
      'foca', 'morsa', 'pop', 'calamar', 'sipia', 'cranc', 'llagosta', 'gamba', 
      'medusa', 'orca', 'manati', 'cavallet de mar', 'estrella de mar', 
      'rajada', 'bacalla', 'tonyina', 'salmo', 'sardina',

      // --- REPTILES & AMPHIBIANS ---
      'sargantana', 'camaleo', 'iguana', 'drago', 'salamandra', 'gripau',

      // --- INSECTS & BUGS (Commonly accepted in these games) ---
      'aranya', 'formiga', 'abella', 'vespa', 'papallona', 'mosca', 'mosquit', 
      'escarabat', 'cargol', 'llimac', 'escorpi', 'saltamarti', 'marieta', 'cuc'
    },
    'Fruites': {
      // --- LLISTA ORIGINAL ---
      'poma', 'pera', 'platan', 'taronja', 'llimona', 'maduixa', 'cirera', 
      'melo', 'sindria', 'raïm', 'pressec', 'albercoc', 'pinya', 'kiwi', 
      'mango', 'figa', 'pruna', 'mandarina', 'coco', 'gerds',

      // --- CiTRICS I aCIDS ---
      'llima', 'aranja', 'clementina', 'pomelo', 

      // --- FRUITES D'OS I TEMPORADA (Molt tipiques) ---
      'nectarina', 'paraguiana', 'nespra', 'caqui', 'magrana', 'codony', 
      'figa de moro',

      // --- FRUITES DEL BOSC ---
      'nabiu', 'mora', 'grosella', 'gerd', 'aranyo',

      // --- TROPICALS I EXoTIQUES ---
      'banana', 'papaia', 'alvocat', 'xirimoia', 'datil', 'litxi', 
      'maracuja', 'guaiaba', 'pitaya', 'fruit del drac', 'tamarinde', 
      'fisalis', 'cumquat'
    },
    'Colors': {
      // --- LLISTA ORIGINAL ---
      'vermell', 'blau', 'verd', 'groc', 'negre', 'blanc', 'lila', 'rosa', 
      'taronja', 'gris', 'marro', 'turquesa', 'beix', 'daurat', 'platejat',

      // --- MATISOS DE VERMELL I ROSA ---
      'granat', 'bordeus', 'fucsia', 'magenta', 'coral', 'salmo', 'escarlata', 
      'carmi', 'rosat',

      // --- MATISOS DE BLAU I VERD ---
      'blau cel', 'blau mari', 'indi', 'cian', 'maragda', 'verd oliva', 
      'verd poma', 'verd llima', 'aiguamarina', 'menta', 'atzur',

      // --- MATISOS DE GROC I TERRA ---
      'ocre', 'mostassa', 'ambre', 'crema', 'vainilla', 'xocolata', 
      'teula', 'terrissa',

      // --- LILES I VIOLETES ---
      'violeta', 'morat', 'purpura', 'lavanda', 'malva',

      // --- METALLS I NEUTRES ---
      'bronze', 'coure', 'ivori', 'caqui', 'cru', 'carbo', 'antracita'
    },
    'Ciutats': {
      // --- ORIGINAL I CATALUNYA (Essencial per a usuaris locals) ---
      'barcelona', 'girona', 'lleida', 'tarragona', 'l\'hospitalet de llobregat',
      'badalona', 'terrassa', 'sabadell', 'mataro', 'santa coloma de gramenet',
      'reus', 'tortosa', 'manresa', 'vic', 'figueres', 'olot', 'blanes', 
      'lloret de mar', 'vilanova i la geltru', 'vilafranca del penedes', 
      'granollers', 'mollet del valles', 'rubi', 'sant cugat del valles',
      'cornella', 'sant boi', 'castelldefels', 'viladecans', 'el prat', 
      'igualada', 'berga', 'banyoles', 'amposta', 'la seu d\'urgell', 'sort', 
      'tremp', 'solsona', 'mora d\'ebre', 'tarrega', 'balaguer', 'andorra la vella', 
      'perpinya', 'l\'alguer',

      // --- ESPANYA (Capitals de provincia i grans ciutats) ---
      'madrid', 'valencia', 'sevilla', 'saragossa', 'malaga', 'murcia', 
      'palma', 'palma de mallorca', 'las palmas', 'bilbao', 'alacant', 'cordova', 
      'valladolid', 'vigo', 'gijon', 'la corunya', 'vitoria', 'granada', 
      'elx', 'oviedo', 'cartagena', 'jerez', 'terratsa', 
      'sant sebastia', 'donostia', 'pamplona', 'almeria', 'burgos', 'santander', 
      'castello', 'castello de la plana', 'logronyo', 'badajoz', 'salamanca', 
      'huelva', 'marbella', 'lleo', 'cadis', 'jaen', 'ourense', 'lugo', 
      'caceres', 'santiago de compostel·la', 'ceuta', 'melilla', 'guadalajara', 
      'toledo', 'pontevedra', 'palencia', 'ciutat real', 'zamora', 'avila', 
      'conca', 'segovia', 'osca', 'soria', 'terol', 'eivissa', 'mao',

      // --- EUROPA (Capitals i grans centres) ---
      'paris', 'londres', 'roma', 'berlin', 'lisboa', 'atenes', 'dublin', 
      'amsterdam', 'brussel·les', 'viena', 'zuric', 'ginebra', 'mila', 
      'napols', 'tori', 'venecia', 'florencia', 'munic', 'frankfurt', 
      'hamburg', 'copenhaguen', 'estocolm', 'oslo', 'helsinki', 'varsovia', 
      'praga', 'budapest', 'bucarest', 'sofia', 'istanbul', 'kiev', 
      'sant petersburg', 'manchester', 'liverpool', 'glasgow', 'edimburg',
      'monaco', 'lio', 'marsella', 'bordeus', 'porto',

      // --- AMeRICA (Nord i Sud) ---
      'nova york', 'los angeles', 'chicago', 'san francisco', 'miami', 
      'washington', 'boston', 'las vegas', 'toronto', 'mont-real', 'vancouver', 
      'ciutat de mexic', 'buenos aires', 'rio de janeiro', 'são paulo', 
      'lima', 'bogota', 'santiago de xile', 'caracas', 'l\'havana', 
      'montevideo', 'quito', 'la paz', 'brasilia',

      // --- aSIA, aFRICA I OCEANIA ---
      'toquio', 'pequin', 'xangai', 'hong kong', 'moscou', 'bombai', 
      'nova delhi', 'dubai', 'jerusalem', 'tel aviv', 'el caire', 
      'marrakech', 'casablanca', 'ciutat del cap', 'johannesburg', 
      'sydney', 'melbourne', 'bangkok', 'singapur', 'seül', 'manila', 
      'jakarta', 'teheran', 'bagdad', 'riad'
    },
    'Roba': {
      // --- LLISTA ORIGINAL ---
      'samarreta', 'pantalons', 'jersei', 'jaqueta', 'abric', 'sabates', 
      'mitjons', 'bufanda', 'barret', 'gorra', 'vestit', 'faldilla', 'camisa',
      'botes', 'guants', 'cinturo',

      // --- PARTS DE DALT I ABRIGAR ---
      'brusa', 'top', 'polo', 'dessuadora', 'americana', 'armilla', 
      'cardigan', 'gavardina', 'impermeable', 'anorac', 'parca', 'ponxo',
      'capa',

      // --- PANTALONS I PART INFERIOR ---
      'texans', 'vaquers', 'pantalons curts', 'bermudes', 'malles', 
      'leggings', 'granota', 'peto',

      // --- ROBA INTERIOR I DE DORMIR ---
      'roba interior', 'calces', 'calcotets', 'sostenidor', 'cotilla', 
      'samarreta interior', 'mitges', 'leotards', 'pijama', 'camisona', 
      'bata', 'barnus',

      // --- ESPORT I BANY ---
      'xandall', 'banyador', 'biquini', 'mallot',

      // --- CALcAT (Molt important acceptar sinonims) ---
      'vambes', 'sabatilles', 'esportives', 'sandalies', 'xancletes', 
      'espardenyes', 'avarques', 'pantuflas', 'sucs', 'talons', 'mocassins',

      // --- ACCESSORIS DE VESTIR ---
      'corbata', 'llacet', 'mocador', 'fulard', 'xal', 'barretina', 
      'boina', 'diadema', 'orelleres'
    },
  };

  static bool isValidCategory(String word, String category) {
    // Normalize: lowercase and trim
    String cleanWord = normalizeText(word);
    // Remove accents for easier matching if needed (optional optimization)
    return categories[category]?.contains(cleanWord) ?? false;
  }

  static String normalizeText(String input) {
    if (input.isEmpty) return "";

    // 1. Convertir a minúscules
    String text = input.toLowerCase();

    // 2. Reemplaçar vocals amb accents i dièresis
    text = text.replaceAll(RegExp(r'[àáâä]'), 'a');
    text = text.replaceAll(RegExp(r'[èéêë]'), 'e');
    text = text.replaceAll(RegExp(r'[ìíîï]'), 'i');
    text = text.replaceAll(RegExp(r'[òóôö]'), 'o');
    text = text.replaceAll(RegExp(r'[ùúûü]'), 'u');

    // 3. Reemplaçar caràcters especials (ç, ñ, l·l)
    text = text.replaceAll('ç', 'c');
    text = text.replaceAll('ñ', 'n');
    
    // 4. Eliminar el punt volat de la ela geminada (l·l -> ll)
    // De vegades el reconeixement de veu posa un punt normal o un guió
    text = text.replaceAll('·', ''); 
    text = text.replaceAll('.', ''); 
    text = text.replaceAll('•', ''); 

    // 5. Eliminar espais extra (opcional, però recomanat)
    return text.trim();
  }


  static bool isValidLetter(String word, String letter) {
    String cleanWord = word.trim();
    if (cleanWord.isEmpty) return false;
    return cleanWord.toUpperCase().startsWith(letter.toUpperCase());
  }
}