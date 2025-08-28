import 'package:flutter/material.dart';
import 'package:event_app/utils/constants/image_strings.dart';
import 'package:event_app/utils/constants/sizes.dart';

class TRoundedImage extends StatelessWidget {
  const TRoundedImage({
    super.key,
    required this.image,
    this.onTab,
  });
  final String image;
  final VoidCallback? onTab;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTab ?? () {},
      child: ClipRRect(
        borderRadius: BorderRadius.circular(TSizes.lg), // Round corners
        child: Image.asset(
          image,
          fit: BoxFit.contain, // Make image fully cover the container
        ),
      ),
    );
  }
}
