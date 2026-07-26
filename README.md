# Fortune Wheel Demo

A Flutter-based Fortune Wheel demo showcasing a polished spinning wheel experience with clean animations, modular architecture, and a modern UI.

## Overview

This project demonstrates a simple Fortune Wheel application built entirely in Flutter. It focuses on smooth user interactions, reusable components, and maintainable code while using mock data to simulate real application behavior.

## Features

- Animated fortune wheel
- Sequential screen transition and wheel spin animations
- Prize result dialog
- Mock profile and prize data
- Native sharing support
- Custom typography and theming
- Modular widget structure

## Architecture

The application follows Flutter's built-in `StatefulWidget` + `setState` pattern without additional state management libraries.

### Animation Flow

The application separates the screen transition and wheel spin into two independent animations.

1. The screen performs its slide transition.
2. Once completed, the wheel spin animation begins.
3. Streams and callbacks coordinate the sequence while keeping both animations independent.

This separation keeps animation logic simple, reusable, and easy to maintain.

## Project Structure

```text
lib/
├── data/
│   └── prize_data.dart
├── widgets/
│   ├── wheel.dart
│   ├── result_dialog.dart
│   └── ...
├── theme.dart
└── main.dart
```

## Coding Conventions

The project follows several Flutter best practices:

- Widget composition instead of inheritance
- Named parameters for constructors
- `const` constructors wherever possible
- Proper resource cleanup using `dispose()`
- Shared colors defined in `theme.dart`
- Standard `flutter_lints` configuration
- Inline comments and documentation where appropriate

## Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_fortune_wheel` | Fortune wheel widget |
| `google_fonts` | Custom fonts |
| `flutter_svg` | SVG rendering |
| `share_plus` | Native share functionality |
| `cupertino_icons` | iOS-style icons |
| `flutter_lints` | Dart and Flutter lint rules |

## Future Improvements

- OAuth authentication
- Backend integration
- Replace mock data with API responses
- Improve landscape responsiveness
- Better adaptive sizing for the wheel and controls

## Contributing

When extending the project:

- Continue using `StatefulWidget` and `setState`
- Keep application data centralized in `prize_data.dart`
- Add new theme colors to `theme.dart`
- Dispose every `AnimationController`, `Timer`, and `StreamController`
- Avoid introducing state management libraries unless the application's complexity requires them

## Getting Started

Clone the repository and install dependencies:

```bash
git clone https://github.com/mohammad-elahii/Fortune-wheel-demo.git
cd Fortune-wheel-demo
flutter pub get
flutter run
```

## License

This project is intended as a Flutter demonstration application.