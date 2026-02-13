import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

enum FaceFilterCapability {
  none,
  asset, // Renders an image asset (png)
  procedural, // Renders via code (painters)
}

enum FaceLandmarkAnchor {
  forehead, // For crowns, hats
  eyes,     // For glasses
  nose,     // For noses, whiskers
  face,     // Full face mask
}

class FaceFilter {
  final String id;
  final String name;
  final String iconUrl; // For the UI selector
  final FaceFilterCapability type;
  final Map<String, dynamic> params;
  
  // For Asset Filters
  final String? assetUrl;
  final FaceLandmarkAnchor? anchor;
  final double scale;
  final Offset offset;

  // Runtime cache
  ui.Image? cachedImage;

  FaceFilter({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.type,
    this.params = const {},
    this.assetUrl,
    this.anchor,
    this.scale = 1.0,
    this.offset = Offset.zero,
  });

  factory FaceFilter.fromJson(Map<String, dynamic> json) {
    FaceFilterCapability typeEnum = FaceFilterCapability.values.firstWhere(
      (e) => e.toString().split('.').last == (json['type'] ?? 'asset'),
      orElse: () => FaceFilterCapability.asset, // Default to asset
    );
    
    FaceLandmarkAnchor? anchorEnum;
    if (json['anchor'] != null) {
       anchorEnum = FaceLandmarkAnchor.values.firstWhere(
         (e) => e.toString().split('.').last == json['anchor'],
         orElse: () => FaceLandmarkAnchor.forehead,
       );
    }

    double offsetX = (json['offset_x'] ?? 0).toDouble();
    double offsetY = (json['offset_y'] ?? 0).toDouble();

    return FaceFilter(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown',
      iconUrl: json['icon_url'] ?? '',
      type: typeEnum,
      assetUrl: json['asset_url'],
      anchor: anchorEnum,
      scale: (json['scale'] ?? 1.0).toDouble(),
      offset: Offset(offsetX, offsetY),
      params: json['params'] ?? {},
    );
  }
}

class FilterRepository {
  static List<FaceFilter> get filters => [
    FaceFilter(
      id: 'none',
      name: 'Normal',
      iconUrl: 'https://cdn-icons-png.flaticon.com/512/159/159604.png', // Stop/Block icon
      type: FaceFilterCapability.none,
    ),
    FaceFilter(
      id: 'cool_glasses',
      name: 'Cool Shades',
      iconUrl: 'https://cdn-icons-png.flaticon.com/512/17/17260.png', // Glasses Icon
      type: FaceFilterCapability.asset,
      assetUrl: 'https://i.imgur.com/g3d0J3m.png', // Placeholder Pixel Glasses (Transparent PNG)
      anchor: FaceLandmarkAnchor.eyes,
      scale: 2.5,
    ),
    FaceFilter(
      id: 'flower_crown',
      name: 'Flower Crown',
      iconUrl: 'https://cdn-icons-png.flaticon.com/512/187/187158.png', 
      type: FaceFilterCapability.asset,
      assetUrl: 'https://i.imgur.com/2X7l3wB.png', // Placeholder visual
      anchor: FaceLandmarkAnchor.forehead,
      scale: 1.8,
      offset: const Offset(0, -50),
    ),
     FaceFilter(
      id: 'dog_ears',
      name: 'Puppy',
      iconUrl: 'https://cdn-icons-png.flaticon.com/512/616/616430.png', 
      type: FaceFilterCapability.asset,
      assetUrl: 'https://i.imgur.com/c6U7k4P.png', 
      anchor: FaceLandmarkAnchor.forehead,
      scale: 2.0,
      offset: const Offset(0, -80),
    ),
  ];
}
