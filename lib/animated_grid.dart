import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// Animated grid background
/// An 8×8 grid of tiles that light up one-at-a-time with a random color
/// on a 300 ms timer, used as a decorative background behind the UI.
class SpinnerAnimatedGrid extends StatefulWidget {
  final double gridHeight; // Height of the grid area on screen

  const SpinnerAnimatedGrid({super.key, required this.gridHeight});

  @override
  State<SpinnerAnimatedGrid> createState() => _SpinnerAnimatedGridState();
}

class _SpinnerAnimatedGridState extends State<SpinnerAnimatedGrid> {
  final Set<int> _litTiles = {}; // Holds the single currently-lit tile index
  Color _currentLitColor = Colors.yellow;
  Timer? _gridTimer; // Periodic timer driving the animation
  final Random _random = Random();

  // Palette cycled through when picking the next lit color
  static const _colors = [
    Colors.yellow,
    Colors.cyanAccent,
    Colors.pinkAccent,
    Colors.lightGreenAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.redAccent,
    Colors.blueAccent,
  ];

  @override
  void initState() {
    super.initState();
    // Every 300 ms pick a random tile and random color, then rebuild
    _gridTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      if (!mounted) return;
      setState(() {
        _litTiles.clear();
        _litTiles.add(_random.nextInt(64));
        _currentLitColor = _colors[_random.nextInt(_colors.length)];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: widget.gridHeight,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(), // Prevent user scrolling
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8, // 8 columns
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
        ),
        itemCount: 64, // 8 × 8 = 64
        itemBuilder: (_, index) {
          final lit = _litTiles.contains(index);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            decoration: BoxDecoration(
              color: lit
                  ? _currentLitColor.withValues(alpha: 0.4) // Glow effect
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: Colors.white24, width: 0.5),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _gridTimer?.cancel(); // Stop the timer when the widget leaves the tree
    super.dispose();
  }
}
