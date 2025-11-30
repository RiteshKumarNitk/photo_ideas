class PhotoModel {
  final String url;
  final String posingInstructions;
  final String category;

  const PhotoModel({
    required this.url,
    required this.posingInstructions,
    required this.category,
  });

  // Factory constructor to create from Supabase JSON
  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      url: json['url'] as String,
      posingInstructions: json['posing_instructions'] as String? ?? 
          'Stand naturally and smile! Ensure good lighting falls on your face.',
      category: json['category'] as String? ?? 'General',
    );
  }
}
