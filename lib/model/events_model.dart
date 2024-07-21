import 'package:flutter_to_do_list/model/task_model.dart';

class Event {
  String id;
  String name;
  String description;
  String location;
  DateTime startDateTime;
  DateTime endDateTime;
  String notes;
  List<String> invitees;
  final bool isComplete;
  double allocatedAmount; 
  double remainingAmount; 
  List<Expense> expenses; 
  List<Task> tasks; 

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.startDateTime,
    required this.endDateTime,
    required this.notes,
    required this.invitees,
    this.isComplete = false,
    this.allocatedAmount = 0.0, 
    this.remainingAmount = 0.0, 
    this.expenses = const [], 
    this.tasks = const [], 
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'startDateTime': startDateTime.toIso8601String(),
      'endDateTime': endDateTime.toIso8601String(),
      'notes': notes,
      'invitees': invitees,
      'isComplete': isComplete,
      'allocatedAmount': allocatedAmount, 
      'remainingAmount': remainingAmount, 
      'expenses': expenses.map((e) => e.toMap()).toList(), 
      'tasks': tasks.map((t) => t.toMap()).toList(), 
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      location: map['location'],
      startDateTime: DateTime.parse(map['startDateTime']),
      endDateTime: DateTime.parse(map['endDateTime']),
      notes: map['notes'],
      invitees: List<String>.from(map['invitees']),
      isComplete: map['isComplete'] ?? false,
      allocatedAmount: map['allocatedAmount'] ?? 0.0, 
      remainingAmount: map['remainingAmount'] ?? 0.0, 
      expenses: (map['expenses'] as List<dynamic>?)
              ?.map((e) => Expense.fromMap(e))
              .toList() ??
          [], 
      tasks: (map['tasks'] as List<dynamic>?)
              ?.map((t) => Task.fromMap(t))
              .toList() ??
          [], 
    );
  }
}

class Expense {
  final double amount;
  final String description;
  final String event;

  Expense({
    required this.amount,
    required this.description,
    required this.event,
  });

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'description': description,
      'event': event,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      amount: map['amount'],
      description: map['description'],
      event: map['event'],
    );
  }
}
