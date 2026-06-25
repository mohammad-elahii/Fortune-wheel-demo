// Reusable UI components: textWithStyle, iconButton, AccountDropdown, SpinButton.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spinner_app/prize_data.dart';

// Renders a single-line text with a Google Font and color
Widget textWithStyle({
  required String name,
  required String font,
  required Color color,
  required double fontSize,
}) {
  return Text(
    name,
    //fontWeigh can be modified if asked later
    style: GoogleFonts.getFont(
      font,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: 0.5,
    ),
    textAlign: TextAlign.left,
    overflow: TextOverflow.ellipsis, // Cut off with "…" if too long
    maxLines: 1, // Single line only
  );
}

/// A round icon button built from an SVG asset
Widget iconButton({
  required String assetPath, // Path to the .svg file in assets/
  required VoidCallback onPressed,
  required Color backgroundColor,
  required Color iconColor,
}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      //padding is not responsive i will change it after measuring correctly
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: iconColor, width: 1.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SvgPicture.asset(
        assetPath,
        // size is also not responsive so it'll be a problem for later and other screens except phones
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      ),
    ),
  );
}

/// Slide-down panel showing the user's profile info and won prizes.
class AccountDropdown extends StatelessWidget {
  final ProfileData profile; // User data (name, phone, tickets, prizes)
  final Color lightBackground;
  final Color onPrimary;

  // constructor of this class
  const AccountDropdown({
    super.key,
    required this.profile,
    required this.lightBackground,
    required this.onPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: lightBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: onPrimary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Shrink-wrap content
        children: [
          //User name
          Text(
            profile.name.isNotEmpty ? profile.name : 'Guest',
            style: GoogleFonts.getFont(
              'Roboto',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: onPrimary,
            ),
          ),
          const SizedBox(height: 4),
          // Phone number
          Text(
            profile.phoneNumber.isNotEmpty ? profile.phoneNumber : 'No phone',
            style: GoogleFonts.getFont(
              'Roboto',
              fontSize: 13,
              color: onPrimary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          // Chances left
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
                '${profile.tickets}',
                style: GoogleFonts.getFont(
                  'Roboto',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: onPrimary,
                ),
              ),
            ],
          ),
          // won prizes
          if (profile.wonPrizes.isNotEmpty) ...[
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
            // mao prizes into a row
            ...profile.wonPrizes.map(
              (p) => Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  children: [
                    Icon(p.icon, size: 14, color: p.color),
                    const SizedBox(width: 6),
                    Text(
                      p.name.trim(),
                      style: GoogleFonts.getFont(
                        'Roboto',
                        fontSize: 12,
                        color: onPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The SPIN button
class SpinButton extends StatelessWidget {
  final bool isSpinning; // Whether the wheel is currently animating
  final int tickets;
  final VoidCallback onSpin; // Callback when the user taps to spin
  final Color primary; // Active button background
  final Color lightBackground; // Disabled button background
  final Color onPrimary; // Text color

  //constructor of this class
  const SpinButton({
    super.key,
    required this.isSpinning,
    required this.tickets,
    required this.onSpin,
    required this.primary,
    required this.lightBackground,
    required this.onPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final canSpin =
        !isSpinning && tickets > 0; // if has ticket and not spininig currently
    return ElevatedButton(
      onPressed: canSpin ? onSpin : null, // null → disabled state
      style: ElevatedButton.styleFrom(
        backgroundColor: canSpin ? primary : lightBackground,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: textWithStyle(
        name: canSpin ? "SPIN" : "...", // Show "..." when disabled
        font: 'Roboto',
        color: onPrimary,
        fontSize: 22,
      ),
    );
  }
}
