import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:spinner_app/prize_data.dart';
import 'package:share_plus/share_plus.dart';

const background = Color(0XFF161E2F);
const lightBackground = Color(0xFF242F49);
const primary = Color(0xFF384358);
const onPrimary = Color(0xFFFFA586);
const secondary = Color(0xFFB51A2B);
const onBackground = Color(0xFF541A2E);

class Wheel extends StatefulWidget {
  const Wheel({super.key});

  @override
  State<Wheel> createState() => _WheelState();
}

class _WheelState extends State<Wheel> with TickerProviderStateMixin {
  final StreamController<int> selectedController = StreamController<int>();
  final ProfileData _profile = ProfileData();
  bool _isSpinning = false;
  bool _showAccountDropdown = false;
  int _lastWonIndex = 0;

  late final AnimationController _wheelCtrl;
  late final Animation<double> _wheelAnim;

  @override
  void initState() {
    super.initState();
    _wheelCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _wheelAnim = CurvedAnimation(parent: _wheelCtrl, curve: Curves.easeInOut);
    _wheelCtrl.addListener(() {
      if (mounted) setState(() {});
    });
    _wheelCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _lastWonIndex = Fortune.randomInt(0, prizes.length);
        selectedController.add(_lastWonIndex);
      }
    });
  }

  @override
  void dispose() {
    _wheelCtrl.dispose();
    selectedController.close();
    super.dispose();
  }

  Future<void> _spin() async {
    if (_isSpinning) return;
    _profile.tickets--;
    setState(() => _isSpinning = true);
    await _wheelCtrl.forward();
  }

  void _onSpinEnd() {
    Future.delayed(const Duration(milliseconds: 600), () async {
      await _wheelCtrl.reverse();
      if (mounted) _showResultDialog();
    });
  }

  void _reset() {
    setState(() => _isSpinning = false);
  }

  void _showResultDialog() {
    final won = prizes[_lastWonIndex];
    if (won.name != 'Try Again') {
      _profile.wonPrizes.add(won);
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: background,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(won.icon, size: 64, color: won.color),
            const SizedBox(height: 16),
            if (won.name == 'Try Again')
              Text(
                "unlucky !",
                style: TextStyle(color: Colors.white, fontSize: 24),
              )
            else
              Text(
                "You won!",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            const SizedBox(height: 8),
            Text(won.name, style: TextStyle(color: won.color, fontSize: 18)),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              final shareText =
                  '''
🎉 I just won ${won.name}!

You can also be a winner in RectaZone.

Try your luck here:
https://fortune-wheel-demo-cb9c2.web.app
''';
              SharePlus.instance.share(ShareParams(text: shareText));
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: won.color,
              side: BorderSide(color: won.color),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text("Share"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _reset();
            },
            child: const Text("OK", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final wheelSize = size.width * 0.85;
    final gridBottom = size.height * 0.45;
    final t = _wheelAnim.value;

    final wheelBottom =
        (-wheelSize * 0.45) * (1 - t) + (size.height / 2 - wheelSize / 2) * t;
    final contentOpacity = 1 - t;

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: size.height - gridBottom,
            child: AnimatedOpacity(
              opacity: contentOpacity,
              duration: const Duration(milliseconds: 200),
              child: _AnimatedGrid(gridHeight: gridBottom),
            ),
          ),
          AnimatedOpacity(
            opacity: contentOpacity,
            duration: const Duration(milliseconds: 200),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            iconButton('assets/ticket.svg', () {}),
                            const SizedBox(height: 5),
                            if (_profile.tickets > 0)
                              textWithStyle(
                                name: '${_profile.tickets}',
                                font: 'Roboto',
                                color: onPrimary,
                                fontSize: 18,
                              )
                            else
                              textWithStyle(
                                name: '${_profile.tickets}',
                                font: 'Roboto',
                                color: secondary,
                                fontSize: 18,
                              ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        iconButton('assets/account.svg', () {
                          setState(
                            () => _showAccountDropdown = !_showAccountDropdown,
                          );
                        }),
                      ],
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _showAccountDropdown
                        ? Container(
                            margin: EdgeInsets.fromLTRB(
                              size.width / 3,
                              0,
                              20,
                              0,
                            ),
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: lightBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: onPrimary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _profile.name.isNotEmpty
                                      ? _profile.name
                                      : 'Guest',
                                  style: GoogleFonts.getFont(
                                    'Roboto',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: onPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _profile.phoneNumber.isNotEmpty
                                      ? _profile.phoneNumber
                                      : 'No phone',
                                  style: GoogleFonts.getFont(
                                    'Roboto',
                                    fontSize: 13,
                                    color: onPrimary.withValues(alpha: 0.5),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      'Chances: ',
                                      style: GoogleFonts.getFont(
                                        'Roboto',
                                        fontSize: 13,
                                        color: onPrimary.withValues(alpha: 0.5),
                                      ),
                                    ),
                                    Text(
                                      '${_profile.tickets}',
                                      style: GoogleFonts.getFont(
                                        'Roboto',
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: onPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                if (_profile.wonPrizes.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Won Prizes:',
                                    style: GoogleFonts.getFont(
                                      'Roboto',
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: onPrimary.withValues(alpha: 0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  ..._profile.wonPrizes.map(
                                    (p) => Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Row(
                                        children: [
                                          Icon(
                                            p.icon,
                                            size: 14,
                                            color: p.color,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            p.name.trim(),
                                            style: GoogleFonts.getFont(
                                              'Roboto',
                                              fontSize: 12,
                                              color: onPrimary.withValues(
                                                alpha: 0.8,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Spacer(flex: 2),
                        SizedBox(
                          height: 100,
                          child: Center(
                            child: textWithStyle(
                              name: 'Rectazone',
                              font: 'Audiowide',
                              color: onPrimary,
                              fontSize: 45.0,
                            ),
                          ),
                        ),
                        textWithStyle(
                          name: "Get a chance to win a reward Today!!",
                          font: 'Roboto',
                          color: onPrimary.withValues(alpha: 0.5),
                          fontSize: 14,
                        ),
                        const SizedBox(height: 30),
                        if (!_isSpinning && _profile.tickets > 0)
                          ElevatedButton(
                            onPressed: _spin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 50,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: textWithStyle(
                              name: "SPIN",
                              font: 'Roboto',
                              color: onPrimary,
                              fontSize: 22,
                            ),
                          )
                        else
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: lightBackground,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 50,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: textWithStyle(
                              name: "...",
                              font: 'Roboto',
                              color: onPrimary,
                              fontSize: 22,
                            ),
                          ),
                        const Spacer(flex: 3),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: wheelBottom,
            left: (size.width - wheelSize) / 2,
            child: SizedBox(
              width: wheelSize,
              height: wheelSize,
              child: FortuneWheel(
                selected: selectedController.stream,
                onAnimationEnd: _onSpinEnd,
                items: prizes.map((prize) {
                  return FortuneItem(
                    style: FortuneItemStyle(
                      color: prize.color,
                      borderColor: Color(0xFFE5E9EB),
                      borderWidth: 2,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: textWithStyle(
                        name: prize.name,
                        font: 'Roboto',
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
                animateFirst: false,
                physics: CircularPanPhysics(),
                duration: const Duration(seconds: 5),
                curve: FortuneCurve.spin,
                indicators: const <FortuneIndicator>[
                  FortuneIndicator(
                    alignment: Alignment.topCenter,
                    child: TriangleIndicator(
                      width: 30,
                      color: Color(0xFFE5E9EB),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget iconButton(String assetPath, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: onPrimary, width: 1.8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: SvgPicture.asset(
          assetPath,
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(onPrimary, BlendMode.srcIn),
        ),
      ),
    );
  }
}

class _AnimatedGrid extends StatefulWidget {
  final double gridHeight;

  const _AnimatedGrid({required this.gridHeight});

  @override
  State<_AnimatedGrid> createState() => _AnimatedGridState();
}

class _AnimatedGridState extends State<_AnimatedGrid> {
  final Set<int> _litTiles = {};
  Color _currentLitColor = Colors.yellow;
  Timer? _gridTimer;
  final Random _random = Random();

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
    _gridTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      if (!mounted) return;
      setState(() {
        _litTiles.clear();
        _litTiles.add(_random.nextInt(81));
        _currentLitColor = _colors[_random.nextInt(_colors.length)];
      });
    });
  }

  @override
  void dispose() {
    _gridTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: widget.gridHeight,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
        ),
        itemCount: 81,
        itemBuilder: (_, index) {
          final lit = _litTiles.contains(index);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            decoration: BoxDecoration(
              color: lit
                  ? _currentLitColor.withValues(alpha: 0.4)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: Colors.white24, width: 0.5),
            ),
          );
        },
      ),
    );
  }
}

Widget textWithStyle({
  required String name,
  required String font,
  required Color color,
  required double fontSize,
}) {
  return Text(
    name,
    style: GoogleFonts.getFont(
      font,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: 0.5,
    ),
    textAlign: TextAlign.left,
    overflow: TextOverflow.ellipsis,
    maxLines: 1,
  );
}
