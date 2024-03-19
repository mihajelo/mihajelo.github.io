// ignore_for_file: deprecated_member_use, avoid_print, unused_local_variable, unnecessary_null_comparison, library_private_types_in_public_api

import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

class EmployeeEditPage extends StatefulWidget {
  final String selectedUserId;

  const EmployeeEditPage({super.key, required this.selectedUserId});

  @override
  _EmployeeEditPageState createState() => _EmployeeEditPageState();
}

var username = '';
String dateMonth = '';
DateTime exportOd = DateTime.now();
DateTime exportDo = DateTime.now();
var companyUid = '';
bool loadingExcel = false;

class WorkSessionExcel {
  final String startTime;
  final String endTime;
  final String companyid;
  final String startTimeLunch;
  final String endTimeLunch;
  final String wokrHours;
  final String lunchTime;
  final String date;
  final String vrsta;

  WorkSessionExcel(
      {required this.startTime,
      required this.endTime,
      required this.companyid,
      required this.startTimeLunch,
      required this.endTimeLunch,
      required this.wokrHours,
      required this.lunchTime,
      required this.date,
      required this.vrsta});
}

class _EmployeeEditPageState extends State<EmployeeEditPage> {
  String _userId = '';
  DateTime _selectedDate = DateTime.now();

  User? currentUser;
  String sprememba = '';

  late DatabaseReference _userReference;
  var username = '';
  String dateMonth = '';

  DateTime exportOd = DateTime.now();
  DateTime exportDo = DateTime.now();
  var companyUid = '';
  late String userId; // Add this variable
  List<WorkSessionExcel> workSessionsExcel = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late int selectedYear;
  late int selectedMonth;

  DateTime _selectedWeekStart = DateTime.now();
  DateTime _selectedWeekEnd = DateTime.now();

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

  List<WorkSession> _workSessions = [];
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('sl_SI', null); // Initialize for Slovenian locale
    initializeDateFormatting('sl_SI', null); // Initialize for Slovenian locale

    userId = widget.selectedUserId;
    initializeData();
    nastaviDan();

    DateTime now = DateTime.now();
    selectedYear = now.year;
    selectedMonth = now.month;
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = widget.selectedUserId;
        sprememba = user.uid;
      });
    }
    _showWorkSessionsForCurrentUser();
    // Fetch the user's name and surname and set them as the app bar title
    fetchUserNameAndSurname(_userId).then((userInfo) {
      if (userInfo != null) {
        setState(() {
          _userName = '${userInfo['name']} ${userInfo['surname']}';
        });
      }
    });
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
      await _fetchUserData();
    }
    final userId = widget.selectedUserId;
    checkStoragePermission();
    fetchWorkSessions(
        userId, updateDateTimeObjectDan1(), updateDateTimeObjectDan2());
  }

  List<int> getYears() {
    int currentYear = DateTime.now().year;
    return List.generate(5, (index) => currentYear - index);
  }

  List<String> getMonths() {
    return List.generate(12, (index) => '${index + 1}');
  }

  Future<String> getCompanyName() async {
    try {
      final DatabaseReference companiesRef =
          FirebaseDatabase.instance.reference().child('companies');

      // Assuming `companyUid` is the key you want to query
      DatabaseEvent event =
          await companiesRef.orderByKey().equalTo(companyUid).once();

      // Extract the DataSnapshot from the DatabaseEvent
      DataSnapshot snapshot = event.snapshot;

      // Check if the snapshot has data
      if (snapshot.value != null) {
        // Extract company data from the snapshot
        Map<dynamic, dynamic> companyData =
            snapshot.value as Map<dynamic, dynamic>;

        // Assuming you want the name property, replace 'name' with the actual property you need
        String companyName = companyData[companyUid]['name'];

        // Return the company name
        return companyName;
      } else {
        // Handle the case where no data is found
        return 'Company not found';
      }
    } catch (error) {
      // Handle any errors that might occur during the data retrieval
      return 'Error getting company name';
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
            username = '$name $surname';
            companyUid = companyId;
          });
        }
      }
    }
  }

  Future<String> _fetchUserName(userexport) async {
    final user = FirebaseAuth.instance.currentUser;

    _userReference =
        FirebaseDatabase.instance.reference().child('users/$userexport');
    final snapshot = await _userReference.once();

    final userData = snapshot.snapshot.value as Map<dynamic, dynamic>;
    final name = userData['name'];
    final surname = userData['surname'];
    final username = ('$surname $name');

    return username;
  }

  DateTime updateDateTimeObjectDan1() {
    DateTime firstDayOfMonth = DateTime(selectedYear, selectedMonth, 1);
    return firstDayOfMonth;
  }

  DateTime updateDateTimeObjectDan2() {
    DateTime lastDayOfMonth = DateTime(selectedYear, selectedMonth + 1, 1);
    return lastDayOfMonth;
  }

  Future<void> fetchWorkSessions(oseba, exportOd, exportDo) async {
    final DatabaseReference workSessionsRef =
        FirebaseDatabase.instance.reference().child('work_sessions');
    DateTime startDate = exportOd;
    DateTime endDate = exportDo;

    workSessionsRef
        .orderByChild('username')
        .equalTo(userId)
        .onValue
        .listen((event) {
      final Map<dynamic, dynamic> sessionsData =
          event.snapshot.value as Map<dynamic, dynamic>;

      if (sessionsData != null) {
        final List<String?> sessionTexts = sessionsData.entries
            .map((entry) {
              final sessionData = entry.value;

              // Check if the 'right' attribute is true
              if (sessionData['right'] == true) {
                final vrsta = sessionData['vrsta'] as String;
                final date = sessionData['start_time'] as String;
                final startTime = sessionData['start_time'] as String;
                final endTime = sessionData['end_time'] as String;
                final startTimeTime = DateTime.parse(sessionData['start_time']);
                final endTimeTime = DateTime.parse(sessionData['end_time']);
                final startTimeLunchTime =
                    DateTime.parse(sessionData['start_time_lunch']);
                final endTimeLunchTime =
                    DateTime.parse(sessionData['end_time_lunch']);
                final companyid = sessionData['companyid'];
                Duration lunchTime =
                    endTimeLunchTime.difference(startTimeLunchTime);
                Duration workHours = endTimeTime.difference(startTimeTime);
                String formatedDate =
                    DateFormat('yyyy-MM-dd').format(DateTime.parse(date));
                String formattedDateMonth =
                    DateFormat('yyyy-MM').format(DateTime.parse(date));
                String formattedWorkHours = DateFormat.Hms().format(
                  DateTime(
                      0,
                      1,
                      1,
                      workHours.inHours,
                      workHours.inMinutes.remainder(60),
                      workHours.inSeconds.remainder(60)),
                );
                String formattedLunchHours = DateFormat.Hms().format(
                  DateTime(
                      0,
                      1,
                      1,
                      lunchTime.inHours,
                      lunchTime.inMinutes.remainder(60),
                      lunchTime.inSeconds.remainder(60)),
                );

                if (sessionData['start_time'] is String) {
                  final startdateTime =
                      DateTime.parse(sessionData['start_time'] as String);
                  if (startdateTime.isAfter(startDate) &&
                      startdateTime.isBefore(endDate)) {
                    // Your logic here

                    String formattedStartTime =
                        DateFormat('HH:mm').format(DateTime.parse(startTime));
                    String formattedEndTime =
                        DateFormat('HH:mm').format(DateTime.parse(endTime));
                    String formattedStartTimeLunch =
                        DateFormat('HH:mm').format(startTimeLunchTime);
                    String formattedEndTimeLunch =
                        DateFormat('HH:mm').format(endTimeLunchTime);
                    setState(() {
                      dateMonth = formattedDateMonth;
                    });

                    return '$formattedStartTime\n$formattedEndTime\n$formattedWorkHours\n$formattedStartTimeLunch\n$formattedEndTimeLunch\n$formattedLunchHours\n$formatedDate\n$companyid\n$vrsta';
                  }
                }
              }

              return null;
            })
            .where((text) => text != null)
            .toList();

        List<WorkSessionExcel> workSessionsExcelList = sessionTexts
            .map((text) => WorkSessionExcel(
                  startTime: text!.split('\n')[0].substring(0),
                  endTime: text.split('\n')[1].substring(0),
                  startTimeLunch: text.split('\n')[3].substring(0),
                  endTimeLunch: text.split('\n')[4].substring(0),
                  wokrHours: text.split('\n')[2].substring(0),
                  lunchTime: text.split('\n')[5].substring(0),
                  date: text.split('\n')[6].substring(0),
                  companyid: text.split('\n')[7].substring(0),
                  vrsta: text.split('\n')[8].substring(0),
                ))
            .toList();

        workSessionsExcelList.sort((a, b) {
          final DateTime startTimeA = DateTime.parse(a.date);
          final DateTime startTimeB = DateTime.parse(b.date);
          return startTimeA.compareTo(startTimeB);
        });
        setState(() {
          workSessionsExcel = workSessionsExcelList;
        });
      } else {
        setState(() {
          workSessionsExcel.clear();
        });
      }
    });
  }

  void generateExcelOseba(
      DateTime exportOd, DateTime exportDo, String filename) async {
    // Use the 'xlsio' alias for Workbook
    setState(() {
      loadingExcel = true;
    });
    xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];
    final String formattedMonth = DateFormat.yMMMM('sl_SI').format(exportOd);
    final delavec = await _fetchUserName(userId);
    fetchWorkSessions(
        userId, updateDateTimeObjectDan1(), updateDateTimeObjectDan2());

    // Create a bold font style
    sheet.getRangeByIndex(1, 1).setText('Izvoz delavnih ur za osebo:');
    sheet.getRangeByIndex(1, 2).setText(delavec);

    sheet.getRangeByIndex(2, 1).setText('Šifra');
    sheet.getRangeByIndex(2, 2).setText(userId);

    // Append the first row with the bold style
    sheet.getRangeByIndex(3, 1).setText('Za mesec:');
    sheet.getRangeByIndex(3, 2).setText(formattedMonth);

    sheet.getRangeByIndex(4, 1).setText('Datum');
    sheet.getRangeByIndex(4, 2).setText('Vrsta dela');
    sheet.getRangeByIndex(4, 3).setText('Prihod na delo');
    sheet.getRangeByIndex(4, 4).setText('Odhod z dela');
    sheet.getRangeByIndex(4, 5).setText('Trajanje dela');
    sheet.getRangeByIndex(4, 6).setText('Začetek malice');
    sheet.getRangeByIndex(4, 7).setText('Konec malice');
    sheet.getRangeByIndex(4, 8).setText('Trajanje malice');

    // Append the data rows
    int rowIndes = 5;
    for (var workSession in workSessionsExcel) {
      sheet.getRangeByIndex(rowIndes, 1).setText(workSession.date);
      sheet.getRangeByIndex(rowIndes, 2).setText(workSession.vrsta);
      sheet.getRangeByIndex(rowIndes, 3).setText(workSession.startTime);
      sheet.getRangeByIndex(rowIndes, 4).setText(workSession.endTime);
      sheet.getRangeByIndex(rowIndes, 5).setText(workSession.wokrHours);
      sheet.getRangeByIndex(rowIndes, 6).setText(workSession.startTimeLunch);
      sheet.getRangeByIndex(rowIndes, 7).setText(workSession.endTimeLunch);
      sheet.getRangeByIndex(rowIndes, 8).setText(workSession.lunchTime);

      rowIndes++;
    }
    for (int rowIndex = 1; rowIndex <= 11; rowIndex++) {
      sheet.autoFitRow(rowIndex);
    }

    final String path = (await getApplicationSupportDirectory()).path;
    final String fileName = '$path/$delavec _ $formattedMonth.xlsx';

    // Ensure the directory exists
    Directory(path).createSync(recursive: true);

    final List<int> bytes = workbook.saveAsStream();
    final File file = File(fileName);
    await file.writeAsBytes(bytes, flush: true);

    workbook.dispose();
    setState(() {
      loadingExcel = false;
    });
    // Open the saved Excel file
    OpenFile.open(fileName);
  }

  Future<Map<String, String>?> fetchUserNameAndSurname(String userId) async {
    final DatabaseReference usersRef =
        FirebaseDatabase.instance.reference().child('users');
    final DatabaseEvent snapshot = await usersRef.child(userId).once();
    final Map<dynamic, dynamic>? userData =
        snapshot.snapshot.value as Map<dynamic, dynamic>?;
    if (userData != null) {
      final String name = userData['name'] as String;
      final String surname = userData['surname'] as String;
      return {'name': name, 'surname': surname};
    }
    return null;
  }

  void _showWorkSessionsForCurrentUser({
    bool setDate = false,
    DateTime? selectedDate,
  }) {
    // Ignore: deprecated_member_use
    final DatabaseReference workSessionsRef =
        FirebaseDatabase.instance.reference().child('work_sessions');

    DateTime startDate;
    DateTime endDate;

    if (setDate && selectedDate != null) {
      // Calculate the start of the week based on the selected date (Monday)
      startDate = selectedDate
          .subtract(Duration(days: selectedDate.weekday - DateTime.monday));
      // Calculate the end of the week based on the selected date (Sunday)
      endDate = startDate.add(const Duration(days: 7));
    } else {
      // Calculate the start of the current week (Monday)
      startDate = DateTime.now()
          .subtract(Duration(days: DateTime.now().weekday - DateTime.monday));
      // Calculate the end of the current week (Sunday)
      endDate = startDate.add(const Duration(days: 7));
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
      if (sessionsData != null) {
        final List<String?> sessionTexts = sessionsData.entries
            .map((entry) {
              final sessionData = entry.value as Map<dynamic, dynamic>;
              final username = sessionData['username'] as String;
              final endTime = sessionData['end_time'] as String;

              // Check if 'end_time' is not null
              if (username == _userId) {
                final sessionId = entry.key as String; // Extract session ID

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
                final sprememba = sessionData['sprememba'] as String;

                if (startDateTime.isAfter(startDate) &&
                    startDateTime.isBefore(endDate)) {
                  final formattedStartTime =
                      DateFormat('yyyy-MM-dd HH:mm:ss').format(startDateTime);
                  final formattedEndTime = DateFormat('yyyy-MM-dd HH:mm:ss')
                      .format(DateTime.parse(endTime));

                  return 'Start Time: $formattedStartTime\nEnd Time: $formattedEndTime\nStart Time Lunch: $startTimeLunch\nEnd Time Lunch: $endTimeLunch\nStart Time Card: $startTimecard\nEnd Time Card: $endTimecard\n$comapnyId\nRight:$right\n$username\n$vrsta\n$prijavaLatitude\n$prijavaLongitude\n$odjavaLatitude\n$odjavaLongitude\n$napravaPrijava\n$napravaOdjava\n$datumStempla\n$sprememba\n$sessionId';
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

  void _showWorkSessionsForCurrentUserDay({
    bool setDate = false,
    DateTime? selectedDate,
  }) {
    // Ignore: deprecated_member_use
    final DatabaseReference workSessionsRef =
        FirebaseDatabase.instance.reference().child('work_sessions');

    DateTime startDate;
    DateTime endDate;

    if (setDate && selectedDate != null) {
      startDate = selectedDate;
      endDate = selectedDate.add(const Duration(days: 1));
    } else {
      startDate = _selectedWeekStart;
      endDate = _selectedWeekEnd;
    }

    workSessionsRef
        .orderByChild('end_time')
        .startAt('')
        .endAt('\uf8ff')
        .onValue
        .listen((event) {
      final Map<dynamic, dynamic> sessionsData =
          event.snapshot.value as Map<dynamic, dynamic>;
      if (sessionsData != null) {
        final List<String?> sessionTexts = sessionsData.entries
            .map((entry) {
              final sessionData = entry.value as Map<dynamic, dynamic>;
              final username = sessionData['username'] as String;
              final endTime = sessionData['end_time'] as String;
              final sessionId = entry.key as String; // Extract session ID


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
                final sprememba = sessionData['sprememba'] as String;
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

                  return 'Start Time: $formattedStartTime\nEnd Time: $formattedEndTime\nStart Time Lunch: $startTimeLunch\nEnd Time Lunch: $endTimeLunch\nStart Time Card: $startTimecard\nEnd Time Card: $endTimecard\n$comapnyId\nRight:$right\n$username\n$vrsta\n$prijavaLatitude\n$prijavaLongitude\n$odjavaLatitude\n$odjavaLongitude\n$napravaPrijava\n$napravaOdjava\n$datumStempla\n$sprememba\n$sessionId';
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

  String _userName = '';
  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = MediaQuery.of(context).padding;
    double topPadding = padding.top;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double size = screenHeight / screenWidth;

    DateTime currentDate = DateTime.now();
    int datet = DateTime.now().day;
    return Scaffold(
        body: Stack(
      children: [
        Positioned.fill(
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
                      _userName,
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
              padding: const EdgeInsets.symmetric(vertical: 5.0),
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
                            ? DateFormat.MMMd('sl_SI').format(
                                _selectedWeekStart.add(const Duration(days: 0)))
                            : DateFormat.MMMd('sl_SI').format(_selectedWeekStart
                                .add(const Duration(days: 1))),
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
                            ? DateFormat.MMMd('sl_SI').format(
                                _selectedWeekEnd.add(const Duration(days: -1)))
                            : DateFormat.MMMd('sl_SI').format(
                                _selectedWeekEnd.add(const Duration(days: 0))),
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
            Container(
              padding: const EdgeInsets.symmetric(vertical: 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: const BorderSide(
                        color: Color.fromARGB(197, 255, 166, 0),
                      ),
                    ),
                    child: SizedBox(
                      height: screenHeight * 0.0503,
                      child: DropdownButton<int>(
                        value: selectedYear,
                        items: getYears().map((int year) {
                          return DropdownMenuItem<int>(
                            value: year,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                '$year',
                                style:
                                    TextStyle(fontSize: screenHeight * 0.0201),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          setState(() {
                            selectedYear = newValue!;
                            updateDateTimeObjectDan1();
                          });
                        },
                        style: TextStyle(
                          color: Color.fromARGB(197, 0, 0, 0),
                          fontSize: screenHeight * 0.0201,
                        ),
                        underline: Container(
                          height: 0,
                        ),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: const BorderSide(
                        color: Color.fromARGB(197, 255, 166, 0),
                      ),
                    ),
                    child: SizedBox(
                      height: screenHeight * 0.0503,
                      child: DropdownButton<int>(
                        value: selectedMonth,
                        items: getMonths().map((String month) {
                          return DropdownMenuItem<int>(
                            value: int.parse(month),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                month,
                                style:
                                    TextStyle(fontSize: screenHeight * 0.0201),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          setState(() {
                            selectedMonth = newValue!;
                            updateDateTimeObjectDan2();
                          });
                        },
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: screenHeight * 0.0201,
                        ),
                        underline: Container(
                          height: 0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  SizedBox(
                    height: screenHeight * 0.0503,
                    child: ElevatedButton(
                      onPressed: () {
                        var name = getCompanyName();
                        var date = DateFormat.yMMMM('sl_SI')
                            .format(updateDateTimeObjectDan1());

                        generateExcelOseba(updateDateTimeObjectDan1(),
                            updateDateTimeObjectDan2(), '$name _ $date');
                      },
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(197, 255, 166, 0),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          'Mesečni izvoz',
                          style: TextStyle(
                            color: Color.fromARGB(197, 0, 0, 0),
                            fontSize: screenHeight * 0.0201,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
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
                    companyId: _workSessions[index].companyid,
                    right: _workSessions[index].right,
                    username: _workSessions[index].username,
                    vrsta: _workSessions[index].vrsta,
                    prijavaLatitude: _workSessions[index].prijavaLatitude,
                    prijavaLongitude: _workSessions[index].prijavaLongitude,
                    odjavaLatitude: _workSessions[index].odjavaLatitude,
                    odjavaLongitude: _workSessions[index].odjavaLongitude,
                    napravaPrijava: _workSessions[index].napravaPrijava,
                    napravaOdjava: _workSessions[index].napravaOdjava,
                    sprememba: _workSessions[index].sprememba,
                    screenHeight: screenHeight,
                    sessionId: _workSessions[index].sessionId);
              },
            )),
          ],
        ),
        if (loadingExcel)
          if (loadingExcel)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: 5,
                    sigmaY: 5), // Adjust the sigma values for more or less blur
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text(
                          "Odpiranje Excel datoteke",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      ],
    ));
  }
}

Future<void> showSessionDetailsDialog(
    BuildContext context,
    String vrsta,
    String username,
    String startTimeLunch,
    String endTimeLunch,
    String startTimecard,
    String endTimecard,
    bool right,
    String companyId,
    String prijavaLatitude,
    String prijavaLongitude,
    String odjavaLatitude,
    String odjavaLongitude,
    String napravaPrijava,
    String napravaOdjava,
    String sprememba,
    String sessionId) async {
  TextEditingController startTimeController =
      TextEditingController(text: startTimecard);
  TextEditingController endTimeController =
      TextEditingController(text: endTimecard);
  TextEditingController startTimeLunchController =
      TextEditingController(text: startTimeLunch);
  TextEditingController endTimeLunchController =
      TextEditingController(text: endTimeLunch);
  bool changesMade = false;
  void onInputChange() {
    changesMade = true;
  }

  startTimeController.addListener(() {
    onInputChange();
  });

  void addListenersToControllers() {
    startTimeController.addListener(() {
      onInputChange();
    });

    endTimeController.addListener(() {
      onInputChange();
    });

    startTimeLunchController.addListener(() {
      onInputChange();
    });

    endTimeLunchController.addListener(() {
      onInputChange();
    });
  }

  addListenersToControllers();

  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;
  startTimeController.text = startTimecard;
  endTimeController.text = endTimecard;
  startTimeLunchController.text = startTimeLunch;
  endTimeLunchController.text = endTimeLunch;

  bool areTimesValid() {
    DateTime? parseDateTime(String time) {
      try {
        return DateTime.tryParse(time);
      } catch (e) {
        return null;
      }
    }

    bool isValidDate(DateTime dateTime) {
      int daysInMonth(int year, int month) {
        return DateTime(year, month, 0).day;
      }

      return dateTime != null &&
          dateTime.year >= 0 &&
          dateTime.month >= 1 &&
          dateTime.month <= 12 &&
          dateTime.day >= 1 &&
          dateTime.day <= daysInMonth(dateTime.year, dateTime.month);
    }

    bool isValidTime(DateTime dateTime) {
      return dateTime != null &&
          dateTime.hour >= 0 &&
          dateTime.hour <= 23 &&
          dateTime.minute >= 0 &&
          dateTime.minute <= 59 &&
          dateTime.second >= 0 &&
          dateTime.second <= 59;
    }

    ;

    int daysInMonth(int year, int month) {
      return DateTime(year, month + 1, 0).day;
    }

    final startTime = parseDateTime(startTimeController.text);
    final endTime = parseDateTime(endTimeController.text);
    final startTimeLunch = parseDateTime(startTimeLunchController.text);
    final endTimeLunch = parseDateTime(endTimeLunchController.text);

    return isValidDate(startTime!) &&
        isValidTime(startTime) &&
        isValidDate(endTime!) &&
        isValidTime(endTime) &&
        isValidDate(startTimeLunch!) &&
        isValidTime(startTimeLunch) &&
        isValidDate(endTimeLunch!) &&
        isValidTime(endTimeLunch);
  }

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return SingleChildScrollView(
          child: AlertDialog(
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: screenHeight * 0.0012,
                color: const Color.fromARGB(255, 197, 193, 193),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.02,
              ),
              child: Text(
                'UREDI DELAVNIK',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenHeight * 0.0255),
              ),
            ),
            Expanded(
              child: Container(
                height: screenHeight * 0.0012,
                color: const Color.fromARGB(255, 197, 193, 193),
              ),
            ),
          ],
        ),
        content: Column(
          children: [
            TextField(
              controller: startTimeController,
              decoration: InputDecoration(
                labelText: "Čas prihoda",
                labelStyle: TextStyle(fontSize: screenHeight * 0.0201),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.blue), // Border color
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide:
                      BorderSide(color: Colors.blue), // Focused border color
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide:
                      BorderSide(color: Colors.grey), // Enabled border color
                ),
                filled: true,
                fillColor: Colors.grey[0],
                hintStyle: TextStyle(
                    fontSize:
                        1), // Set the font size for the text inside the TextField
              ),
            ),
            SizedBox(
              height: 15,
            ),
            TextField(
              controller: endTimeController,
              decoration: InputDecoration(
                labelText: "Čas odhoda",
                labelStyle: TextStyle(fontSize: screenHeight * 0.0201),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.blue), // Border color
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide:
                      BorderSide(color: Colors.blue), // Focused border color
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide:
                      BorderSide(color: Colors.grey), // Enabled border color
                ),
                filled: true,
                fillColor: Colors.grey[0], // Background color
              ),
            ),
            SizedBox(
              height: 15,
            ),
            TextField(
              controller: startTimeLunchController,
              decoration: InputDecoration(
                labelText: "Začetek malice",
                labelStyle: TextStyle(fontSize: screenHeight * 0.0201),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.blue), // Border color
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide:
                      BorderSide(color: Colors.blue), // Focused border color
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide:
                      BorderSide(color: Colors.grey), // Enabled border color
                ),
                filled: true,
                fillColor: Colors.grey[0],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            TextField(
              controller: endTimeLunchController,
              decoration: InputDecoration(
                labelText: "Konec malice",
                labelStyle: TextStyle(fontSize: screenHeight * 0.0201),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.blue), // Border color
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide:
                      BorderSide(color: Colors.blue), // Focused border color
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide:
                      BorderSide(color: Colors.grey), // Enabled border color
                ),
                filled: true,
                fillColor: Colors.grey[0], // Background color
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: screenHeight * 0.0012,
                    color: const Color.fromARGB(255, 197, 193, 193),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.02,
                  ),
                  child: Text(
                    'NAPRAVA',
                    style: TextStyle(
                      color: Color.fromARGB(255, 197, 193, 193),
                      fontWeight: FontWeight.bold,
                      fontSize: screenHeight * 0.0201,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: screenHeight * 0.0012,
                    color: const Color.fromARGB(255, 197, 193, 193),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Text('Prijave: $napravaPrijava',
                style: TextStyle(fontSize: screenHeight * 0.0201)),
            const SizedBox(
              height: 10,
            ),
            Text('Odjave: $napravaOdjava',
                style: TextStyle(fontSize: screenHeight * 0.0201)),
            const SizedBox(
              height: 20,
            ),
            Visibility(
                visible:
                    sprememba.isNotEmpty, // Show if $sprememba is not empty
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: screenHeight * 0.0012,
                            color: const Color.fromARGB(255, 197, 193, 193),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02,
                          ),
                          child: Text(
                            'SPREMENIL',
                            style: TextStyle(
                                color: Color.fromARGB(255, 197, 193, 193),
                                fontWeight: FontWeight.bold,
                                fontSize: screenHeight * 0.0201),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: screenHeight * 0.0012,
                            color: const Color.fromARGB(255, 197, 193, 193),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text('$sprememba'),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                )),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: screenHeight * 0.0012,
                    color: const Color.fromARGB(255, 197, 193, 193),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.02,
                  ),
                  child: Text(
                    'LOKACIJA',
                    style: TextStyle(
                        color: Color.fromARGB(255, 197, 193, 193),
                        fontWeight: FontWeight.bold,
                        fontSize: screenHeight * 0.0201),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: screenHeight * 0.0012,
                    color: const Color.fromARGB(255, 197, 193, 193),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      openGoogleMaps(prijavaLatitude, prijavaLongitude);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Color.fromARGB(103, 225, 225, 225),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text('Prijave',
                            style: TextStyle(
                              fontSize: screenHeight * 0.0201,
                              color: Colors.black,
                            )),
                        Icon(
                          Icons.location_pin,
                          color: Colors.black,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      openGoogleMaps(odjavaLatitude, odjavaLongitude);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Color.fromARGB(103, 225, 225, 225),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Odjave',
                          style: TextStyle(
                            fontSize: screenHeight * 0.0201,
                            color: Colors.black, // Set text color to black
                          ),
                        ),
                        Icon(
                          Icons.location_pin,
                          color: Colors.black, // Set icon color to black
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: screenHeight * 0.0012,
                    color: const Color.fromARGB(255, 197, 193, 193),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: screenHeight * 0.0012,
                    color: const Color.fromARGB(255, 197, 193, 193),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text("Prekliči"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          Visibility(
            visible: right,
            child: TextButton(
              child: const Text("Shrani"),
              onPressed: true
                  ? () async {
                      if (rightValue(
                            startTimeController.text,
                            endTimeController.text,
                            startTimeLunchController.text,
                            endTimeLunchController.text,
                          ) &&
                          changeValid(
                              startTimeController.text,
                              startTimecard,
                              endTimeController.text,
                              endTimecard,
                              startTimeLunchController.text,
                              startTimeLunch,
                              endTimeLunchController.text,
                              endTimeLunch)) {
                        // Valid times, proceed with the update

                        final updatedStartTimeCard = startTimeController.text;
                        final updatedEndTimeCard = endTimeController.text;
                        final updatedStartTimeLunch =
                            startTimeLunchController.text;
                        final updatedEndTimeLunch = endTimeLunchController.text;
                        final updatedVrsta = vrsta;
                        final updatedprijavaLatitude = prijavaLatitude;
                        final updatedprijavaLongitude = prijavaLongitude;
                        final updatedodjavaLatitude = odjavaLatitude;
                        final updatedodjavaLongitude = odjavaLongitude;
                        final updatednapravaPrijava = napravaPrijava;
                        final updatednapravaOdjava = napravaOdjava;
                        final updatedsprememba = sprememba;

                        final updatedCompanyId = companyId;
                        addWorkSession(
                          username,
                          updatedStartTimeLunch,
                          updatedEndTimeLunch,
                          updatedStartTimeCard,
                          updatedEndTimeCard,
                          updatedVrsta,
                          true,
                          updatedCompanyId,
                          updatedprijavaLatitude,
                          updatedprijavaLongitude,
                          updatedodjavaLatitude,
                          updatedodjavaLongitude,
                          updatednapravaPrijava,
                          updatednapravaOdjava,
                          updatedsprememba,
                        );

                        await updateWorkSession(
                          sessionId: sessionId
                        );

                        Navigator.of(context).pop();
                      } else {
                        // Invalid times, show an error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Sprememb ni mogoče shraniti. Napaka v zapisu datuma/ure ali podvajanju delavnika.'),
                            duration: Duration(seconds: 5),
                          ),
                        );
                      }
                      // ignore: dead_code
                    }
                  : null,
            ),
          ),
        ],
      ));
    },
  );
}

bool rightValue(String start, String end, String startLunch, String endLunch) {
int daysInMonth(int year, int month) {
  int days = DateTime(year, month + 1, 0).day;
  return days;
}


int letoStart = int.parse(start.substring(0, 4));
int mesecStart = int.parse(start.substring(5, 7));
int danStart = int.parse(start.substring(8, 10));
int uraStart = int.parse(start.substring(11, 13));
int minutaStart = int.parse(start.substring(14, 16));
int sekundaStart = int.parse(start.substring(17, 19));

int startDnivmescu = daysInMonth(letoStart,mesecStart);
print(startDnivmescu);



int letoEnd = int.parse(end.substring(0, 4));
int mesecEnd = int.parse(end.substring(5, 7));
int danEnd = int.parse(end.substring(8, 10));
int uraEnd = int.parse(end.substring(11, 13));
int minutaEnd = int.parse(end.substring(14, 16));
int sekundaEnd = int.parse(end.substring(17, 19));

int endDnivmescu = daysInMonth(letoEnd, mesecEnd);


int letoStartLunch = int.parse(startLunch.substring(0, 4));
int mesecStartLunch = int.parse(startLunch.substring(5, 7));
int danStartLunch = int.parse(startLunch.substring(8, 10));
int uraStartLunch = int.parse(startLunch.substring(11, 13));
int minutaStartLunch = int.parse(startLunch.substring(14, 16));
int sekundaStartLunch = int.parse(startLunch.substring(17, 19));

int startLunchDnivmescu = daysInMonth(letoStartLunch, mesecStartLunch);


int letoEndLunch = int.parse(endLunch.substring(0, 4));
int mesecEndLunch = int.parse(endLunch.substring(5, 7));
int danEndLunch = int.parse(endLunch.substring(8, 10));
int uraEndLunch = int.parse(endLunch.substring(11, 13));
int minutaEndLunch = int.parse(endLunch.substring(14, 16));
int sekundaEndLunch = int.parse(endLunch.substring(17, 19));

int endLunchDnivmescu = daysInMonth(letoEndLunch, mesecEndLunch);
print(letoStartLunch);
print(letoEndLunch);
print('letoStart: ${letoStart >= 2024}');
print('letoEnd: ${letoEnd >= 2024}');
print('letoStartLunch: ${letoStartLunch >= 2024}');
print('letoEndLunch: ${letoEndLunch >= 2024}');

print('mesecStart: ${mesecStart <= 12}');
print('mesecEnd: ${mesecEnd <= 12}');
print('mesecStartLunch: ${mesecStartLunch <= 12}');
print('mesecEndLunch: ${mesecEndLunch <= 12}');

print('danStart: ${danStart <= startDnivmescu}');
print('danEnd: ${danEnd <= endDnivmescu}');
print('danStartLunch: ${danStartLunch <= startLunchDnivmescu}');
print('danEndLunch: ${danEndLunch <= endLunchDnivmescu}');

print('uraStart: ${uraStart < 24}');
print('uraEnd: ${uraEnd < 24}');
print('uraStartLunch: ${uraStartLunch < 24}');
print('uraEndLunch: ${uraEndLunch < 24}');

print('minutaStart: ${minutaStart < 60}');
print('minutaEnd: ${minutaEnd < 60}');
print('minutaStartLunch: ${minutaStartLunch < 60}');
print('minutaEndLunch: ${minutaEndLunch < 60}');

print('sekundaStart: ${sekundaStart < 60}');
print('sekundaEnd: ${sekundaEnd < 60}');
print('sekundaStartLunch: ${sekundaStartLunch < 60}');
print('sekundaEndLunch: ${sekundaEndLunch < 60}');



if (
letoStart >= 2024 &&
letoEnd >= 2024 &&
mesecStart <=12 &&
mesecEnd <=12 &&
mesecStartLunch <=12 &&
mesecEndLunch <=12 &&
danStart<= startDnivmescu &&
danEnd <= endDnivmescu &&
danStartLunch <= startLunchDnivmescu &&
danEndLunch <= endLunchDnivmescu&&
uraStart <24&&
uraEnd <24&&
uraStartLunch <24&&
uraEndLunch <24&&
minutaStart <60 &&
minutaEnd <60 &&
minutaStartLunch <60 &&
minutaEndLunch <60 &&
sekundaStart <60 &&
sekundaEnd <60 &&
sekundaStartLunch <60 &&
sekundaEndLunch <60 


){

  return true;
}
else {return false;
}


}

bool changeValid(
    startTimeController,
    startTimecard,
    endTimeController,
    endTimecard,
    startTimeLunchController,
    startTimeLunch,
    endTimeLunchController,
    endTimeLunch) 
    
    {
      print(startTimeController);
  return startTimeController != startTimecard ||
      endTimeController != endTimecard ||
      startTimeLunchController != startTimeLunch ||
      endTimeLunchController != endTimeLunch;
}

void openGoogleMaps(String latitude, String longitude) async {
  final double lat = double.parse(latitude);
  final double long = double.parse(longitude);

  final String googleMapsUrl =
      'https://www.google.com/maps/search/?api=1&query=$lat,$long';

  if (await canLaunch(googleMapsUrl)) {
    await launch(googleMapsUrl);
  } else {
    throw 'Could not launch $googleMapsUrl';
  }
}

class WorkSessionCard extends StatelessWidget {
  final String startTime;
  final String endTime;
  final String startTimeLunch;
  final String endTimeLunch;
  final String startTimecard;
  final String endTimecard;
  final String companyId;
  final String username;
  final bool
      right; // This is the attribute indicating if the card should be red
  final String vrsta;
  final String prijavaLatitude;
  final String prijavaLongitude;
  final String odjavaLatitude;
  final String odjavaLongitude;
  final String napravaPrijava;
  final String napravaOdjava;
  final String sprememba;
  final double screenHeight;
  final String sessionId;
  

  const WorkSessionCard({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.endTimeLunch,
    required this.startTimeLunch,
    required this.startTimecard,
    required this.endTimecard,
    required this.vrsta,
    required this.username,
    required this.companyId,
    required this.right, // Include 'right' in the constructor
    required this.prijavaLatitude, // Include 'right' in the constructor
    required this.prijavaLongitude, // Include 'right' in the constructor
    required this.odjavaLatitude, // Include 'right' in the constructor
    required this.odjavaLongitude,
    required this.napravaPrijava,
    required this.napravaOdjava,
    required this.sprememba,
    required this.screenHeight,
    required this.sessionId
    // Include 'right' in the constructor
  });

  @override
  Widget build(BuildContext context) {
    // Determine the card color based on the 'right' attribute
    Color cardColor = right == false
        ? const Color.fromARGB(255, 198, 198, 198)
        : const Color.fromARGB(255, 255, 255, 255);

    return SingleChildScrollView(
        child: InkWell(
      onTap: () {
        // Show the session details dialog here
        showSessionDetailsDialog(
            context,
            vrsta,
            username,
            startTimeLunch,
            endTimeLunch,
            startTimecard,
            endTimecard,
            right,
            companyId,
            prijavaLatitude,
            prijavaLongitude,
            odjavaLatitude,
            odjavaLongitude,
            napravaPrijava,
            napravaOdjava,
            sprememba,
            sessionId);
      },
      child: Card(
        color: cardColor, // Set the card color based on the 'right' attribute
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
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    endTime, // Time difference in the format "hh hours mm minutes"
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenHeight * 0.0201),
                  ),
                  SizedBox(width: 15),
                  Icon(
                    Icons.edit,
                    size: screenHeight * 0.0251,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

Future<void> updateWorkSession(
    {required String sessionId
   }) async {
  final DatabaseReference workSessionsRef =
      FirebaseDatabase.instance.reference().child('work_sessions');

  try {
    // Get the current user from Firebase Authentication
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String currentUserEmail = currentUser.email ?? '';

      DatabaseEvent snapshot = await workSessionsRef.once();

      if (snapshot.snapshot.value != null) {
        Map<dynamic, dynamic> workSessionsData =
            snapshot.snapshot.value as Map<dynamic, dynamic>;

        workSessionsData.forEach((key, value) {
          Map<dynamic, dynamic> sessionData = value as Map<dynamic, dynamic>;

         
          if (true==true) {
            // Update the 'right' attribute to false and add 'sprememba'
            workSessionsRef.child(sessionId).update({
              'right': false,
              'sprememba': currentUserEmail,
            });
          }
        });

        // Print a message if the work session was not found
      } else {}
    } else {}
  } catch (error) {
    print('Error updating work session: $error');
  }
}

Future<void> addWorkSession(
    String userId,
    String startTimeLunch,
    String endTimeLunch,
    String startTimeCard,
    String endTimeCard,
    String vrsta,
    bool right,
    String comapnyId,
    String prijavaLatitude,
    String prijavaLongitude,
    String odjavaLatitude,
    String odjavaLongitude,
    String napravaPrijava,
    String napravaOdjava,
    String sprememba) async {
  try {
    final DatabaseReference workSessionsRef =
        FirebaseDatabase.instance.reference().child('work_sessions');

    final newWorkSessionRef = workSessionsRef.push();

    await newWorkSessionRef.set({
      'username': userId,
      'start_time': startTimeCard,
      'end_time': endTimeCard,
      'start_time_lunch': startTimeLunch,
      'end_time_lunch': endTimeLunch,
      'vrsta': vrsta,
      'right': right,
      'companyid': comapnyId,
      'lokacija_prijave_latitude': prijavaLatitude,
      'lokacija_prijave_longitude': prijavaLongitude,
      'lokacija_odjave_latitude': odjavaLatitude,
      'lokacija_odjave_longitude': odjavaLongitude,
      'napravaPrijava': napravaPrijava,
      'napravaOdjava': napravaOdjava,
      'sprememba': sprememba
    });
  } catch (error) {
    print('Error adding work session: $error');
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
    } catch (e) {
      print('Error parsing date: $e');
    }

    return 'Invalid Date';
  }

  String getFormattedDuration(String startTime, String endTime) {
    try {
      final DateTime startDateTime = DateTime.parse(startTime);
      final DateTime endDateTime = DateTime.parse(endTime);
      final Duration difference = endDateTime.difference(startDateTime);
      final int hours = difference.inHours;
      final int minutes = difference.inMinutes.remainder(60);
      return '$hours: $minutes ';
    } catch (e) {
      print('Error calculating time difference: $e');
    }

    return 'Invalid Time Difference';
  }

  String getFormattedDateForCard() {
    final parts = text.split('\n');
    final startTime = parts[0].replaceAll('Start Time: ', '');
    return getFormattedDate(startTime);
  }

  String getFormattedTimeDifferenceForCard() {
    final parts = text.split('\n');
    final startTime = parts[0].replaceAll('Start Time: ', '');
    final endTime = parts[1].replaceAll('End Time: ', '');
    return getFormattedTimeDifference(startTime, endTime);
  }

  String getFormattedDateForPopup() {
    final parts = text.split('\n');
    final startTime = parts[0].replaceAll('Start Time: ', '');
    return getFormattedDate(startTime);
  }

  String getFormattedDurationForPopup() {
    final parts = text.split('\n');
    final startTime = parts[0].replaceAll('Start Time: ', '');
    final endTime = parts[1].replaceAll('End Time: ', '');
    return 'Start Time: $startTime\nEnd Time: $endTime';
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

  String get prijavaLatitude {
    final parts = text.split('\n');
    final prijavaLatitude = parts[10].replaceAll('', '');
    return prijavaLatitude;
  }

  String get prijavaLongitude {
    final parts = text.split('\n');
    final prijavaLongitude = parts[11].replaceAll('', '');
    return prijavaLongitude;
  }

  String get odjavaLatitude {
    final parts = text.split('\n');
    final odjavaLatitude = parts[12].replaceAll('', '');
    return odjavaLatitude;
  }

  String get odjavaLongitude {
    final parts = text.split('\n');
    final odjavaLongitude = parts[13].replaceAll('', '');
    return odjavaLongitude;
  }

  String get napravaPrijava {
    final parts = text.split('\n');
    final napravaPrijava = parts[14].replaceAll('', '');
    return napravaPrijava;
  }
  String get sessionId {
    final parts = text.split('\n');
    final sessionId = parts[18].replaceAll('', '');
    return sessionId;
  }
  String get napravaOdjava {
    final parts = text.split('\n');
    final napravaOdjava = parts[15].replaceAll('', '');
    return napravaOdjava;
  }

  String get sprememba {
    final parts = text.split('\n');
    final sprememba = parts[17].replaceAll('', '');
    return sprememba;
  }

  String get vrsta {
    final parts = text.split('\n');
    final vrsta = parts[9].replaceAll('vrsta: ', '');
    return vrsta;
  }

  String get companyid {
    final parts = text.split('\n');
    final companyid = parts[6].replaceAll('companyId: ', '');
    return companyid;
  }

  String get username {
    final parts = text.split('\n');
    final username = parts[8].replaceAll('username: ', '');
    return username;
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

  String get endTime {
    final parts = text.split('\n');
    return getFormattedTimeDifference(
      parts[0].replaceAll('Start Time: ', ''),
      parts[1].replaceAll('End Time: ', ''),
    );
  }

  String getFormattedDateTime(String dateTimeString) {
    try {
      final DateTime parsedDateTime = DateTime.parse(dateTimeString);
      final String formattedDateTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(parsedDateTime);
      return formattedDateTime;
    } catch (e) {
      return 'Invalid Date/Time';
    }
  }

  String get startTimeLunch {
    final parts = text.split('\n');
    if (parts.length >= 4) {
      final startTimeLunch = parts[2].replaceAll('Start Time Lunch: ', '');
      return getFormattedDateTime(startTimeLunch);
    }
    return 'N/A';
  }

  String get startTimecard {
    final parts = text.split('\n');
    if (parts.length >= 6) {
      final startTimecard = parts[4].replaceAll('Start Time Card: ', '');
      return getFormattedDateTime(startTimecard);
    }
    return 'N/A';
  }

  String get endTimecard {
    final parts = text.split('\n');
    if (parts.length >= 6) {
      final endTimecard = parts[5].replaceAll('End Time Card: ', '');
      return getFormattedDateTime(endTimecard);
    }
    return 'N/A';
  }

  String get endTimeLunch {
    final parts = text.split('\n');
    if (parts.length >= 4) {
      final endTimeLunch = parts[3].replaceAll('End Time Lunch: ', '');
      return getFormattedDateTime(endTimeLunch);
    }
    return 'N/A';
  }

  String get datumStempla {
    final parts = text.split('\n');
    final datumStempla = parts[16].replaceAll('', '');
    return datumStempla;
  }
}
