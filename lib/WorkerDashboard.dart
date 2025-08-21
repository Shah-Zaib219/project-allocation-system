import 'package:flutter/material.dart';
import 'data.dart';
import 'package:pas/Employer/AddProjectScreen.dart';
import 'Employer/BidsList.dart';
import 'ProjectsDetails/PendingProjects.dart';
import 'workers/bids.dart';

class Worker_Dashboard extends StatefulWidget {
  final Map userdata;
  const Worker_Dashboard({super.key, required this.userdata});

  @override
  _Worker_DashboardState createState() => _Worker_DashboardState();
}

class _Worker_DashboardState extends State<Worker_Dashboard> {
  int _selectedIndex = 2;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    // final Map user = widget.userdata;

    // print(widget.userdata);
    List<Widget> screens = [
      const Center(child: Text('Bids on Projects')),
      MyProjectsPage(
        username: widget.userdata['username'],
      ),
      PendingProjectsPage(
        orgusername: widget.userdata['orgusername'],
        username: widget.userdata['username'],
      ),
      const Center(child: Text('Chat with Employers')),
      const Center(child: Text('Reports')),
    ];

    List<Widget> drawerScreens = [
      const Center(child: Text('Profile')),
      const Center(child: Text('Settings')),
      const Center(child: Text('Help')),
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "${widget.userdata['fullName']}",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF5D4DA8),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF5D4DA8),
              ),
              child: Text(
                'Worker Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF5D4DA8)),
              title: const Text('Profile',
                  style: TextStyle(color: Color(0xFF5D4DA8))),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) => const AlertDialog(
                    title: Text('Profile Option'),
                    content: Text('This is the Profile section.'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF5D4DA8)),
              title: const Text('Settings',
                  style: TextStyle(color: Color(0xFF5D4DA8))),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) => const AlertDialog(
                    title: Text('Settings Option'),
                    content: Text('This is the Settings section.'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help, color: Color(0xFF5D4DA8)),
              title: const Text('Help',
                  style: TextStyle(color: Color(0xFF5D4DA8))),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) => const AlertDialog(
                    title: Text('Help Option'),
                    content: Text('This is the Help section.'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF5D4DA8),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.folder_special, 0),
            label: "My Projects",
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.business_center, 1),
            label: "Bids",
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.list_alt, 2),
            label: "Available Projects",
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.chat, 3),
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.bar_chart, 4),
            label: "Reports",
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData iconData, int index) {
    bool isSelected = _selectedIndex == index;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: isSelected
          ? const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            )
          : null,
      child: Icon(
        iconData,
        color: isSelected ? const Color(0xFF5D4DA8) : Colors.white,
      ),
    );
  }
}
