import 'package:flutter/material.dart';
import 'package:flutter_to_do_list/model/events_model.dart';
import 'package:flutter_to_do_list/data/firestor.dart';
import 'package:flutter_to_do_list/const/colors.dart';

class Event_Widget extends StatelessWidget {
  final Event event;

  Event_Widget({required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(event.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.description),
            Text('Location: ${event.location}'),
            Text('Start: ${event.startDateTime}'),
            Text('End: ${event.endDateTime}'),
            Text('Notes: ${event.notes}'),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Text('Edit'),
              value: 'edit',
            ),
            PopupMenuItem(
              child: Text('Mark as Complete'),
              value: 'complete',
            ),
            PopupMenuItem(
              child: Text('Delete'),
              value: 'delete',
            ),
            PopupMenuItem(
              child: Text('Invite'),
              value: 'invite',
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              // Navigate to edit screen
            } else if (value == 'complete') {
              // Mark as complete
            } else if (value == 'delete') {
              Firestore_Datasource().deleteEvent(event.id);
            } else if (value == 'invite') {
              // Handle invite
            }
          },
        ),
      ),
    );
  }
}
