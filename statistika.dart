// ignore_for_file: unused_field, unused_local_variable, library_private_types_in_public_api, deprecated_member_use, empty_catches
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class StatisticPage extends StatefulWidget {
  final double screenHeight;
  final double screenWidth;

  const StatisticPage(
      {super.key, required this.screenHeight, required this.screenWidth});

  @override
  _StatisticPageState createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  String _userId = '';
  DateTime _selectedDate = DateTime.now();
  double screenHeight = 0;
  double screenWidth = 0;

  DateTime _selectedWeekStart = DateTime.now();
  DateTime _selectedWeekEnd = DateTime.now();

  User? currentUser;
  final int _currentIndex = 0;
  bool isAdmin = false;
  List<WorkSession> _workSessions = [];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('sl_SI', null); // Initialize for Slovenian locale
    screenHeight = widget.screenHeight;
    screenWidth = widget.screenWidth;
    final User? user = FirebaseAuth.instance.currentUser;
    nastaviDan();
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
      _showWorkSessionsForCurrentUser(setDate: false);
    }
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
        return snapshot.snapshot.value as bool;
      }

      return false;
    } catch (e) {
      return false;
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

              // Check if 'end_time' is not null
              if (username == _userId) {
                final startTime = sessionData['start_time'] as String;
                final startTimecard = sessionData['start_time'] as String;
                final endTimecard = sessionData['end_time'] as String;
                final startTimeLunch =
                    sessionData['start_time_lunch'] as String;
                final endTimeLunch = sessionData['end_time_lunch'] as String;
                final comapnyId = sessionData['companyid'] as String;
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
    DateTime? selectedDate,
  }) {
    final DatabaseReference workSessionsRef =
        FirebaseDatabase.instance.reference().child('work_sessions');

    DateTime startDate;
    DateTime endDate;

    if (setDate && selectedDate != null) {
      // Calculate the start of the week based on the selected date (Monday)
      startDate = selectedDate
          .subtract(Duration(days: selectedDate.weekday - DateTime.monday + 1));
      // Calculate the end of the week based on the selected date (Sunday)
      endDate = startDate.add(const Duration(days: 6));
    } else {
      // Calculate the start of the current week (Monday)
      startDate = DateTime.now().subtract(
          Duration(days: DateTime.now().weekday - DateTime.monday - 1));
      // Calculate the end of the current week (Sunday)
      endDate = startDate.add(const Duration(days: 6));
    }
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

              // Check if 'end_time' is not null
              if (username == _userId) {
                final startTime = sessionData['start_time'] as String;
                final startTimecard = sessionData['start_time'] as String;
                final endTimecard = sessionData['end_time'] as String;
                final startTimeLunch =
                    sessionData['start_time_lunch'] as String;
                final endTimeLunch = sessionData['end_time_lunch'] as String;
                final comapnyId = sessionData['companyid'] as String;
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

  void _updateWeek(int days) {
    _selectedWeekStart = _selectedWeekStart.add(Duration(days: days));
    _selectedWeekEnd = _selectedWeekEnd.add(Duration(days: days));
    _showWorkSessionsForCurrentUser();
  }

// Helper function to build the date range widget
  Widget _buildDateRange() {
    return Row(
      children: [
        Text(
          kIsWeb
              ? DateFormat.MMMd('sl_SI')
                  .format(_selectedWeekStart.add(Duration(days: 0)))
              : DateFormat.MMMd('sl_SI')
                  .format(_selectedWeekStart.add(Duration(days: 1))),
          style:  TextStyle(fontWeight: FontWeight.bold, fontSize: screenHeight*0.0245),
        ),
         Text('   -   ', style: TextStyle(fontSize: screenHeight*0.0256)),
        Text(
          kIsWeb
              ? DateFormat.MMMd('sl_SI')
                  .format(_selectedWeekEnd.add(Duration(days: -1)))
              : DateFormat.MMMd('sl_SI')
                  .format(_selectedWeekEnd.add(Duration(days: 0))),
          style:  TextStyle(fontWeight: FontWeight.bold, fontSize: screenHeight*0.0245),
        ),
      ],
    );
  }

// Helper function to build the date with calendar icon widget
  Widget _buildDateWithCalendarIcon() {
    DateTime danasnjidatum = DateTime.now();
    int datet = danasnjidatum.day;
    double size=screenHeight/screenWidth;
    return
     Stack(
      children: [
        Column(
          children: [
            SizedBox(height: screenHeight *0.012),
            Text(
              datet >= 1 && datet <= 9 ? '   $datet' : '  $datet',
              style:  TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenHeight*0.0201), // Adjust the fontSize
            ),
          ],
        ),
        Row(
          children: [
            SizedBox(width: screenHeight*0.0025),
            InkWell(
              onTap: () => _selectDate(context),
              child: Icon(
                Icons.calendar_today,
                color: Colors.blue,
                size: screenHeight*0.04,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime currentDate = DateTime.now();
    EdgeInsets padding = MediaQuery.of(context).padding;
    double topPadding = padding.top;
    screenHeight = widget.screenHeight;
    screenWidth = widget.screenWidth;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color.fromARGB(199, 119, 192, 252), Colors.white],
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              children: [
                Container(
                  color: Colors.black,
                  height: topPadding,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon:  Icon(Icons.arrow_left, size: screenHeight* 0.0376),
                        onPressed: () => _updateWeek(-7),
                      ),
                      _buildDateRange(),
                      IconButton(
                        icon:  Icon(Icons.arrow_right, size: screenHeight* 0.0376),
                        onPressed: !(currentDate.isAfter(_selectedWeekStart) &&
                                currentDate.isBefore(_selectedWeekEnd))
                            ? () {
                                _updateWeek(7);
                              }
                            : null,
                      ),
                       SizedBox(width: screenWidth*0.026),
                      _buildDateWithCalendarIcon(),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text('Datum', textAlign: TextAlign.left,style: TextStyle(fontSize: screenHeight*0.0201),),
                    ),
                    Spacer(), // This will push the next widget (Text) to the right edge
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Text('Trajanje', textAlign: TextAlign.right,style: TextStyle(fontSize: screenHeight*0.0201),),
                    ),
                  ],
                ),                SizedBox(height: 10,)
,
                Expanded(
                  child: ListView.builder(
                                      padding: EdgeInsets.zero,  // Add this line to remove padding

                    shrinkWrap: true,
                    itemCount: _workSessions.length,
                    itemBuilder: (context, index) => WorkSessionCard(
                      startTime: _workSessions[index].startTime,
                      endTime: _workSessions[index].endTime,
                      endTimeLunch: _workSessions[index].endTimeLunch,
                      startTimeLunch: _workSessions[index].startTimeLunch,
                      startTimecard: _workSessions[index].startTimecard,
                      endTimecard: _workSessions[index].endTimecard,
                      right: _workSessions[index].right,
                      screenHeight: screenHeight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

// Helper function to update the selected week
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
    bool right) {
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

class WorkSessionCard extends StatelessWidget {
  final String startTime;
  final String endTime;
  final String startTimeLunch;
  final String endTimeLunch;
  final String startTimecard;
  final String endTimecard;
  final bool right;
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
        );
      },
      child: Card(
        color: cardColor, // Use the calculated card color
        margin:  EdgeInsets.all(screenHeight*0.01015),
        child: Padding(
          padding:  EdgeInsets.all(screenHeight*0.0201),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    startTime, // Formatted date like "27 Oct"
                    style:  TextStyle(fontWeight: FontWeight.bold,fontSize: screenHeight*0.0245),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    endTime, // Time difference in the format "hh hours mm minutes"
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: screenHeight*0.0245),
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
      final String formattedDate =
          DateFormat.MMMd('sl_SI').format(parsedDateTime);
      return formattedDate;
    } catch (e) {}

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
    } catch (e) {}

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

    return false; // Default value if 'Right:' attribute is not found
  }
}
