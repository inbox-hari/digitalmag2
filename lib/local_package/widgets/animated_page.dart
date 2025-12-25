import 'package:flutter/material.dart';
import '../models/app_state.dart';

class AnimatedPage extends StatelessWidget {
  final AppState appState;
  final Animation<double> rotationAnimation;
  final double finalPageWidth;
  final double finalPageHeight;

  const AnimatedPage({
    Key? key,
    required this.appState,
    required this.rotationAnimation,
    required this.finalPageWidth,
    required this.finalPageHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// The page we are leaving (Old Page)
    final oldPageIndex = appState.currentPageComplete;

    /// Check if page exists and get the image
    final image =
        (oldPageIndex >= 0 && oldPageIndex < appState.pageImages.length)
        ? appState.pageImages[oldPageIndex]
        : null;

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: rotationAnimation,
        builder: (context, child) {
          /// Fade out the old page to reveal the new page (which is rendered by BookPage)
          /// Opacity goes from 1.0 down to 0.0
          final opacity = 1.0 - rotationAnimation.value.abs();

          if (opacity <= 0 || image == null) {
            return Container(); // Hide if invisible or no image
          }

          return Opacity(
            opacity: opacity,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                height: finalPageHeight,
                width: finalPageWidth,
                child: Image.memory(
                  image.bytes,
                  fit: BoxFit.fill,
                  gaplessPlayback: true,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
