import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart'; // Fortune wheel widget
import 'package:spinner_app/prize_data.dart';
import 'package:spinner_app/components.dart';
import 'package:spinner_app/animated_grid.dart';
import 'package:spinner_app/result_dialog.dart';
import 'package:spinner_app/theme.dart';

// Main fortune wheel screen
class Wheel extends StatefulWidget {
  const Wheel({super.key});

  @override
  State<Wheel> createState() => _WheelState();
}

class _WheelState extends State<Wheel> with TickerProviderStateMixin {
  // ---- State fields ----
  final StreamController<int> selectedController =
      StreamController<int>(); // Feeds the FortuneWheel stream
  final ProfileData _profile = ProfileData(); // User data
  bool _isSpinning = false;
  bool _showAccountDropdown = false;
  int _lastWonIndex = 0;

  // ---- Animation ----
  late final AnimationController
  _wheelCtrl; // Controls the wheel slide-up animation
  late final Animation<double> _wheelAnim;

  @override
  void initState() {
    super.initState();
    _wheelCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _wheelAnim = CurvedAnimation(parent: _wheelCtrl, curve: Curves.easeInOut);
    // Rebuild on every animation frame so the wheel position updates
    _wheelCtrl.addListener(() {
      //state final set mishe bad az reposition
      if (mounted) setState(() {});
    });
    // When the slide-up animation finishes, pick a random prize
    _wheelCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        //function random winner
        _lastWonIndex = Fortune.randomInt(0, prizes.length);
        selectedController.add(
          _lastWonIndex,
        ); // Tell the FortuneWheel where to land
      }
    });
  }

  @override
  void dispose() {
    _wheelCtrl.dispose();
    selectedController.close();
    super.dispose();
  }

  /// Called when the user taps SPIN.
  Future<void> _spin() async {
    if (_isSpinning) return;
    _profile.tickets--; // Spend one ticket
    setState(() => _isSpinning = true); // state page changes
    await _wheelCtrl.forward(); // Animate the wheel sliding up
  }

  /// Called by the FortuneWheel when its spin animation ends.
  void _onSpinEnd() {
    Future.delayed(const Duration(milliseconds: 600), () async {
      await _wheelCtrl.reverse(); // Slide the wheel back down
      if (mounted)
        await _showResultDialog(); //when done we go to state of result dialog
    });
  }

  /// Reset state back to idle so the user can spin again.
  void _reset() {
    setState(() => _isSpinning = false);
  }

  /// Show the result dialog and record the prize.
  Future<void> _showResultDialog() async {
    final won = prizes[_lastWonIndex];
    // Don't save pooch as a real prize in profile
    if (won.name != 'Try Again') {
      _profile.wonPrizes.add(won);
    }
    await showResultDialog(context: context, wonPrize: won, onReset: _reset);
  }

  // BUILD
  @override
  Widget build(BuildContext context) {
    //responsive sizes
    final size = MediaQuery.of(context).size;
    final wheelSize =
        size.width *
        0.85; // Wheel fits 85 % of screen width (there's a problem with landscape screens)
    final gridBottom = size.height * 0.45; // Grid occupies the top 45 %
    final t = _wheelAnim.value; // 0 = hidden, 1 = fully up

    // Interpolate wheel vertical position: starts below screen, ends centered
    final wheelBottom =
        (-wheelSize * 0.45) * (1 - t) + (size.height / 2 - wheelSize / 2) * t;
    // Fade out the top UI as the wheel slides up
    final contentOpacity = 1 - t;

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          // Animated grid background (top 45 %)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            //padding from bottom
            bottom: size.height - gridBottom,
            //function in another file
            child: AnimatedOpacity(
              opacity: contentOpacity,
              duration: const Duration(milliseconds: 200),
              child: SpinnerAnimatedGrid(gridHeight: gridBottom),
            ),
          ),

          // Foreground content (fades during spin)
          AnimatedOpacity(
            opacity: contentOpacity,
            duration: const Duration(milliseconds: 200),
            child: SafeArea(
              child: Column(
                children: [
                  //Top-right toolbar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ticket column: icon + count
                        Column(
                          children: [
                            iconButton(
                              assetPath: 'assets/ticket.svg',
                              onPressed: () {},
                              backgroundColor: background,
                              iconColor: onPrimary,
                            ),
                            const SizedBox(height: 5),
                            // Ticket count — red when 0, peach otherwise
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
                        // Account toggle button
                        iconButton(
                          assetPath: 'assets/account.svg',
                          onPressed: () {
                            // set state for dropdown account detail
                            setState(
                              () =>
                                  _showAccountDropdown = !_showAccountDropdown,
                            );
                          },
                          backgroundColor: background,
                          iconColor: onPrimary,
                        ),
                      ],
                    ),
                  ),

                  // Animated account dropdown panel
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _showAccountDropdown
                        ? Padding(
                            padding: EdgeInsets.fromLTRB(
                              size.width / 3,
                              0,
                              20,
                              0,
                            ),
                            //function defined in components
                            child: AccountDropdown(
                              profile: _profile,
                              lightBackground: lightBackground,
                              onPrimary: onPrimary,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  //Center content
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Spacer(flex: 2),
                        // later can be replaced by logoType
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
                        // function defined in components
                        SpinButton(
                          isSpinning: _isSpinning,
                          tickets: _profile.tickets,
                          onSpin: _spin,
                          primary: primary,
                          lightBackground: lightBackground,
                          onPrimary: onPrimary,
                        ),
                        const Spacer(flex: 3),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          //Fortune wheel slides up from bottom
          //it is the build not class!!
          Positioned(
            bottom: wheelBottom,
            left: (size.width - wheelSize) / 2,
            child: SizedBox(
              width: wheelSize,
              height: wheelSize,
              child: FortuneWheel(
                selected: selectedController
                    .stream, // Stream that announces the winning index
                onAnimationEnd: _onSpinEnd,
                //map items based on the prize data
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
                        color: Color(0xFFE5E9EB),
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),

                animateFirst: false, // Don't auto-spin on first render
                physics:
                    CircularPanPhysics(), // Allow manual drag-to-spin(responsive wheel)
                duration: const Duration(seconds: 5), //duration of spin
                curve: FortuneCurve
                    .spin, // Deceleration easing for the spin(curve animation)
                // Pointer indicator triangle at the top
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
}
