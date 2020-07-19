import 'package:filcnaplo/data/context/app.dart';
import 'package:filcnaplo/data/models/user.dart';
import 'package:filcnaplo/helpers/debug.dart';
import 'package:filcnaplo/utils/tools.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:filcnaplo/ui/profile_icon.dart';
import 'package:filcnaplo/utils/format.dart';
import 'package:filcnaplo/generated/i18n.dart';
import 'package:filcnaplo/ui/pages/login.dart';

class AccountHelper {
  final User user;
  final Function callback;

  AccountHelper({this.user, this.callback});

  void updateName(String name) {
    String newName = name.trim();

    if (newName.toLowerCase() == user.name.toLowerCase()) {
      return;
    }

    app.storage.users[user.id]
        .update("settings", {"nickname": newName}).then((_) {
      app.users.firstWhere((search) => search.id == user.id).name = newName;

      app.users.firstWhere((search) => search.id == user.id).profileIcon =
          ProfileIcon(name: newName, size: 0.7, image: user.customProfileIcon);

      user.name = newName;

      callback(() {});
      app.sync.updateCallback();
    });
  }

  Future<ProfileIcon> changeProfileI(BuildContext context) async {
    File newImage = await FilePicker.getFile(type: FileType.image);

    if (newImage == null) return null;

    File result = await ImageCropper.cropImage(
      sourcePath: newImage.path,
      compressFormat: ImageCompressFormat.jpg,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: capital(I18n.of(context).accountProfileIconEdit),
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: true,
        hideBottomControls: true,
      ),
      iosUiSettings: IOSUiSettings(
        title: capital(I18n.of(context).accountProfileIconEdit),
        minimumAspectRatio: 1.0,
        doneButtonTitle: capital(I18n.of(context).dialogDone),
        cancelButtonTitle: capital(I18n.of(context).dialogCancel),
        showCancelConfirmationDialog: false,
        rotateButtonsHidden: true,
      ),
    );

    if (result == null) return null;

    dynamic data = await result.readAsBytes();

    String profileId = generateProfileId(user.id);

    String imagePath =
        path.join(app.appDataPath + "profile_" + profileId + ".jpg");

    try {
      await File(path.join(
              app.appDataPath + "profile_" + user.customProfileIcon + ".jpg"))
          .delete();
    } catch (e) {}

    await File(imagePath).writeAsBytes(data);
    await result.delete();

    await app.storage.users[user.id]
        .update("settings", {"custom_profile_icon": profileId});

    app.users
        .firstWhere(
          (search) => search.id == user.id,
        )
        .profileIcon = ProfileIcon(
      name: user.name,
      size: 0.7,
      image: profileId,
    );

    user.customProfileIcon = profileId;

    app.users.firstWhere((search) => search.id == user.id).customProfileIcon =
        profileId;

    callback(() {});
    app.sync.updateCallback();

    return ProfileIcon(name: user.name, size: 3.0, image: profileId);
  }

  void deleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: app.settings.theme.backgroundColor,
        content: Text(I18n.of(context).accountDeleteConfirm(user.name)),
        actions: <Widget>[
          FlatButton(
            textColor: app.settings.appColor,
            child: Text(I18n.of(context).dialogYes),
            onPressed: () {
              app.users.removeWhere((search) => search.id == user.id);
              app.sync.users[user.id] = null;

              app.storage.deleteUser(user.id).then((_) {
                if (app.users.length == 0) {
                  DebugHelper().eraseData().then((_) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => LoginPage()),
                      (_) => false,
                    );
                  });
                } else {
                  if (app.selectedUser >= app.users.length)
                    app.selectedUser = app.users.length - 1;

                  app.sync.updateCallback();
                  Navigator.of(context).pop(true);
                }
              });
            },
          ),
          FlatButton(
            textColor: app.settings.appColor,
            child: Text(I18n.of(context).dialogNo),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      ),
    ).then((needsPop) {
      if (needsPop == true) Navigator.of(context).pop(true);
    });
  }

  void deleteProfileI() {
    app.users.firstWhere((search) => search.id == user.id).profileIcon =
        ProfileIcon(name: user.name, size: 0.7);

    app.users.firstWhere((search) => search.id == user.id).customProfileIcon =
        "";

    app.storage.users[user.id].update(
      "settings",
      {"custom_profile_icon": ""},
    );

    callback(() {});
    app.sync.updateCallback();
  }
}