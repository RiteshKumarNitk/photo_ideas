class PhotoModel {
  final String? id;
  final String url;
  final String? title;
  final String posingInstructions;
  final String category;

  const PhotoModel({
    this.id,
    required this.url,
    this.title,
    required this.posingInstructions,
    required this.category,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    // Handle both old and new API response formats
    String imageUrl;

    // Check for 'url' (old) or 'imageUrl' (new)
    if (json['url'] != null) {
      imageUrl = json['url'] as String;
    } else if (json['imageUrl'] != null) {
      imageUrl = json['imageUrl'] as String;
    } else {
      imageUrl = '';
    }

    // Handle category (can be String or Object)
    String categoryName = 'General';
    if (json['category'] != null) {
      if (json['category'] is String) {
        categoryName = json['category'] as String;
      } else if (json['category'] is Map) {
        categoryName =
            (json['category'] as Map)['name'] as String? ?? 'General';
      }
    }

    return PhotoModel(
      id: json['id']?.toString(),
      url: imageUrl,
      title: json['title'] as String? ?? json['subtitle'] as String?,
      posingInstructions:
          json['posingInstructions'] as String? ??
          json['posing_instructions'] as String? ??
          'Stand naturally and smile! Ensure good lighting falls on your face.',
      category: categoryName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'posingInstructions': posingInstructions,
      'category': category,
    };
  }
}
