// ignore_for_file: unused_field, unused_local_variable, avoid_print, library_private_types_in_public_api, deprecated_member_use, unnecessary_string_interpolations, use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class ArhivPage extends StatefulWidget {
  const ArhivPage({super.key});

  @override
  _ArhivPageState createState() => _ArhivPageState();
}

class _ArhivPageState extends State<ArhivPage> {
  String _userId = '';
  DateTime _selectedDate = DateTime.now();

  DateTime _selectedWeekStart = DateTime.now();
  DateTime _selectedWeekEnd = DateTime.now();
  String currentcompanyid = '';
  User? currentUser;
  List<WorkSession> _workSessions = [];
  String imeInPriimek = '';
  @override
  void initState() {
    super.initState();

    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    }
    initializeDateFormatting();
    initializeData();
  }

  Future<void> initializeData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    }

    await fetchCompany(_userId);
    nastaviDan();
    _showWorkSessionsForCurrentUser(setDate: true);
  }

  DateTime nastaviDan() {
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
    return DateTime.now();
  }

  Future<String> fetchCompany(String userId) async {
    try {
      final snapshot = await FirebaseDatabase.instance
          .reference()
          .child('users')
          .child(userId)
          .child('companyId')
          .once();
      print(snapshot.snapshot.value);
      if (snapshot.snapshot.value != null) {
        setState(() {
          currentcompanyid = snapshot.snapshot.value.toString();
        });
        return snapshot.snapshot.value.toString();
      }

      return '';
    } catch (e) {
      print(e.toString()); // Handle errors appropriately
      return '';
    }
  }

  void _showWorkSessionsForCurrentUserDay({
    bool setDate = false,
    DateTime? selectedDate,
  }) {
    final DatabaseReference workSessionsRef =
        FirebaseDatabase.instance.reference().child('work_sessions');

    DateTime startDate;
    DateTime endDate;

    if (setDate && selectedDate != null) {
      // Set the startDate and endDate to the selected date only
      startDate = selectedDate;
      endDate = selectedDate.add(const Duration(days: 1));
    } else {
      // By default, use the current date
      startDate = DateTime.now();
      endDate = startDate.add(const Duration(days: 1));
    }

    workSessionsRef
        .orderByChild('end_time')
        .startAt('')
        .endAt('\uf8ff')
        .onValue
        .listen((event) {
      final Map<dynamic, dynamic> sessionsData =
          event.snapshot.value as Map<dynamic, dynamic>;
      // ignore: unnecessary_null_comparison
      if (sessionsData != null) {
        final List<String?> sessionTexts = sessionsData.entries
            .map((entry) {
              final sessionData = entry.value as Map<dynamic, dynamic>;

              final username = sessionData['username'] as String;
              final endTime = sessionData['end_time'] as String;
              final comapnyId = sessionData['companyid'] as String;

              // Check if 'end_time' is not null
              if (comapnyId == currentcompanyid) {
                final startTime = sessionData['start_time'] as String;
                final startTimecard = sessionData['start_time'] as String;
                final endTimecard = sessionData['end_time'] as String;
                final startTimeLunch =
                    sessionData['start_time_lunch'] as String;
                final endTimeLunch = sessionData['end_time_lunch'] as String;
                final right = sessionData['right'] as bool;
                final startDateTime = DateTime.parse(startTime);
                final vrsta = sessionData['vrsta'] as String;
                final napravaPrijava = sessionData['napravaPrijava'] as String;
                final napravaOdjava = sessionData['napravaOdjava'] as String;
                final prijavaLatitude =
                    sessionData['lokacija_prijave_latitude'] as String;
                final prijavaLongitude =
                    sessionData['lokacija_prijave_longitude'] as String;
                final odjavaLatitude =
                    sessionData['lokacija_odjave_latitude'] as String;
                final odjavaLongitude =
                    sessionData['lokacija_odjave_longitude'] as String;
                final datumStempla = sessionData['start_time'] as String;

                if (startDateTime.isAfter(startDate) &&
                    startDateTime.isBefore(endDate)) {
                  final formattedStartTime =
                      DateFormat('yyyy-MM-dd HH:mm:ss').format(startDateTime);
                  final formattedEndTime = DateFormat('yyyy-MM-dd HH:mm:ss')
                      .format(DateTime.parse(endTime));

                  return 'Start Time: $formattedStartTime\nEnd Time: $formattedEndTime\nStart Time Lunch: $startTimeLunch\nEnd Time Lunch: $endTimeLunch\nStart Time Card: $startTimecard\nEnd Time Card: $endTimecard\n$comapnyId\nRight:$right\n$username\n$vrsta\n$prijavaLatitude\n$prijavaLongitude\n$odjavaLatitude\n$odjavaLongitude\n$napravaPrijava\n$napravaOdjava\n$datumStempla';
                }
              }

              return null;
            })
            .where((text) => text != null)
            .toList();

        List<WorkSession> workSessionsList =
            sessionTexts.map((text) => WorkSession(text!)).toList();

        workSessionsList.sort((a, b) {
          final DateTime startTimeCardA = DateTime.parse(a.datumStempla);
          final DateTime startTimeCardB = DateTime.parse(b.datumStempla);

          return startTimeCardB.compareTo(startTimeCardA);
        });

        setState(() {
          _workSessions = workSessionsList;
        });
      } else {
        setState(() {
          _workSessions.clear();
        });
      }
    });
  }

  void _showWorkSessionsForCurrentUser({
    bool setDate = false,
  }) {
    final DatabaseReference workSessionsRef =
        FirebaseDatabase.instance.reference().child('work_sessions');

    DateTime startDate;
    DateTime endDate;
    startDate = _selectedWeekStart;
    endDate = _selectedWeekEnd;
    workSessionsRef
        .orderByChild('end_time')
        .startAt('')
        .endAt('\uf8ff')
        .onValue
        .listen((event) {
      final Map<dynamic, dynamic> sessionsData =
          event.snapshot.value as Map<dynamic, dynamic>;
      // ignore: unnecessary_null_comparison
      if (sessionsData != null) {
        final List<String?> sessionTexts = sessionsData.entries
            .map((entry) {
              final sessionData = entry.value as Map<dynamic, dynamic>;

              final username = sessionData['username'] as String;
              final endTime = sessionData['end_time'] as String;
              final comapnyId = sessionData['companyid'] as String;
              // Check if 'end_time' is not null
              if (comapnyId == currentcompanyid) {
                final startTime = sessionData['start_time'] as String;
                final startTimecard = sessionData['start_time'] as String;
                final endTimecard = sessionData['end_time'] as String;
                final startTimeLunch =
                    sessionData['start_time_lunch'] as String;
                final endTimeLunch = sessionData['end_time_lunch'] as String;
                final right = sessionData['right'] as bool;
                final startDateTime = DateTime.parse(startTime);
                final vrsta = sessionData['vrsta'] as String;
                final napravaPrijava = sessionData['napravaPrijava'] as String;
                final napravaOdjava = sessionData['napravaOdjava'] as String;
                final prijavaLatitude =
                    sessionData['lokacija_prijave_latitude'] as String;
                final prijavaLongitude =
                    sessionData['lokacija_prijave_longitude'] as String;
                final odjavaLatitude =
                    sessionData['lokacija_odjave_latitude'] as String;
                final odjavaLongitude =
                    sessionData['lokacija_odjave_longitude'] as String;
                final datumStempla = sessionData['start_time'] as String;

                if (startDateTime.isAfter(startDate) &&
                    startDateTime.isBefore(endDate)) {
                  final formattedStartTime =
                      DateFormat('yyyy-MM-dd HH:mm:ss').format(startDateTime);
                  final formattedEndTime = DateFormat('yyyy-MM-dd HH:mm:ss')
                      .format(DateTime.parse(endTime));

                  return 'Start Time: $formattedStartTime\nEnd Time: $formattedEndTime\nStart Time Lunch: $startTimeLunch\nEnd Time Lunch: $endTimeLunch\nStart Time Card: $startTimecard\nEnd Time Card: $endTimecard\n$comapnyId\nRight:$right\n$username\n$vrsta\n$prijavaLatitude\n$prijavaLongitude\n$odjavaLatitude\n$odjavaLongitude\n$napravaPrijava\n$napravaOdjava\n$datumStempla';
                }
              }

              return null;
            })
            .where((text) => text != null)
            .toList();

        List<WorkSession> workSessionsList =
            sessionTexts.map((text) => WorkSession(text!)).toList();

        workSessionsList.sort((a, b) {
          final DateTime startTimeCardA = DateTime.parse(a.datumStempla);
          final DateTime startTimeCardB = DateTime.parse(b.datumStempla);

          return startTimeCardB.compareTo(startTimeCardA);
        });

        setState(() {
          _workSessions = workSessionsList;
        });
      } else {
        setState(() {
          _workSessions.clear();
        });
      }
    });
  }

  final DatabaseReference _databaseRef = FirebaseDatabase.instance.reference();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });

      _showWorkSessionsForCurrentUserDay(
        setDate: true,
        selectedDate: _selectedDate,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime currentDate = DateTime.now();
    int datet = _selectedDate.day;
    EdgeInsets padding = MediaQuery.of(context).padding;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double size = screenHeight / screenWidth;

    // Access the top padding
    double topPadding = padding.top;
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
                      'ARHIV VSEH DELAVNIH UR',
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_left,
                            size: screenHeight * 0.0376), // Adjust the size
                        onPressed: () {
                          _selectedWeekStart = _selectedWeekStart
                              .subtract(const Duration(days: 7));
                          _selectedWeekEnd = _selectedWeekEnd
                              .subtract(const Duration(days: 7));
                          _showWorkSessionsForCurrentUser();
                        },
                      ),
                      Text(
                        kIsWeb
                            ? '${DateFormat.MMMd('sl_SI').format(_selectedWeekStart.add(const Duration(days: 0)))}'
                            : '${DateFormat.MMMd('sl_SI').format(_selectedWeekStart.add(const Duration(days: 1)))}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize:
                                screenHeight * 0.0256), // Adjust the fontSize
                      ),
                      const Text('   -   ',
                          style:
                              TextStyle(fontSize: 20.0)), // Adjust the fontSize
                      Text(
                        kIsWeb
                            ? '${DateFormat.MMMd('sl_SI').format(_selectedWeekEnd.add(const Duration(days: -1)))}'
                            : '${DateFormat.MMMd('sl_SI').format(_selectedWeekEnd.add(const Duration(days: 0)))}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize:
                                screenHeight * 0.0256), // Adjust the fontSize
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_right,
                            size: screenHeight * 0.0376), // Adjust the size
                        onPressed: !(currentDate.isAfter(_selectedWeekStart) &&
                                currentDate.isBefore(_selectedWeekEnd))
                            ? () {
                                _selectedWeekStart = _selectedWeekStart
                                    .add(const Duration(days: 7));
                                _selectedWeekEnd = _selectedWeekEnd
                                    .add(const Duration(days: 7));
                                _showWorkSessionsForCurrentUser();
                              }
                            : null,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                  Stack(
                    children: [
                      Column(
                        children: [
                          SizedBox(height: screenHeight * 0.012),
                          Text(
                            datet >= 1 && datet <= 9 ? '   $datet' : '  $datet',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: screenHeight *
                                    0.0201), // Adjust the fontSize
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(width: screenHeight * 0.0025),
                          InkWell(
                            onTap: () => _selectDate(context),
                            child: Icon(
                              Icons.calendar_today,
                              color: Colors.blue,
                              size: screenHeight * 0.04,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '    Datum',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: screenHeight * 0.0201),
                ),
                Text(
                  'Trajanje      .',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: screenHeight * 0.0201),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                
                padding: EdgeInsets.zero, // Add this line to remove padding

                shrinkWrap: true,
                itemCount: _workSessions.length,
                itemBuilder: (context, index) {
                  return WorkSessionCard(
                    startTime: _workSessions[index].startTime,
                    endTime: _workSessions[index].endTime,
                    endTimeLunch: _workSessions[index].endTimeLunch,
                    startTimeLunch: _workSessions[index].startTimeLunch,
                    startTimecard: _workSessions[index].startTimecard,
                    endTimecard: _workSessions[index].endTimecard,
                    right: _workSessions[index].right,
                    username: _workSessions[index].username,
                    screenHeight: screenHeight,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    ));
  }
}

void showSessionDetailsDialog(
    BuildContext context,
    String startTime,
    String endTime,
    String startTimeLunch,
    String endTimeLunch,
    String startTimecard,
    String endTimecard,
    bool right,
    String username) async {
  String imeInPriimek = await _fetchUserName(username);
showDialog(
  context: context,
  builder: (BuildContext context) {
    return AlertDialog(
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Prihodi/Odhodi"),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      content: Container(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
             _buildCustomListTile("Delavec:", imeInPriimek, Color.fromARGB(197, 255, 202, 103)),

            _buildCustomListTile("Začetek dela:", startTimecard, Colors.blue),
            _buildCustomListTile("Konec dela:", endTimecard, Colors.blue),
            _buildCustomListTile("Začetek malice:", startTimeLunch, Colors.grey),
            _buildCustomListTile("Konec malice:", endTimeLunch, Colors.grey),
          ],
        ),
      ),
    );
  },
);

}
Widget _buildCustomListTile( String text1, String text2, Color color) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    decoration: BoxDecoration(
      color: color.withOpacity(0.2),
      borderRadius: BorderRadius.circular(8.0),
      border: Border.all(
        color: color.withOpacity(0.5),
        width: .0,
      ),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.3),
          spreadRadius: 0.1,
          blurRadius: 0.11,
          offset: const Offset(0, 0),
        ),
      ],
    ),
    child: ListTile(
      
      title:  Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(text1),
    Spacer(), // Adds space between Text widgets
    Text(text2),
  ],
)

    ),
  );
}

Future<String> _fetchUserName(String username) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    var userReference =
        FirebaseDatabase.instance.reference().child('users/$username');

    try {
      final snapshot = await userReference.once();

      if (snapshot.snapshot.value != null) {
        final userData = snapshot.snapshot.value as Map<dynamic, dynamic>;
        final name = userData['name'];
        final surname = userData['surname'];

        return '$name $surname';
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  return '';
}

class WorkSessionCard extends StatelessWidget {
  final String startTime;
  final String endTime;
  final String startTimeLunch;
  final String endTimeLunch;
  final String startTimecard;
  final String endTimecard;
  final bool right;
  final String username;
  final double screenHeight;

  const WorkSessionCard({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.endTimeLunch,
    required this.startTimeLunch,
    required this.startTimecard,
    required this.endTimecard,
    required this.right,
    required this.username,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    Color cardColor = right == false
        ? const Color.fromARGB(255, 198, 198, 198)
        : Colors.white;

    return InkWell(
      onTap: () {
        // Show the session details dialog here
        showSessionDetailsDialog(
          context,
          startTime,
          endTime,
          startTimeLunch,
          endTimeLunch,
          startTimecard,
          endTimecard,
          right,
          username,
        );
      },
      child: Card(
        color: cardColor, // Use the calculated card color
        margin: EdgeInsets.all(screenHeight * 0.01015),
        child: Padding(
          padding: EdgeInsets.all(screenHeight * 0.0201),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    startTime, // Formatted date like "27 Oct"
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenHeight * 0.0201),
                  ),
                  FutureBuilder<String>(
                    future: _fetchUserName(username),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(fontSize: screenHeight * 0.0201),
                        );
                      } else {
                        String userName = snapshot.data ?? '';
                        return Text(
                          userName,
                          style: TextStyle(fontSize: screenHeight * 0.0201),
                        );
                      }
                    },
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    endTime, // Time difference in the format "hh hours mm minutes"
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenHeight * 0.0201),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WorkSession {
  final String text;

  WorkSession(this.text);

  // Existing methods for formatting dates and durations
  String getFormattedDate(String dateTimeString) {
    try {
      final DateTime parsedDateTime = DateTime.parse(dateTimeString);
      final String formattedDate = DateFormat('d MMM').format(parsedDateTime);
      return formattedDate;
    } catch (e) {
      print('Error parsing date: $e');
    }

    return 'Invalid Date';
  }

  String getFormattedTimeDifference(String startTime, String endTime) {
    try {
      final DateTime startDateTime = DateTime.parse(startTime);
      final DateTime endDateTime = DateTime.parse(endTime);
      final Duration difference = endDateTime.difference(startDateTime);
      final int hours = difference.inHours;
      final int minutes = difference.inMinutes.remainder(60);
      return '$hours:${minutes.toString().padLeft(2, '0')}'; // Format as "hh:mm"
    } catch (e) {
      print('Error calculating time difference: $e');
    }

    return 'Invalid Time Difference';
  }

  String get startTime {
    final parts = text.split('\n');
    final startTime = parts[0].replaceAll('Start Time: ', '');
    return getFormattedDate(startTime);
  }

  String get datumStempla {
    final parts = text.split('\n');
    final datumStempla = parts[16].replaceAll('', '');
    return datumStempla;
  }

  String get endTime {
    final parts = text.split('\n');
    final endTime = parts[1].replaceAll('End Time: ', '');
    return getFormattedTimeDifference(
      parts[0].replaceAll('Start Time: ', ''),
      parts[1].replaceAll('End Time: ', ''),
    );
  }

  String get startTimeLunch {
    final parts = text.split('\n');
    if (parts.length >= 4) {
      final startTimeLunch = parts[2].replaceAll('Start Time Lunch: ', '');
      // Extract the time part from the full DateTime
      final time =
          DateFormat('HH:mm:ss').format(DateTime.parse(startTimeLunch));
      return time;
    }
    return 'N/A';
  }

  String get username {
    final parts = text.split('\n');
    if (parts.length >= 4) {
      final username = parts[8].replaceAll('', '');
      // Extract the time part from the full DateTime

      return username;
    }
    return 'N/A';
  }

  String get startTimecard {
    final parts = text.split('\n');
    if (parts.length >= 6) {
      final startTimecard = parts[4].replaceAll('Start Time Card: ', '');
      // Extract the time part from the full DateTime
      final time = DateFormat('HH:mm:ss').format(DateTime.parse(startTimecard));
      return time;
    }
    return 'N/A';
  }

  String get endTimecard {
    final parts = text.split('\n');
    if (parts.length >= 6) {
      final endTimecard = parts[5].replaceAll('End Time Card: ', '');
      // Extract the time part from the full DateTime
      final time = DateFormat('HH:mm:ss').format(DateTime.parse(endTimecard));
      return time;
    }
    return 'N/A';
  }

  String get endTimeLunch {
    final parts = text.split('\n');
    if (parts.length >= 4) {
      final endTimeLunch = parts[3].replaceAll('End Time Lunch: ', '');
      // Extract the time part from the full DateTime
      final time = DateFormat('HH:mm:ss').format(DateTime.parse(endTimeLunch));
      return time;
    }
    return 'N/A';
  }

  bool get right {
    final parts = text.split('\n');
    for (String part in parts) {
      if (part.startsWith('Right:')) {
        final value = part.replaceAll('Right:', '').trim();
        if (value == 'true') {
          return true;
        } else if (value == 'false') {
          return false;
        }
      }
    }

    print('Right attribute not found'); // Add this line for debugging
    return false; // Default value if 'Right:' attribute is not found
  }
}
