import 'package:flutter/material.dart';

import 'package:everyone_subtitle/utils/constants/colors.dart';
import 'package:everyone_subtitle/utils/constants/image_strings.dart';
import 'package:everyone_subtitle/utils/constants/sizes.dart';
import 'package:everyone_subtitle/utils/helpers/helper_functions.dart';

class CircularButton extends StatelessWidget {
  const CircularButton({
    super.key,
    this.label,
    required this.image,
    required this.onTab,
    required this.size,
  });

  final String? label;
  final String image;
  final VoidCallback onTab;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bool isDark = THelperFunctions.isDarkMode(context);
    return GestureDetector(
      onTap: onTab,
      child: Padding(
        padding: const EdgeInsets.only(right: TSizes.spaceBtwItems),
        child: Column(
          children: [
            Container(
              width: size,
              height: size,
              padding: const EdgeInsets.all(TSizes.sm),
              decoration: BoxDecoration(
                color: isDark ? TColors.dark : TColors.light,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Image(
                image: AssetImage(image),
                fit: BoxFit.cover,
                color: isDark ? TColors.light : TColors.dark,
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems / 2),
            SizedBox(
              width: 55,
              child: Text(
                label ?? '',
                style: Theme.of(context).textTheme.labelMedium!.apply(
                      color: TColors.light,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
