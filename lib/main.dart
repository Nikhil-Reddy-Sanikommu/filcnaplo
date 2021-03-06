import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:package_info/package_info.dart';

import 'package:filcnaplo/data/context/app.dart';
import 'package:filcnaplo/generated/i18n.dart';
import 'package:filcnaplo/utils/format.dart';

import 'package:filcnaplo/ui/pages/frame.dart';
import 'package:filcnaplo/ui/pages/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  app.currentAppVersion = packageInfo.version;
  await app.storage.init();

  try {
    await app.storage.storage.query("settings");
  } catch (_) {
    await app.storage.create();
  }

  await app.settings.update(login: false);


  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) => runApp(App()));
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final i18n = I18n.delegate;

  @override
  void initState() {
    super.initState();
    I18n.onLocaleChanged = onLocaleChange;
  }

  void onLocaleChange(Locale locale) {
    setState(() {
      I18n.locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    I18n.onLocaleChanged(languages[app.settings.language]);

    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => app.settings.theme,
      themedWidgetBuilder: (context, theme) {
        return MaterialApp(
          localizationsDelegates: [
            i18n,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate
          ],
          debugShowCheckedModeBanner: false,
          supportedLocales: i18n.supportedLocales,
          localeResolutionCallback: (device, supported) {
            if (device != null && app.settings.language == "auto") {
              I18n.locale = device;
              app.settings.deviceLanguage = device.toString();
              app.settings.language = device.toString();
            }

            return i18n.resolution(fallback: Locale("hu", "HU"))(
                device, supported);
          },
          onGenerateTitle: (BuildContext context) => I18n.of(context).appTitle,
          title: 'Filc Napló',
          theme: theme,
          home: app.users.length > 0 ? PageFrame() : LoginPage(),
        );
      },
    );
  }
}
