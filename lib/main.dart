import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'signup.dart';
import 'WorkerDashboard.dart';
import 'Emp_Dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PAS',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const LoginSignUp(),
    );
  }
}

class LoginSignUp extends StatefulWidget {
  const LoginSignUp({super.key});

  @override
  State<LoginSignUp> createState() => _LoginSignUpState();
}

class _LoginSignUpState extends State<LoginSignUp> {
  bool isLogin = true;
  final TextEditingController loginController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  String userType = "Worker"; // Default role is Worker

  // Handle login process
  void handleLogin() async {
    String email = loginController.text.trim();
    String password = loginPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showMessage("Please fill all fields.");
      return;
    }

    try {
      // Authenticate with Firebase
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user == null) {
        showMessage("User not found.");
        return;
      }

      String userId = user.uid;
      String collection = userType == "Worker" ? "workers" : "employers";

      // Check if user exists in the Firestore collection
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .where('email',
              isEqualTo: email) // Match by email, assuming email field exists
          .get();

      if (snapshot.docs.isNotEmpty) {
        var userData = snapshot.docs.first.data() as Map<String, dynamic>;

        // Navigate to respective dashboard
        if (userType == "Worker") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => Worker_Dashboard(userdata: userData)),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => Employer_Dashoboard(userdata: userData)),
          );
        }
      } else {
        showMessage("No account found in the $collection.");
      }
    } catch (e) {
      showMessage("Login failed: ${e.toString()}");
    }
  }

  // Show message to user
  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDECF6),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: isLogin ? buildLoginForm() : SignupScreen(),
        ),
      ),
    );
  }

  // Login form UI
  Widget buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Welcome",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D4DA8),
            ),
          ),
          const SizedBox(height: 20),
          const Icon(Icons.assignment, size: 80, color: Color(0xFF5D4DA8)),
          const SizedBox(height: 20),

          // Email Field
          TextField(
            controller: loginController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.email),
              labelText: "Email",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // Password Field
          TextField(
            controller: loginPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock),
              labelText: "Password",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // Role Dropdown
          DropdownButtonFormField<String>(
            value: userType,
            items: ["Worker", "Employer"].map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                userType = value!;
              });
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.account_circle),
              labelText: "Select Role",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Login Button
          ElevatedButton(
            onPressed: handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5D4DA8),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("LOGIN", style: TextStyle(color: Colors.white)),
          ),

          const SizedBox(height: 15),

          // Switch to SignUp
          GestureDetector(
            onTap: () {
              setState(() {
                isLogin = false;
              });
            },
            child: const Text(
              "Don't have an account? Sign up",
              style: TextStyle(
                color: Color(0xFF5D4DA8),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
