import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shape;

  const ShimmerPlaceholder({
    super.key,
    required this.width,
    required this.height,
    this.shape = const RoundedRectangleBorder(),
  });

  factory ShimmerPlaceholder.rectangular({
    required double width,
    required double height,
    double borderRadius = 0,
  }) {
    return ShimmerPlaceholder(
      width: width,
      height: height,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  factory ShimmerPlaceholder.circular({
    required double radius,
  }) {
    return ShimmerPlaceholder(
      width: radius * 2,
      height: radius * 2,
      shape: const CircleBorder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.1),
      highlightColor: Colors.white.withOpacity(0.3),
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: Colors.black,
          shape: shape,
        ),
      ),
    );
  }
}
