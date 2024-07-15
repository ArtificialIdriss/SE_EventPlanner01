import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_to_do_list/model/events_model.dart'; // Import your Event model

class Firestore_Datasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> CreateUser(String email) async {
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
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('events')
          .doc(event.id)
          .set({
        'id': event.id,
        'name': event.name,
        'description': event.description,
        'location': event.location,
        'startDateTime': event.startDateTime.toIso8601String(),
        'endDateTime': event.endDateTime.toIso8601String(),
        'notes': event.notes,
        'invitees': event.invitees,
      });
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
          .update({
        'name': event.name,
        'description': event.description,
        'location': event.location,
        'startDateTime': event.startDateTime.toIso8601String(),
        'endDateTime': event.endDateTime.toIso8601String(),
        'notes': event.notes,
        'invitees': event.invitees,
      });
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
      return Event(
        id: data['id'],
        name: data['name'],
        description: data['description'],
        location: data['location'],
        startDateTime: DateTime.parse(data['startDateTime']),
        endDateTime: DateTime.parse(data['endDateTime']),
        notes: data['notes'],
        invitees: List<String>.from(data['invitees']),
      );
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
}
