import 'package:shared_preferences/shared_preferences.dart';

class DailyTracker {
  // IDs for our tests
  static const String KEY_FLUENCY = 'last_fluency';
  static const String KEY_SPEED = 'last_speed';
  static const String KEY_ATTENTION = 'last_attention';
  static const String KEY_MEMORY = 'last_memory';
  static const String KEY_SUBJECTIVE = 'last_subjective';

  // Mark a test as done TODAY
  static Future<void> markAsDone(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    // Save string like "2023-10-25"
    String today = "${now.year}-${now.month}-${now.day}";
    await prefs.setString(key, today);
  }

  // Check if done TODAY
  static Future<bool> isDoneToday(String key) async {
    final prefs = await SharedPreferences.getInstance();
    String? lastDate = prefs.getString(key);
    if (lastDate == null) return false;

    final now = DateTime.now();
    String today = "${now.year}-${now.month}-${now.day}";
    
    return lastDate == today;
  }
}