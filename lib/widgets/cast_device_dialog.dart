import 'package:flutter/material.dart';
import 'package:flutter_chrome_cast/entities.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/cast_provider.dart';

/// Dialog that discovers and lists available Chromecast devices on the network.
///
/// Automatically starts discovery when opened. Shows a loading spinner while
/// searching, a retry button when no devices are found, and the device list
/// when results arrive.
class CastDeviceDialog extends StatefulWidget {
  /// The local stream URL being played; needed to build the Cast URL.
  final String streamUrl;

  const CastDeviceDialog({super.key, required this.streamUrl});

  @override
  State<CastDeviceDialog> createState() => _CastDeviceDialogState();
}

class _CastDeviceDialogState extends State<CastDeviceDialog> {
  @override
  void initState() {
    super.initState();
    context.read<CastProvider>().startDiscovery();
  }

  @override
  void dispose() {
    // Stop scanning when the dialog closes to save battery.
    // Using a post-frame callback to ensure provider is still accessible.
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cast = context.watch<CastProvider>();

    return AlertDialog(
      title: Text(l.castDialogTitle),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: StreamBuilder<List<GoogleCastDevice>>(
          stream: cast.devicesStream,
          builder: (context, snapshot) {
            final devices = snapshot.data ?? [];

            if (devices.isEmpty) {
              return Center(child: _buildEmptyState(l, cast));
            }

            return ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return ListTile(
                  leading: const Icon(Icons.cast),
                  title: Text(device.friendlyName),
                  subtitle: device.modelName != null
                      ? Text(device.modelName!)
                      : null,
                  onTap: () {
                    cast.connectAndCast(device, widget.streamUrl);
                    Navigator.pop(context);
                  },
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            cast.stopDiscovery();
            cast.disconnect();
            Navigator.pop(context);
          },
          child: Text(l.btnCancel),
        ),
      ],
    );
  }

  /// Builds the placeholder shown when no devices have been found yet.
  Widget _buildEmptyState(AppLocalizations l, CastProvider cast) {
    if (cast.discoveryState == CastDiscoveryState.searching) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(l.castSearching),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l.castNoDevices),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => cast.startDiscovery(),
          icon: const Icon(Icons.refresh),
          label: Text(l.castRetry),
        ),
      ],
    );
  }
}
