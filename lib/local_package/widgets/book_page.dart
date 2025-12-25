import 'package:flutter/material.dart';
import '../models/app_state.dart';

class BookPage extends StatelessWidget {
  final AppState appState;
  final double finalPageWidth;
  final double finalPageHeight;

  const BookPage({
    super.key,
    required this.appState,
    required this.finalPageWidth,
    required this.finalPageHeight,
  });

  @override
  Widget build(BuildContext context) {
    final image = appState.pageImages[appState.currentPage];

    if (image == null) {
      return Container(
        height: finalPageHeight,
        width: finalPageWidth,
        color: Colors.white,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Visibility(
      visible: true,
      child: SizedBox(
        height: finalPageHeight,
        width: finalPageWidth,
        child: Image.memory(image.bytes, fit: BoxFit.contain),
      ),
    );
  }
}
