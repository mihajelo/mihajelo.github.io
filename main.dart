// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, unused_local_variable

import 'dart:developer';
import 'gpay.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:pay/pay.dart';
import 'package:permission_handler/permission_handler.dart';
import 'registracija.dart';
import 'registracija_delavca.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bottom_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      appId: "1:252279026147:android:23c26baf654d36368e70d6",
      messagingSenderId: '252279026147',
      apiKey: "AIzaSyBF4xvBRRIT--UDOLyH81lRg2JdJvWpJVo",
      authDomain: 'stempl-a0d50.firebaseapp.com',
      projectId: 'stempl-a0d50',
      databaseURL:
          "https://stempl-a0d50-default-rtdb.europe-west1.firebasedatabase.app",
    ),
  );

  Intl.defaultLocale = 'sl_SI';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Login and Registration',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;
  bool obscurePassword = true;
  late Future<bool> _userCanPay;

  Pay payClient = Pay.withAssets(['gpay.json']);

  @override
  void initState() {
    super.initState();
    _userCanPay = payClient.userCanPay(PayProvider.google_pay);

    retrieveLoginData();
    if (rememberMe) {
      _autoSignIn(context);
    }
  }

  void _signIn(BuildContext context) async {
    final String name = usernameController.text;
    final String password = passwordController.text;

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: name,
        password: password,
      );

      User? user = userCredential.user;
      if (rememberMe) {
        saveLoginData(name, password);
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BottomBar(
            currentIndex: 1,
          ),
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("NAPAKA PRI PRIJAVI"),
            content: Text(
                "Preverite, če ste vpisali pravilno uporabniško ime in geslo."),
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

  void _autoSignIn(BuildContext context) async {
    final String name = usernameController.text;
    final String password = passwordController.text;

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: name,
        password: password,
      );

      User? user = userCredential.user;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BottomBar(
            currentIndex: 1,
          ),
        ),
      );
    } catch (e) {
      // Handle the case when automatic sign-in fails (e.g., credentials are no longer valid)
    }
  }

  // Save data when the user logs in
  void saveLoginData(String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username', rememberMe ? username : '');
    prefs.setString('password', rememberMe ? password : '');
  }

// Retrieve data when initializing the login page
  void retrieveLoginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      usernameController.text = prefs.getString('username') ?? '';
      passwordController.text = prefs.getString('password') ?? '';
      rememberMe = prefs.getString('username') != null &&
          prefs.getString('password') != null;
    });
  }

  Future<bool> checkLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isGranted) {
      // Permission is granted
      return true;
    } else if (status.isDenied) {
      // Permission is denied, request it
      var result = await Permission.location.request();

      if (result.isGranted) {
        // Permission granted
        return true;
      } else {
        // Permission denied
        return false;
      }
    } else {
      // First time requesting permission
      var result = await Permission.location.request();

      if (result.isGranted) {
        // Permission granted
        return true;
      } else {
        // Permission denied
        return false;
      }
    }
  }

  void _signInAdmin(BuildContext context) async {
    const String adminEmail = 'admin@gmail.com';
    const String adminPassword = 'admin123';

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );

      User? user = userCredential.user;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BottomBar(
            currentIndex: 1,
          ),
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Admin Sign-In Error"),
            content: Text("An error occurred during admin sign-in: $e"),
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

  void clearLoginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('username');
    prefs.remove('password');
  }

  void _resetPassword(BuildContext context) async {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Ponastavi geslo"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Vpišite svoj email naslov:"),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Email",
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Prekliči"),
            ),
            TextButton(
              onPressed: () async {
                final String email = emailController.text;

                try {
                  // Attempt to create a user with a dummy password
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: email,
                    password: "dummyPassword",
                  );

                  // If successful, the email is not registered
                  Navigator.of(context).pop(); // Close the dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Neveljaven email naslov"),
                        content: Text(
                            "Vpisan email naslov ni shranjen v našem sistemu."),
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
                  // If an error occurs, check if it's an email already registered error
                  if (e is FirebaseAuthException &&
                      e.code == 'email-already-in-use') {
                    // Email is registered, send password reset email
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: email,
                    );

                    Navigator.of(context).pop(); // Close the dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Ponastavitev gesla."),
                          content: Text(
                            "Email z navodili za ponastavitev gesla je bil poslan na $email.",
                          ),
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
                  } else {
                    // Handle other errors, e.g., network issues
                    print("Error: $e");
                  }
                }
              },
              child: const Text("Send"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;
          EdgeInsets padding = MediaQuery.of(context).padding;
          double topPadding = padding.top;

          return Stack(
            children: [
              Positioned(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromARGB(199, 119, 192, 252),
                        Colors.white
                      ],
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
                                  child: Stack(
                                    children: [
                                      SingleChildScrollView(
                                        child: Padding(
                                          padding: EdgeInsets.all(0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height: screenHeight * 0.03,
                                              ),
                                              Positioned(
                                                top: topPadding,
                                                right: 0,
                                                child: Image.asset(
                                                  'assets/StemplLogo1.png',
                                                  width: 130,
                                                  height: 131,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              SizedBox(
                                                  height: screenHeight * 0.025),
                                              TextField(
                                                controller: usernameController,
                                                decoration: InputDecoration(
                                                  labelText: 'Email',
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                    vertical:
                                                        screenHeight * 0.02,
                                                    horizontal:
                                                        screenWidth * 0.044,
                                                  ),
                                                  labelStyle: TextStyle(
                                                    fontSize:
                                                        screenHeight * 0.025,
                                                  ),
                                                ),
                                                onSubmitted: (_) =>
                                                    _signIn(context),
                                              ),
                                              SizedBox(
                                                  height: screenHeight * 0.025),
                                              TextField(
                                                controller: passwordController,
                                                decoration: InputDecoration(
                                                  labelText: 'Geslo',
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30.0), // Adjust the border radius
                                                  ),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                    vertical: screenHeight *
                                                        0.01, // Adjust the vertical padding
                                                    horizontal:
                                                        screenWidth * 0.044,
                                                  ),
                                                  labelStyle: TextStyle(
                                                    fontSize:
                                                        screenHeight * 0.025,
                                                  ),
                                                  suffixIcon: IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        obscurePassword =
                                                            !obscurePassword;
                                                      });
                                                    },
                                                    iconSize:
                                                        screenHeight * 0.03,
                                                    icon: Icon(
                                                      obscurePassword
                                                          ? Icons.visibility
                                                          : Icons
                                                              .visibility_off,
                                                    ),
                                                  ),
                                                ),
                                                obscureText: obscurePassword,
                                                onSubmitted: (_) =>
                                                    _signIn(context),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Checkbox(
                                                        value: rememberMe,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            rememberMe = value!;
                                                            if (!rememberMe) {
                                                              clearLoginData();
                                                            }
                                                          });
                                                        },
                                                        activeColor: rememberMe
                                                            ? Colors.green
                                                            : Colors.red,
                                                        materialTapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                        visualDensity:
                                                            VisualDensity
                                                                .compact,
                                                        checkColor:
                                                            Colors.white,
                                                        tristate: false,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  screenWidth *
                                                                      0.015),
                                                        ),
                                                        side: BorderSide(
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Zapomni si me',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize:
                                                              screenHeight *
                                                                  0.02,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      _resetPassword(context);
                                                    },
                                                    child: Text(
                                                      'Pozabljeno geslo?',
                                                      style: TextStyle(
                                                        color: Colors.blue,
                                                        fontSize:
                                                            screenHeight * 0.02,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                  height: screenHeight * 0.025),
                                              SizedBox(
                                                width: screenWidth / 2,
                                                height: screenHeight * 0.06,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    _signIn(context);
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: Colors.blue,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              screenWidth *
                                                                  0.06),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'Prijava',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          screenHeight * 0.025,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                  height: screenHeight * 0.037),
                                              Container(
                                                width: screenWidth,
                                                alignment: Alignment.center,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        height: screenHeight *
                                                            0.0012,
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 197, 193, 193),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        horizontal:
                                                            screenWidth * 0.02,
                                                      ),
                                                      child: Text(
                                                        'REGISTRACIJA',
                                                        style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255,
                                                              197,
                                                              193,
                                                              193),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        height: screenHeight *
                                                            0.0012,
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 197, 193, 193),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                  height:
                                                      screenHeight * 0.0125),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: screenWidth / 3,
                                                    height:
                                                        screenHeight * 0.062,
                                                    child: OutlinedButton(
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                RegistrationPage(),
                                                          ),
                                                        );
                                                      },
                                                      style: OutlinedButton
                                                          .styleFrom(
                                                        primary: const Color
                                                            .fromARGB(
                                                            0, 33, 149, 243),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      screenWidth *
                                                                          0.06),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        'Podjetja',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize:
                                                              screenHeight *
                                                                  0.025,
                                                          color: Colors.blue,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: screenWidth * 0.027,
                                                  ),
                                                  SizedBox(
                                                    width: screenWidth / 3,
                                                    height:
                                                        screenHeight * 0.062,
                                                    child: OutlinedButton(
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                RegistrationWorkerPage(),
                                                          ),
                                                        );
                                                      },
                                                      style: OutlinedButton
                                                          .styleFrom(
                                                        primary: const Color
                                                            .fromARGB(
                                                            0, 33, 149, 243),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      screenWidth *
                                                                          0.06),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        'Delavca',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize:
                                                              screenHeight *
                                                                  0.025,
                                                          color: Colors.blue,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height:
                                                        screenHeight * 0.125,
                                                  ),
                                                ],
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  // Navigate to the second page when the button is pressed.
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            GPayPage()),
                                                  );
                                                },
                                                child:
                                                    Text('Go to Second Page'),
                                              ),
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
