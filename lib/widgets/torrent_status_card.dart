import 'package:flutter/material.dart';
import 'package:libtorrent_flutter/libtorrent_flutter.dart';

import '../services/torrent_service.dart';

/// Material card showing live torrent status: name, progress bar,
/// peer count, and download speed.
class TorrentStatusCard extends StatelessWidget {
  /// The torrent info to display. When `null`, a placeholder is shown.
  final TorrentInfo? info;

  const TorrentStatusCard({super.key, this.info});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (info == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'Sin torrent activo',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    final t = info!;
    final progressPct = (t.progress * 100).toStringAsFixed(1);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t.name.isNotEmpty ? t.name : 'Cargando metadatos…',
              style: theme.textTheme.titleSmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: t.progress),
            const SizedBox(height: 8),
            Text(
              '$progressPct%  ·  ${t.state.label}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.people_outline, size: 16),
                const SizedBox(width: 4),
                Text('${t.numPeers} peers', style: theme.textTheme.bodySmall),
                const SizedBox(width: 16),
                const Icon(Icons.download_outlined, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${TorrentService.formatBytes(t.downloadRate)}/s',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
