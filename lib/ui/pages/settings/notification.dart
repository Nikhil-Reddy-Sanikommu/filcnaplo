import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:filcnaplo/data/context/app.dart';
import 'package:filcnaplo/generated/i18n.dart';
import 'package:flutter/material.dart';

class NotificationSettings extends StatefulWidget {
  @override
  _NotificationSettingsState createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(I18n.of(context).settingsNotificationsTitle),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            ListTile(
              leading: Icon(app.settings.enableNotifications
                  ? FeatherIcons.bell
                  : FeatherIcons.bellOff),
              title: Text(I18n.of(context).settingsNotificationsTitle),
              trailing: Switch(
                value: app.settings.enableNotifications,
                onChanged: (bool value) {
                  setState(() {
                    app.settings.enableNotifications = value;
                  });

                  app.storage.storage.update("settings", {
                    "notifications":
                        (app.settings.enableNotifications ? 1 : 0)
                  });
                },
              ),
            ),

            // todo: Notification categories
          ],
        ),
      ),
    );
  }
}
