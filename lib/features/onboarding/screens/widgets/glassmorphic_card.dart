import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:money_transfer/core/utils/global_constants.dart';
import 'package:money_transfer/core/utils/assets.dart';

class GlassmorphicCard extends StatelessWidget {
  final double height;
  final double width;

  const GlassmorphicCard(
      {super.key, required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: height,
                  width: width,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: CustomPaint(
                    painter: _GradientPainter(),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 15,
              top: 10,
              child: Image.asset(
                logo,
                height: heightValue50,
              ),
            ),
            Positioned(
              top: 93,
              left: 20,
              child: Image.asset(
                cardChipImage,
                height: heightValue50,
              ),
            ),
            const Positioned(
              top: 100,
              bottom: 0,
              left: 25,
              right: 85,
              child: Text(
                "Seamless cross-border transactions—empowered by cryptocurrency.",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: Image.asset(
                contactLessIcon,
                height: heightValue40,
              ),
            )
          ],
        ),
      ],
    );
  }
}

class _GradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFB3E0B8),
        Colors.white.withOpacity(0.2),
      ],
    );
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(heightValue20)), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
