import 'package:flutter/material.dart';
import 'package:flutter_to_do_list/model/events_model.dart';
import 'package:flutter_to_do_list/data/firestor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  Map<String, Event> eventsMap = {};
  String? selectedEventId;

  final Firestore_Datasource _datasource = Firestore_Datasource();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  void fetchEvents() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('events')
            .where('isComplete', isEqualTo: false)
            .get();

        List<Event> events = _datasource.getEventsFromSnapshot(querySnapshot);

        setState(() {
          eventsMap = {for (var event in events) event.id: event};
          if (eventsMap.isNotEmpty) {
            selectedEventId = eventsMap.keys.first;
            fetchBudgetDetails(selectedEventId!);
          }
        });
      }
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  void fetchBudgetDetails(String eventId) async {
    setState(() {
      print('Event details updated for $eventId');
    });
  }

  void addExpense() async {
    if (selectedEventId == null) return;

    final TextEditingController amountController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Expense'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Amount'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  double amount = double.parse(amountController.text);
                  String description = descriptionController.text.trim();

                  Expense newExpense = Expense(
                    amount: amount,
                    description: description,
                    event: selectedEventId!,
                  );

                  setState(() {
                    Event? event = eventsMap[selectedEventId!];
                    if (event != null) {
                      event.expenses.add(newExpense);
                      event.remainingAmount -= amount;
                      eventsMap[selectedEventId!] = event;
                    }
                  });

                  try {
                    Event? event = eventsMap[selectedEventId!];
                    if (event != null) {
                      _datasource.updateEvent(event);
                    }
                  } catch (e) {
                    print('Error adding expense: $e');
                  }

                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );

    amountController.clear();
    descriptionController.clear();
  }

  void editAllocatedAmount() async {
    if (selectedEventId == null) return;

    final TextEditingController allocatedController = TextEditingController();
    Event? event = eventsMap[selectedEventId!];
    allocatedController.text = event?.allocatedAmount.toStringAsFixed(2) ?? '0.0';

    double? newAmount = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Allocated Amount'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: allocatedController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'New Allocated Amount'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an allocated amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop(double.tryParse(allocatedController.text));
                }
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (newAmount != null) {
      setState(() {
        Event? event = eventsMap[selectedEventId!];
        if (event != null) {
          event.allocatedAmount = newAmount;
          event.remainingAmount = newAmount - event.expenses.fold(0, (sum, expense) => sum + expense.amount);
          eventsMap[selectedEventId!] = event;
        }
      });

      try {
        Event? event = eventsMap[selectedEventId!];
        if (event != null) {
          await _datasource.updateEvent(event);
        }
      } catch (e) {
        print('Error updating allocated amount: $e');
      }
    }
  }

  void editExpense(Expense expense) async {
    final TextEditingController amountController = TextEditingController(text: expense.amount.toString());
    final TextEditingController descriptionController = TextEditingController(text: expense.description);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Expense'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Amount'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  double amount = double.parse(amountController.text);
                  String description = descriptionController.text.trim();

                  setState(() {
                    Event? event = eventsMap[selectedEventId!];
                    if (event != null) {
                      int index = event.expenses.indexOf(expense);
                      if (index != -1) {
                        event.expenses[index] = Expense(
                          amount: amount,
                          description: description,
                          event: selectedEventId!,
                        );
                        event.remainingAmount += expense.amount - amount;
                        eventsMap[selectedEventId!] = event;
                      }
                    }
                  });

                  try {
                    Event? event = eventsMap[selectedEventId!];
                    if (event != null) {
                      _datasource.updateEvent(event);
                    }
                  } catch (e) {
                    print('Error updating expense: $e');
                  }

                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void deleteExpense(Expense expense) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this expense?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      setState(() {
        Event? event = eventsMap[selectedEventId!];
        if (event != null) {
          event.expenses.remove(expense);
          event.remainingAmount += expense.amount;
          eventsMap[selectedEventId!] = event;
        }
      });

      try {
        Event? event = eventsMap[selectedEventId!];
        if (event != null) {
          await _datasource.updateEvent(event);
        }
      } catch (e) {
        print('Error deleting expense: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget Screen'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: editAllocatedAmount,
          ),
        ],
      ),
      body: eventsMap.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Remaining Budget: \$${eventsMap[selectedEventId!]?.remainingAmount.toStringAsFixed(2) ?? '0.00'}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Allocated Budget: \$${eventsMap[selectedEventId!]?.allocatedAmount.toStringAsFixed(2) ?? '0.00'}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            'Expense List',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: addExpense,
                        child: Text('Add Expense'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          'Description',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Amount',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Budget After Expense',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Actions',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                Expanded(
                  child: ListView.builder(
                    itemCount: eventsMap[selectedEventId!]?.expenses.length ?? 0,
                    itemBuilder: (context, index) {
                      final expenses = eventsMap[selectedEventId!]!.expenses;
                      double remainingBudget = eventsMap[selectedEventId!]!.allocatedAmount;

                      for (int i = 0; i <= index; i++) {
                        remainingBudget -= expenses[i].amount;
                      }

                      final expense = expenses[index];
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 4.0),
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(expense.description),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '\$${expense.amount.toStringAsFixed(2)}',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '\$${remainingBudget.toStringAsFixed(2)}',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Align(
                                alignment: Alignment.center,
                                child: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'Edit') {
                                      editExpense(expense);
                                    } else if (value == 'Delete') {
                                      deleteExpense(expense);
                                    }
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return [
                                      PopupMenuItem<String>(
                                        value: 'Edit',
                                        child: Text('Edit Expense'),
                                      ),
                                      PopupMenuItem<String>(
                                        value: 'Delete',
                                        child: Text('Delete Expense'),
                                      ),
                                    ];
                                  },
                                  icon: Icon(Icons.more_vert),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
