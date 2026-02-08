import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/data_provider.dart';

class SpeakerButton extends ConsumerWidget {
  final String text;
  final double size;
  final Color? color;

  const SpeakerButton({
    super.key,
    required this.text,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: Icon(
        Icons.volume_up_rounded,
        size: size,
        color: color ?? Theme.of(context).colorScheme.primary,
      ),
      tooltip: 'Écouter',
      onPressed: () {
        ref.read(ttsServiceProvider).speak(text);
      },
    );
  }
}
