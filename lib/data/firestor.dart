import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_to_do_list/model/events_model.dart';
import 'package:flutter_to_do_list/model/task_model.dart';

class Firestore_Datasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> createUser(String email) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .set({"id": _auth.currentUser!.uid, "email": email});
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> addEvent(Event event) async {
    try {
      // Ensure allocatedAmount is set to 5000 by default if not provided
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('events')
          .doc(event.id)
          .set(event.toMap());
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> updateEvent(Event event) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('events')
          .doc(event.id)
          .update(event.toMap());
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> deleteEvent(String eventId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('events')
          .doc(eventId)
          .delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  List<Event> getEventsFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Event.fromMap(data);
    }).toList();
  }

  Stream<List<Event>> streamEvents() {
    return _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('events')
        .snapshots()
        .map(getEventsFromSnapshot);
  }

  Future<Event?> getEventByName(String eventName) async {
    try {
      DocumentSnapshot eventDoc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('events')
          .doc(eventName)
          .get();

      if (eventDoc.exists) {
        return Event.fromMap(eventDoc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching event by name: $e');
      return null;
    }
  }

  Future<bool> updateTask(String eventId, Task task) async {
    try {
      final eventDoc = _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('events')
          .doc(eventId);

      // Fetch the event document
      DocumentSnapshot eventSnapshot = await eventDoc.get();
      if (eventSnapshot.exists) {
        final eventData = eventSnapshot.data() as Map<String, dynamic>;
        Event event = Event.fromMap(eventData);

        // Find and update the task in the event
        final tasks = event.tasks;
        final taskIndex = tasks.indexWhere((t) => t.description == task.description && t.when == task.when);
        if (taskIndex != -1) {
          tasks[taskIndex] = task; // Update the task
          event.tasks = tasks; // Update the event with the modified tasks list

          await eventDoc.update(event.toMap());
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error updating task: $e');
      return false;
    }
  }

  Future<bool> markTaskAsComplete(String eventId, Task task) async {
    try {
      task.isComplete = true; // Mark task as complete
      return await updateTask(eventId, task);
    } catch (e) {
      print('Error marking task as complete: $e');
      return false;
    }
  }

  Future<bool> deleteTask(String eventId, Task task) async {
    try {
      final eventDoc = _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('events')
          .doc(eventId);

      // Fetch the event document
      DocumentSnapshot eventSnapshot = await eventDoc.get();
      if (eventSnapshot.exists) {
        final eventData = eventSnapshot.data() as Map<String, dynamic>;
        Event event = Event.fromMap(eventData);

        // Find and remove the task from the event
        final tasks = event.tasks;
        final taskIndex = tasks.indexWhere((t) => t.description == task.description && t.when == task.when);
        if (taskIndex != -1) {
          tasks.removeAt(taskIndex); // Remove the task
          event.tasks = tasks; // Update the event with the modified tasks list

          await eventDoc.update(event.toMap());
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error deleting task: $e');
      return false;
    }
  }

  Future<void> addTask(String eventId, Task task) async {
    try {
      final eventDoc = _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('events')
          .doc(eventId);

      // Fetch the event document
      DocumentSnapshot eventSnapshot = await eventDoc.get();
      if (eventSnapshot.exists) {
        final eventData = eventSnapshot.data() as Map<String, dynamic>;
        Event event = Event.fromMap(eventData);

        // Add the task to the event
        event.tasks.add(task);
        await eventDoc.update(event.toMap());
      }
    } catch (e) {
      print('Error adding task: $e');
    }
  }
}
