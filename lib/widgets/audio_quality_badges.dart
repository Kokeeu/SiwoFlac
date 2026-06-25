import 'package:flutter/material.dart';
import 'package:neroflac/theme/nero_theme_extension.dart';

class AudioQualityBadge extends StatelessWidget {
  final String label;

  const AudioQualityBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final nero = NeroTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: nero.mistViolet,
        borderRadius: BorderRadius.circular(nero.radiusPill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: nero.royalAmethyst,
          height: 1.3,
        ),
      ),
    );
  }
}

class DolbyAtmosBadge extends StatelessWidget {
  const DolbyAtmosBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final nero = NeroTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: nero.mistViolet,
        borderRadius: BorderRadius.circular(nero.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(
            size: const Size(14, 10),
            painter: DolbyLogoPainter(color: nero.royalAmethyst),
          ),
          const SizedBox(width: 3),
          Text(
            'Atmos',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: nero.royalAmethyst,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class DolbyLogoPainter extends CustomPainter {
  final Color color;

  DolbyLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final h = size.height;
    final w = size.width;
    final cy = h / 2;

    final leftPath = Path()
      ..moveTo(w * 0.08, 0)
      ..lineTo(w * 0.08, h)
      ..lineTo(w * 0.20, h)
      ..arcToPoint(
        Offset(w * 0.20, 0),
        radius: Radius.elliptical(w * 0.25, cy),
        clockwise: false,
      )
      ..close();
    canvas.drawPath(leftPath, paint);

    final rightPath = Path()
      ..moveTo(w * 0.92, 0)
      ..lineTo(w * 0.92, h)
      ..lineTo(w * 0.80, h)
      ..arcToPoint(
        Offset(w * 0.80, 0),
        radius: Radius.elliptical(w * 0.25, cy),
        clockwise: true,
      )
      ..close();
    canvas.drawPath(rightPath, paint);
  }

  @override
  bool shouldRepaint(DolbyLogoPainter oldDelegate) =>
      color != oldDelegate.color;
}

/// Convenience builder: returns a list of quality badge widgets for a track.
/// Pass the result into a Row using spread operator.
List<Widget> buildQualityBadges({
  required String? audioQuality,
  required String? audioModes,
}) {
  final badges = <Widget>[];
  if (audioQuality != null && audioQuality.isNotEmpty) {
    badges.add(const SizedBox(width: 6));
    badges.add(AudioQualityBadge(label: audioQuality));
  }
  if (audioModes != null && audioModes.contains('DOLBY_ATMOS')) {
    badges.add(const SizedBox(width: 4));
    badges.add(const DolbyAtmosBadge());
  }
  return badges;
}