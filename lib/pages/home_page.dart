import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:libtorrent_flutter/libtorrent_flutter.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/magnet_history_provider.dart';
import '../providers/torrent_provider.dart';
import '../services/intent_service.dart';
import '../services/torrent_service.dart';
import 'player_page.dart';

/// Home screen where users enter a magnet link, pick a .torrent file,
/// or select a previously used magnet from history.
///
/// Once metadata is resolved, it either navigates directly to the player
/// (single video file) or shows a file-picker dialog (multiple files).
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _magnetController = TextEditingController();
  StreamSubscription<String>? _intentSub;
  bool _isFromDeepLink = false;

  bool get _isMagnetValid =>
      _magnetController.text.trim().startsWith('magnet:');

  @override
  void initState() {
    super.initState();
    _setupIntentHandling();
  }

  @override
  void dispose() {
    _intentSub?.cancel();
    _magnetController.dispose();
    super.dispose();
  }

  /// Wires up [IntentService] to handle cold-start and subsequent intents.
  void _setupIntentHandling() {
    IntentService.instance.getInitialUri().then((uri) {
      if (uri != null && mounted) _handleIncomingUri(uri);
    });
    _intentSub = IntentService.instance.stream.listen((uri) {
      if (mounted) _handleIncomingUri(uri);
    });
  }

  /// Populates the UI from an incoming [uri] (magnet link or .torrent path)
  /// and starts loading immediately.
  void _handleIncomingUri(String uri) {
    _isFromDeepLink = true;
    final torrent = context.read<TorrentProvider>();
    // Reset any in-progress or completed torrent before starting the new one.
    if (torrent.state != TorrentLoadState.idle) torrent.reset();
    if (uri.startsWith('magnet:')) {
      torrent.torrentFilePath = null;
      _magnetController.text = uri;
    } else {
      _magnetController.clear();
      torrent.torrentFilePath = uri;
    }
    setState(() {});
    _play();
  }

  Future<void> _play() async {
    final torrent = context.read<TorrentProvider>();
    final history = context.read<MagnetHistoryProvider>();

    if (torrent.torrentFilePath != null) {
      await torrent.addTorrentFile(torrent.torrentFilePath!);
    } else {
      final magnet = _magnetController.text.trim();
      await torrent.addMagnet(magnet);
      await history.add(magnet);
    }
  }

  Future<void> _pickTorrentFile() async {
    final torrent = context.read<TorrentProvider>();
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['torrent'],
    );
    if (result != null && result.files.single.path != null) {
      torrent.torrentFilePath = result.files.single.path;
      _magnetController.clear();
      setState(() {});
    }
  }

  void _onVideoFilesReady(TorrentProvider torrent) {
    if (torrent.videoFiles.length == 1) {
      _startPlaying(torrent, torrent.videoFiles.first);
    } else {
      _showFilePicker(torrent);
    }
  }

  void _startPlaying(TorrentProvider torrent, FileInfo file) {
    final url = torrent.startStream(file);
    _magnetController.clear();
    final args = PlayerArgs(streamUrl: url, torrentId: torrent.torrentId!);
    if (_isFromDeepLink) {
      _isFromDeepLink = false;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/player',
        (route) => route.isFirst,
        arguments: args,
      );
    } else {
      Navigator.pushNamed(context, '/player', arguments: args);
    }
  }

  Future<void> _showFilePicker(TorrentProvider torrent) async {
    final l = AppLocalizations.of(context)!;
    final picked = await showDialog<FileInfo>(
      context: context,
      builder: (_) => _VideoFilePickerDialog(files: torrent.videoFiles, l: l),
    );
    if (picked != null) {
      _startPlaying(torrent, picked);
    } else {
      torrent.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Consumer<TorrentProvider>(
      builder: (context, torrent, _) {
        if (torrent.state == TorrentLoadState.ready) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _onVideoFilesReady(torrent);
          });
        }
        if (torrent.state == TorrentLoadState.error &&
            torrent.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(torrent.errorMessage!)));
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(l.appTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: l.settingsTitle,
                onPressed: () => Navigator.pushNamed(context, '/settings'),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _buildInputSection(torrent, l),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildInputSection(TorrentProvider torrent, AppLocalizations l) {
    final canPlay =
        (_isMagnetValid || torrent.torrentFilePath != null) &&
        !torrent.isLoading;

    return [
      TextField(
        controller: _magnetController,
        maxLines: 3,
        enabled: !torrent.isLoading,
        decoration: InputDecoration(
          labelText: l.labelMagnetLink,
          hintText: l.hintMagnetLink,
          border: const OutlineInputBorder(),
          suffixIcon: _magnetController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _magnetController.clear();
                    torrent.torrentFilePath = null;
                    setState(() {});
                  },
                )
              : null,
        ),
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 16),
      if (torrent.torrentFilePath != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              const Icon(Icons.insert_drive_file_outlined, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  torrent.torrentFilePath!.split('/').last,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => torrent.torrentFilePath = null,
              ),
            ],
          ),
        ),
      if (torrent.isLoading)
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: LinearProgressIndicator(),
        ),
      FilledButton.icon(
        onPressed: canPlay ? _play : null,
        icon: const Icon(Icons.play_arrow),
        label: Text(l.btnPlay),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: !torrent.isLoading ? _pickTorrentFile : null,
        icon: const Icon(Icons.folder_open),
        label: Text(l.btnOpenTorrent),
      ),
      _buildHistorySection(l),
    ];
  }

  Widget _buildHistorySection(AppLocalizations l) {
    return Consumer<MagnetHistoryProvider>(
      builder: (context, history, _) {
        if (history.history.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l.labelHistory,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.delete_sweep, size: 18),
                  label: Text(l.btnClearHistory),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        content: Text(l.confirmClearHistory),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(l.btnCancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(l.btnConfirm),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) history.clearAll();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...history.history.map(
              (magnet) => Dismissible(
                key: ValueKey(magnet),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  color: Theme.of(context).colorScheme.error,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => history.remove(magnet),
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.history, size: 20),
                  title: Text(
                    magnet,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    _magnetController.text = magnet;
                    setState(() {});
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Video file picker — AlertDialog
// ---------------------------------------------------------------------------

/// File-picker dialog shown when a torrent contains multiple video files.
class _VideoFilePickerDialog extends StatelessWidget {
  final List<FileInfo> files;
  final AppLocalizations l;

  const _VideoFilePickerDialog({required this.files, required this.l});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(l.dialogSelectVideo),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: files.length,
          itemBuilder: (context, index) {
            final file = files[index];
            return ListTile(
              leading: const Icon(Icons.movie_outlined),
              title: Text(
                file.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(TorrentService.formatBytes(file.size)),
              onTap: () => Navigator.pop(context, file),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.btnCancel),
        ),
      ],
    );
  }
}
