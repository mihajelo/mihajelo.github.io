
// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'statistika.dart';
import 'profile_page.dart';
import 'stemplanje.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_bar.dart';



class BottomBar extends StatefulWidget {
    final int currentIndex;

const BottomBar({super.key, required this.currentIndex});
  @override
  BottomBarState createState() => BottomBarState();
}

class BottomBarState extends State<BottomBar> {

  late PageController _pageController;
  bool _isAdmin = false;
  final User? user = FirebaseAuth.instance.currentUser;
  String _userId = '';
 int _currentIndex=1;
  @override
  void initState() {
    super.initState();
      int _currentIndex = widget.currentIndex;

    _pageController = PageController(initialPage: _currentIndex);
     if (user != null) {
      setState(() {
        _userId = user!.uid;
      });
       fetchAdminPermission(_userId);

    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
 final DatabaseReference _databaseRef = FirebaseDatabase.instance.reference();

  Future<bool> fetchAdminPermission(String userId) async {
    try {
      final snapshot = await FirebaseDatabase.instance
          // ignore: deprecated_member_use
          .reference()
          .child('users')
          .child(userId)
          .child('adminPermission')
          .once();

      if (snapshot.snapshot.value != null) {
         setState(() {
      _isAdmin = snapshot.snapshot.value as bool;
    });
        return snapshot.snapshot.value as bool;
      }

      return false;
    } catch (e) {
      return false;
    }
  }



  @override
  Widget build(BuildContext context) {
        double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          StatisticPage( screenHeight: screenHeight, screenWidth:screenWidth),
          StemplanjePage( screenWidth: screenWidth, screenHeight: screenHeight,),
          ProfilePage( screenWidth: screenWidth, screenHeight: screenHeight,),
          if (_isAdmin) AdminBarPage( screenWidth: screenWidth, screenHeight: screenHeight),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // Add this line to set the type to fixed

        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: _isAdmin
            ? [
                BottomNavigationBarItem(
                  icon: Icon(Icons.insert_chart,size: screenHeight*0.0301,),
                  label: 'Statistika',
                ),
                // Replace this with the icon and label for the second page
                BottomNavigationBarItem(
                  icon: Icon(Icons.home,size: screenHeight*0.0301,),
                  label: 'Štemplanje',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.admin_panel_settings,size: screenHeight*0.0301,),
                  label: 'Profil',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings,size: screenHeight*0.0301,),
                  label: 'Admin',
                ),
              ] 
            : [
                BottomNavigationBarItem(
                  icon: Icon(Icons.insert_chart,size: screenHeight*0.0301,),
                  label: 'Statistika',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.home,size: screenHeight*0.0301,),
                  label: 'Štemplanje',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.admin_panel_settings,size: screenHeight*0.0301,),
                  label: 'Profil',
                ),
              ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedFontSize: screenHeight*0.0175, // Set your desired font size for selected items
  unselectedFontSize: screenHeight*0.0175, 
  
      ),
    );
  }
}


