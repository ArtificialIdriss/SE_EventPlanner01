class Event {
  String id;
  String name;
  String description;
  String location;
  DateTime startDateTime;
  DateTime endDateTime;
  String notes;
  List<String> invitees;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.startDateTime,
    required this.endDateTime,
    required this.notes,
    required this.invitees,
  });
}
