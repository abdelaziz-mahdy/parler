import 'package:flutter/material.dart';

/// Maps Material icon name strings from chapters.json to [IconData].
/// Falls back to [Icons.menu_book_rounded] for unknown names.
IconData chapterIconFromString(String name) {
  return _iconMap[name] ?? Icons.menu_book_rounded;
}

const Map<String, IconData> _iconMap = {
  'translate': Icons.translate_rounded,
  'record_voice_over': Icons.record_voice_over_rounded,
  'wc': Icons.wc_rounded,
  'edit': Icons.edit_rounded,
  'menu_book': Icons.menu_book_rounded,
  'pin': Icons.pin_rounded,
  'warning': Icons.warning_rounded,
  'link': Icons.link_rounded,
  'chat': Icons.chat_rounded,
  'school': Icons.school_rounded,
};
