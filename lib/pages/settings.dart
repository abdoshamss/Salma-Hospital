import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/local_notifications.dart';
import 'login_page.dart';
import 'profile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  bool? activeNotify;

  Future<void> loadNotificationSettings() async {
    bool? checkActiveNotify =
        await LocalNotificationManage.checkNotificationEnabled();
    setState(() {
      activeNotify = checkActiveNotify;
    });
  }

  toggle(bool value) {
    openAppSettings();
  }

  @override
  initState() {
    loadNotificationSettings();

    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadNotificationSettings();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool backupEnabled = true;
  String selectedLanguage = "English";

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFCCE4FF), Color(0xFFF8FBFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Settings",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0A3D62),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Customize your CareCode experience",
                  style: TextStyle(fontSize: 14, color: Color(0xFF4D6A85)),
                ),
                const SizedBox(height: 22),
                _profileCard(context),
                const SizedBox(height: 27),
                _sectionTitle("Preferences"),
                _settingItem(
                  icon: CupertinoIcons.globe,
                  title: "Language",
                  trailing: Text(
                    selectedLanguage,
                    style: const TextStyle(color: Color(0xFF4D6A85)),
                  ),
                  onTap: _openLanguageSheet,
                ),
                _settingItem(
                  icon: CupertinoIcons.bell_fill,
                  title: "Notifications",
                  trailing: Switch(
                    value: activeNotify ?? false,
                    activeThumbColor: const Color(0xFF1B75D1),
                    onChanged: (value) {
                      setState(() => toggle(activeNotify ?? false));
                    },
                  ),
                ),
                _settingItem(
                  icon: CupertinoIcons.cloud_upload_fill,
                  title: "Backup Medical Records",
                  trailing: Text(
                    backupEnabled ? "Enabled" : "Disabled",
                    style: TextStyle(
                      color: backupEnabled ? Color(0xFF1B8A3E) : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: _openBackupSheet,
                ),
                const SizedBox(height: 22),
                _sectionTitle("Safety"),
                _settingItem(
                  icon: CupertinoIcons.shield_fill,
                  title: "Emergency Info",
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                  onTap: _openEmergencySheet,
                ),
                const SizedBox(height: 22),
                _sectionTitle("About"),
                _settingItem(
                  icon: CupertinoIcons.doc_text_fill,
                  title: "Privacy Policy",
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                  onTap: _openPrivacySheet,
                ),
                const SizedBox(height: 32),
                Center(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 14,
                      ),
                      side: const BorderSide(
                        color: Color(0xFFD63031),
                        width: 1.3,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _confirmLogout,
                    icon: const Icon(Icons.logout, color: Color(0xFFD63031)),
                    label: const Text(
                      "Logout",
                      style: TextStyle(
                        color: Color(0xFFD63031),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    "Version 1.0.0",
                    style: TextStyle(color: Colors.black45, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileCard(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MyProfileScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEBF4FF), Color(0xFFFDFEFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.07),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 35,
              backgroundImage: AssetImage(
                "assets/images/profile_picture.jpeg",
              ),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  FirebaseAuth.instance.currentUser?.displayName ?? "User",
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0A3D62),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Verified Emergency Profile",
                  style: TextStyle(fontSize: 14, color: Color(0xFF4D6A85)),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE1EEFF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                CupertinoIcons.qrcode,
                color: Color(0xFF1B75D1),
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 5),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF4D6A85),
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _settingItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7AB8FF), Color(0xFF4A90E2)],
                ),
                borderRadius: BorderRadius.all(Radius.circular(14)),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0A3D62),
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _openLanguageSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select Language",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            ListTile(
              title: const Text("English"),
              onTap: () {
                setState(() => selectedLanguage = "English");
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("العربية"),
              onTap: () {
                setState(() => selectedLanguage = "Arabic");
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openBackupSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Backup Medical Records",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "CareCode securely stores your child's medical history (diseases, allergies, medications) so it can be accessed instantly through the QR Code—even offline.",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              value: backupEnabled,
              onChanged: (v) {
                setState(() => backupEnabled = v);
              },
              title: const Text("Enable Backup"),
            ),
          ],
        ),
      ),
    );
  }

  void _openEmergencySheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Emergency Information",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              "This section shows:\n\n"
              "• The person’s medical condition\n"
              "• Allergies & critical medications\n"
              "• Emergency steps for helpers\n"
              "• A direct call button to guardian\n\n"
              "This appears instantly when scanning the QR Code.",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  void _openPrivacySheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              "Privacy Policy",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              "CareCode securely stores medical data locally and does not share it with third parties. "
              "All emergency data is only displayed when someone scans the QR Code.",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
