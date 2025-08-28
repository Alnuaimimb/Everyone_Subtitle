import 'package:flutter/material.dart';

class TSectionHeader extends StatelessWidget {
  const TSectionHeader({
    super.key,
    required this.title,
    this.textcolor,
    this.buttonTitle = 'View all',
    this.onPressed,
    this.showTextButton = true,
  });
  final String title;
  final Color? textcolor;
  final String buttonTitle;
  final VoidCallback? onPressed;
  final bool showTextButton;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .apply(color: textcolor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (showTextButton)
          TextButton(onPressed: onPressed, child: Text(buttonTitle))
      ],
    );
  }
}
