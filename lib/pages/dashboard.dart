import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/medicalrecord.dart';
import 'package:flutter_application_3/pages/qr.dart';
import 'package:flutter_application_3/pages/medicaldocs.dart';
import 'package:flutter_application_3/pages/settings.dart';
import 'package:flutter_application_3/pages/profile.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPage = 0;


  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _HomePageWidget(), 
      const MedicalRecordScreen(),
      const QRScreen(data: "{}"),
      const MedicalDocumentsApp(),
      const MyProfileScreen(),
      const SettingsScreen(),
    ];
  }

  void _onNavTap(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentPage,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xff3b8ef2),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _currentPage,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          onTap: _onNavTap,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: "Medical Record"),
            BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: "QR"),
            BottomNavigationBarItem(icon: Icon(Icons.file_copy), label: "Docs"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
          ],
        ),
      ),
    );
  }
}

class _HomePageWidget extends StatefulWidget {
  @override
  State<_HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<_HomePageWidget> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, List<String>> notes = {};

  List<String> _getNotesForDay(DateTime day) {
    for (var key in notes.keys) {
      if (isSameDay(key, day)) {
        return notes[key]!;
      }
    }
    return [];
  }

  void _addOrEditNote({String? existingNote, int? index}) {
    TextEditingController controller = TextEditingController();
    if (existingNote != null) {
      controller.text = existingNote;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingNote == null ? "أضف ملاحظة" : "تعديل الملاحظة"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "اكتب الملاحظة هنا"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_selectedDay != null && controller.text.trim().isNotEmpty) {
                final dateKey = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
                notes.putIfAbsent(dateKey, () => []);

                if (existingNote != null && index != null) {
                  notes[dateKey]![index] = controller.text.trim();
                } else {
                  notes[dateKey]!.add(controller.text.trim());
                }

                setState(() {});
              }
              Navigator.pop(context);
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  void _deleteNote(int index) {
    if (_selectedDay != null) {
      final dateKey = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
      notes[dateKey]!.removeAt(index);
      if (notes[dateKey]!.isEmpty) notes.remove(dateKey);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffd5e9ff),
      appBar: AppBar(
        backgroundColor: const Color(0xff3b8ef2),
        title: const Text("Care Code"),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.medication_outlined, color: Colors.white, size: 28),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
              height: 180,
              decoration: const BoxDecoration(
                color: Color(0xff3b8ef2),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(radius: 30, backgroundImage: AssetImage("assets/images/profile_picture.jpeg")),
                  Text(
                    "Hello Marina",
                    style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
              child: Column(
                children: [
                  TableCalendar(
                    firstDay: DateTime.utc(2020),
                    lastDay: DateTime.utc(2030),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                    onDaySelected: (selected, focused) {
                      setState(() {
                        _selectedDay = selected;
                        _focusedDay = focused;
                      });
                    },
                    calendarFormat: CalendarFormat.month,
                    startingDayOfWeek: StartingDayOfWeek.sunday,
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        bool hasNote = _getNotesForDay(day).isNotEmpty;
                        return Container(
                          margin: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: hasNote ? Colors.purple[200] : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text('${day.day}', style: TextStyle(color: hasNote ? Colors.white : Colors.black)),
                        );
                      },
                      todayBuilder: (context, day, focusedDay) {
                        bool hasNote = _getNotesForDay(day).isNotEmpty;
                        return Container(
                          margin: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: hasNote ? Colors.purple[300] : Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Text('${0}', style: TextStyle(color: Colors.white)),
                        );
                      },
                      selectedBuilder: (context, day, focusedDay) {
                        return Container(
                          margin: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(10)),
                          alignment: Alignment.center,
                          child: Text('${day.day}', style: const TextStyle(color: Colors.white)),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_selectedDay != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("الملاحظات:", style: TextStyle(fontSize: 18)),
                        ..._getNotesForDay(_selectedDay!).asMap().entries.map(
                          (entry) {
                            int idx = entry.key;
                            String note = entry.value;
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(note)),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 20, color: Colors.orange),
                                        onPressed: () => _addOrEditNote(existingNote: note, index: idx),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                        onPressed: () => _deleteNote(idx),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addOrEditNote,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.edit),
      ),
    );
  }
}
