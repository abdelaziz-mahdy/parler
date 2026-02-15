import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/app_colors.dart';
import '../services/update_service.dart';

class UpdateDialog extends StatelessWidget {
  final UpdateInfo info;

  const UpdateDialog({super.key, required this.info});

  static Future<void> showIfAvailable(BuildContext context) async {
    final info = await UpdateService.checkForUpdate();
    if (info == null) return;
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (_) => UpdateDialog(info: info),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.system_update, color: AppColors.gold),
          const SizedBox(width: 8),
          Text(
            'Update Available',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'v${info.latestVersion} is available (you have v${info.currentVersion})',
            style: GoogleFonts.inter(fontSize: 14),
          ),
          if (info.releaseNotes != null && info.releaseNotes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                child: MarkdownBody(
                  data: info.releaseNotes!,
                  styleSheet: MarkdownStyleSheet(
                    p: GoogleFonts.inter(fontSize: 13, height: 1.4),
                    h1: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    h2: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    h3: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    listBullet: GoogleFonts.inter(fontSize: 13),
                    strong: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    em: GoogleFonts.inter(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                    blockSpacing: 8,
                  ),
                  onTapLink: (text, href, title) {
                    if (href != null) {
                      launchUrl(
                        Uri.parse(href),
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            UpdateService.dismissVersion(info.latestVersion);
            Navigator.of(context).pop();
          },
          child: Text(
            'Later',
            style: GoogleFonts.inter(color: Colors.grey),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.gold),
          onPressed: () async {
            Navigator.of(context).pop();
            final url = info.downloadUrl ?? info.htmlUrl;
            if (url != null) {
              await launchUrl(
                Uri.parse(url),
                mode: LaunchMode.externalApplication,
              );
            }
          },
          child: Text(
            'Download',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
