/// Helper class for countdown timer formatting
class CountdownHelper {
  /// Formats countdown seconds into MM:SS format
  /// Example: 65 seconds -> "01:05"
  static String formatCountdownTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
