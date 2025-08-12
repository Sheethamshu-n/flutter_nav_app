import 'package:flutter/material.dart';


class PathPainter extends CustomPainter {
  final Map<String, dynamic> nodes;
  final List<String> path;
  final double scale;
  final Size imageSize;


  PathPainter({
    required this.nodes,
    required this.path,
    required this.scale,
    required this.imageSize,
  });


  @override
  void paint(Canvas canvas, Size size) {
    // --- DIAGNOSTIC PRINT 3 ---
    print('PathPainter attempting to paint path: $path');


    if (path.length < 2) {
      print('PathPainter: Path is too short to draw. Aborting.');
      return;
    }


    final paint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;


    final Path linePath = Path();


    final startNode = nodes[path.first];
    if (startNode == null) return;
   
    linePath.moveTo(
      (startNode['x'] as num) * imageSize.width,
      (startNode['y'] as num) * imageSize.height,
    );
   
    for (int i = 1; i < path.length; i++) {
      final node = nodes[path[i]];
      if (node == null) continue;
      linePath.lineTo(
        (node['x'] as num) * imageSize.width,
        (node['y'] as num) * imageSize.height,
      );
    }
   
    canvas.drawPath(linePath, paint);
    print('PathPainter: Successfully drew path.');
  }


  @override
  bool shouldRepaint(covariant PathPainter oldDelegate) {
    return path != oldDelegate.path;
  }
}
