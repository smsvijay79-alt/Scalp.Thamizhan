import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class StatsSection extends StatefulWidget {
  const StatsSection({Key? key}) : super(key: key);

  @override
  State<StatsSection> createState() => _StatsSectionState();
}

class _StatsSectionState extends State<StatsSection>
    with SingleTickerProviderStateMixin {
  Offset _mousePosition = const Offset(0, 0);
  Offset _targetPosition = const Offset(0, 0);
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(() {
      setState(() {
        _mousePosition =
            Offset.lerp(
              _mousePosition,
              _targetPosition,
              0.12, // Smoother interpolation
            )!;
      });
    });
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: Colors.transparent,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              if (isMobile)
                _buildMobileContent()
              else
                MouseRegion(
                  onHover: (event) {
                    _targetPosition = event.localPosition;
                  },
                  child: AspectRatio(
                    aspectRatio: 900 / 600,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return CustomPaint(
                          painter: GridGlowPainter(
                            _mousePosition,
                            constraints.maxWidth,
                            constraints.maxHeight,
                          ),
                          child: _buildGridContent(
                            constraints.maxWidth,
                            constraints.maxHeight,
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileContent() {
    return Wrap(
      spacing: 24,
      runSpacing: 40,
      alignment: WrapAlignment.center,
      children: [
        _buildMobileCard('1000', '+', 'Traders'),
        _buildMobileCard('800', '+', 'Members make a payout'),
        _buildMobileCard('24/7', null, 'Support'),
        _buildMobileCard('12', null, 'Mentors'),
      ],
    );
  }

  Widget _buildMobileCard(
    String metric,
    String? metricSuffix,
    String description,
  ) {
    return Container(
      width: 160,
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                metric,
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              if (metricSuffix != null)
                Text(
                  metricSuffix,
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF22C55E),
                    letterSpacing: -1,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridContent(double width, double height) {
    final verticalDivider = width * 0.583;
    final topHeight = height * 0.417;
    final topRightOffset = height * 0.1;
    final bottomRightOffset = height * 0.602;

    return Stack(
      children: [
        // Top Left Card
        Positioned(
          left: 0,
          top: 0,
          width: verticalDivider,
          height: topHeight,
          child: _buildCard(
            metric: '1000',
            metricSuffix: '+',
            description: 'Traders',
            alignment: Alignment.center,
            padding: const EdgeInsets.only(
              left: 48,
              right: 32,
              top: 32,
              bottom: 32,
            ),
          ),
        ),
        // Top Right Card
        Positioned(
          left: verticalDivider,
          top: topRightOffset,
          width: width - verticalDivider,
          height: topHeight + (topRightOffset * 2),
          child: _buildCard(
            metric: '800',
            metricSuffix: '+',
            description: 'Members make a payout',
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          ),
        ),
        // Bottom Left Card
        Positioned(
          left: 0,
          top: topHeight,
          width: verticalDivider,
          height: height - topHeight,
          child: _buildCard(
            metric: '24/7',
            description: 'Support',
            alignment: Alignment.center,
            padding: const EdgeInsets.only(
              left: 48,
              right: 32,
              top: 32,
              bottom: 32,
            ),
          ),
        ),
        // Bottom Right Card
        Positioned(
          left: verticalDivider,
          top: bottomRightOffset,
          width: width - verticalDivider,
          height: height - bottomRightOffset,
          child: _buildCard(
            metric: '12',
            description: 'Mentors',
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required String metric,
    String? metricSuffix,
    required String description,
    required Alignment alignment,
    required EdgeInsets padding,
  }) {
    return Padding(
      padding: padding,
      child: Align(
        alignment: alignment,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              alignment == Alignment.center
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  metric,
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.1,
                    letterSpacing: -2,
                  ),
                ),
                if (metricSuffix != null)
                  Text(
                    metricSuffix,
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF22C55E),
                      height: 1.1,
                      letterSpacing: -2,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              textAlign:
                  alignment == Alignment.center
                      ? TextAlign.center
                      : TextAlign.left,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[500],
                height: 1.6,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GridGlowPainter extends CustomPainter {
  final Offset mousePosition;
  final double width;
  final double height;

  GridGlowPainter(this.mousePosition, this.width, this.height);

  @override
  void paint(Canvas canvas, Size size) {
    final verticalDivider = width * 0.583;
    final topHeight = height * 0.417;
    final topRightOffset = height * 0.1;
    final bottomRightOffset = height * 0.602;

    final List<Line> gridLines = [
      Line(Offset(verticalDivider, 0), Offset(verticalDivider, height)),
      Line(Offset(0, topHeight), Offset(verticalDivider, topHeight)),
      Line(
        Offset(verticalDivider, topRightOffset),
        Offset(width, topRightOffset),
      ),
      Line(
        Offset(verticalDivider, bottomRightOffset),
        Offset(width, bottomRightOffset),
      ),
    ];

    // Draw base dark grid lines with subtle color
    final darkPaint =
        Paint()
          ..color = const Color(0xFF2A2A2A)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

    for (var line in gridLines) {
      canvas.drawLine(line.start, line.end, darkPaint);
    }

    // Draw glowing segments with enhanced smoothness
    final double glowRadius = 200.0;

    for (var line in gridLines) {
      _drawGlowingLine(canvas, line, mousePosition, glowRadius);
    }
  }

  void _drawGlowingLine(
    Canvas canvas,
    Line line,
    Offset cursor,
    double glowRadius,
  ) {
    final closestPoint = _closestPointOnLine(line.start, line.end, cursor);
    final distance = (closestPoint - cursor).distance;

    if (distance > glowRadius) return;

    final lineVector = line.end - line.start;
    final lineLength = lineVector.distance;
    final lineDirection = lineVector / lineLength;

    final t = _projectPointOnLine(line.start, line.end, cursor);
    final centerOnLine = line.start + lineDirection * (t * lineLength);

    // Enhanced smooth intensity curve for more elegant fade
    final intensity = (1.0 - (distance / glowRadius)).clamp(0.0, 1.0);
    final smoothIntensity = intensity * intensity * (3.0 - 2.0 * intensity);
    final ultraSmooth = smoothIntensity * smoothIntensity;

    // Dynamic segment length with smoother scaling
    final double segmentLength = glowRadius * 1.4 * (0.5 + ultraSmooth * 0.5);

    var glowStart = centerOnLine - lineDirection * segmentLength;
    var glowEnd = centerOnLine + lineDirection * segmentLength;

    glowStart = _clampPointToLine(glowStart, line.start, line.end);
    glowEnd = _clampPointToLine(glowEnd, line.start, line.end);

    final segmentCenter = (glowStart + glowEnd) / 2;
    final segmentRadius = (glowEnd - glowStart).distance / 2;

    // Draw outer glow layers with refined gradient
    for (int i = 5; i >= 1; i--) {
      final layerOpacity = ultraSmooth * 0.12 * (i / 5.0);
      final gradient = ui.Gradient.radial(
        segmentCenter,
        segmentRadius * (1.0 + i * 0.4),
        [
          Color(0xFF22C55E).withOpacity(layerOpacity * 1.2),
          Color(0xFF10B981).withOpacity(layerOpacity * 0.6),
          Color(0xFF22C55E).withOpacity(0),
        ],
        [0.0, 0.5, 1.0],
      );

      final glowPaint =
          Paint()
            ..shader = gradient
            ..strokeWidth = 1.5 + i * 1.5
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, i * 3.5);

      canvas.drawLine(glowStart, glowEnd, glowPaint);
    }

    // Draw enhanced bright core with smoother gradient
    final coreGradient = ui.Gradient.linear(
      glowStart,
      glowEnd,
      [
        Color(0xFF22C55E).withOpacity(0.0),
        Color(0xFF22C55E).withOpacity(ultraSmooth * 0.4),
        Color(0xFF22C55E).withOpacity(ultraSmooth * 0.9),
        Color(0xFF22C55E).withOpacity(ultraSmooth * 0.4),
        Color(0xFF22C55E).withOpacity(0.0),
      ],
      [0.0, 0.2, 0.5, 0.8, 1.0],
    );

    final corePaint =
        Paint()
          ..shader = coreGradient
          ..strokeWidth = 2.8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    canvas.drawLine(glowStart, glowEnd, corePaint);

    // Add refined center point glow
    final centerPaint =
        Paint()
          ..shader = ui.Gradient.radial(
            centerOnLine,
            25.0,
            [
              Color(0xFFFFFFFF).withOpacity(ultraSmooth * 0.3),
              Color(0xFF22C55E).withOpacity(ultraSmooth * 0.8),
              Color(0xFF10B981).withOpacity(ultraSmooth * 0.4),
              Color(0xFF22C55E).withOpacity(0),
            ],
            [0.0, 0.3, 0.6, 1.0],
          )
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);

    canvas.drawCircle(centerOnLine, 25.0, centerPaint);
  }

  Offset _closestPointOnLine(Offset start, Offset end, Offset point) {
    final t = _projectPointOnLine(start, end, point).clamp(0.0, 1.0);
    return start + (end - start) * t;
  }

  double _projectPointOnLine(Offset start, Offset end, Offset point) {
    final lineVec = end - start;
    final pointVec = point - start;
    final lineLength = lineVec.distance;

    if (lineLength == 0) return 0.0;

    return (pointVec.dx * lineVec.dx + pointVec.dy * lineVec.dy) /
        (lineLength * lineLength);
  }

  Offset _clampPointToLine(Offset point, Offset lineStart, Offset lineEnd) {
    final lineVec = lineEnd - lineStart;
    final pointVec = point - lineStart;
    final lineLength = lineVec.distance;

    if (lineLength == 0) return lineStart;

    final t =
        (pointVec.dx * lineVec.dx + pointVec.dy * lineVec.dy) /
        (lineLength * lineLength);
    final clampedT = t.clamp(0.0, 1.0);

    return lineStart + lineVec * clampedT;
  }

  @override
  bool shouldRepaint(GridGlowPainter oldDelegate) {
    return oldDelegate.mousePosition != mousePosition;
  }
}

class Line {
  final Offset start;
  final Offset end;

  Line(this.start, this.end);
}
