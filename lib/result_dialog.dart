// Shows the prize result dialog with share and dismiss actions.
import 'package:flutter/material.dart'; // AlertDialog, buttons, etc.
import 'package:share_plus/share_plus.dart'; // Native share sheet
import 'package:spinner_app/prize_data.dart'; // PrizeData model for the won prize
import 'package:spinner_app/theme.dart'; // Color constants

/// Displays a modal [AlertDialog] after a spin ends.
///
/// [wonPrize] — the prize that was landed on.
/// [onReset] — called when the user taps OK to dismiss + reset the spin state.
Future<void> showResultDialog({
  required BuildContext context,
  required PrizeData wonPrize,
  required VoidCallback onReset,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false, // Must tap a button to close
    builder: (_) => AlertDialog(
      backgroundColor: background,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Large prize icon
          Icon(wonPrize.icon, size: 64, color: wonPrize.color),
          const SizedBox(height: 16),
          // Title — "unlucky !" for Try Again, "You won!" otherwise
          if (wonPrize.name == 'Try Again')
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
          // Prize name displayed in its own color
          Text(
            wonPrize.name,
            style: TextStyle(color: wonPrize.color, fontSize: 18),
          ),
        ],
      ),
      actions: [
        // Share button — opens native share sheet with a pre-built message
        OutlinedButton(
          onPressed: () {
            final shareText =
                '''
🎉 I just won ${wonPrize.name}!

You can also be a winner in RectaZone.

Try your luck here:
https://fortune-wheel-demo-cb9c2.web.app
''';
            SharePlus.instance.share(ShareParams(text: shareText));
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: wonPrize.color,
            side: BorderSide(color: wonPrize.color),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text("Share"),
        ),
        // OK button — closes the dialog and triggers the reset callback
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Dismiss the dialog
            onReset(); // Reset wheel to idle state
          },
          child: const Text("OK", style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
