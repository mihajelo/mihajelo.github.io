// ignore_for_file: deprecated_member_use, empty_catches

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stempl_v1/employee_edit_page.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';

import 'arhiv.dart';

class _AdminPageState extends State<AdminPage> {
  String? companyId;
  List<Employee> employees = [];
  late int selectedYear;
  late int selectedMonth;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.reference();
  User? currentUser;
  var userId = "";
  String prikaz = '';
  late DatabaseReference _userReference;
  String companyname = '';
  var companyUid = '';
  @override
  void initState() {
    super.initState();
    initializeData();
    if (_auth.currentUser != null) {
      userId = _auth.currentUser!.uid;
    }
    // Fetch employees after initializing userId
    _fetchEmployeesForCurrentUser(userId);
  }

  Future<bool> checkStoragePermission() async {
    var status = await Permission.storage.status;
    if (status.isGranted) {
      // Permission is granted
      return true;
    } else if (status.isDenied) {
      // Permission is denied, request it
      var result = await Permission.storage.request();

      if (result.isGranted) {
        // Permission granted
        return true;
      } else {
        // Permission denied
        return false;
      }
    } else {
      // First time requesting permission
      var result = await Permission.storage.request();

      if (result.isGranted) {
        // Permission granted
        return true;
      } else {
        // Permission denied
        return false;
      }
    }
  }

  Future<void> initializeData() async {
    if (_auth.currentUser != null) {
      userId = _auth.currentUser!.uid;
      await _fetchUserData();
    }
    checkStoragePermission();
    getUsersInCompany();
  }

  Future<List<String>> getUsersInCompany() async {
    final DatabaseReference usersRef =
        FirebaseDatabase.instance.reference().child('users');

    // Use the `once` method to get a DatabaseEvent
    DatabaseEvent event =
        await usersRef.orderByChild('companyId').equalTo(companyUid).once();

    // Extract the DataSnapshot from the DatabaseEvent
    DataSnapshot snapshot = event.snapshot;

    final Map<dynamic, dynamic> usersData =
        snapshot.value as Map<dynamic, dynamic>;

    List<String> userIds = [];

    usersData.forEach((key, value) {
      final userId = key;

      // Add the userId to the list
      userIds.add(userId);
    });

    return userIds;
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      _userReference =
          FirebaseDatabase.instance.reference().child('users/${user.uid}');
      final snapshot = await _userReference.once();

      if (snapshot.snapshot.value != null) {
        final userData = snapshot.snapshot.value as Map<dynamic, dynamic>;
        final name = userData['name'];
        final surname = userData['surname'];

        // Get the company ID for the current user
        final companyId = userData['companyId'];
        setState(() {
          companyUid = companyId;
        });
        // Fetch the company name using the company ID
        final companySnapshot = await FirebaseDatabase.instance
            .reference()
            .child('companies/$companyId')
            .once();
        if (companySnapshot.snapshot.value != null) {
          final companyData =
              companySnapshot.snapshot.value as Map<dynamic, dynamic>;
          final companyName = companyData['name'];

          setState(() {
            companyname = companyName;
            username = '$name $surname';
            companyUid = companyId;
          });
        }
      }
    }
  }

  Future<void> _fetchEmployeesForCurrentUser(String currentUserId) async {
    final userSnapshot =
        await _dbRef.child("users").child(currentUserId).once();

    if (userSnapshot.snapshot.value != null) {
      final userData = userSnapshot.snapshot.value as Map<dynamic, dynamic>;

      setState(() {
        companyId = userData['companyId'] as String?;
      });

      if (companyId != null) {
        await _fetchEmployeesWithCompanyId(companyId!);
      }
    }
  }

// Inside the _AdminPageSettingsState class
  Future<void> _fetchEmployeesWithCompanyId(String companyId) async {
    final employeesSnapshot = await _dbRef
        .child("users")
        .orderByChild("companyId")
        .equalTo(companyId)
        .once();

    if (employeesSnapshot.snapshot.value != null) {
      final Map<dynamic, dynamic>? employeesData =
          employeesSnapshot.snapshot.value as Map<dynamic, dynamic>?;

      employeesData?.forEach((key, value) async {
        final state = await getWorkSessionForUser(key);

        final employee = Employee(
            userId: key,
            name: value['name'] ?? '',
            surname: value['surname'] ?? '',
            status: state);
        setState(() {
          employees.add(employee);
        });
      });
    }
  }

  Future<String> getWorkSessionForUser(String userId) async {
    try {
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);

      DatabaseEvent event = await FirebaseDatabase.instance
          .reference()
          .child("work_sessions")
          .orderByChild("username")
          .equalTo(userId)
          .once();

      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> workSessions =
            event.snapshot.value as Map<dynamic, dynamic>;

        for (var workSessionKey in workSessions.keys) {
          var workSession = workSessions[workSessionKey];
          DateTime startTime = DateTime.parse(workSession['start_time']);
          DateTime workSessionDate =
              DateTime(startTime.year, startTime.month, startTime.day);

          if (workSessionDate.isAtSameMomentAs(today) &&
              workSession.length == 8) {
            return workSession[
                'vrsta']; // Replace 'some_field' with the actual field you want to return
          } else if (workSessionDate.isAtSameMomentAs(today) &&
              workSession.length == 9) {
            return 'Na malici'; // Replace 'some_field' with the actual field you want to return
          } else if (workSessionDate.isAtSameMomentAs(today) &&
              workSession.length == 10) {
            return workSession[
                'vrsta']; // Replace 'some_field' with the actual field you want to return
          }
        }
      }
    } catch (error) {}
    // Return 'nothing' when no matching work session is found
    return 'Ni na delu';
  }
Card _buildCard(
  IconData icon,
  String title,
  Function() onTap,
  double screenHeight,
  double screenWidth,
) {
  return Card(
    elevation: 4.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Padding(
      padding: EdgeInsets.all(.0), // Padding added here
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: screenHeight * 0.03,
              ),
              SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: screenHeight * 0.0201,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    ),
  );
}

  void _navigateToPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    employees.sort((a, b) => a.name.compareTo(b.name));
    EdgeInsets padding = MediaQuery.of(context).padding;
    double topPadding = padding.top;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        body: Stack(
      children: [
        Positioned(
            child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color.fromARGB(197, 255, 202, 103), Colors.white],
            ),
          ),
        )),
        Column(
          children: [
            Container(
              height: topPadding, // Set the desired height for your container
              color: Colors.black, // Your container color
            ),
            Stack(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: screenHeight * 0.0314,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    Text(
                      'UREJANJE UR DELAVCEV',
                      style: TextStyle(
                        fontSize: screenHeight * 0.0276,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                        width: screenHeight *
                            0.0314), // Adjust the space as needed
                  ],
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                        0.3), // Adjust the shadow color and opacity
                    blurRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Divider(
                color: Colors
                    .transparent, // Set the color of the Divider to transparent
                height: 1.0, // Set the thickness of the underline
              ),
            ),
             SizedBox(
              height: 10,
            ),
           Padding(padding: EdgeInsets.all(15),
           child: _buildCard(
              Icons.archive,
              'Arhiv delavnih ur podjetja',
              () => _navigateToPage(const ArhivPage()),
              screenHeight,
              screenWidth,
            ), )
           ,
           
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                      height: screenHeight * 0.0012,
                      color: Colors.black.withOpacity(0.3)),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.02,
                  ),
                  child: Text(
                    'Uredi delavne ure delavca',
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.3),
                        fontWeight: FontWeight.bold,
                        fontSize: screenHeight * 0.0201),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: screenHeight * 0.0012,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero, // Add this line to remove padding

                children: employees.map((employee) {
                  return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => EmployeeEditPage(
                            selectedUserId: employee.userId,
                          ),
                        ));
                      },
                      child: ListTile(
                          title: Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              8.0), // Adjust the radius as needed
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          color: Colors.transparent,
                          child: Stack(
                            children: [
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '${employee.name} ${employee.surname}',
                                        style: TextStyle(
                                            fontSize: screenHeight * 0.0201),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        employee.status,
                                        style: TextStyle(
                                            fontSize: screenHeight * 0.0201,
                                            color: Colors.grey),
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      if (employee.status == 'Ni na delu')
                                        Icon(
                                          Icons.block,
                                          color: Colors.red,
                                          size: screenHeight * 0.0201,
                                        )
                                      else if (employee.status == 'Na malici')
                                        Icon(
                                          Icons.lunch_dining,
                                          color: Colors.orange,
                                          size: screenHeight * 0.0201,
                                        )
                                      else if (employee.status != 'Na malici' &&
                                          employee.status != 'Ni na delu')
                                        Icon(
                                          Icons.work,
                                          color: Colors.green,
                                          size: screenHeight * 0.0201,
                                        ),
                                    ],
                                  )
                                ],
                              ),
                              Positioned(
                                top: 10,
                                right: 0,
                                child: Icon(Icons.edit),
                              ),
                            ],
                          ),
                        ),
                      )));
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    ));
  }
}

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdminPageState createState() => _AdminPageState();
}

class Employee {
  String userId;
  String name;
  String surname;
  String status;

  Employee(
      {required this.userId,
      required this.name,
      required this.surname,
      required this.status});
}
