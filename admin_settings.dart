// ignore_for_file: deprecated_member_use, unnecessary_cast, empty_catches, use_build_context_synchronously, use_key_in_widget_constructors, library_private_types_in_public_api, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stempl_v1/bottom_bar.dart';

class _AdminPageSettingsState extends State<AdminPageSettings> {
  String? companyId; // Store the companyId
  List<Employee> employees = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.reference();
  User? currentUser;
  var userId = "";
  int activeCount = 0;
  int numberOfUsers = 0;
  int activeAdmins = 0;
  String companyName = ''; // Initialize the variable

  @override
  void initState() {
    super.initState();
    // Initialize userId with the current user's ID
    if (_auth.currentUser != null) {
      userId = _auth.currentUser!.uid;
    }
    getCompanyName(); // Fetch employees after initializing userId
    _fetchEmployeesForCurrentUser(userId);
  }

  Future<String> getCompanyName() async {
    try {
      final DatabaseReference companiesRef =
          FirebaseDatabase.instance.reference().child('companies');

      // Assuming `companyUid` is the key you want to query
      DatabaseEvent event = await companiesRef
          .orderByKey()
          .equalTo(companyId)
          .once() as DatabaseEvent;

      // Extract the DataSnapshot from the DatabaseEvent
      DataSnapshot snapshot = event.snapshot;

      // Check if the snapshot has data
      if (snapshot.value != null) {
        // Extract company data from the snapshot
        Map<dynamic, dynamic> companyData =
            snapshot.value as Map<dynamic, dynamic>;

        // Assuming you want the name property, replace 'name' with the actual property you need
        String companyName = companyData[companyId]['name'];
        // Return the company name
        setState(() {
          companyName = companyName;
        });
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

  Future<void> toggleUserActiveStatus(String userId) async {
    try {
      final userSnapshot = await _dbRef.child("users").child(userId).once();
      if (userSnapshot.snapshot.value != null) {
        final userData = userSnapshot.snapshot.value as Map<dynamic, dynamic>;
        final currentActiveStatus = userData['active'] ?? true;
        final newActiveStatus = !currentActiveStatus;

        await _dbRef
            .child("users")
            .child(userId)
            .update({"active": newActiveStatus});

        // You can also perform any other necessary actions here
      }
    } catch (e) {
      // Handle the error if the update fails
    }
  }

  void toggleAdminStatusAndNavigate({
    required VoidCallback? onTap,
    required VoidCallback onNavigate,
  }) {
    if (onTap != null) {
      onTap();
    }
    onNavigate();
  }

  Widget buildAdminSwitchButton(
      {required bool isAdmin,
      required int activeAdmins,
      required VoidCallback? onTap,
      required VoidCallback onNavigate,
      required screenHeight}) {
    return Transform.scale(
      scale: screenHeight * 0.00125, // Adjust the scale factor to set the size
      child: Switch(
        value: isAdmin,
        onChanged: (value) {
          if (activeAdmins > 1 || !isAdmin) {
            toggleAdminStatusAndNavigate(
              onTap: onTap,
              onNavigate: onNavigate,
            );
          }
        },
        activeColor: Colors.blue,
      ),
    );
  }

  Future<void> toggleUserAdminStatus(String userId) async {
    try {
      final userSnapshot = await _dbRef.child("users").child(userId).once();
      if (userSnapshot.snapshot.value != null) {
        final userData = userSnapshot.snapshot.value as Map<dynamic, dynamic>;
        final currentActiveStatus = userData['adminPermission'] ?? false;
        final newActiveStatus = !currentActiveStatus;

        await _dbRef
            .child("users")
            .child(userId)
            .update({"adminPermission": newActiveStatus});

        // You can also perform any other necessary actions here
      }
    } catch (e) {
      // Handle the error if the update fails
    }
  }

  Future<int> countActiveAdmins() async {
    int activeAdmins = 0;

    try {
      final employeesSnapshot = await _dbRef
          .child("users")
          .orderByChild("companyId")
          .equalTo(companyId)
          .once();

      if (employeesSnapshot.snapshot.value != null) {
        final Map<dynamic, dynamic>? employeesData =
            employeesSnapshot.snapshot.value as Map<dynamic, dynamic>?;

        employeesData?.forEach((key, value) {
          final bool isActive = value['adminPermission'];
          if (isActive == true) {
            activeAdmins++;
          }
        });
      }
    } catch (e) {}
    setState(() {
      activeAdmins = activeAdmins;
    });
    return activeAdmins;
  }

  Future<int> countActiveUsers() async {
    int activeCount = 0;

    try {
      final employeesSnapshot = await _dbRef
          .child("users")
          .orderByChild("companyId")
          .equalTo(companyId)
          .once();

      if (employeesSnapshot.snapshot.value != null) {
        final Map<dynamic, dynamic>? employeesData =
            employeesSnapshot.snapshot.value as Map<dynamic, dynamic>?;

        employeesData?.forEach((key, value) {
          final bool isActive = value['active'];
          if (isActive == true) {
            activeCount++;
          }
        });
      }
    } catch (e) {}
    setState(() {
      activeCount = activeCount;
    });
    return activeCount;
  }

  Future<int> fetchNumberOfUsers(String companyId) async {
    try {
      final planSnapshot = await _dbRef
          .child("companies")
          .child(companyId)
          .child("selectedPlan")
          .once();

      if (planSnapshot.snapshot.value != null) {
        final selectedPlan = planSnapshot.snapshot.value as String;
        int numberOfUsers;

        switch (selectedPlan) {
          case "Do 5 delavcev":
            numberOfUsers = 5;
            break;
          case "Do 10 delavcev":
            numberOfUsers = 10;
            break;
          case "Do 20 delavcev":
            numberOfUsers = 20;
            break;
          case "Samostojni uporabnik":
            numberOfUsers = 1;
            break;
          default:
            numberOfUsers = 0; // Handle other cases if necessary
        }

        return numberOfUsers;
      } else {
        // Handle the case when selectedPlan is not found
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  Future<void> addUserToCompany(String userId, String companyId) async {
    try {
      await _dbRef
          .child("users")
          .child(userId)
          .update({"companyId": companyId});
    } catch (e) {}
  }

  Future<void> showAddUserDialog(BuildContext context, String companyId) async {
    String userId = ""; // Replace with your actual company ID

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Dodaj uporabnika"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: const InputDecoration(hintText: "Uporabnikov ID"),
                onChanged: (value) {
                  userId = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () async {
                // Check if the user ID exists in the database
                if (await userExists(userId)) {
                  // Call the function to add the user to the company with the entered userId
                  addUserToCompany(userId, companyId);
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          AdminPageSettings())); // Close the dialog
                } else {
                  // User doesn't exist, show an error message or take appropriate action
                  // For example, show an error message using a SnackBar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Uporabnik ne obstaja"),
                    ),
                  );
                }
              },
              child: const Text("Dodaj"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Prekliči"),
            ),
          ],
        );
      },
    );
  }

  Future<bool> userExists(String userId) async {
    final DatabaseReference dbRef = FirebaseDatabase.instance.reference();

    try {
      // Query the "users" node in your database
      final userSnapshot = await dbRef.child("users").child(userId).once();

      if (userSnapshot.snapshot.value != null) {
        // User with the given userId exists
        return true;
      } else {
        // User does not exist
        return false;
      }
    } catch (e) {
      // Handle any errors that occur during the database query
      return false; // You might want to return false in case of an error
    }
  }

  Future<void> removeUserFromCompany(String userId) async {
    try {
      await _dbRef
          .child("users")
          .child(userId)
          .update({"adminPermission": false});
      await _dbRef.child("users").child(userId).update({"companyId": ""});
    } catch (e) {
      // Handle the error if the update fails
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
        numberOfUsers = await fetchNumberOfUsers(companyId!);

        await _fetchEmployeesWithCompanyId(companyId!);
      }
    }
  }

  Future<void> _fetchEmployeesWithCompanyId(String companyId) async {
    final employeesSnapshot = await _dbRef
        .child("users")
        .orderByChild("companyId")
        .equalTo(companyId)
        .once();

    if (employeesSnapshot.snapshot.value != null) {
      final Map<dynamic, dynamic>? employeesData =
          employeesSnapshot.snapshot.value as Map<dynamic, dynamic>?;

      employeesData?.forEach((key, value) {
        final employee = Employee(
          userId: key,
          name: value['name'] ?? '',
          surname: value['surname'] ?? '',
          active: value['active'],
          adminPermission: value['adminPermission'],
        );
        setState(() {
          employees.add(employee);
        });
      });
      activeCount = await countActiveUsers();
      activeAdmins = await countActiveAdmins();
      numberOfUsers = await fetchNumberOfUsers(companyId);
      companyName = await getCompanyName();
    }
  }

  void toggleUserAndNavigate({
    required VoidCallback? onTap,
    required VoidCallback onNavigate,
  }) {
    if (onTap != null) {
      onTap();
    }
    onNavigate();
  }

  Widget buildSwitchButton(
      {required bool isActive,
      required int activeCount,
      required int numberOfUsers,
      required VoidCallback? onTapRed,
      required VoidCallback? onTapGreen,
      required VoidCallback onNavigate,
      required screenHeight}) {
    return Transform.scale(
      scale: screenHeight * 0.00125, // Adjust the scale factor to set the size
      child: Switch(
        value: isActive,
        onChanged: (value) {
          if (value) {
            toggleUserAndNavigate(
              onTap: onTapRed,
              onNavigate: onNavigate,
            );
          } else {
            if (activeCount < numberOfUsers) {
              toggleUserAndNavigate(
                onTap: onTapGreen,
                onNavigate: onNavigate,
              );
            }
          }
        },
        activeColor: Colors.green,
        inactiveThumbColor: Colors.red,
        activeTrackColor: Colors.green.withOpacity(0.5),
        inactiveTrackColor: Colors.red.withOpacity(0.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = MediaQuery.of(context).padding;
    double topPadding = padding.top;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildTopBar(topPadding),
              _buildAppBar(),
              _buildDivider(),
              SizedBox(
                height: screenHeight * 0.0125,
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: employees.map((employee) {
                    return _buildEmployeeCard(employee);
                  }).toList(),
                ),
              ),
              const SizedBox(width: 20),
              _buildAddUserButton(),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToBottomBar() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BottomBar(
          currentIndex: 5,
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.fromARGB(197, 255, 202, 103), Colors.white],
        ),
      ),
    );
  }

  Widget _buildTopBar(double topPadding) {
    return Container(
      color: Colors.black,
      height: topPadding,
    );
  }

  Widget _buildAppBar() {
    double screenHeight = MediaQuery.of(context).size.height;

    return 
    
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
                 Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>  BottomBar(
            currentIndex: 4,
          ),
        ),
      );
              },
            ),
            Text(
              'UREJANJE PRAVIC',
              style: TextStyle(
                fontSize: screenHeight * 0.0276,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(
                width: screenHeight * 0.0314), // Adjust the space as needed
          ],
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Divider(
        color: Colors.transparent,
        height: 1.0,
      ),
    );
  }

  Widget _buildEmployeeCard(Employee employee) {
    double screenHeight = MediaQuery.of(context).size.height;

    return 
    Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
      child: 
   Container(
  constraints: BoxConstraints(
    maxWidth: 400.0, // Set your desired maximum width
  ),
  child: ExpansionTile(
     trailing: Icon(
    Icons.expand_more, // You can replace this with your desired icon
    size: screenHeight * 0.03, // Adjust the size as needed
  ),
    title: Padding(
      padding: EdgeInsets.zero,
      child: Text(
        '${employee.name} ${employee.surname}',
        style: TextStyle(
          fontSize: screenHeight * 0.02,
        ),
      ),
    ),
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSwitchButtonRow(employee),
          _buildAdminSwitchButtonRow(employee),
          _buildRemoveUserButtonRow(employee),
        ],
      ),
    ],
  ),
)
    );
  }

  Widget _buildSwitchButtonRow(Employee employee) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
      child: Row(
        children: [
          Container(
            width: screenWidth * 0.1381,
            child: buildSwitchButton(
                isActive: employee.active,
                activeCount: activeCount,
                numberOfUsers: numberOfUsers,
                onTapRed: () => toggleUserActiveStatus(employee.userId),
                onTapGreen: () => toggleUserActiveStatus(employee.userId),
                onNavigate: _navigateToAdminPageSettings,
                screenHeight: screenHeight),
          ),
          Text(
            '  Aktivacija uporabnika',
            style: TextStyle(
              fontSize: screenHeight * 0.019,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminSwitchButtonRow(Employee employee) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
      child: Row(
        children: [
          Container(
            width: screenWidth * 0.1381,
            child: buildAdminSwitchButton(
                isAdmin: employee.adminPermission,
                activeAdmins: activeAdmins,
                onTap: () => toggleUserAdminStatus(employee.userId),
                onNavigate: _navigateToAdminPageSettings,
                screenHeight: screenHeight),
          ),
          Text(
            '  Admin pravice',
            style: TextStyle(
              fontSize: screenHeight * 0.019,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemoveUserButtonRow(Employee employee) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      child: Row(
        children: [
          Container(
            width: screenWidth * 0.1381, // Set your desired width
            child: IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                  size: screenHeight * 0.035,
                ),
                onPressed: () {
                  _showRemoveUserDialog(employee.userId);
                }),
          ),
          Text(
            '  Odstrani delavca',
            style: TextStyle(
              fontSize: screenHeight * 0.019,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddUserButton() {
    return FloatingActionButton(
      onPressed: () => showAddUserDialog(context, companyId!),
      child: const Icon(
        Icons.add,
        color: Colors.white,
      ),
      backgroundColor: Colors.blue,
      elevation: 10.0,
    );
  }

 void _showRemoveUserDialog(String userId) {
  final currentUser = FirebaseAuth.instance.currentUser;

  // Check if the user is trying to remove themselves
  if (currentUser != null && userId == currentUser.uid) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("POZOR"),
content: const Text("Sami sebe ne morate odstraniti s podjetja, saj s tem lahko podjetje izgubi administratorja.\n\nNajprej določite novega administartorja in nato naj vas novi administrator izbriše s podjetja."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Prekliči"),
            ),
          ],
        );
      },
    );
  } else {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("POTRDITEV"),
          content: const Text(
              "Ali ste prepričani da želite odstraniti osebo z vašega podjetja?\nuporabnika lahko kasneje dodate z njihovim id naslovom."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Prekliči"),
            ),
            TextButton(
              onPressed: () {
                removeUserFromCompany(userId);
                _navigateToAdminPageSettings();
                Navigator.of(context).pop();
                 Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdminPageSettings()
        ),
      );
              },
              child: const Text("Odstrani"),
            ),
          ],
        );
      },
    );
  }
}

  void _navigateToAdminPageSettings() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AdminPageSettings(),
    ));
  }
}

class AdminPageSettings extends StatefulWidget {
  @override
  _AdminPageSettingsState createState() => _AdminPageSettingsState();
}

class Employee {
  String userId;
  String name;
  String surname;
  bool active;
  bool adminPermission;

  Employee(
      {required this.userId,
      required this.name,
      required this.surname,
      required this.active,
      required this.adminPermission});
}
