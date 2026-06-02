import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spinner_app/wheel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fortune Wheel Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      ),
      home: const Wheel(),
    );
  }
}

class PrizeData {
  final String name;
  final IconData icon;
  final Color color;

  PrizeData({required this.name, required this.icon, required this.color});
}

class SpinningWheelPage extends StatefulWidget {
  const SpinningWheelPage({super.key});

  @override
  State<SpinningWheelPage> createState() => _SpinningWheelPageState();
}

class _SpinningWheelPageState extends State<SpinningWheelPage> {
  final StreamController<int> selectedController = StreamController<int>();

  bool isSpinning = false;
  bool isExpanded = false; // Controls the up/down position of the wheel
  int winningIndex = 0;

  final List<PrizeData> prizes = [
    PrizeData(
      name: '10 min free game',
      icon: Icons.timer,
      color: Colors.redAccent,
    ),
    PrizeData(
      name: ' Gift Card ',
      icon: Icons.card_giftcard,
      color: Colors.blueAccent,
    ),
    PrizeData(name: '20 min free game', icon: Icons.watch, color: Colors.green),
    PrizeData(
      name: 'Try Again',
      icon: Icons.sentiment_dissatisfied,
      color: Colors.blueGrey,
    ),
    PrizeData(
      name: 'free second ride',
      icon: Icons.person,
      color: Colors.orangeAccent,
    ),
    PrizeData(
      name: '30% food court off',
      icon: Icons.percent,
      color: Colors.purpleAccent,
    ),
  ];

  @override
  void dispose() {
    selectedController.close();
    super.dispose();
  }

  Future<void> _spinWheel() async {
    if (isSpinning) return;

    // 1. Move the wheel up first
    setState(() {
      isSpinning = true;
      isExpanded = true;
    });

    // 2. Wait for the slide animation to finish
    await Future.delayed(const Duration(milliseconds: 800));

    // 3. Trigger the spin
    setState(() {
      winningIndex = Random().nextInt(prizes.length);
    });
    selectedController.add(winningIndex);
  }

  void _showResultDialog() {
    final wonPrize = prizes[winningIndex];
    final overlaySize = MediaQuery.of(context).size;

    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (_) => _PrizeOverlay(
        prize: wonPrize,
        screenSize: overlaySize,
        onDismiss: () {
          overlayEntry?.remove();
          setState(() {
            isSpinning = false;
            isExpanded = false;
          });
        },
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Wheel size dynamically calculated based on screen width
    // Using 95% of the shortest side to ensure it fits nicely
    final double wheelSize =
        (size.width < size.height ? size.width : size.height) * 0.75;

    // Calculate offsets for the AnimatedPositioned widget
    // Math: $y = -D / 2$ to hide exactly half the wheel ($D$ = diameter/size)
    final double hiddenBottomOffset =
        -(wheelSize / 2.2); // Divided by 2.2 to leave room for the indicator
    final double centeredBottomOffset =
        (size.height - wheelSize) / 2; // Centers it vertically

    final double buttonWidth = size.width * 0.5;
    final double buttonHeight = wheelSize * 0.09;
    final double buttonFontSize = wheelSize * 0.045;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Stack(
        children: [
          // SPINNER BUTTON (Positioned near the top)
          Positioned(
            top: size.height * 0.2,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: isSpinning ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Column(
                children: [
                  Text(
                    'Rectazone',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * 0.08,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: size.height * 0.005),
                  Text(
                    'Get a chance to win a reward',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: size.width * 0.035,
                    ),
                  ),
                  SizedBox(height: size.height * 0.025),
                  Center(
                    child: SizedBox(
                      width: buttonWidth,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: isSpinning ? null : _spinWheel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'SPIN',
                          style: TextStyle(
                            fontSize: buttonFontSize,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // FORTUNE WHEEL (Animated Up & Down)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 800),
            curve:
                Curves.easeOutBack, // Gives a nice little bounce when moving up
            bottom: isExpanded ? centeredBottomOffset : hiddenBottomOffset,
            left: (size.width - wheelSize) / 2, // Always center horizontally
            child: SizedBox(
              width: wheelSize,
              height: wheelSize,
              child: FortuneWheel(
                animateFirst: false,
                selected: selectedController.stream,
                physics: CircularPanPhysics(),
                duration: const Duration(seconds: 5),
                curve: FortuneCurve.spin,
                onAnimationEnd: _showResultDialog,
                indicators: <FortuneIndicator>[
                  FortuneIndicator(
                    alignment: Alignment.topCenter,
                    child: TriangleIndicator(
                      color: Colors.white,
                      width: wheelSize * 0.06,
                      height: wheelSize * 0.06,
                      elevation: 5,
                    ),
                  ),
                ],
                items: prizes.map((prize) {
                  return FortuneItem(
                    style: FortuneItemStyle(
                      color: prize.color,
                      borderColor: Colors.white,
                      borderWidth: 2,
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: wheelSize * 0.04),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              prize.icon,
                              color: Colors.white,
                              size: wheelSize * 0.04,
                            ),
                            SizedBox(width: wheelSize * 0.015),
                            Text(
                              prize.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: wheelSize * 0.025,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrizeOverlay extends StatefulWidget {
  final PrizeData prize;
  final Size screenSize;
  final VoidCallback onDismiss;

  const _PrizeOverlay({
    required this.prize,
    required this.screenSize,
    required this.onDismiss,
  });

  @override
  State<_PrizeOverlay> createState() => _PrizeOverlayState();
}

class _PrizeOverlayState extends State<_PrizeOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _entryController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  late final AnimationController _sparkleController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  late final List<_Sparkle> _sparkles;

  static const _sparkleColors = [
    Colors.yellow,
    Colors.cyanAccent,
    Colors.pinkAccent,
    Colors.lightGreenAccent,
    Colors.orangeAccent,
    Colors.lightBlueAccent,
    Colors.amberAccent,
    Colors.redAccent,
    Colors.purpleAccent,
    Colors.limeAccent,
  ];

  @override
  void initState() {
    super.initState();
    _entryController.forward();
    _sparkleController.forward();
    _sparkles = List.generate(
      40,
      (_) => _Sparkle(
        Random().nextDouble(),
        Random().nextDouble(),
        Random().nextDouble() * 4 + 2,
        Random().nextDouble(),
        _sparkleColors[Random().nextInt(_sparkleColors.length)],
      ),
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_entryController, _sparkleController]),
      builder: (context, _) {
        final double anim = _entryController.value;
        final double scale = Curves.easeOutBack.transform(anim);

        return Stack(
          children: [
            Container(color: const Color(0xFF1E1E1E)),
            // Sparkle effect
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _SparklePainter(
                    sparkles: _sparkles,
                    animationValue: _sparkleController.value,
                    entryValue: anim,
                  ),
                ),
              ),
            ),
            // X close button
            Positioned(
              top: widget.screenSize.height * 0.08,
              right: widget.screenSize.width * 0.05,
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: anim,
                  child: GestureDetector(
                    onTap: widget.onDismiss,
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
            // Center content
            Center(
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: anim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.prize.icon,
                        size: widget.screenSize.width * 0.2,
                        color: widget.prize.color,
                      ),
                      SizedBox(height: widget.screenSize.height * 0.02),
                      Text(
                        "You won!!",
                        style: GoogleFonts.mate(
                          color: Colors.white,
                          fontSize: widget.screenSize.width * 0.065,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: widget.screenSize.height * 0.035),
                      Text(
                        widget.prize.name,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.siemreap(
                          color: widget.prize.color,
                          fontSize: widget.screenSize.width * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: widget.screenSize.height * 0.035),
                      Text(
                        "congrats! you won ${widget.prize.name}",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.mate(
                          color: Colors.white54,
                          fontSize: widget.screenSize.width * 0.03,
                        ),
                      ),
                      SizedBox(height: widget.screenSize.height * 0.01),
                      Text(
                        "share this experience with your friends",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.mate(
                          color: Colors.white54,
                          fontSize: widget.screenSize.width * 0.03,
                        ),
                      ),
                      SizedBox(height: widget.screenSize.height * 0.03),
                      OutlinedButton(
                        onPressed: null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.yellow,
                          side: const BorderSide(
                            color: Colors.yellow,
                            width: 1.5,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: widget.screenSize.width * 0.08,
                            vertical: widget.screenSize.height * 0.018,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          "Share with your friends",
                          style: GoogleFonts.poppins(
                            fontSize: widget.screenSize.width * 0.04,
                            fontWeight: FontWeight.bold,
                            color: Colors.yellow,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Sparkle {
  final double x, y, radius, phase;
  final Color color;
  const _Sparkle(this.x, this.y, this.radius, this.phase, this.color);
}

class _SparklePainter extends CustomPainter {
  final List<_Sparkle> sparkles;
  final double animationValue;
  final double entryValue;

  _SparklePainter({
    required this.sparkles,
    required this.animationValue,
    required this.entryValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in sparkles) {
      final pulse = animationValue < 0.5
          ? animationValue * 2
          : (1 - animationValue) * 2;
      if (pulse <= 0) continue;
      final opacity = pulse * entryValue;
      final scale = pulse * 0.6 + 0.4;

      final paint = Paint()
        ..color = s.color.withOpacity(opacity * 0.9)
        ..style = PaintingStyle.fill;

      final cx = s.x * size.width;
      final cy = s.y * size.height;
      final r = s.radius * scale;

      final path = Path();
      path.moveTo(cx, cy - r);
      path.lineTo(cx + r * 0.4, cy - r * 0.4);
      path.lineTo(cx + r, cy);
      path.lineTo(cx + r * 0.4, cy + r * 0.4);
      path.lineTo(cx, cy + r);
      path.lineTo(cx - r * 0.4, cy + r * 0.4);
      path.lineTo(cx - r, cy);
      path.lineTo(cx - r * 0.4, cy - r * 0.4);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SparklePainter oldDelegate) => true;
}
