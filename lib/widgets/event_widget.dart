import 'package:flutter/material.dart';
import 'package:flutter_to_do_list/model/events_model.dart';
import 'package:flutter_to_do_list/data/firestor.dart';
import 'package:flutter_to_do_list/screens/add_event_screen.dart';

class Event_Widget extends StatelessWidget {
  final Event event;

  Event_Widget({required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          event.name,
          style: TextStyle(
            decoration: event.isComplete ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.description,
              style: TextStyle(
                decoration: event.isComplete ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
            Text(
              'Location: ${event.location}',
              style: TextStyle(
                decoration: event.isComplete ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
            Text(
              'Start: ${event.startDateTime}',
              style: TextStyle(
                decoration: event.isComplete ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
            Text(
              'End: ${event.endDateTime}',
              style: TextStyle(
                decoration: event.isComplete ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
            Text(
              'Notes: ${event.notes}',
              style: TextStyle(
                decoration: event.isComplete ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Text('Edit'),
              value: 'edit',
            ),
            PopupMenuItem(
              child: Text(event.isComplete ? 'Mark as Incomplete' : 'Mark as Complete'),
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
          onSelected: (value) async {
            if (value == 'edit') {
              // Navigate to the edit screen with the current event
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddEventScreen(event: event),
                ),
              );
            } else if (value == 'complete') {
              // Toggle the completion status
              final updatedEvent = Event(
                id: event.id,
                name: event.name,
                description: event.description,
                location: event.location,
                startDateTime: event.startDateTime,
                endDateTime: event.endDateTime,
                notes: event.notes,
                invitees: event.invitees,
                isComplete: !event.isComplete, // Toggle the isComplete field
              );
              await Firestore_Datasource().updateEvent(updatedEvent);
            } else if (value == 'delete') {
              // Show confirmation dialog before deleting
              bool confirmDelete = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Confirm Delete'),
                  content: Text('Are you sure you want to delete this event?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false); // Return false when canceled
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true); // Return true when confirmed
                      },
                      child: Text('Delete'),
                    ),
                  ],
                ),
              );

              // If user confirms deletion, proceed with deletion
              if (confirmDelete == true) {
                await Firestore_Datasource().deleteEvent(event.id);
              }
            } else if (value == 'invite') {
              // Handle invite action
              // (You can implement this based on your requirements)
            }
          },
        ),
      ),
    );
  }
}