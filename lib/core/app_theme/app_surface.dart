import 'package:flutter/material.dart';
import 'app_visuals.dart';

class AppSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final bool sheet;
  final bool inset;
  final Color? backgroundColor;

  const AppSurface({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.constraints,
    this.sheet = false,
    this.inset = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppVisuals.of(context);
    final decoration = sheet
        ? colors.sheet
        : inset
        ? colors.insetPanel
        : colors.panel(backgroundColor: backgroundColor);
    return Container(
      margin: margin,
      width: width,
      height: height,
      constraints: constraints,
      decoration: decoration,
      child: Material(
        type: MaterialType.transparency,
        borderRadius: decoration.borderRadius,
        clipBehavior: Clip.antiAlias,
        child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
      ),
    );
  }
}
