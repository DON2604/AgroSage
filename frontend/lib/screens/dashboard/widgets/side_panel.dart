import 'package:flutter/material.dart';

class SidePanel extends StatelessWidget {
  final Widget? child;
  final double widthFactor;
  final double verticalPadding;
  final double horizontalPadding;
  final double borderRadius;
  final Color backgroundColor;

  const SidePanel({
    super.key,
    this.child,
    this.widthFactor = 0.55,
    this.verticalPadding = 20.0,
    this.horizontalPadding = 16.0,
    this.borderRadius = 20.0,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.only(
        top: verticalPadding,
        bottom: verticalPadding,
        right: horizontalPadding,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: SizedBox(
            width: screenSize.width * widthFactor - horizontalPadding,
            height: screenSize.height - (2 * verticalPadding),
            child: child ?? Container(color: backgroundColor),
          ),
        ),
      ),
    );
  }
}
