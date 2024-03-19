// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stempl_v1/main.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Registration Page',
      home: RegistrationPage(),
    );
  }
}

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController companyDavcnaController = TextEditingController();
  final TextEditingController companyAdressController = TextEditingController();
  final TextEditingController companyPosteController = TextEditingController();
  final TextEditingController companyPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool registrationButtonPressed = false;

  bool isRegistrationButtonEnabled = false;
  bool isTermsAccepted = false;

  // Dropdown menu options
  List<String> planOptions = [
    'Izberi plan',
    'Samostojni uporabnik',
    'Do 5 delavcev',
    'Do 10 delavcev',
    'Do 20 delavcev'
  ];
  String selectedPlan = 'Izberi plan'; // Default selected plan

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
            ),
          ),
          Column(
            children: [
              Container(
                height: topPadding,
                color: Colors.black,
              ),
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
                    'REGISTRACIJA PODJETJA',
                    style: TextStyle(
                      fontSize: screenHeight * 0.03, // Adjusted size
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Container(
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
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.0),
                  child: CustomScrollView(
                    slivers: [
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.05,
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: screenHeight *
                                          0.04, // Adjusted height
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: screenWidth *
                                              0.01, // Adjusted width
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Registracija administratorja:',
                                            style: TextStyle(
                                              fontSize: screenHeight *
                                                  0.03, // Adjusted size
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.02),
                                    _buildRoundedInput(
                                        labelText: 'Ime',
                                        controller: nameController,
                                        height: screenHeight),
                                    SizedBox(height: screenHeight * 0.01),
                                    _buildRoundedInput(
                                        labelText: 'Priimek',
                                        controller: surnameController,
                                        height: screenHeight),
                                    SizedBox(height: screenHeight * 0.01),
                                    _buildRoundedInput(
                                        labelText: 'E-pošta',
                                        controller: emailController,
                                        height: screenHeight),
                                    SizedBox(height: screenHeight * 0.01),
                                    _buildRoundedInput(
                                      labelText: 'Geslo',
                                      controller: passwordController,
                                      height: screenHeight,
                                      obscureText: true,
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    _buildRoundedInput(
                                      labelText: 'Potrdi geslo',
                                      controller: confirmPasswordController,
                                      height: screenHeight,
                                      obscureText: true,
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 2,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Divider(
                                        color: Colors.transparent,
                                        height: 1.0,
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.03),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: screenWidth *
                                              0.01, // Adjusted width
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Registracija podjetja:',
                                            style: TextStyle(
                                              fontSize: screenHeight *
                                                  0.03, // Adjusted size
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.02),
                                    _buildRoundedInput(
                                        labelText: 'Ime podjetja',
                                        controller: companyNameController,
                                        height: screenHeight),
                                    SizedBox(height: screenHeight * 0.01),
                                    _buildRoundedInput(
                                        labelText: 'Davčna št. podjetja',
                                        controller: companyDavcnaController,
                                        height: screenHeight),
                                    SizedBox(height: screenHeight * 0.01),
                                    _buildRoundedInput(
                                        labelText: 'Naslov',
                                        controller: companyAdressController,
                                        height: screenHeight),
                                    SizedBox(height: screenHeight * 0.01),
                                    _buildRoundedInput(
                                        labelText: 'Pošta',
                                        controller: companyPosteController,
                                        height: screenHeight),
                                    SizedBox(height: screenHeight * 0.01),
                                    _buildRoundedInput(
                                        labelText: 'Geslo podjetja',
                                        controller: companyPasswordController,
                                        height: screenHeight),
                                    SizedBox(height: screenHeight * 0.01),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        border: Border.all(
                                          color: registrationButtonPressed
                                              ? (selectedPlan == 'Izberi plan'
                                                  ? Colors.red
                                                  : (_formKey.currentState
                                                              ?.validate() ??
                                                          false)
                                                      ? Colors.grey
                                                      : Colors.grey)
                                              : Colors.grey,
                                        ),
                                      ),
                                      child: DropdownButtonFormField<String>(
                                        value: selectedPlan,
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedPlan =
                                                newValue ?? 'Izberi plan';
                                            registrationButtonPressed =
                                                (selectedPlan !=
                                                        'Izberi plan') &&
                                                    isTermsAccepted &&
                                                    _isPasswordValid();
                                          });
                                        },
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: screenHeight * 0.02,
                                              vertical: 8.0),
                                          enabledBorder: InputBorder.none,
                                        ),
                                        items: planOptions
                                            .map((String plan) =>
                                                DropdownMenuItem<String>(
                                                  value: plan,
                                                  child: Text(
                                                    plan,
                                                    style: TextStyle(
                                                        fontSize: screenHeight *
                                                            0.02), // Adjusted font size
                                                  ),
                                                ))
                                            .toList(),
                                        selectedItemBuilder:
                                            (BuildContext context) {
                                          return planOptions
                                              .map<Widget>((String plan) {
                                            return Text(
                                              plan,
                                              style: TextStyle(
                                                  fontSize: screenHeight *
                                                      0.02), // Adjusted font size
                                            );
                                          }).toList();
                                        },
                                        elevation: 2,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                                14.0), // Adjusted font size
                                        icon: const Icon(Icons.arrow_drop_down),
                                        iconSize: screenHeight * 0.03,
                                        isExpanded: true,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: isTermsAccepted,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              isTermsAccepted = value ?? false;
                                            });
                                          },
                                          activeColor: isTermsAccepted
                                              ? Colors.green
                                              : Colors.transparent,
                                          checkColor: Colors.white,
                                        ),
                                        Text(
                                          'Strinjam se s pogoji uporabe',
                                          style: TextStyle(
                                            fontSize: screenHeight * 0.02,
                                            color: (isTermsAccepted == false &&
                                                    registrationButtonPressed)
                                                ? Colors.red
                                                : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    SizedBox(
                                      height: screenHeight *
                                          0.06, // Adjusted height
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          setState(() {
                                            registrationButtonPressed = true;
                                          });

                                          if (_formKey.currentState != null &&
                                              _formKey.currentState!
                                                  .validate()) {
                                            if (_areAllFieldsFilled()) {
                                               addUserAndCompanyToFirebase();
                                              try {
                                                // Create user account
                                                UserCredential userCredential =
                                                    await FirebaseAuth.instance
                                                        .createUserWithEmailAndPassword(
                                                  email: emailController.text,
                                                  password:
                                                      passwordController.text,
                                                );

                                                // Send verification email
                                                 userCredential.user!
                                                    .sendEmailVerification();

                                                // Show success message to the user
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'E-pošta za preverjanje registracije je bila poslana. '
                                                      'Preverite svoj e-poštni predal in kliknite na povezavo za potrditev.',
                                                    ),
                                                  ),
                                                );
                                              } catch (e) {
                                                print(
                                                    'Error creating user: $e');
                                                // Handle error (show error message, log, etc.)
                                              }
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Prosim izpolnite vsa polja za vstavljanje besedila!',
                                                  ),
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
                                        child: Text(
                                          'Registracija',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: screenHeight *
                                                0.023, // Adjusted size
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isPasswordValid() {
    return passwordController.text == confirmPasswordController.text;
  }

  Future<bool> checkIfCompanyExists(String companyName) async {
    final DatabaseReference companiesRef =
        FirebaseDatabase.instance.reference().child('companies');

    // Use the `once` method to get a DatabaseEvent
    DatabaseEvent event =
        await companiesRef.orderByChild('name').equalTo(companyName).once();

    // Extract the DataSnapshot from the DatabaseEvent
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.value != null) {
      // Company with the given name exists
      return true;
    }

    // Company with the given name does not exist
    return false;
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
            if (registrationButtonPressed) {
              if (value == null || value.isEmpty) {
                return 'To polje je obvezno';
              }
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

  Future<void> addUserAndCompanyToFirebase() async {
    final DatabaseReference usersRef =
        FirebaseDatabase.instance.reference().child("users");
    final DatabaseReference companiesRef =
        FirebaseDatabase.instance.reference().child("companies");

    final String name = nameController.text;
    final String surname = surnameController.text;
    final String email = emailController.text;
    final String password = passwordController.text;
    final String companyName = companyNameController.text;
    final String companyDavcna = companyDavcnaController.text;
    final String companyAddress = companyAdressController.text;
    final String companyPostalCode = companyPosteController.text;
    final String companyPasswordCode = companyPasswordController.text;

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = userCredential.user?.uid ?? "";

      if (userId.isNotEmpty) {
        DatabaseReference newUserRef = usersRef.child(userId);
        newUserRef.set({
          "name": name,
          "surname": surname,
          "email": email,
          "companyId": null,
          "adminPermission": true,
          "active": true,
        });

        DatabaseReference newCompanyRef = companiesRef.push();
        String companyId = newCompanyRef.key ?? "";

        if (companyId.isNotEmpty) {
          newCompanyRef.set({
            "name": companyName,
            "davcna": companyDavcna,
            "address": companyAddress,
            "postalCode": companyPostalCode,
            "selectedPlan": selectedPlan,
            "companyPassword": companyPasswordCode,
          });

          newUserRef.update({
            "companyId": companyId,
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uporabnik ter podjetje sta shranjena v sistem!'),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding user and company data: $error'),
        ),
      );
    }

    nameController.clear();
    surnameController.clear();
    emailController.clear();
    passwordController.clear();
    companyNameController.clear();
    companyDavcnaController.clear();
    companyAdressController.clear();
    companyPosteController.clear();
    confirmPasswordController.clear();
    companyPasswordController.clear();
    selectedPlan = 'Izberi plan';
  }

  List<DropdownMenuItem<String>> _buildDropdownItemsWithDividers() {
    List<DropdownMenuItem<String>> items = [];
    for (String plan in planOptions) {
      items.add(DropdownMenuItem<String>(
        value: plan,
        child: Text(plan),
      ));
      items.add(DropdownMenuItem<String>(
        // Divider
        value: 'divider_$plan', // Unique value for dividers
        child: Divider(
          height: 1,
          color: Colors.grey,
        ),
      ));
    }
    return items;
  }

  bool _areAllFieldsFilled() {
    return nameController.text.isNotEmpty &&
        surnameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        companyNameController.text.isNotEmpty &&
        companyPasswordController.text.isNotEmpty &&
        companyDavcnaController.text.isNotEmpty &&
        companyAdressController.text.isNotEmpty &&
        companyPosteController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        companyPasswordController.text.isNotEmpty &&
        selectedPlan != 'Izberi plan' &&
        isTermsAccepted == true;
  }
}
