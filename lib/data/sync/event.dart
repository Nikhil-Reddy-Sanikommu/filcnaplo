import 'dart:convert';

import 'package:filcnaplo/data/context/app.dart';
import 'package:filcnaplo/data/models/event.dart';

class EventSync {
  List<Event> data = [];

  Future<bool> sync() async {
    if (!app.debugUser) {
      List<Event> events;
      events = await app.user.kreta.getEvents();

      if (events == null) {
        await app.user.kreta.refreshLogin();
        events = await app.user.kreta.getEvents();
      }

      if (events != null) {
        data = events;

        await app.user.storage.delete("kreta_events");

        await Future.forEach(events, (event) async {
          if (event.json != null) {
            await app.user.storage.insert("kreta_events", {
              "json": jsonEncode(event.json),
            });
          }
        });

        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  delete() {
    data = [];
  }
}
