import 'package:flutter/material.dart';
import 'package:flutter_to_do_list/data/firestor.dart';
import 'package:flutter_to_do_list/model/events_model.dart';
import 'package:flutter_to_do_list/widgets/event_widget.dart';

class Stream_event extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Event>>(
      stream: Firestore_Datasource().streamEvents(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        final eventsList = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final event = eventsList[index];
            return Event_Widget(event: event);
          },
          itemCount: eventsList.length,
        );
      },
    );
  }
}
