import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'qr.dart';

class MedicalRecordScreen extends StatefulWidget {
  const MedicalRecordScreen({super.key});

  @override
  State<MedicalRecordScreen> createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends State<MedicalRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _criticalAllergiesController = TextEditingController();
  final TextEditingController _guardianPhoneController = TextEditingController();
  final TextEditingController _lastVisitController = TextEditingController();

  String? _selectedBloodType;
  final List<String> _bloodTypes = ['O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'];
  Map<String, String>? _savedMedicalData;

  List<TextEditingController> _allergiesControllers = [TextEditingController()];
  List<TextEditingController> _medicationsControllers = [TextEditingController()];

  void _saveData() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _savedMedicalData = {
          "name": _nameController.text,
          "bloodType": _selectedBloodType ?? '',
          "allergies": _allergiesControllers.map((c) => c.text).where((t) => t.isNotEmpty).join(', '),
          "criticalAllergies": _criticalAllergiesController.text,
          "medications": _medicationsControllers.map((c) => c.text).where((t) => t.isNotEmpty).join(', '),
          "guardianPhone": _guardianPhoneController.text,
          "lastVisit": _lastVisitController.text,
        };
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _goToQRScreen() {
    if (_savedMedicalData != null) {
      String jsonData = jsonEncode(_savedMedicalData);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => QRScreen(data: jsonData)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please save the data first!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF4B5563), fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, color: Color(0xFF256D85)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) return 'This field is required';
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required List<String> items,
    String? selectedValue,
    required ValueChanged<String?> onChanged,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF4B5563), fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, color: Color(0xFF256D85)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        validator: isRequired ? (v) => v == null || v.isEmpty ? 'This field is required' : null : null,
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) controller.text = "${picked.day}/${picked.month}/${picked.year}";
  }

  Widget _dynamicListField({
    required String label,
    required IconData icon,
    required List<TextEditingController> controllers,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF256D85))),
        const SizedBox(height: 8),
        ...controllers.map((controller) => Row(
              children: [
                Expanded(child: _buildTextField(controller: controller, label: '', icon: icon)),
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () => setState(() => controllers.remove(controller)),
                ),
              ],
            )),
        ElevatedButton.icon(
          onPressed: () => setState(() => controllers.add(TextEditingController())),
          icon: const Icon(Icons.add),
          label: Text('Add $label'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF256D85),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 45),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F2FF), Color(0xFFDFFCF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _iconButton(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
                    const Text(
                      'Medical Record',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF256D85)),
                    ),
                    _iconButton(Icons.save, _saveData),
                  ],
                ),
              ),
              
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _sectionCard(
                        title: 'Basic Info',
                        icon: Icons.person_outline,
                        iconColor: Colors.white,
                        iconBg: Color(0xFF256D85),
                        children: [
                          _buildTextField(controller: _nameController, label: 'Full Name', icon: Icons.badge, isRequired: true),
                          _buildDropdown(
                            label: 'Blood Type',
                            icon: Icons.bloodtype,
                            items: _bloodTypes,
                            selectedValue: _selectedBloodType,
                            onChanged: (val) => setState(() => _selectedBloodType = val),
                            isRequired: true,
                          ),
                        ],
                      ),
                      _sectionCard(
                        title: 'Allergies',
                        icon: Icons.warning_amber_outlined,
                        iconColor: Colors.redAccent,
                        iconBg: Colors.red.shade200,
                        children: [
                          _dynamicListField(label: 'Allergy', icon: Icons.sick, controllers: _allergiesControllers),
                          _buildTextField(controller: _criticalAllergiesController, label: 'Critical Allergies', icon: Icons.dangerous, maxLines: 2),
                        ],
                      ),
                      _sectionCard(
                        title: 'Medications',
                        icon: Icons.medical_services,
                        iconColor: Colors.white,
                        iconBg: Color(0xFF256D85),
                        children: [
                          _dynamicListField(label: 'Medication', icon: Icons.local_pharmacy, controllers: _medicationsControllers),
                          _buildTextField(controller: _lastVisitController, label: 'Last Doctor Visit', icon: Icons.calendar_today, readOnly: true, onTap: () => _selectDate(context, _lastVisitController)),
                        ],
                      ),
                      _sectionCard(
                        title: 'Guardian Contact',
                        icon: Icons.verified_user,
                        iconColor: Colors.white,
                        iconBg: Color(0xFF256D85),
                        children: [
                          _buildTextField(controller: _guardianPhoneController, label: 'Emergency contact phone', icon: Icons.phone, isRequired: true, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _goToQRScreen,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF256D85),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Generate QR Code', style: TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconButton(IconData iconData, VoidCallback onPressed) {
    return Container(
      width: 44,
      height: 44,
      child: IconButton(
        icon: Icon(iconData, size: 28, color: Color(0xFF256D85)),
        onPressed: onPressed,
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: Colors.white.withOpacity(0.95),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: iconBg, radius: 20, child: Icon(icon, color: iconColor)),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF256D85))),
              ],
            ),
            const Divider(height: 16, color: Colors.black12),
            Column(children: children),
          ],
        ),
      ),
    );
  }
}

