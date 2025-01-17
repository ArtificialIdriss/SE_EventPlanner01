import 'package:flutter/material.dart';
import 'package:flutter_to_do_list/const/colors.dart';
import 'package:flutter_to_do_list/screens/add_event_screen.dart';
import 'package:flutter_to_do_list/widgets/stream_event.dart';
import 'package:flutter_to_do_list/screens/budget_screen.dart';
import 'package:flutter_to_do_list/screens/task_screen.dart';
import 'package:flutter_to_do_list/screens/logout.dart'; // Import the logout file

class Home_Screen extends StatefulWidget {
  const Home_Screen({Key? key}) : super(key: key);

  @override
  State<Home_Screen> createState() => _Home_ScreenState();
}

class _Home_ScreenState extends State<Home_Screen> {
  int _selectedIndex = 0; // Index for the current tab
  bool show = true;

  // Pages for each tab
  final List<Widget> _pages = [
    Stream_event(),
    BudgetScreen(),
    TaskScreen(),
  ];

  // Handle bottom navigation item tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColors,
      appBar: AppBar(
        title: Text('Event Planner'),
      ),
      body: SafeArea(
        child: _pages[_selectedIndex], // Display current page based on index
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomRight,
            child: Visibility(
              visible: show,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AddEventScreen(),
                  ));
                },
                backgroundColor: custom_green,
                child: Icon(Icons.add, size: 30),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, bottom: 16.0),
              child: Visibility(
                visible: show,
                child: FloatingActionButton(
                  onPressed: () {
                    logout(context); // Call the logout function
                  },
                  backgroundColor: Colors.red,
                  child: Icon(Icons.logout, size: 30),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Budget',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Tasks',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: custom_green,
        onTap: _onItemTapped,
      ),
    );
  }
}
