import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'login_page.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _displayNameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _displayNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _displayNameCtrl.text = user.displayName ?? "user";
      _emailCtrl.text = user.email ?? "";
      _phoneCtrl.text = user.phoneNumber ?? "";
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          // Update Display Name
          if (_displayNameCtrl.text != user.displayName) {
            await user.updateDisplayName(_displayNameCtrl.text);
          }

          // Reload user to get latest data
          await user.reload();
          user = FirebaseAuth.instance.currentUser;

          if (mounted) {
            setState(() {
              _loadUserData();
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Profile Updated Successfully")),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error updating profile: $e")),
            );
          }
        }
      }
    }
  }

  void _changePasswordSheet() {
    final TextEditingController oldPass = TextEditingController();
    final TextEditingController newPass = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Change Password",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _bottomField(label: "Old Password", controller: oldPass),
              const SizedBox(height: 15),
              _bottomField(label: "New Password", controller: newPass),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff005A9C),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    String oldPassword = oldPass.text.trim();
                    String newPassword = newPass.text.trim();

                    if (oldPassword.isEmpty || newPassword.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please fill all fields")),
                      );
                      return;
                    }

                    if (newPassword.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                "New password must be at least 6 characters")),
                      );
                      return;
                    }

                    User? user = FirebaseAuth.instance.currentUser;

                    if (user != null && user.email != null) {
                      try {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );

                        // Reauthenticate
                        AuthCredential credential =
                            EmailAuthProvider.credential(
                          email: user.email!,
                          password: oldPassword,
                        );

                        await user.reauthenticateWithCredential(credential);

                        // Update Password
                        await user.updatePassword(newPassword);

                        Navigator.pop(context); // Close loading dialog
                        Navigator.pop(context); // Close bottom sheet

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Password Updated Successfully")),
                        );
                      } on FirebaseAuthException catch (e) {
                        Navigator.pop(context); // Close loading dialog
                        String message = "Error updating password";
                        if (e.code == 'wrong-password') {
                          message = 'Incorrect old password.';
                        } else if (e.code == 'weak-password') {
                          message = 'The new password is too weak.';
                        } else {
                          message = e.message ?? "An error occurred";
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      } catch (e) {
                        Navigator.pop(context); // Close loading dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e")),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("No user logged in")),
                      );
                    }
                  },
                  child: const Text(
                    "Update Password",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _changeEmailSheet() {
    final TextEditingController newEmailCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Change Email",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: newEmailCtrl,
                decoration: InputDecoration(
                  labelText: "New Email",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff005A9C),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _emailCtrl.text = newEmailCtrl.text;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Update Email",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2F4F7),
      appBar: AppBar(
        backgroundColor: const Color(0xffF2F4F7),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          },
        ),
        title: const Text(
          "My Profile",
          style: TextStyle(
            color: Color(0xff111827),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _profileHeader(),
              const SizedBox(height: 25),
              _cardWrapper(
                children: [
                  _buildField(
                    label: "Display Name",
                    controller: _displayNameCtrl,
                    editable: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Display name cannot be empty";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildField(
                    label: "Email Address",
                    controller: _emailCtrl,
                    editable: false,
                  ),
                  const SizedBox(height: 10),
                  _changeOption(
                    text: "Change Email",
                    onTap: _changeEmailSheet,
                  ),
                  const SizedBox(height: 20),
                  // _buildField(
                  //   label: "Phone Number",
                  //   controller: _phoneCtrl,
                  //   editable: true,
                  //   validator: (value) {
                  //     if (value == null || value.trim().isEmpty) {
                  //       return "Phone number is required";
                  //     }
                  //     if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                  //       return "Phone must contain only numbers";
                  //     }
                  //     return null;
                  //   },
                  // ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff005A9C),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _changePasswordSheet,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xff005A9C)),
                    backgroundColor: const Color(0xffE6F0F6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Change Password",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xff005A9C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    backgroundColor: Colors.redAccent.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileHeader() {
    File? image2;
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            final ImagePicker picker = ImagePicker();
            final XFile? image =
                await picker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              image2 = File(image.path);
              print("image 2 is $image2");
            }
            setState(() {});
          },
          child: Stack(
            children: [
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(
                      "assets/images/profile_picture.jpeg",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xff005A9C),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _displayNameCtrl.text,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xff111827),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _emailCtrl.text,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xff6B7280),
          ),
        ),
      ],
    );
  }

  Widget _cardWrapper({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required bool editable,
    FormFieldValidator<String>? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xff111827),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: !editable,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: editable ? Colors.white : const Color(0xffF3F4F6),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _changeOption({required String text, required VoidCallback onTap}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xff005A9C),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _bottomField({
    required String label,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
