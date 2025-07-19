import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/spin_data.dart';

class SpinWheel extends StatelessWidget {
  final List<SpinItem> items;
  final double size;

  const SpinWheel({
    super.key,
    required this.items,
    this.size = 300,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // 外圈装饰
          Container(
            width: size + 20,
            height: size + 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.amber.withOpacity(0.8),
                  Colors.orange.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),
          // 转盘背景
          Center(
            child: Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
          // 转盘扇形
          Center(
            child: CustomPaint(
              size: Size(size, size),
              painter: SpinWheelPainter(items),
            ),
          ),
          // 中心圆点
          Center(
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.grey.withOpacity(0.3), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.center_focus_strong,
                size: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SpinWheelPainter extends CustomPainter {
  final List<SpinItem> items;

  SpinWheelPainter(this.items);

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final anglePerItem = 2 * math.pi / items.length;

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final startAngle = i * anglePerItem - math.pi / 2;
      final paint = Paint()
        ..color = Color(item.color)
        ..style = PaintingStyle.fill;

      // 绘制扇形
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        anglePerItem,
        true,
        paint,
      );

      // 绘制边框
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        anglePerItem,
        true,
        borderPaint,
      );

      // 绘制文字
      final textAngle = startAngle + anglePerItem / 2;
      final textRadius = radius * 0.7;
      final textX = center.dx + textRadius * math.cos(textAngle);
      final textY = center.dy + textRadius * math.sin(textAngle);

      _drawText(
        canvas,
        item.text,
        Offset(textX, textY),
        textAngle,
        _getTextColor(Color(item.color)),
      );
    }
  }

  void _drawText(Canvas canvas, String text, Offset position, double angle, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    canvas.save();
    canvas.translate(position.dx, position.dy);
    
    // 如果角度在右半边，旋转文字以便阅读
    if (angle > math.pi / 2 && angle < 3 * math.pi / 2) {
      canvas.rotate(angle + math.pi);
    } else {
      canvas.rotate(angle);
    }

    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );

    canvas.restore();
  }

  Color _getTextColor(Color backgroundColor) {
    // 根据背景色计算合适的文字颜色
    final brightness = backgroundColor.computeLuminance();
    return brightness > 0.5 ? Colors.black : Colors.white;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
