import '../core/models/photo_model.dart';

class DataSource {
  static const String _haircutTips = "Ask for a clean fade on the sides. Keep the top textured for volume. Angle your face to show the jawline.";
  static const String _weddingTips = "Hold hands naturally. Look at each other and smile. Ensure the background is not distracting.";
  static const String _babyTips = "Get down to the baby's eye level. Use natural light. Capture candid moments.";
  static const String _natureTips = "Use the rule of thirds. Look for leading lines. Capture the golden hour light.";
  static const String _travelTips = "Include local landmarks. Act candidly like you are exploring. Don't look directly at the camera.";
  static const String _archTips = "Look for symmetry. Use a wide angle if possible. Capture unique details.";

  static final List<PhotoModel> haircutImages = [
    PhotoModel(url: 'https://images.unsplash.com/photo-1560869713-7d0a29430803?auto=format&fit=crop&w=800&q=80', category: 'Haircut', posingInstructions: _haircutTips),
    PhotoModel(url: 'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?auto=format&fit=crop&w=800&q=80', category: 'Haircut', posingInstructions: _haircutTips),
    PhotoModel(url: 'https://images.unsplash.com/photo-1595476108010-b4d1f102b1b1?auto=format&fit=crop&w=800&q=80', category: 'Haircut', posingInstructions: _haircutTips),
    PhotoModel(url: 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?auto=format&fit=crop&w=800&q=80', category: 'Haircut', posingInstructions: _haircutTips),
    PhotoModel(url: 'https://images.unsplash.com/photo-1521119989659-a83eee488058?auto=format&fit=crop&w=800&q=80', category: 'Haircut', posingInstructions: _haircutTips),
    PhotoModel(url: 'https://images.unsplash.com/photo-1605497788044-5a32c7078486?auto=format&fit=crop&w=800&q=80', category: 'Haircut', posingInstructions: _haircutTips),
    PhotoModel(url: 'https://images.unsplash.com/photo-1596392927816-73a37e09c094?auto=format&fit=crop&w=800&q=80', category: 'Haircut', posingInstructions: _haircutTips),
    PhotoModel(url: 'https://images.unsplash.com/photo-1503951914875-452162b7f304?auto=format&fit=crop&w=800&q=80', category: 'Haircut', posingInstructions: _haircutTips),
  ];

  static final List<PhotoModel> weddingImages = [
    PhotoModel(url: 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=800&q=80', category: 'Wedding', posingInstructions: _weddingTips),
    PhotoModel(url: 'https://images.unsplash.com/photo-1511285560982-1351cdeb9821?auto=format&fit=crop&w=800&q=80', category: 'Wedding', posingInstructions: _weddingTips),
    PhotoModel(url: 'https://images.unsplash.com/photo-1515934751635-c81c6bc9a2d8?auto=format&fit=crop&w=800&q=80', category: 'Wedding', posingInstructions: _weddingTips),
    PhotoModel(url: 'https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?auto=format&fit=crop&w=800&q=80', category: 'Wedding', posingInstructions: _weddingTips),
    PhotoModel(url: 'https://images.unsplash.com/photo-1469334031218-e382a71b716b?auto=format&fit=crop&w=800&q=80', category: 'Wedding', posingInstructions: _weddingTips),
    PhotoModel(url: 'https://images.unsplash.com/photo-1522673607200-1645062cd958?auto=format&fit=crop&w=800&q=80', category: 'Wedding', posingInstructions: _weddingTips),
    PhotoModel(url: 'https://images.unsplash.com/photo-1520854221256-17451cc330e7?auto=format&fit=crop&w=800&q=80', category: 'Wedding', posingInstructions: _weddingTips),
    PhotoModel(url: 'https://images.unsplash.com/photo-1507915977619-6ccfe8003ae6?auto=format&fit=crop&w=800&q=80', category: 'Wedding', posingInstructions: _weddingTips),
  ];

  static final List<PhotoModel> babyImages = [
    PhotoModel(url: 'https://images.unsplash.com/photo-1519689680058-324335c77eba?auto=format&fit=crop&w=800&q=80', category: 'Baby', posingInstructions: _babyTips),
    PhotoModel(url: 'https://images.unsplash.com/photo-1555252333-9f8e92e65df9?auto=format&fit=crop&w=800&q=80', category: 'Baby', posingInstructions: _babyTips),
    PhotoModel(url: 'https://images.unsplash.com/photo-1510154221590-ff63e90a136f?auto=format&fit=crop&w=800&q=80', category: 'Baby', posingInstructions: _babyTips),
    PhotoModel(url: 'https://images.unsplash.com/photo-1519340241574-2cec6aef0c01?auto=format&fit=crop&w=800&q=80', category: 'Baby', posingInstructions: _babyTips),
    PhotoModel(url: 'https://images.unsplash.com/photo-1505686994434-e3cc5abf1330?auto=format&fit=crop&w=800&q=80', category: 'Baby', posingInstructions: _babyTips),
    PhotoModel(url: 'https://images.unsplash.com/photo-1544126566-475a10623325?auto=format&fit=crop&w=800&q=80', category: 'Baby', posingInstructions: _babyTips),
    PhotoModel(url: 'https://images.unsplash.com/photo-1522771930-78848d9293e8?auto=format&fit=crop&w=800&q=80', category: 'Baby', posingInstructions: _babyTips),
    PhotoModel(url: 'https://images.unsplash.com/photo-1514359668584-1ddea8163f3e?auto=format&fit=crop&w=800&q=80', category: 'Baby', posingInstructions: _babyTips),
  ];

  static final List<PhotoModel> natureImages = [
    PhotoModel(url: 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=800&q=80', category: 'Nature', posingInstructions: _natureTips),
    PhotoModel(url: 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&fit=crop&w=800&q=80', category: 'Nature', posingInstructions: _natureTips),
    PhotoModel(url: 'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?auto=format&fit=crop&w=800&q=80', category: 'Nature', posingInstructions: _natureTips),
    PhotoModel(url: 'https://images.unsplash.com/photo-1501854140884-074bf6f243e?auto=format&fit=crop&w=800&q=80', category: 'Nature', posingInstructions: _natureTips),
    PhotoModel(url: 'https://images.unsplash.com/photo-1510784722466-f2aa9c52fff6?auto=format&fit=crop&w=800&q=80', category: 'Nature', posingInstructions: _natureTips),
    PhotoModel(url: 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=800&q=80', category: 'Nature', posingInstructions: _natureTips),
  ];

  static final List<PhotoModel> travelImages = [
    PhotoModel(url: 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?auto=format&fit=crop&w=800&q=80', category: 'Travel', posingInstructions: _travelTips),
    PhotoModel(url: 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?auto=format&fit=crop&w=800&q=80', category: 'Travel', posingInstructions: _travelTips),
    PhotoModel(url: 'https://images.unsplash.com/photo-1503220317375-aaad61436b1b?auto=format&fit=crop&w=800&q=80', category: 'Travel', posingInstructions: _travelTips),
    PhotoModel(url: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80', category: 'Travel', posingInstructions: _travelTips),
    PhotoModel(url: 'https://images.unsplash.com/photo-1523906834658-6e24ef2386f9?auto=format&fit=crop&w=800&q=80', category: 'Travel', posingInstructions: _travelTips),
  ];

  static final List<PhotoModel> architectureImages = [
    PhotoModel(url: 'https://images.unsplash.com/photo-1511818966892-d7d671e672a2?auto=format&fit=crop&w=800&q=80', category: 'Architecture', posingInstructions: _archTips),
    PhotoModel(url: 'https://images.unsplash.com/photo-1487958449943-2429e8be8625?auto=format&fit=crop&w=800&q=80', category: 'Architecture', posingInstructions: _archTips),
    PhotoModel(url: 'https://images.unsplash.com/photo-1479839672679-a46483c0e7c8?auto=format&fit=crop&w=800&q=80', category: 'Architecture', posingInstructions: _archTips),
    PhotoModel(url: 'https://images.unsplash.com/photo-1518780664697-55e3ad937233?auto=format&fit=crop&w=800&q=80', category: 'Architecture', posingInstructions: _archTips),
  ];

  // Haircut Filters
  static final Map<String, List<PhotoModel>> haircutFilters = {
    'All': haircutImages,
    'Men': [
      PhotoModel(url: 'https://images.unsplash.com/photo-1595476108010-b4d1f102b1b1?auto=format&fit=crop&w=800&q=80', category: 'Haircut', posingInstructions: _haircutTips),
      PhotoModel(url: 'https://images.unsplash.com/photo-1605497788044-5a32c7078486?auto=format&fit=crop&w=800&q=80', category: 'Haircut', posingInstructions: _haircutTips),
      PhotoModel(url: 'https://images.unsplash.com/photo-1503951914875-452162b7f304?auto=format&fit=crop&w=800&q=80', category: 'Haircut', posingInstructions: _haircutTips),
    ],
    'Women': [
      PhotoModel(url: 'https://images.unsplash.com/photo-1560869713-7d0a29430803?auto=format&fit=crop&w=800&q=80', category: 'Haircut', posingInstructions: _haircutTips),
      PhotoModel(url: 'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?auto=format&fit=crop&w=800&q=80', category: 'Haircut', posingInstructions: _haircutTips),
      PhotoModel(url: 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?auto=format&fit=crop&w=800&q=80', category: 'Haircut', posingInstructions: _haircutTips),
    ],
    'Short': [
      PhotoModel(url: 'https://images.unsplash.com/photo-1595476108010-b4d1f102b1b1?auto=format&fit=crop&w=800&q=80', category: 'Haircut', posingInstructions: _haircutTips),
      PhotoModel(url: 'https://images.unsplash.com/photo-1521119989659-a83eee488058?auto=format&fit=crop&w=800&q=80', category: 'Haircut', posingInstructions: _haircutTips),
    ],
    'Long': [
      PhotoModel(url: 'https://images.unsplash.com/photo-1560869713-7d0a29430803?auto=format&fit=crop&w=800&q=80', category: 'Haircut', posingInstructions: _haircutTips),
      PhotoModel(url: 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?auto=format&fit=crop&w=800&q=80', category: 'Haircut', posingInstructions: _haircutTips),
    ],
  };

  // Wedding Filters
  static final Map<String, List<PhotoModel>> weddingFilters = {
    'All': weddingImages,
    'Couple': [
      PhotoModel(url: 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=800&q=80', category: 'Wedding', posingInstructions: _weddingTips),
      PhotoModel(url: 'https://images.unsplash.com/photo-1511285560982-1351cdeb9821?auto=format&fit=crop&w=800&q=80', category: 'Wedding', posingInstructions: _weddingTips),
      PhotoModel(url: 'https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?auto=format&fit=crop&w=800&q=80', category: 'Wedding', posingInstructions: _weddingTips),
    ],
    'Bride': [
      PhotoModel(url: 'https://images.unsplash.com/photo-1515934751635-c81c6bc9a2d8?auto=format&fit=crop&w=800&q=80', category: 'Wedding', posingInstructions: _weddingTips),
      PhotoModel(url: 'https://images.unsplash.com/photo-1469334031218-e382a71b716b?auto=format&fit=crop&w=800&q=80', category: 'Wedding', posingInstructions: _weddingTips),
    ],
    'Groom': [
      PhotoModel(url: 'https://images.unsplash.com/photo-1507915977619-6ccfe8003ae6?auto=format&fit=crop&w=800&q=80', category: 'Wedding', posingInstructions: _weddingTips),
    ],
    'Decor': [
      PhotoModel(url: 'https://images.unsplash.com/photo-1522673607200-1645062cd958?auto=format&fit=crop&w=800&q=80', category: 'Wedding', posingInstructions: _weddingTips),
      PhotoModel(url: 'https://images.unsplash.com/photo-1520854221256-17451cc330e7?auto=format&fit=crop&w=800&q=80', category: 'Wedding', posingInstructions: _weddingTips),
    ],
  };

  // Baby Filters
  static final Map<String, List<PhotoModel>> babyFilters = {
    'All': babyImages,
    'Newborn': [
      PhotoModel(url: 'https://images.unsplash.com/photo-1519689680058-324335c77eba?auto=format&fit=crop&w=800&q=80', category: 'Baby', posingInstructions: _babyTips),
      PhotoModel(url: 'https://images.unsplash.com/photo-1555252333-9f8e92e65df9?auto=format&fit=crop&w=800&q=80', category: 'Baby', posingInstructions: _babyTips),
    ],
    'Family': [
      PhotoModel(url: 'https://images.unsplash.com/photo-1511895426328-dc8714191300?auto=format&fit=crop&w=800&q=80', category: 'Baby', posingInstructions: _babyTips),
      PhotoModel(url: 'https://images.unsplash.com/photo-1544126566-475a10623325?auto=format&fit=crop&w=800&q=80', category: 'Baby', posingInstructions: _babyTips),
    ],
    'Outdoor': [
      PhotoModel(url: 'https://images.unsplash.com/photo-1519340241574-2cec6aef0c01?auto=format&fit=crop&w=800&q=80', category: 'Baby', posingInstructions: _babyTips),
      PhotoModel(url: 'https://images.unsplash.com/photo-1505686994434-e3cc5abf1330?auto=format&fit=crop&w=800&q=80', category: 'Baby', posingInstructions: _babyTips),
    ],
  };

  // Nature Filters
  static final Map<String, List<PhotoModel>> natureFilters = {
    'All': natureImages,
    'Landscape': [
      PhotoModel(url: 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=800&q=80', category: 'Nature', posingInstructions: _natureTips),
      PhotoModel(url: 'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?auto=format&fit=crop&w=800&q=80', category: 'Nature', posingInstructions: _natureTips),
    ],
    'Forest': [
      PhotoModel(url: 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&fit=crop&w=800&q=80', category: 'Nature', posingInstructions: _natureTips),
      PhotoModel(url: 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=800&q=80', category: 'Nature', posingInstructions: _natureTips),
    ],
    'Beach': [
      PhotoModel(url: 'https://images.unsplash.com/photo-1501854140884-074bf6f243e?auto=format&fit=crop&w=800&q=80', category: 'Nature', posingInstructions: _natureTips),
      PhotoModel(url: 'https://images.unsplash.com/photo-1510784722466-f2aa9c52fff6?auto=format&fit=crop&w=800&q=80', category: 'Nature', posingInstructions: _natureTips),
    ],
  };

  // Travel Filters
  static final Map<String, List<PhotoModel>> travelFilters = {
    'All': travelImages,
    'City': [
      PhotoModel(url: 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?auto=format&fit=crop&w=800&q=80', category: 'Travel', posingInstructions: _travelTips),
      PhotoModel(url: 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?auto=format&fit=crop&w=800&q=80', category: 'Travel', posingInstructions: _travelTips),
    ],
    'Adventure': [
      PhotoModel(url: 'https://images.unsplash.com/photo-1503220317375-aaad61436b1b?auto=format&fit=crop&w=800&q=80', category: 'Travel', posingInstructions: _travelTips),
      PhotoModel(url: 'https://images.unsplash.com/photo-1523906834658-6e24ef2386f9?auto=format&fit=crop&w=800&q=80', category: 'Travel', posingInstructions: _travelTips),
    ],
    'Beach': [
      PhotoModel(url: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80', category: 'Travel', posingInstructions: _travelTips),
    ],
  };

  // Architecture Filters
  static final Map<String, List<PhotoModel>> architectureFilters = {
    'All': architectureImages,
    'Modern': [
      PhotoModel(url: 'https://images.unsplash.com/photo-1511818966892-d7d671e672a2?auto=format&fit=crop&w=800&q=80', category: 'Architecture', posingInstructions: _archTips),
      PhotoModel(url: 'https://images.unsplash.com/photo-1487958449943-2429e8be8625?auto=format&fit=crop&w=800&q=80', category: 'Architecture', posingInstructions: _archTips),
    ],
    'Historic': [
      PhotoModel(url: 'https://images.unsplash.com/photo-1479839672679-a46483c0e7c8?auto=format&fit=crop&w=800&q=80', category: 'Architecture', posingInstructions: _archTips),
      PhotoModel(url: 'https://images.unsplash.com/photo-1518780664697-55e3ad937233?auto=format&fit=crop&w=800&q=80', category: 'Architecture', posingInstructions: _archTips),
    ],
  };

  static final List<String> quotesList = [
    "The best thing to hold onto in life is each other.",
    "Photography is the story I fail to put into words.",
    "Taking an image, freezing a moment, reveals how rich reality truly is.",
    "A portrait is not made in the camera but on either side of it.",
    "The best images are the ones that retain their strength and impact over the years, regardless of the number of times they are viewed.",
    "In photography there is a reality so subtle that it becomes more real than reality.",
    "There is one thing the photograph must contain, the humanity of the moment.",
    "Photography is a way of feeling, of touching, of loving.",
    "We take photos as a return ticket to a moment otherwise gone.",
    "A good snapshot keeps a moment from running away.",
  ];

  static final Map<String, List<String>> quoteCategories = {
    'Love': [
      "The best thing to hold onto in life is each other.",
      "Love is composed of a single soul inhabiting two bodies.",
      "Where there is love there is life.",
    ],
    'Wedding': [
      "A successful marriage requires falling in love many times, always with the same person.",
      "To love and be loved is to feel the sun from both sides.",
      "True love stories never have endings.",
    ],
    'Sad': [
      "Tears come from the heart and not from the brain.",
      "The word 'happy' would lose its meaning if it were not balanced by sadness.",
      "Sadness flies away on the wings of time.",
    ],
    'Motivational': [
      "The only way to do great work is to love what you do.",
      "Believe you can and you're halfway there.",
      "Your time is limited, don't waste it living someone else's life.",
    ],
    'Funny': [
      "I am not lazy, I am on energy saving mode.",
      "Life is short. Smile while you still have teeth.",
      "Common sense is like deodorant. The people who need it most never use it.",
    ],
  };
}
