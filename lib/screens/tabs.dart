import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vibeme/screens/profile.dart';

class Tabs extends StatefulWidget {
  const Tabs({super.key});

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    Center(child: Text('Chats Page')),
    Center(child: Text('Contacts Page')),
    Center(child: Text('Calls Page')),
    Center(child: Profile()),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset('assets/images/chat.png', width: 50, height: 50),
            const Text('Vibe Me'),
          ],
        ),
        actions: [
          Builder(
            builder:
                (context) => PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'settings') {
                    } else if (value == 'logout') {
                      FirebaseAuth.instance.signOut();
                    }
                  },
                  offset: Offset(
                    0,
                    kToolbarHeight,
                  ), // 👈 Push it down below the AppBar
                  itemBuilder:
                      (BuildContext context) => [
                        PopupMenuItem(
                          value: 'settings',
                          child: Row(
                            children: [
                              Icon(Icons.settings, size: 20),
                              SizedBox(width: 8),
                              Text('Settings'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, size: 20),
                              SizedBox(width: 8),
                              Text('Logout'),
                            ],
                          ),
                        ),
                      ],
                  icon: Icon(Icons.more_vert),
                ),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed, // ✅ Needed for more than 3 items
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.call), label: 'Calls'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
