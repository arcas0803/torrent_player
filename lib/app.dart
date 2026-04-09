import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chrome_cast/cast_context.dart';
import 'package:flutter_chrome_cast/entities.dart';
import 'package:flutter_chrome_cast/models.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'pages/home_page.dart';
import 'pages/player_page.dart';
import 'pages/settings_page.dart';
import 'providers/cast_provider.dart';
import 'providers/magnet_history_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/torrent_provider.dart';

/// Root widget of the Torrent Player application.
///
/// Initialises the Google Cast SDK, sets up the [MultiProvider] tree with
/// application-wide providers ([SettingsProvider], [TorrentProvider],
/// [MagnetHistoryProvider], [CastProvider]), and configures theming,
/// localisation, and routing.
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    _initCast();
  }

  void _initCast() {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    final appId = GoogleCastDiscoveryCriteria.kDefaultApplicationId;
    if (Platform.isAndroid) {
      GoogleCastContext.instance.setSharedInstanceWithOptions(
        GoogleCastOptionsAndroid(
          appId: appId,
          stopCastingOnAppTerminated: true,
        ),
      );
    } else {
      GoogleCastContext.instance.setSharedInstanceWithOptions(
        IOSGoogleCastOptions(
          GoogleCastDiscoveryCriteriaInitialize.initWithApplicationID(appId),
          stopCastingOnAppTerminated: true,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
        ChangeNotifierProvider(create: (_) => TorrentProvider()),
        ChangeNotifierProvider(create: (_) => MagnetHistoryProvider()..load()),
        ChangeNotifierProvider(create: (_) => CastProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Torrent Player',
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.dark,
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1565C0),
                brightness: Brightness.dark,
              ),
            ),
            locale: Locale(settings.locale),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('es')],
            initialRoute: '/',
            onGenerateRoute: (routeSettings) {
              switch (routeSettings.name) {
                case '/':
                  return MaterialPageRoute(builder: (_) => const HomePage());
                case '/player':
                  final args = routeSettings.arguments as PlayerArgs;
                  return MaterialPageRoute(
                    builder: (_) => PlayerPage(args: args),
                  );
                case '/settings':
                  return MaterialPageRoute(
                    builder: (_) => const SettingsPage(),
                  );
                default:
                  return MaterialPageRoute(builder: (_) => const HomePage());
              }
            },
          );
        },
      ),
    );
  }
}
