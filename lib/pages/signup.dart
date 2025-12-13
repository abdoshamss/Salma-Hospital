import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'login_page.dart';

class CreateAccountModernScreen extends StatefulWidget {
  const CreateAccountModernScreen({super.key});

  @override
  State<CreateAccountModernScreen> createState() =>
      _CreateAccountModernScreenState();
}

class _CreateAccountModernScreenState extends State<CreateAccountModernScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();

  bool showPass = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4E73DF), Color(0xFF1CC7D0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "Join us and manage your medical info easily.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 25),
                      customField(
                        controller: fullNameCtrl,
                        label: "Full Name",
                        icon: Icons.person,
                        validator: (v) =>
                            v!.isEmpty ? "Full name required" : null,
                      ),
                      const SizedBox(height: 18),
                      customField(
                        controller: emailCtrl,
                        label: "Email",
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) =>
                            v!.contains("@") ? null : "Enter valid email",
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: passwordCtrl,
                        obscureText: !showPass,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              showPass
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                showPass = !showPass;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        validator: (v) =>
                            v!.length < 6 ? "Min 6 characters" : null,
                      ),
                      const SizedBox(height: 18),
                      customField(
                        controller: phoneCtrl,
                        label: "Phone Number",
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                            v!.length < 10 ? "Invalid phone number" : null,
                      ),
                      const SizedBox(height: 25),
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4E73DF), Color(0xFF1CC7D0)],
                          ),
                        ),
                        child: MaterialButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomeScreen(),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const LoginPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Already have an account? Sign In",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget customField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      validator: validator,
    );
  }
}
