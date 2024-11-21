import 'dart:core';
import 'dart:developer';

import 'package:azure_devops/src/app.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:purple_theme/purple_theme.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await StorageServiceCore().init();

  PurpleThemeHandler()
      .init(defaultTheme: AppTheme.lightTheme, allThemes: AppTheme.allThemes);

  const sentryDns = String.fromEnvironment('SENTRY_DNS');

  if (sentryDns.isEmpty || kDebugMode) {
    runApp(const AzureDevOps());
  } else {
    await SentryFlutter.init(
      (options) {
        options
          ..dsn = sentryDns
          ..reportSilentFlutterErrors = true
          ..debug = false
          ..enableAppLifecycleBreadcrumbs = true
          ..enableAutoNativeBreadcrumbs = false
          ..enableUserInteractionBreadcrumbs = true
          ..maxBreadcrumbs = 500
          ..attachScreenshot = true
          ..screenshotQuality = SentryScreenshotQuality.low
          ..tracesSampler = (samplingContext) {
            if (kDebugMode) return null;
            return 1;
          }
          ..beforeSend = (evt, hint) {
            if (kDebugMode) {
              log('[sentry] ${evt.exceptions?.firstOrNull?.value}');
              return null;
            }

            switch (evt.throwable.runtimeType.toString()) {
              case 'HttpExceptionWithStatus':
              case 'ClientException':
              case '_ClientSocketException':
              case 'NetworkImageLoadException':
                return null;
            }

            return evt..tags?.putIfAbsent('hint', () => hint.toString());
          };
      },
      appRunner: () async {
        runApp(
          SentryScreenshotWidget(
            child: SentryUserInteractionWidget(
              child: const AzureDevOps(),
            ),
          ),
        );
      },
    );
  }
}
