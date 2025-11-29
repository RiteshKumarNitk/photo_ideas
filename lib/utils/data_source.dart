
class DataSource {
  static final List<String> haircutImages = [
    'https://images.unsplash.com/photo-1560869713-7d0a29430803?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1595476108010-b4d1f102b1b1?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1521119989659-a83eee488058?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1605497788044-5a32c7078486?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1596392927816-73a37e09c094?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1503951914875-452162b7f304?auto=format&fit=crop&w=800&q=80',
  ];

  static final List<String> weddingImages = [
    'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1511285560982-1351cdeb9821?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1515934751635-c81c6bc9a2d8?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1469334031218-e382a71b716b?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1522673607200-1645062cd958?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1520854221256-17451cc330e7?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1507915977619-6ccfe8003ae6?auto=format&fit=crop&w=800&q=80',
  ];

  static final List<String> babyImages = [
    'https://images.unsplash.com/photo-1519689680058-324335c77eba?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1555252333-9f8e92e65df9?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1510154221590-ff63e90a136f?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1519340241574-2cec6aef0c01?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1505686994434-e3cc5abf1330?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1544126566-475a10623325?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1522771930-78848d9293e8?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1514359668584-1ddea8163f3e?auto=format&fit=crop&w=800&q=80',
  ];

  static final List<String> natureImages = [
    'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1501854140884-074bf6f243e?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1510784722466-f2aa9c52fff6?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=800&q=80',
  ];

  static final List<String> travelImages = [
    'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1488646953014-85cb44e25828?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1503220317375-aaad61436b1b?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1523906834658-6e24ef2386f9?auto=format&fit=crop&w=800&q=80',
  ];

  static final List<String> architectureImages = [
    'https://images.unsplash.com/photo-1511818966892-d7d671e672a2?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1487958449943-2429e8be8625?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1479839672679-a46483c0e7c8?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1518780664697-55e3ad937233?auto=format&fit=crop&w=800&q=80',
  ];

  // Haircut Filters Data
  static final Map<String, List<String>> haircutFilters = {
    'All': haircutImages,
    'Short': [
      'https://images.unsplash.com/photo-1595476108010-b4d1f102b1b1?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1521119989659-a83eee488058?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1596392927816-73a37e09c094?auto=format&fit=crop&w=800&q=80',
    ],
    'Long': [
      'https://images.unsplash.com/photo-1560869713-7d0a29430803?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?auto=format&fit=crop&w=800&q=80',
    ],
    'Fade': [
      'https://images.unsplash.com/photo-1605497788044-5a32c7078486?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1503951914875-452162b7f304?auto=format&fit=crop&w=800&q=80',
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
}
