import 'package:flutter/material.dart';
import 'package:everyone_subtitle/common/widgets/custome_curved_edges.dart';
import 'package:everyone_subtitle/utils/constants/colors.dart';

class HeaderContainer extends StatelessWidget {
  const HeaderContainer({super.key, required this.child, required this.size});
  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    // cusome curves
    return ClipPath(
      clipper: TCustomeCurvedEdges(),
      // background
      child: Container(
        height: size,
        color: TColors.primary,
        padding: const EdgeInsets.all(0),
        child: Stack(
          // cirular container
          children: [
            const Positioned(
                top: -150, right: -250, child: CircularContainer()),
            const Positioned(top: 100, right: -300, child: CircularContainer()),
            child,
          ],
        ),
      ),
    );
  }
}

class CircularContainer extends StatelessWidget {
  const CircularContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 400,
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(400),
        color: TColors.textWhite.withAlpha(50),
      ),
    );
  }
}
