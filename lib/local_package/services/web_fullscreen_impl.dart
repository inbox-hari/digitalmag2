// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void toggleWebFullScreen(bool enable) {
  if (enable) {
    html.document.documentElement?.requestFullscreen();
  } else {
    html.document.exitFullscreen();
  }
}

void initFullScreenListener(
  void Function(bool isFullScreen) onFullScreenChange,
) {
  html.document.onFullscreenChange.listen((event) {
    final isFullScreen = html.document.fullscreenElement != null;
    onFullScreenChange(isFullScreen);
  });
}
