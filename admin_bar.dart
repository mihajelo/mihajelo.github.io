// ignore_for_file: deprecated_member_use, unnecessary_null_comparison, unused_local_variable, library_private_types_in_public_api

import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stempl_v1/bottom_bar.dart';
import 'admin_settings.dart';
import 'adminpage.dart';
import 'adminSubscription.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:connectivity/connectivity.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:open_file/open_file.dart';

class AdminBarPage extends StatefulWidget {
  final double screenHeight;
  final double screenWidth;

  const AdminBarPage(
      {super.key, required this.screenHeight, required this.screenWidth});

  @override
  AdminBarPageState createState() => AdminBarPageState();
}

class AdminBarPageState extends State<AdminBarPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  double screenHeight = 0.0;
  double screenWidth = 0;
  String _company = '';
  late DatabaseReference _userReference;
  get result => null; // Added variable to store total work minutes.
  var username = '';
  String dateMonth = '';
  User? currentUser;
  var userId = "";
  String companyPassword = '';
  int currentIndex = 0;
  DateTime exportOd = DateTime.now();
  DateTime exportDo = DateTime.now();
  var companyUid = '';
  List<String> _userIds = [];
  String companyDavcna = '';
  bool loadingExcel = false;
  // Function to get the current user's UID from Firebase Authentication

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late int selectedYear;
  late int selectedMonth;
  @override
  void initState() {
    super.initState();
    screenHeight = widget.screenHeight;
    screenWidth = widget.screenWidth;
    _fetchUserData();
    _initConnectivity();
    initializeData();
    getCompanyPassword();
    _requestPermissions();
    DateTime now = DateTime.now();
    selectedYear = now.year;
    selectedMonth = now.month;
  }

  Future<void> initializeData() async {
    if (_auth.currentUser != null) {
      userId = _auth.currentUser!.uid;
      await _fetchUserData();
    }
    getUsersInCompany();
  }

  List<int> getYears() {
    int currentYear = DateTime.now().year;
    return List.generate(5, (index) => currentYear - index);
  }

  List<String> getMonths() {
    return List.generate(12, (index) => '${index + 1}');
  }

  Future<String> getCompanyPassword() async {
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
        String companyPassword = companyData[companyUid]['companyPassword'];
        setState(() {
          companyPassword = companyPassword;
        });
        // Return the company name
        return companyPassword;
      } else {
        // Handle the case where no data is found
        return 'Company not found';
      }
    } catch (error) {
      // Handle any errors that might occur during the data retrieval
      return 'Error getting company name';
    }
  }

  Future<String> getCompanyName() async {
    try {
      final DatabaseReference companiesRef =
          FirebaseDatabase.instance.reference().child('companies');

      DatabaseEvent event =
          await companiesRef.orderByKey().equalTo(companyUid).once();

      DataSnapshot snapshot = event.snapshot;

      // Check if the snapshot has data
      if (snapshot.value != null) {
        // Extract company data from the snapshot
        Map<dynamic, dynamic> companyData =
            snapshot.value as Map<dynamic, dynamic>;

        // Assuming you want the name property, replace 'name' with the actual property you need
        String companyName = companyData[companyUid]['name'];
        setState(() {
          companyDavcna = companyData[companyUid]['davcna'];
        });

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

    setState(() {
      // Assuming you have a variable in your State class called _userIds
      _userIds = userIds;
    });

    return userIds;
  }

  Future<int> countAllWorkSessionsMalica(String userexport, String companyId,
      DateTime startDate, DateTime endDate) async {
    final DatabaseReference workSessionsRef =
        FirebaseDatabase.instance.reference().child('work_sessions');
    int counter = 0;
    // Use the `once` method to get a DatabaseEvent
    DatabaseEvent snapshot = await workSessionsRef
        .orderByChild('companyid')
        .equalTo(companyId)
        .once();

    // Extract the DataSnapshot from the DatabaseEvent

    if (snapshot.snapshot.value != null) {
      final Map<dynamic, dynamic> sessionsData =
          snapshot.snapshot.value as Map<dynamic, dynamic>;

      return counter;
    }
    return 0;
  }

  Future<String> calculateTotalWorkDuration(
      String userId, startdate, enddate) async {
    final DatabaseReference workSessionsRef =
        FirebaseDatabase.instance.reference().child('work_sessions');

    Duration totalDuration = Duration.zero;

    // Assuming the user ID is stored in the 'username' field in the 'work_sessions' node
    final event =
        await workSessionsRef.orderByChild('username').equalTo(userId).once();

    final Map<dynamic, dynamic>? sessionsData =
        event.snapshot.value as Map<dynamic, dynamic>?;

    if (sessionsData != null) {
      sessionsData.forEach((key, session) {
        if (session['vrsta'] as String == 'Redno delo' &&
            session['right'] == true) {
          final String startTimeString = session['start_time'] as String;
          final DateTime startTime = DateTime.parse(startTimeString);

          if (startTime.isAfter(startdate) && startTime.isBefore(enddate)) {
            final String startTimeString = session['start_time'] as String;
            final String endTimeString = session['end_time'] as String;

            final DateTime startTime = DateTime.parse(startTimeString);
            final DateTime endTime = DateTime.parse(endTimeString);

            totalDuration += endTime.difference(startTime);
          }
        }
      });
    }

    final formattedDuration = formatDuration(totalDuration);
    return formattedDuration;
  }

  String formatDuration(Duration duration) {
    // Your implementation of formatting Duration into a String
    // Example: HH:mm:ss
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  Future<int> countAllWorkSessions(String userexport, String companyId,
      DateTime startDate, DateTime endDate) async {
    final DatabaseReference workSessionsRef =
        FirebaseDatabase.instance.reference().child('work_sessions');
    int counter = 0;
    // Use the `once` method to get a DatabaseEvent
    DatabaseEvent snapshot = await workSessionsRef
        .orderByChild('companyid')
        .equalTo(companyId)
        .once();

    // Extract the DataSnapshot from the DatabaseEvent

    if (snapshot.snapshot.value != null) {
      final Map<dynamic, dynamic> sessionsData =
          snapshot.snapshot.value as Map<dynamic, dynamic>;

      final int count = sessionsData.entries.where((entry) {
        final sessionData = entry.value;
        final startTimeString = sessionData['start_time'] as String;

        final startTime = DateTime.parse(startTimeString);
        // Check if the 'right' attribute is true and the date is between startDate and endDate
        if (sessionData['right'] == true &&
            sessionData['companyid'] == companyId &&
            sessionData['username'] == userexport &&
            startTime.isAfter(startDate) &&
            startTime.isBefore(endDate)) {
          final date = sessionData['start_time'] as String;
          final startDateTime = DateTime.parse(date);
          counter = counter + 1;
          return startDateTime.isAfter(startDate) &&
              startDateTime.isBefore(endDate);
        }

        return false;
      }).length;

      return counter;
    }
    return 0;
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

  Future<String> calculateTotalWorkDurationPraznik(
      String userId, startdate, enddate) async {
    final DatabaseReference workSessionsRef =
        FirebaseDatabase.instance.reference().child('work_sessions');

    Duration totalDuration = Duration.zero;

    // Assuming the user ID is stored in the 'username' field in the 'work_sessions' node
    final event =
        await workSessionsRef.orderByChild('username').equalTo(userId).once();

    final Map<dynamic, dynamic>? sessionsData =
        event.snapshot.value as Map<dynamic, dynamic>?;

    if (sessionsData != null) {
      sessionsData.forEach((key, session) {
        if (session['vrsta'] as String == 'Praznik') {
          {
            final String startTimeString = session['start_time'] as String;
            final DateTime startTime = DateTime.parse(startTimeString);

            if (startTime.isAfter(startdate) && startTime.isBefore(enddate)) {
              final String startTimeString = session['start_time'] as String;
              final String endTimeString = session['end_time'] as String;

              final DateTime startTime = DateTime.parse(startTimeString);
              final DateTime endTime = DateTime.parse(endTimeString);

              totalDuration += endTime.difference(startTime);
            }
          }
        }
      });
    }

    final formattedDuration = formatDuration(totalDuration);
    return formattedDuration;
  }

  Future<String> calculateTotalWorkDurationNoc(
      String userId, startdate, enddate) async {
    final DatabaseReference workSessionsRef =
        FirebaseDatabase.instance.reference().child('work_sessions');

    Duration totalDuration = Duration.zero;

    // Assuming the user ID is stored in the 'username' field in the 'work_sessions' node
    final event =
        await workSessionsRef.orderByChild('username').equalTo(userId).once();

    final Map<dynamic, dynamic>? sessionsData =
        event.snapshot.value as Map<dynamic, dynamic>?;

    if (sessionsData != null) {
      sessionsData.forEach((key, session) {
        if (session['vrsta'] as String == 'Nočno delo') {
          {
            final String startTimeString = session['start_time'] as String;
            final DateTime startTime = DateTime.parse(startTimeString);

            if (startTime.isAfter(startdate) && startTime.isBefore(enddate)) {
              final String startTimeString = session['start_time'] as String;
              final String endTimeString = session['end_time'] as String;

              final DateTime startTime = DateTime.parse(startTimeString);
              final DateTime endTime = DateTime.parse(endTimeString);

              totalDuration += endTime.difference(startTime);
            }
          }
        }
      });
    }

    final formattedDuration = formatDuration(totalDuration);
    return formattedDuration;
  }

  Future<String> calculateTotalWorkDurationIzmena(
      String userId, startdate, enddate) async {
    final DatabaseReference workSessionsRef =
        FirebaseDatabase.instance.reference().child('work_sessions');

    Duration totalDuration = Duration.zero;

    // Assuming the user ID is stored in the 'username' field in the 'work_sessions' node
    final event =
        await workSessionsRef.orderByChild('username').equalTo(userId).once();

    final Map<dynamic, dynamic>? sessionsData =
        event.snapshot.value as Map<dynamic, dynamic>?;

    if (sessionsData != null) {
      sessionsData.forEach((key, session) {
        if (session['vrsta'] as String == 'Izmensko delo') {
          {
            final String startTimeString = session['start_time'] as String;
            final DateTime startTime = DateTime.parse(startTimeString);

            if (startTime.isAfter(startdate) && startTime.isBefore(enddate)) {
              final String startTimeString = session['start_time'] as String;
              final String endTimeString = session['end_time'] as String;

              final DateTime startTime = DateTime.parse(startTimeString);
              final DateTime endTime = DateTime.parse(endTimeString);

              totalDuration += endTime.difference(startTime);
            }
          }
        }
      });
    }

    final formattedDuration = formatDuration(totalDuration);
    return formattedDuration;
  }

  Future<String> calculateTotalWorkDurationDeljenoDelo(
      String userId, startdate, enddate) async {
    final DatabaseReference workSessionsRef =
        FirebaseDatabase.instance.reference().child('work_sessions');

    Duration totalDuration = Duration.zero;

    // Assuming the user ID is stored in the 'username' field in the 'work_sessions' node
    final event =
        await workSessionsRef.orderByChild('username').equalTo(userId).once();

    final Map<dynamic, dynamic>? sessionsData =
        event.snapshot.value as Map<dynamic, dynamic>?;

    if (sessionsData != null) {
      sessionsData.forEach((key, session) {
        if (session['vrsta'] as String == 'Izmensko delo') {
          {
            final String startTimeString = session['start_time'] as String;
            final DateTime startTime = DateTime.parse(startTimeString);

            if (startTime.isAfter(startdate) && startTime.isBefore(enddate)) {
              final String startTimeString = session['start_time'] as String;
              final String endTimeString = session['end_time'] as String;

              final DateTime startTime = DateTime.parse(startTimeString);
              final DateTime endTime = DateTime.parse(endTimeString);

              totalDuration += endTime.difference(startTime);
            }
          }
        }
      });
    }

    final formattedDuration = formatDuration(totalDuration);
    return formattedDuration;
  }

  Future<String> calculateTotalWorkDurationNedelja(
      String userId, startdate, enddate) async {
    final DatabaseReference workSessionsRef =
        FirebaseDatabase.instance.reference().child('work_sessions');

    Duration totalDuration = Duration.zero;

    // Assuming the user ID is stored in the 'username' field in the 'work_sessions' node
    final event =
        await workSessionsRef.orderByChild('username').equalTo(userId).once();

    final Map<dynamic, dynamic>? sessionsData =
        event.snapshot.value as Map<dynamic, dynamic>?;

    if (sessionsData != null) {
      sessionsData.forEach((key, session) {
        if (session['vrsta'] as String == 'Nedeljsko delo') {
          {
            final String startTimeString = session['start_time'] as String;
            final DateTime startTime = DateTime.parse(startTimeString);

            if (startTime.isAfter(startdate) && startTime.isBefore(enddate)) {
              final String startTimeString = session['start_time'] as String;
              final String endTimeString = session['end_time'] as String;

              final DateTime startTime = DateTime.parse(startTimeString);
              final DateTime endTime = DateTime.parse(endTimeString);

              totalDuration += endTime.difference(startTime);
            }
          }
        }
      });
    }

    final formattedDuration = formatDuration(totalDuration);
    return formattedDuration;
  }

  Future<String> calculateTotalWorkDurationOstalo(
      String userId, startdate, enddate) async {
    final DatabaseReference workSessionsRef =
        FirebaseDatabase.instance.reference().child('work_sessions');

    Duration totalDuration = Duration.zero;

    // Assuming the user ID is stored in the 'username' field in the 'work_sessions' node
    final event =
        await workSessionsRef.orderByChild('username').equalTo(userId).once();

    final Map<dynamic, dynamic>? sessionsData =
        event.snapshot.value as Map<dynamic, dynamic>?;

    if (sessionsData != null) {
      sessionsData.forEach((key, session) {
        if (session['vrsta'] as String == 'ostalo') {
          {
            final String startTimeString = session['start_time'] as String;
            final DateTime startTime = DateTime.parse(startTimeString);

            if (startTime.isAfter(startdate) && startTime.isBefore(enddate)) {
              final String startTimeString = session['start_time'] as String;
              final String endTimeString = session['end_time'] as String;

              final DateTime startTime = DateTime.parse(startTimeString);
              final DateTime endTime = DateTime.parse(endTimeString);

              totalDuration += endTime.difference(startTime);
            }
          }
        }
      });
    }

    final formattedDuration = formatDuration(totalDuration);
    return formattedDuration;
  }

  DateTime updateDateTimeObjectDan1() {
    DateTime firstDayOfMonth = DateTime(selectedYear, selectedMonth, 1);
    return firstDayOfMonth;
  }

  DateTime updateDateTimeObjectDan2() {
    DateTime lastDayOfMonth = DateTime(selectedYear, selectedMonth + 1, 1);
    return lastDayOfMonth;
  }

  void generateExcel(
      DateTime exportOd, DateTime exportDo, String filename) async {
    // Use the 'xlsio' alias for Workbook
    xlsio.Workbook workbook = xlsio.Workbook();
    setState(() {
      loadingExcel = true;
    });
    final xlsio.Worksheet sheet = workbook.worksheets[0];
    final companyName = await getCompanyName();
    final String formattedMonth = DateFormat.yMMMM('sl_SI').format(exportOd);

// Set bold border for the specified range
// Optionally, you can set the bold font style for the cells

    // Your existing code to populate the Excel sheet
    sheet.getRangeByIndex(1, 1).setText('Izvoz delavnih ur za podjetje:');
    sheet.getRangeByIndex(1, 2).setText(companyName);

    sheet.getRangeByIndex(2, 1).setText('Davčna št. podjetja:');
    sheet.getRangeByIndex(2, 2).setText(companyDavcna);

    sheet.getRangeByIndex(3, 1).setText('Za mesec:');
    sheet.getRangeByIndex(3, 2).setText(formattedMonth);

    sheet.getRangeByIndex(5, 1).setText('Šifra');
    sheet.getRangeByIndex(5, 2).setText('Priimek in ime');
    sheet.getRangeByIndex(5, 3).setText('Redno delo');
    sheet.getRangeByIndex(5, 4).setText('Praznik');
    sheet.getRangeByIndex(5, 5).setText('Dopust');
    sheet.getRangeByIndex(5, 6).setText('Izredni dopust');
    sheet.getRangeByIndex(5, 7).setText('Stimulacija');
    sheet.getRangeByIndex(5, 8).setText('Bolniška');
    sheet.getRangeByIndex(5, 10).setText('Nega');
    sheet.getRangeByIndex(5, 12).setText('Malica');
    sheet.getRangeByIndex(5, 13).setText('Prevoz');
    sheet.getRangeByIndex(5, 14).setText('Praznik');
    sheet.getRangeByIndex(5, 15).setText('Nočno delo');
    sheet.getRangeByIndex(5, 16).setText('Nedeljsko delo');
    sheet.getRangeByIndex(5, 17).setText('Izmesko delo');
    sheet.getRangeByIndex(5, 18).setText('Delo v deljenem delavnem času');
    sheet.getRangeByIndex(5, 19).setText('Ostalo');
    sheet.getRangeByIndex(5, 20).setText('Delo od doma');

// Values for the 3rd row (index 3) and columns 1 to 13
    sheet.autoFitRow(1);

    sheet.getRangeByIndex(6, 1).setText('');
    sheet.getRangeByIndex(6, 2).setText('');
    sheet.getRangeByIndex(6, 3).setText('Ure');
    sheet.getRangeByIndex(6, 4).setText('Ure');
    sheet.getRangeByIndex(6, 5).setText('Ure');
    sheet.getRangeByIndex(6, 6).setText('Ure');
    sheet.getRangeByIndex(6, 7).setText('Bruto');
    sheet.getRangeByIndex(6, 8).setText('Ure');
    sheet.getRangeByIndex(6, 9).setText('Ure');
    sheet.getRangeByIndex(6, 10).setText('Datum od');
    sheet.getRangeByIndex(6, 11).setText('Datum do');
    sheet.getRangeByIndex(6, 12).setText('Dni');
    sheet.getRangeByIndex(6, 13).setText('Dni');
// Values for the 4th row (index 4) and columns 1 to 13
    sheet.getRangeByIndex(7, 1).setText('#F1');
    sheet.getRangeByIndex(7, 2).setText('');
    sheet.getRangeByIndex(7, 3).setText('U1');
    sheet.getRangeByIndex(7, 4).setText('U3');
    sheet.getRangeByIndex(7, 5).setText('U4');
    sheet.getRangeByIndex(7, 6).setText('U5');
    sheet.getRangeByIndex(7, 7).setText('B81');
    sheet.getRangeByIndex(7, 8).setText('U160');
    sheet.getRangeByIndex(7, 9).setText('U211');
    sheet.getRangeByIndex(7, 10).setText('OD211');
    sheet.getRangeByIndex(7, 11).setText('D211');
    sheet.getRangeByIndex(7, 12).setText('T361');
    sheet.getRangeByIndex(7, 13).setText('T366');
    sheet.getRangeByIndex(7, 14).setText('U23');
    sheet.getRangeByIndex(7, 15).setText('U20');
    sheet.getRangeByIndex(7, 16).setText('U22');
    sheet.getRangeByIndex(7, 17).setText('');
    sheet.getRangeByIndex(7, 20).setText('U15');

    int rowIndes = 8;
    for (var user in _userIds) {
      final delavec = await _fetchUserName(user);
      final ureDela =
          await calculateTotalWorkDuration(user, exportOd, exportDo);
      final noc = await calculateTotalWorkDurationNoc(user, exportOd, exportDo);
      final nedelja =
          await calculateTotalWorkDurationNedelja(user, exportOd, exportDo);
      final izmena =
          await calculateTotalWorkDurationIzmena(user, exportOd, exportDo);
      final praznik =
          await calculateTotalWorkDurationPraznik(user, exportOd, exportDo);
      final deljenoDelo =
          await calculateTotalWorkDurationDeljenoDelo(user, exportOd, exportDo);
      final ostalo =
          await calculateTotalWorkDurationOstalo(user, exportOd, exportDo);

      final workSessionsCount =
          await countAllWorkSessions(user, companyUid, exportOd, exportDo);
      final malicaCount = await countAllWorkSessionsMalica(
          user, companyUid, exportOd, exportDo);

      // Values for the specified variables in the next row (adjust the row index accordingly)
      sheet.getRangeByIndex(rowIndes, 1).setText(user);
      sheet.getRangeByIndex(rowIndes, 2).setText(delavec);
      sheet.getRangeByIndex(rowIndes, 3).setText(ureDela.toString());
// Add empty strings for the placeholders
      sheet.getRangeByIndex(rowIndes, 4).setText('');
      sheet.getRangeByIndex(rowIndes, 5).setText('');
      sheet.getRangeByIndex(rowIndes, 6).setText('');
      sheet.getRangeByIndex(rowIndes, 7).setText('');
      sheet.getRangeByIndex(rowIndes, 8).setText('');
      sheet.getRangeByIndex(rowIndes, 9).setText('');
      sheet.getRangeByIndex(rowIndes, 10).setText('');
      sheet.getRangeByIndex(rowIndes, 14).setText(praznik.toString());
      sheet.getRangeByIndex(rowIndes, 12).setText(malicaCount.toString());
      sheet.getRangeByIndex(rowIndes, 13).setText(workSessionsCount.toString());
      sheet.getRangeByIndex(rowIndes, 15).setText(noc.toString());
      sheet.getRangeByIndex(rowIndes, 16).setText(nedelja.toString());
      sheet.getRangeByIndex(rowIndes, 17).setText(izmena.toString());
      sheet.getRangeByIndex(rowIndes, 18).setText(deljenoDelo.toString());
      sheet.getRangeByIndex(rowIndes, 19).setText(ostalo.toString());

      rowIndes++;
    }
    for (int columnIndex = 1; columnIndex <= 19; columnIndex++) {
      sheet.autoFitColumn(columnIndex);
    }

    final String path = (await getApplicationSupportDirectory()).path;
    final String fileName = '$path/$companyName _ $formattedMonth.xlsx';

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

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();
    if (statuses[Permission.storage] == PermissionStatus.granted) {
      // Permission granted, proceed with file operations
    } else {
      // Permission denied, handle accordingly
    }
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
          final companypassword = companyData['companyPassword'];
          setState(() {
            username = '$name $surname';
            companyUid = companyId;
            _company = companyName;
            companyPassword = companypassword;
          });
        }
      }
    }
  }

  Future<void> changeCompanyPassword(String companyId, newpassword) async {
    try {
      final snapshot = await FirebaseDatabase.instance
          .reference()
          .child('companies/$companyId')
          .once();

      if (snapshot.snapshot.value != null) {
        final newActiveStatus = newpassword;
        await FirebaseDatabase.instance
            .reference()
            .child('companies/$companyId')
            .update({"companyPassword": newActiveStatus});
        getCompanyPassword();
        setState(() {
          companyPassword = companyPassword;
        });
        // You can also perform any other necessary actions here
      }
    } catch (e) {
      // Handle the error if the update fails
    }
  }

Future<String> getCurrentCompanyPassword(String companyUid) async {
  try {
     final snapshot = await FirebaseDatabase.instance
          .reference()
          .child('companies/$companyUid')
          .once();

    // Retrieve the current password from the database
    return snapshot.toString(); // Assuming password is stored as a string
  } catch (e) {
    // Handle errors
    print('Error getting current password: $e');
    return ''; // Return empty string in case of error
  }
}

Future<void> _showPopupPassword(BuildContext context) async {
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmNewPasswordController = TextEditingController();

  String currentPassword = '';
  String passwordzdej = '';
  String newPassword = '';
  String confirmNewPassword = '';
  

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Spremenite geslo podjetja:',
          style: TextStyle(fontSize: screenHeight * 0.0201),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trenutno geslo podjetja:',
              style: TextStyle(fontSize: screenHeight * 0.0201),
            ),
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(hintText: 'Vnesite trenutno geslo'),
            ),
            SizedBox(height: 10.0),
            Text(
              'Novo geslo:',
              style: TextStyle(fontSize: screenHeight * 0.0201),
            ),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(hintText: 'Vnesite novo geslo'),
            ),
            SizedBox(height: 10.0),
            Text(
              'Potrdite novo geslo:',
              style: TextStyle(fontSize: screenHeight * 0.0201),
            ),
            TextField(
              controller: confirmNewPasswordController,
              obscureText: true,
              decoration: InputDecoration(hintText: 'Potrdite novo geslo'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the popup
            },
            child: Text('Prekliči',
                style: TextStyle(fontSize: screenHeight * 0.0201)),
          ),
          ElevatedButton(
            onPressed: () {

              passwordzdej = getCurrentCompanyPassword as String;
              currentPassword = currentPasswordController.text;
              newPassword = newPasswordController.text;
              confirmNewPassword = confirmNewPasswordController.text;

              // Validate if the current password matches the actual company password
              // You need to implement this validation
              if (passwordzdej==currentPassword) {
                // Validate if the new passwords match
                if (newPassword == confirmNewPassword) {
                  // Change company password
                  changeCompanyPassword(companyUid, newPassword);
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BottomBar(
                        currentIndex: 4,
                      ),
                    ),
                  );
                } else {
                  // Show error message if new passwords don't match
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Novi gesli se ne ujemata.'),
                    ),
                  );
                }
              } else {
                // Show error message if current password is invalid
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Vneseno trenutno geslo ni pravilno.'),
                  ),
                );
              }
            },
            child: Text('Shrani', style: TextStyle(fontSize: screenHeight * 0.0201)),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = MediaQuery.of(context).padding;
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
            ),
          ),
          SingleChildScrollView(
              child: Center(
            child: Column(
              children: [
                Container(
                  color: Colors.black,
                  height: topPadding,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: screenHeight * 0.0125,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 8.0,
                              left:
                                  15), // Adjust the right padding for the icon
                          child: Icon(
                            Icons.business_center,
                            size: screenHeight* 0.0314,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal:
                                    8.0), // Adjust the horizontal padding for the text
                            child: Text(
                              '$_company',
                              style: TextStyle(
                                fontSize: screenHeight * 0.0376,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              softWrap: true,
                              overflow:
                                  TextOverflow.clip, // or TextOverflow.ellipsis
                              maxLines:
                                  5, // Set to the desired number of lines before clipping or use null for unlimited
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: screenHeight * 0.0125,
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
                    SizedBox(height: screenHeight * 0.0201),
                    Column(
                      children: [
                        _buildListTile(
                          Icons.schedule,
                          'Pregled delavnih ur',
                          () => _navigateToPage(const AdminPage()),
                        ),
                       
                        _buildListTile(
                          Icons.settings_accessibility_rounded,
                          'Urejanje pravic delavcev',
                          () => _navigateToPage(AdminPageSettings()),
                        ),
                        _buildListTile(
                          Icons.settings,
                          'Urejanje subscription',
                          () => _navigateToPage(AdminSubscriptionPage()),
                        ),
                        _buildPasswordListTile(),
                        _buildDateDropdown(),
                      ],
                    ),
                  ],
                ),
                if (loadingExcel) _buildLoadingOverlay(),
              ],
            ),
          ))
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        size: screenHeight * 0.0314,
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: screenHeight * 0.0201),
      ),
      trailing: Icon(
        Icons.arrow_forward,
        size: screenHeight * 0.0314,
      ),
    );
  }

  Widget _buildPasswordListTile() {
    return ListTile(
      onTap: () => _showPopupPassword(context),
      leading:  Icon(Icons.password,        size: screenHeight * 0.0314,
),
      title: RichText(
        text: TextSpan(
          text: 'Spremeni geslo podjetja:',
          style:
              TextStyle(color: Colors.black, fontSize: screenHeight * 0.0201),
          children: <TextSpan>[
            TextSpan(
              text: '\n$companyPassword',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      trailing:  Icon(Icons.arrow_forward ,size: screenHeight * 0.0314,),
    );
  }

  Widget _buildDateDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Card(
        color: Color.fromARGB(255, 252, 222, 165).withOpacity(1),
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: const EdgeInsets.only(top: 20.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ure podjetja',
                style: TextStyle(
                  fontSize: screenHeight * 0.0201,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.0125),
              ListTile(
                title: Wrap(
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                     Icon(Icons.business,size: screenHeight*0.0314,),
                    SizedBox(width: screenHeight * 0.0125),
                    _buildYearDropdown(),
                    SizedBox(width: screenHeight * 0.0125),
                    _buildMonthDropdown(),
                    SizedBox(width: screenHeight * 0.0125),
                    _buildExportButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYearDropdown() {
    return 
    
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
                  style: TextStyle(fontSize: screenHeight * 0.0201),
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
    );
  }

  Widget _buildMonthDropdown() {
    return 
    
    
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
                  style: TextStyle(fontSize: screenHeight * 0.0201),
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
    );
  }

  Widget _buildExportButton() {
    return Padding(
        padding: const EdgeInsets.all(.0), // Adjust the padding as needed
        child: SizedBox(
          height: screenHeight * 0.0503,
          child: ElevatedButton(
            onPressed: () {
              var name = getCompanyName();
              var date =
                  DateFormat.yMMMM('sl_SI').format(updateDateTimeObjectDan1());

              generateExcel(
                updateDateTimeObjectDan1(),
                updateDateTimeObjectDan2(),
                '$name _ $date',
              );
            },
            style: ElevatedButton.styleFrom(
              primary: const Color.fromARGB(197, 255, 166, 0),
            ),
            child: Text(
              'Izvoz',
              style: TextStyle(
                  color: Color.fromARGB(197, 0, 0, 0),
                  fontSize: screenHeight * 0.0201),
            ),
          ),
        ));
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 5,
          sigmaY: 5,
        ),
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: screenHeight * 0.0125),
                Text(
                  "Odpiranje Excel datoteke",
                  style: TextStyle(
                      color: Colors.white, fontSize: screenHeight * 0.0201),
                ),
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
}

class Workbook {
  xlsio.Workbook workbook = xlsio.Workbook();
}
