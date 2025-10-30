class Breakpoints {
  final bool isSmall;
  final bool isMedium;
  final bool isLarge;
  final double scale;

  Breakpoints._(this.isSmall, this.isMedium, this.isLarge, this.scale);

  factory Breakpoints.of(double width) {
    final isSmall = width < 600;
    final isMedium = width >= 600 && width < 900;
    final isLarge = width >= 900;
    final scale = (width / 1200).clamp(0.8, 1.2);
    return Breakpoints._(isSmall, isMedium, isLarge, scale.toDouble());
  }
}
