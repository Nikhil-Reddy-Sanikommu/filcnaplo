import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:filcnaplo/ui/pages/login.dart';
import 'package:filcnaplo/ui/profile_icon.dart';
import 'package:filcnaplo/utils/format.dart';
import 'package:filcnaplo/data/context/app.dart';
import 'package:filcnaplo/data/models/user.dart';
import 'package:flutter/material.dart';
import 'package:filcnaplo/ui/pages/settings/page.dart';
import 'package:filcnaplo/generated/i18n.dart';
import 'package:filcnaplo/ui/pages/accounts/view.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  void selectCallback(int id) {
    setState(() {
      if (app.selectedUser != id) {
        app.selectedMessagePage = 0;
        app.selectedEvalPage = 0;
        app.evalSortBy = 0;
      }
      app.selectedUser = id;
    });
    app.sync.updateCallback();
    app.sync.fullSync();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> users = [];

    for (int i = 0; i < app.users.length; i++) {
      if (i != app.selectedUser)
        users.add(AccountTile(
          app.users[i],
          onSelect: selectCallback,
          onDelete: () => setState(() {}),
        ));
    }

    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.only(top: 32.0, left: 12.0),
              child: IconButton(
                icon: Icon(FeatherIcons.x),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),

            // Users
            Expanded(
              child: Container(
                padding: EdgeInsets.only(top: 12.0),
                child: Column(
                  children: <Widget>[
                    app.users.length > 0
                        ? AccountTile(
                            app.users[app.selectedUser],
                            onSelect: selectCallback,
                            onDelete: () => setState(() {}),
                          )
                        : Container(),

                    app.users.length > 1 ? Divider() : Container(),

                    app.users.length > 1
                        ? Flexible(
                            child: ListView(
                              physics: BouncingScrollPhysics(),
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              children: users,
                            ),
                          )
                        : Container(),

                    // Add user
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: ListTile(
                        leading: Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(
                            FeatherIcons.userPlus,
                            color: app.debugUser ? Colors.grey : null,
                          ),
                        ),
                        title: Text(
                          capitalize(I18n.of(context).accountAdd),
                          style: TextStyle(
                            color: app.debugUser ? Colors.grey : null,
                          ),
                        ),
                        onTap: !app.debugUser
                            ? () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => LoginPage()));
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Settings
            Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                contentPadding: EdgeInsets.only(left: 24.0),
                leading: Icon(FeatherIcons.settings),
                title: Text(I18n.of(context).settingsTitle),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SettingsPage()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountTile extends StatefulWidget {
  final User user;
  final Function onSelect;
  final Function onDelete;

  AccountTile(this.user, {this.onSelect, this.onDelete});

  @override
  _AccountTileState createState() => _AccountTileState();
}

class _AccountTileState extends State<AccountTile> {
  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: () {
        widget.onSelect(app.users.indexOf(widget.user));
      },
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => AccountView(widget.user, callback: setState),
          backgroundColor: Colors.transparent,
        ).then((deleted) {
          if (deleted == true) widget.onDelete();
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: ListTile(
          leading: ProfileIcon(
              name: widget.user.name,
              size: 0.85,
              image: widget.user.customProfileIcon),
          //cannot reuse the default profile icon because of size differences
          title: Text(
            widget.user.name ?? "?",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            icon: Icon(FeatherIcons.moreVertical),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) =>
                    AccountView(widget.user, callback: setState),
                backgroundColor: Colors.transparent,
              ).then((deleted) {
                if (deleted == true) widget.onDelete();
              });
            },
          ),
        ),
      ),
    );
  }
}
