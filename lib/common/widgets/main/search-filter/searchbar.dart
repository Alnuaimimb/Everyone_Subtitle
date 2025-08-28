import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'package:event_app/utils/constants/colors.dart';
import 'package:event_app/utils/constants/sizes.dart';
import 'package:event_app/utils/device/device_utility.dart';
import 'package:event_app/utils/helpers/helper_functions.dart';

class TSearchContainer extends StatelessWidget {
  const TSearchContainer({
    super.key,
    required this.text,
    this.showBackground = true,
    this.showBoarder = true,
    this.icon = Iconsax.search_normal,
  });

  final String text;
  final IconData? icon;
  final bool showBackground, showBoarder;
  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
      child: Container(
        width: TDeviceUtils.getScreenWidth(context),
        padding: const EdgeInsets.all(TSizes.md),
        decoration: BoxDecoration(
          color: showBackground
              ? isDark
                  ? TColors.dark
                  : TColors.light
              : Colors.transparent,
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
          border: showBoarder
              ? Border.all(color: isDark ? TColors.dark : TColors.light)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDark ? TColors.light : TColors.grey,
            ),
            const SizedBox(width: TSizes.spaceBtwItems),
            Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
            )
          ],
        ),
      ),
    );
  }
}
