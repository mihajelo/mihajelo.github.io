// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:stempl_v1/main.dart';
import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';

class ProfilePage extends StatefulWidget {
  final double screenHeight;
  final double screenWidth;

  const ProfilePage(
      {super.key, required this.screenHeight, required this.screenWidth});

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String _username = '';
  String _email = '';
  String _company = '';
  String _userId = '';
  late DatabaseReference _userReference;
  int _totalWorkMinutesMonth = 0;
  int _totalWorkMinutesWeek = 0;
  double screenHeight = 0.0;
  double screenWidth = 0;
  get result => null; // Added variable to store total work minutes.

  // Function to get the current user's UID from Firebase Authentication
  String? _getCurrentUserUid() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    screenHeight = widget.screenHeight;
    screenWidth = widget.screenWidth;
    _userId = _getCurrentUserUid() ?? '';
    _calculateWorkMinutesForCurrentUserWeek();
    _calculateWorkMinutesForCurrentUserMonth();
    _initConnectivity();
  }

  void _initConnectivity() {
    Connectivity().onConnectivityChanged.listen((result) {
      // Handle network connectivity changes here
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        // Device is online
      } else {
        // Device is offline
      }
    });
  }

  Future<void> _calculateWorkMinutesForCurrentUserMonth() async {
    final DatabaseReference workSessionsRef =
        FirebaseDatabase.instance.reference().child('work_sessions');

    // Calculate the start and end dates for the current month
    final DateTime now = DateTime.now();
    final DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    final DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    // Fetch the data as a DatabaseEvent
    final DatabaseEvent event =
        await workSessionsRef.orderByChild('username').equalTo(_userId).once();
    // Convert the DatabaseEvent to a DataSnapshot
    final DataSnapshot snapshot = event.snapshot;

    final dynamic data = snapshot.value;
    if (data != null) {
      // Parse the data as a Map
      final Map<dynamic, dynamic> workSessionsData =
          data as Map<dynamic, dynamic>;

      // Calculate work minutes by iterating through work sessions
      int totalWorkMinutes = 0;

      workSessionsData.forEach((key, value) {
        if (value.length == 15) {
          final workSession = value as Map<dynamic, dynamic>;
          if (workSession['right'] == true) {
            final startTime = DateTime.parse(workSession['start_time']);
            final endTime = DateTime.parse(workSession['end_time']);

            // Check if the username matches the current user's ID and the date is within the current month
            if (workSession['username'] == _userId &&
                startTime.isAfter(firstDayOfMonth) &&
                endTime.isBefore(lastDayOfMonth) &&
                workSession.length == 15) {
              // Calculate the time difference in minutes
              totalWorkMinutes += endTime.difference(startTime).inMinutes;
            }
          }
        }
      });

      setState(() {
        _totalWorkMinutesMonth =
            totalWorkMinutes; // Update the total work minutes
      });
    } else {
      setState(() {
        _totalWorkMinutesMonth =
            0; // No work sessions found for the current user.
      });
    }
  }

  Future<void> _calculateWorkMinutesForCurrentUserWeek() async {
    final DatabaseReference workSessionsRef =
        FirebaseDatabase.instance.reference().child('work_sessions');

    DateTime _selectedWeekStart = DateTime.now();
    DateTime _selectedWeekEnd = DateTime.now();

    DateTime now = DateTime.now();
    int currentDayOfWeek = now.weekday;
    if (currentDayOfWeek == 1) {
      setState(() {
        _selectedWeekStart = DateTime.now().subtract(Duration(
          days: 0,
          hours: DateTime.now().hour,
          minutes: DateTime.now().minute,
          seconds: DateTime.now().second,
          milliseconds: DateTime.now().millisecond,
          microseconds: DateTime.now().microsecond,
        ));
        _selectedWeekEnd =
            DateTime.now().add(const Duration(days: 7)).subtract(Duration(
                  hours: DateTime.now().hour,
                  minutes: DateTime.now().minute,
                  seconds: DateTime.now().second,
                  milliseconds: DateTime.now().millisecond,
                  microseconds: DateTime.now().microsecond,
                ));
      });
    }
    if (currentDayOfWeek == 2) {
      setState(() {
        _selectedWeekStart = DateTime.now().subtract(Duration(
          days: 1,
          hours: DateTime.now().hour,
          minutes: DateTime.now().minute,
          seconds: DateTime.now().second,
          milliseconds: DateTime.now().millisecond,
          microseconds: DateTime.now().microsecond,
        ));
        _selectedWeekEnd =
            DateTime.now().add(const Duration(days: 6)).subtract(Duration(
                  hours: DateTime.now().hour,
                  minutes: DateTime.now().minute,
                  seconds: DateTime.now().second,
                  milliseconds: DateTime.now().millisecond,
                  microseconds: DateTime.now().microsecond,
                ));
      });
    }
    if (currentDayOfWeek == 3) {
      setState(() {
        _selectedWeekStart = DateTime.now().subtract(Duration(
          days: 2,
          hours: DateTime.now().hour,
          minutes: DateTime.now().minute,
          seconds: DateTime.now().second,
          milliseconds: DateTime.now().millisecond,
          microseconds: DateTime.now().microsecond,
        ));
        _selectedWeekEnd =
            DateTime.now().add(const Duration(days: 5)).subtract(Duration(
                  hours: DateTime.now().hour,
                  minutes: DateTime.now().minute,
                  seconds: DateTime.now().second,
                  milliseconds: DateTime.now().millisecond,
                  microseconds: DateTime.now().microsecond,
                ));
      });
    }
    if (currentDayOfWeek == 4) {
      setState(() {
        _selectedWeekStart = DateTime.now().subtract(Duration(
          days: 3,
          hours: DateTime.now().hour,
          minutes: DateTime.now().minute,
          seconds: DateTime.now().second,
          milliseconds: DateTime.now().millisecond,
          microseconds: DateTime.now().microsecond,
        ));
        _selectedWeekEnd =
            DateTime.now().add(const Duration(days: 4)).subtract(Duration(
                  hours: DateTime.now().hour,
                  minutes: DateTime.now().minute,
                  seconds: DateTime.now().second,
                  milliseconds: DateTime.now().millisecond,
                  microseconds: DateTime.now().microsecond,
                ));
      });
    }
    if (currentDayOfWeek == 5) {
      setState(() {
        _selectedWeekStart = DateTime.now().subtract(Duration(
          days: 4,
          hours: DateTime.now().hour,
          minutes: DateTime.now().minute,
          seconds: DateTime.now().second,
          milliseconds: DateTime.now().millisecond,
          microseconds: DateTime.now().microsecond,
        ));
        _selectedWeekEnd =
            DateTime.now().add(const Duration(days: 3)).subtract(Duration(
                  hours: DateTime.now().hour,
                  minutes: DateTime.now().minute,
                  seconds: DateTime.now().second,
                  milliseconds: DateTime.now().millisecond,
                  microseconds: DateTime.now().microsecond,
                ));
      });
    }
    if (currentDayOfWeek == 6) {
      setState(() {
        _selectedWeekStart = DateTime.now().subtract(Duration(
          days: 5,
          hours: DateTime.now().hour,
          minutes: DateTime.now().minute,
          seconds: DateTime.now().second,
          milliseconds: DateTime.now().millisecond,
          microseconds: DateTime.now().microsecond,
        ));
        _selectedWeekEnd =
            DateTime.now().add(const Duration(days: 2)).subtract(Duration(
                  hours: DateTime.now().hour,
                  minutes: DateTime.now().minute,
                  seconds: DateTime.now().second,
                  milliseconds: DateTime.now().millisecond,
                  microseconds: DateTime.now().microsecond,
                ));
      });
    }

    if (currentDayOfWeek == 7) {
      setState(() {
        _selectedWeekStart = DateTime.now().subtract(Duration(
          days: 6,
          hours: DateTime.now().hour,
          minutes: DateTime.now().minute,
          seconds: DateTime.now().second,
          milliseconds: DateTime.now().millisecond,
          microseconds: DateTime.now().microsecond,
        ));
        _selectedWeekEnd =
            DateTime.now().add(const Duration(days: 1)).subtract(Duration(
                  hours: DateTime.now().hour,
                  minutes: DateTime.now().minute,
                  seconds: DateTime.now().second,
                  milliseconds: DateTime.now().millisecond,
                  microseconds: DateTime.now().microsecond,
                ));
      });
    }
    // Calculate the start and end dates for the current month

// Calculate the difference between the current day and Monday

// Calculate the first day of the week

    // Fetch the data as a DatabaseEvent
    final DatabaseEvent event =
        await workSessionsRef.orderByChild('username').equalTo(_userId).once();
    // Convert the DatabaseEvent to a DataSnapshot
    final DataSnapshot snapshot = event.snapshot;

    final dynamic data = snapshot.value;
    if (data != null) {
      // Parse the data as a Map
      final Map<dynamic, dynamic> workSessionsData =
          data as Map<dynamic, dynamic>;

      // Calculate work minutes by iterating through work sessions
      int totalWorkMinutes = 0;

      workSessionsData.forEach((key, value) {
        if (value.length == 15) {
          final workSession = value as Map<dynamic, dynamic>;
          if (workSession['right'] == true) {
            final startTime = DateTime.parse(workSession['start_time']);
            final endTime = DateTime.parse(workSession['end_time']);

            // Check if the username matches the current user's ID and the date is within the current month
            if (workSession['username'] == _userId &&
                startTime.isAfter(_selectedWeekStart) &&
                endTime.isBefore(_selectedWeekEnd) &&
                workSession.length == 15) {
              // Calculate the time difference in minutes
              totalWorkMinutes += endTime.difference(startTime).inMinutes;
            }
          }
        }
      });

      setState(() {
        _totalWorkMinutesWeek =
            totalWorkMinutes; // Update the total work minutes
      });
    } else {
      setState(() {
        _totalWorkMinutesWeek =
            0; // No work sessions found for the current user.
      });
    }
  }

  void _resetPassword(BuildContext context) async {
    final String email = emailController.text;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _email,
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Password Reset Email Sent"),
            content: Text(
                "An email with instructions to reset your password has been sent to $email."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Password Reset Error"),
            content: Text(
                "An error occurred while sending the password reset email: $e"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
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
        final email = user.email;

        // Get the company ID for the current user
        final companyId = userData['companyId'];

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
            _username = '$name $surname';
            _email = email!;
            _company = companyName;
          });
        }
      }
    }
  }

  Widget customListTile1({
    required String titleText,
    void Function()? onTap,
  }) {
    return Container(
      width: double.infinity, // Set to stretch through the width of the screen
      padding: EdgeInsets.symmetric(
          horizontal: 16.0), // Adjust horizontal padding as needed
      child: Card(
        color: Colors.white, // Set background color to white
        elevation: 5.0, // Add elevation if desired
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(10.0), // Set border radius as needed
        ),
        child: Container(
          padding: EdgeInsets.all(16.0), // Adjust internal padding as needed
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Teden:',
                style: TextStyle(
                  fontSize: screenHeight *
                      0.0201, // Adjust the font size for 'Mesec' text
                ),
              ),
              Text(
                titleText,
                style: TextStyle(
                  fontSize: screenHeight *
                      0.0201, // Adjust the font size for the time text
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget customListTile2({
    required String titleText,
    void Function()? onTap,
  }) {
    return Container(
      width: double.infinity, // Set to stretch through the width of the screen
      padding: EdgeInsets.symmetric(
          horizontal: 16.0), // Adjust horizontal padding as needed
      child: Card(
        color:
            Color.fromARGB(255, 255, 255, 255), // Set background color to white
        elevation: 5.0, // Add elevation if desired
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(10.0), // Set border radius as needed
        ),
        child: Container(
          padding: EdgeInsets.all(16.0), // Adjust internal padding as needed
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mesec:',
                style: TextStyle(
                  fontSize: screenHeight *
                      0.0201, // Adjust the font size for 'Mesec' text
                ),
              ),
              Text(
                titleText,
                style: TextStyle(
                  fontSize: screenHeight *
                      0.0201, // Adjust the font size for the time text
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = MediaQuery.of(context).padding;
    double topPadding = padding.top;
    screenHeight = screenHeight;
    screenWidth = screenWidth;
    return Scaffold(
        body: Stack(
      children: [
        Positioned(
            child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color.fromARGB(199, 119, 192, 252), Colors.white],
            ),
          ),
        )),
        Center(
          child: Column(
            children: [
              Container(
                color: Colors.black,
                height: topPadding,
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: ListView(
                  children: [
                    _buildUserInfoContainer(
                        _company, _username, _email, _userId),
                    SizedBox(
                      height: screenHeight * 0.0125,
                    ),
                    // Align "Delavne ure" with customListTile1
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 35, bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.access_time,
                                color: Colors.black,
                                size: screenHeight * 0.0301,
                              ),
                              SizedBox(width: screenWidth * 0.022),
                              Text(
                                'Delovne ure',
                                style: TextStyle(
                                  fontSize: screenHeight * 0.0201,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // customListTile1
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: customListTile1(
                            titleText: _totalWorkMinutesWeek == 0
                                ? '0:00'
                                : '${_totalWorkMinutesWeek ~/ 60}:${(_totalWorkMinutesWeek % 60).toString().padLeft(2, '0')}',
                          ),
                        ),
                      ],
                    ),
                    // customListTile2
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: customListTile2(
                        titleText: _totalWorkMinutesMonth == 0
                            ? '0:00'
                            : '${_totalWorkMinutesMonth ~/ 60}:${(_totalWorkMinutesMonth % 60).toString().padLeft(2, '0')}',
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.0628),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: screenHeight * 0.0503,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  30.0), // Adjust the border radius as needed
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(
                                      0.5), // Adjust the shadow color and opacity
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      30.0), // Adjust the border radius as needed
                                ),
                              ),
                              onPressed: () async {
                                // Create a TextEditingController for the password input
                                TextEditingController passwordController =
                                    TextEditingController();

                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Spremeni geslo"),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          // Text input for the current password
                                          TextField(
                                            controller: passwordController,
                                            decoration: const InputDecoration(
                                                labelText: 'Trenutno geslo'),
                                            obscureText: true,
                                          ),
                                        ],
                                      ),
                                      actions: <Widget>[
                                        ElevatedButton(
                                          child: const Text("Spremeni geslo"),
                                          onPressed: () async {
                                            // Get the current password from the text input
                                            String currentPassword =
                                                passwordController.text;

                                            try {
                                              User? user = FirebaseAuth
                                                  .instance.currentUser;

                                              // Reauthenticate the user with the current password
                                              EmailAuthCredential? credential =
                                                  EmailAuthProvider.credential(
                                                          email: _email,
                                                          password:
                                                              currentPassword)
                                                      as EmailAuthCredential?;
                                              await user!
                                                  .reauthenticateWithCredential(
                                                      credential
                                                          as AuthCredential);

                                              // Call your password reset function here
                                              _resetPassword(context);

                                              // Show a snackbar with the message
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Email z navodili za spremembo gesla so bila poslana na: $_email'),
                                                ),
                                              );

                                              Navigator.of(context)
                                                  .pop(); // Close the current dialog
                                            } on FirebaseAuthException {
                                              // Handle reauthentication errors (e.g., incorrect password)
                                              // Show an error message
                                            }
                                          },
                                        ),
                                        ElevatedButton(
                                          child: const Text("Prekliči"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.lock,
                                      color: Colors.grey,
                                      size: screenHeight * 0.0301),
                                  SizedBox(
                                      width: screenWidth *
                                          0.022), // Adjust the spacing between icon and text
                                  Text(
                                    "Spremeni geslo",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: screenHeight * 0.0226),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.0376),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: screenHeight * 0.0503,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  30.0), // Adjust the border radius as needed
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(
                                      0.5), // Adjust the shadow color and opacity
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      30.0), // Adjust the border radius as needed
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const HomeScreen()));

                                // Handle the logout option here
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.exit_to_app,
                                    color: Colors.grey,
                                    size: screenHeight * 0.0301,
                                  ),
                                  SizedBox(
                                      width: screenWidth *
                                          0.022), // Adjust the spacing between icon and text
                                  Text(
                                    "Odjava",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: screenHeight * 0.0226),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.0125,
                    ),
                  ],
                ),
              ))
            ],
          ),
        )
      ],
    ));
  }

  Widget _buildUserInfoContainer(company, username, email, userId) {
    // Define a common width for the cards

    // Define padding for the content inside each card
    EdgeInsetsGeometry cardContentPadding = EdgeInsets.all(6.0);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              username,
              style: TextStyle(
                fontSize: screenHeight * 0.0503,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.0314),

          // Podatki o delavcu Label with Person Icon
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                // Person Icon
                Icon(
                  Icons.person,
                  size: screenHeight * 0.0226,
                  color: Colors.black,
                ),
                // Label "Moji podatki"
                Text(
                  '  Moji podatki',
                  style: TextStyle(
                    fontSize: screenHeight * 0.0201,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // Email Card with vertical content
          Card(
            color: Colors.white,
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: cardContentPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.email,
                          size: screenHeight * 0.0256,
                          color: Colors.grey,
                        ),
                        SizedBox(width: screenWidth * 0.0276),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: screenHeight * 0.0201,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Company Card with vertical content
          Card(
            color: Colors.white,
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: cardContentPadding,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align content to the left
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center content vertically
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment
                          .center, // Center content vertically in the row
                      children: [
                        Icon(
                          Icons.business_center,
                          size: screenHeight * 0.0256,
                          color: Colors.grey,
                        ),
                        SizedBox(width: screenWidth * 0.0276),
                        Text(
                          company,
                          style: TextStyle(
                            fontSize: screenHeight * 0.0201,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // User ID Card with vertical content
          Builder(
            builder: (context) => GestureDetector(
                onTap: () {
                  _copyToClipboard(context, userId);
                },
                child: Card(
                  color: Colors.white,
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: cardContentPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Align content to the left
                        mainAxisAlignment: MainAxisAlignment
                            .center, // Center content vertically
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment
                                .center, // Center content vertically in the row
                            children: [
                              Icon(
                                Icons.person,
                                size: screenHeight * 0.0256,
                                color: Colors.grey,
                              ),
                              SizedBox(width: screenWidth * 0.0276),
                              Text(
                                'Kopiraj uporabniški ID naslov',
                                style: TextStyle(
                                  fontSize: screenHeight * 0.0201,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
          )
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));

    // Show SnackBar notification
    final snackBar = SnackBar(
      content: Text('Kopirano v odložišče'),
      duration: Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
