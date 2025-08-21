import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pas/main.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController =
      TextEditingController();

  String? selectedOrganization;
  String? selectedRole;
  List<String> organizations = [];
  List<String> availableSkills = [];
  List<String> selectedSkills = [];
  final List<String> roles = ['Worker', 'Employer'];
  String? selectedOrgUsername;
  File? resumeFile;
  String? resumeUrl;

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    loadOrganizations();
  }

  void loadOrganizations() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('organizations').get();
    setState(() {
      organizations = snapshot.docs
          .map((doc) => doc['organization_name'].toString())
          .toList();
    });
  }

  void loadSkillsForOrganization(String organization) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('organizations')
        .where('organization_name', isEqualTo: organization)
        .get();

    if (snapshot.docs.isNotEmpty) {
      var orgDoc = snapshot.docs.first;
      List<String> skills = List<String>.from(orgDoc['skills'] ?? []);
      String? username = orgDoc['username'];
      setState(() {
        availableSkills = skills;
        selectedSkills = [];
        selectedOrgUsername = username;
      });
    }
  }

  Future<bool> isUsernameOrEmailTaken(String username, String email) async {
    QuerySnapshot usernameSnapshot = await FirebaseFirestore.instance
        .collection('workers')
        .where('username', isEqualTo: username)
        .get();

    QuerySnapshot emailSnapshot = await FirebaseFirestore.instance
        .collection('workers')
        .where('email', isEqualTo: email)
        .get();

    if (usernameSnapshot.docs.isNotEmpty || emailSnapshot.docs.isNotEmpty) {
      return true;
    }

    usernameSnapshot = await FirebaseFirestore.instance
        .collection('employers')
        .where('username', isEqualTo: username)
        .get();

    emailSnapshot = await FirebaseFirestore.instance
        .collection('employers')
        .where('email', isEqualTo: email)
        .get();

    return usernameSnapshot.docs.isNotEmpty || emailSnapshot.docs.isNotEmpty;
  }

  void handleSignUp() async {
    String username = usernameController.text.trim();
    String fullName = nameController.text.trim();
    String email = emailController.text.trim();
    String contact = contactController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmpasswordController.text.trim();

    if (username.isEmpty ||
        fullName.isEmpty ||
        email.isEmpty ||
        contact.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Password must be at least 6 characters long.")),
      );
      return;
    }

    if (!RegExp(r'^\d{11}$').hasMatch(contact)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Contact number must be exactly 11 digits")),
      );
      return;
    }

    if (selectedRole == "Worker" && selectedOrganization == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an organization")),
      );
      return;
    }

    bool isTaken = await isUsernameOrEmailTaken(username, email);
    if (isTaken) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username or Email is already taken")),
      );
      return;
    }

    try {
      if (selectedRole == "Employer") {
        final employerData = {
          'username': username,
          'fullName': fullName,
          'email': email,
          'contact': contact,
          'password': password,
          'role': selectedRole,
          'profilePic': "default_profile_pic_url",
          'projects': {
            'total': [],
            'pending': [],
            'approved': [],
            'completed': [],
            'remaining': []
          }
        };

        await FirebaseFirestore.instance
            .collection('employers')
            .doc(username)
            .set(employerData);

        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        await FirebaseFirestore.instance.collection('newmembers').add({
          'username': username,
          'fullName': fullName,
          'email': email,
          'contact': contact,
          'password': password,
          'organization': selectedOrganization,
          'orgusername': selectedOrgUsername,
          'role': selectedRole,
          'skills': selectedSkills,
          'profilePic': "default_profile_pic_url",
          'resume': resumeUrl ?? "dummy_resume_url",
          'projects': {
            'total': [],
            'pending': [],
            'completed': [],
            'remaining': []
          }
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sign-up successful!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyApp()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              "Sign Up",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4DA8),
              ),
            ),
            const SizedBox(height: 10),
            _buildTextField(usernameController, "User Name", Icons.person),
            _buildTextField(nameController, "Full Name", Icons.person),
            _buildTextField(emailController, "Email", Icons.email),
            _buildTextField(contactController, "Contact Number", Icons.phone),
            _buildPasswordField(passwordController, "Password"),
            _buildPasswordField(confirmpasswordController, "Confirm Password"),
            const SizedBox(height: 10),
            _buildRoleDropdown(),
            if (selectedRole == "Worker") _buildOrganizationDropdown(),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D4DA8),
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: handleSignUp,
              child: const Text(
                "SIGN UP",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyApp()),
                );
              },
              child: const Text(
                "Already have an account? Log in",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label) {
    bool isPassword = label == "Password";
    bool isConfirmPassword = label == "Confirm Password";

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? !_passwordVisible : !_confirmPasswordVisible,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock),
          suffixIcon: IconButton(
            icon: Icon(
              (isPassword ? _passwordVisible : _confirmPasswordVisible)
                  ? Icons.visibility
                  : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                if (isPassword) {
                  _passwordVisible = !_passwordVisible;
                } else {
                  _confirmPasswordVisible = !_confirmPasswordVisible;
                }
              });
            },
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedRole,
      onChanged: (value) {
        setState(() {
          selectedRole = value;
        });
      },
      items: roles.map((role) {
        return DropdownMenuItem(value: role, child: Text(role));
      }).toList(),
      decoration: _buildInputDecoration("Select Role"),
    );
  }

  Widget _buildOrganizationDropdown() {
    return Column(
      children: [
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: selectedOrganization,
          onChanged: (value) {
            setState(() {
              selectedOrganization = value;
              loadSkillsForOrganization(value!);
            });
          },
          items: organizations.map((org) {
            return DropdownMenuItem(value: org, child: Text(org));
          }).toList(),
          decoration: _buildInputDecoration("Select Organization"),
        ),
        const SizedBox(height: 10),
        Wrap(
          children: availableSkills.map((skill) {
            bool isSelected = selectedSkills.contains(skill);
            return ChoiceChip(
              label: Text(skill),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedSkills.add(skill);
                  } else {
                    selectedSkills.remove(skill);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
