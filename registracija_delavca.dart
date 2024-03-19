// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Registration Page',
      home: RegistrationWorkerPage(),
    );
  }
}

class RegistrationWorkerPage extends StatefulWidget {
  const RegistrationWorkerPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationWorkerPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController companyPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Add a GlobalKey for the form

  bool isCompanyListVisible = false;
  final TextEditingController companySearchController = TextEditingController();
  List<String> filteredCompanies = [];

  List<String> companyNames = [];
  String selectedCompany = '';
  Map<dynamic, dynamic> companies = {};

  final FirebaseAuth _auth =
      FirebaseAuth.instance; // Define _auth at class level
  final DatabaseReference _dbRef =
      // ignore: deprecated_member_use
      FirebaseDatabase.instance.reference(); // Define _dbRef at class level

  @override
  void initState() {
    super.initState();
    fetchCompanyNames();
    companySearchController.addListener(() {
      onSearchTextChanged(companySearchController.text);
    });
  }

  Future<void> fetchCompanyNames() async {
    final DatabaseEvent companyDataSnapshot =
        await _dbRef.child("companies").once();
    if (companyDataSnapshot.snapshot.value != null) {
      companies = companyDataSnapshot.snapshot.value as Map<dynamic, dynamic>;
      final names = companies.keys
          .map((key) => companies[key]['name'].toString())
          .toList();
      setState(() {
        companyNames = names;
        selectedCompany = companyNames.isNotEmpty ? companyNames.first : '';
      });
    }
  }

  void onSearchTextChanged(String query) {
    setState(() {
      filteredCompanies = companyNames.where((company) {
        return company.toLowerCase().contains(query.toLowerCase());
      }).toList();
      isCompanyListVisible = true; // Show the list when there's a search query
    });
  }

  Widget _buildRoundedInput({
    required String labelText,
    required TextEditingController controller,
    required double height,
    bool obscureText = false,
  }) {
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: height * 0.02,
            vertical: 0.0), // Adjusted vertical padding
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: (value) {
            // Check if the registration button has been pressed before showing validation error
            if (value == null || value.isEmpty) {
              return 'To polje je obvezno';
            }

            return null;
          },
          style: TextStyle(fontSize: height * 0.021), // Adjusted font size

          decoration: InputDecoration(
            labelText: labelText,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              colors: [Color.fromARGB(199, 119, 192, 252), Colors.white],
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
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: screenHeight * 0.03,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Text(
                    'REGISTRACIJA DELAVCA',
                    style: TextStyle(
                      fontSize: screenHeight * 0.03, // Adjusted size
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
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
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.05), // Adjust the horizontal margin
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: screenHeight*0.02),
                                _buildRoundedInput(
                                    labelText: 'Ime',
                                    controller: nameController,
                                    height: screenHeight),
                                SizedBox(height: screenHeight*0.01),
                                _buildRoundedInput(
                                    labelText: 'Priimek',
                                    controller: surnameController,
                                    height: screenHeight),
                                SizedBox(height: screenHeight*0.01),
                                _buildRoundedInput(
                                    labelText: 'Email',
                                    controller: emailController,
                                    height: screenHeight),
                                SizedBox(height: screenHeight*0.01),
                                _buildRoundedInput(
                                    labelText: 'Geslo',
                                    controller: passwordController,
                                    obscureText: true,
                                    height: screenHeight),
                                SizedBox(height: screenHeight*0.01),
                                _buildRoundedInput(
                                    labelText: 'Poišči podjetje',
                                    controller: companySearchController,
                                    height: screenHeight),
                                Visibility(
                                  visible: isCompanyListVisible &&
                                      companySearchController.text.isNotEmpty,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors
                                          .white, // Set the background color
                                      borderRadius: BorderRadius.circular(
                                          15.0), // Adjust border radius as needed
                                      border: Border.all(
                                        color:
                                            Colors.grey, // Set the border color
                                        width: 1.0, // Set the border width
                                      ),
                                    ),
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      itemCount: filteredCompanies.length,
                                      separatorBuilder:
                                          (BuildContext context, int index) {
                                        // Add a gray line separator
                                        return const Divider(
                                          color: Colors.grey,
                                          height: 1,
                                        );
                                      },
                                      itemBuilder: (context, index) {
                                        final sortedCompanies =
                                            filteredCompanies..sort();
                                        final company = sortedCompanies[index];
                                        return ListTile(
                                          title: Text(company),
                                          onTap: () {
                                            setState(() {
                                              selectedCompany = company;
                                              companySearchController.text =
                                                  company;
                                              isCompanyListVisible = false;
                                            });
                                            FocusScope.of(context)
                                                .unfocus(); // Hide the keyboard
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(height: screenHeight*0.01),
                                _buildRoundedInput(
                                    labelText: 'Geslo podjetja',
                                    controller: companyPasswordController,
                                    height: screenHeight),
                                SizedBox(height: screenHeight*0.01),
                                Center(
                                  child: Container(
                                    margin:  EdgeInsets.only(top: screenHeight*0.025),
                                    width: screenWidth,
                                    height: 50.0,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (_formKey.currentState != null &&
                                            _formKey.currentState!.validate()) {
                                          // Check if all required fields are not empty
                                          if (nameController.text.isNotEmpty &&
                                              surnameController
                                                  .text.isNotEmpty &&
                                              emailController.text.isNotEmpty &&
                                              passwordController
                                                  .text.isNotEmpty &&
                                              companySearchController
                                                  .text.isNotEmpty &&
                                              companyPasswordController
                                                  .text.isNotEmpty) {
                                            // All required fields are filled, proceed with registration
                                            registerUser();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const HomeScreen(),
                                              ),
                                            );
                                          } else {
                                            // Show a SnackBar if not all fields are filled
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Prosim izpolnite vsa polja za vstavljanje besedila!'),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        primary:
                                            Color.fromARGB(255, 33, 149, 243),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(35.0),
                                        ),
                                      ),
                                      child:  Text(
                                        'Registracija',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: screenHeight *
                                                0.023,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ],
    ));
  }

  Future<void> registerUser() async {
    final String name = nameController.text;
    final String surname = surnameController.text;
    final String email = emailController.text;
    final String password = passwordController.text;
    final String enteredCompanyPassword = companyPasswordController.text;

    // ... (rest of your code)
    String selectedCompanyId = '';
    for (final entry in companies.entries) {
      if (entry.value['name'] == selectedCompany) {
        selectedCompanyId = entry.key;
        break;
      }
    }

    // Retrieve the correct company password
    String correctCompanyPassword = '';
    if (companies.containsKey(selectedCompanyId)) {
      correctCompanyPassword = companies[selectedCompanyId]['companyPassword'];
    }

    // Check if the entered company password matches the correct one
    if (enteredCompanyPassword != correctCompanyPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nepravilno geslo podjetja'),
        ),
      );
      return; // Don't proceed with user registration
    }
    String capitalize(String input) {
      if (input.isEmpty) {
        return input;
      }
      return input[0].toUpperCase() + input.substring(1);
    }

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the generated UID for the user
      String userId = userCredential.user?.uid ?? "";

      if (userId.isNotEmpty) {
        // Push user data with the UID as the key
        DatabaseReference newUserRef = _dbRef.child("users").child(userId);
        newUserRef.set({
          "name": capitalize(name),
          "surname": capitalize(surname),
          "email": email,
          "companyId": selectedCompanyId,
          "adminPermission": false,
          "active": false // Save the selected company ID
        });

        // User data saved successfully
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uporabnik shranjen v sistem!'),
          ),
        );
      }
    } catch (error) {
      // Handle errors here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Napaka pri registraciji uporabnika: $error'),
        ),
      );
    }

    // Clear the input fields
    nameController.clear();
    surnameController.clear();
    emailController.clear();
    passwordController.clear();
    companyPasswordController.clear();
    companySearchController.clear();
  }
}
