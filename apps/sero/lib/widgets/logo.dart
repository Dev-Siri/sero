import "package:flutter/material.dart";
import "package:flutter_svg/svg.dart";
import "package:vector_graphics/vector_graphics_compat.dart";

class Logo extends StatelessWidget {
  final double height;
  final double width;
  final Color? color;

  const Logo({
    super.key,
    required this.height,
    required this.width,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture(
      const AssetBytesLoader("assets/vectors/icon.svg.vec"),
      height: height,
      width: width,
      colorFilter: ColorFilter.mode(
        color ?? Theme.of(context).primaryColor,
        BlendMode.srcIn,
      ),
    );
  }
}
