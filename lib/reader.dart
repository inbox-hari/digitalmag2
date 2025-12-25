import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'local_package/flutter_pdf_flipbook.dart';

class ReaderPage extends StatefulWidget {
  const ReaderPage({super.key});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  bool _isFullScreen = false;

  void _onFullScreenChanged(bool isFullScreen) {
    print('ReaderPage: _onFullScreenChanged called with $isFullScreen');
    setState(() {
      _isFullScreen = isFullScreen;
    });

    if (isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  void dispose() {
    // Restore system UI on exit
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PdfBookViewer(
            pdfUrl: 'magazine.pdf',
            onFullScreenChanged: _onFullScreenChanged,
          ),
          if (!_isFullScreen)
            Positioned(
              top: 40,
              left: 20,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
        ],
      ),
    );
  }
}
