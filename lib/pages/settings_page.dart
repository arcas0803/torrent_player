import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';

/// Settings screen exposing torrent speed limits, mpv cache/demuxer
/// configuration, and language selection.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              _SectionHeader(l.settingsSectionTorrent),
              _SpeedTile(
                label: l.settingsDownloadSpeed,
                valueBytes: settings.downloadLimitBytes,
                unlimitedLabel: l.settingsUnlimited,
                onChanged: (v) => settings.setDownloadLimitBytes(v),
              ),
              _SpeedTile(
                label: l.settingsUploadSpeed,
                valueBytes: settings.uploadLimitBytes,
                unlimitedLabel: l.settingsUnlimited,
                onChanged: (v) => settings.setUploadLimitBytes(v),
              ),
              const Divider(),
              _SectionHeader(l.settingsSectionPlayer),
              _SliderTile(
                label: l.settingsCacheSeconds,
                value: settings.cacheSeconds.toDouble(),
                min: 1,
                max: 60,
                divisions: 59,
                displayLabel: '${settings.cacheSeconds} s',
                onChanged: (v) => settings.setCacheSeconds(v.round()),
              ),
              _SliderTile(
                label: l.settingsDemuxerMaxMb,
                value: settings.demuxerMaxMb.toDouble(),
                min: 10,
                max: 500,
                divisions: 49,
                displayLabel: '${settings.demuxerMaxMb} MB',
                onChanged: (v) => settings.setDemuxerMaxMb(v.round()),
              ),
              const Divider(),
              _SectionHeader(l.settingsSectionLanguage),
              RadioGroup<String>(
                groupValue: settings.locale,
                onChanged: (v) => settings.setLocale(v ?? settings.locale),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: Text(l.settingsLangEs),
                      value: 'es',
                    ),
                    RadioListTile<String>(
                      title: Text(l.settingsLangEn),
                      value: 'en',
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Section header for the settings list.
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

/// Speed slider tile: 0–10 000 KB/s, where 0 means unlimited.
class _SpeedTile extends StatelessWidget {
  final String label;
  final int valueBytes;
  final String unlimitedLabel;
  final ValueChanged<int> onChanged;

  const _SpeedTile({
    required this.label,
    required this.valueBytes,
    required this.unlimitedLabel,
    required this.onChanged,
  });

  static const _maxKbs = 10000;

  @override
  Widget build(BuildContext context) {
    final kbs = (valueBytes / 1024).round().clamp(0, _maxKbs);
    final displayLabel = kbs == 0 ? unlimitedLabel : '$kbs KB/s';

    return ListTile(
      title: Text(label),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Slider(
            value: kbs.toDouble(),
            min: 0,
            max: _maxKbs.toDouble(),
            divisions: 100,
            label: displayLabel,
            onChanged: (v) => onChanged(v.round() * 1024),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Text(
              displayLabel,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// Generic slider tile for numeric settings with min/max bounds.
class _SliderTile extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String displayLabel;
  final ValueChanged<double> onChanged;

  const _SliderTile({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.displayLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: displayLabel,
            onChanged: onChanged,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Text(
              displayLabel,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
