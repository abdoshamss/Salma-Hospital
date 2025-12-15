import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
            BottomNavigationBarItem(
                icon: Icon(Icons.medical_services), label: "Medical Record"),
            BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: "QR"),
            BottomNavigationBarItem(icon: Icon(Icons.file_copy), label: "Docs"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: "Settings"),
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

class NoteModel {
  final String id;
  final String content;
  final DateTime date;

  NoteModel({required this.id, required this.content, required this.date});

  factory NoteModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NoteModel(
      id: doc.id,
      content: data['content'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
    );
  }
}

class _HomePageWidgetState extends State<_HomePageWidget> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  Map<DateTime, List<NoteModel>> _groupNotesByDate(List<NoteModel> notes) {
    Map<DateTime, List<NoteModel>> data = {};
    for (var note in notes) {
      DateTime date =
          DateTime.utc(note.date.year, note.date.month, note.date.day);
      if (data[date] == null) {
        data[date] = [];
      }
      data[date]!.add(note);
    }
    return data;
  }

  List<NoteModel> _getNotesForDay(
      DateTime day, Map<DateTime, List<NoteModel>> groupedNotes) {
    DateTime date = DateTime.utc(day.year, day.month, day.day);
    return groupedNotes[date] ?? [];
  }

  void _addOrEditNote({NoteModel? existingNote}) {
    TextEditingController controller = TextEditingController();
    if (existingNote != null) {
      controller.text = existingNote.content;
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
            onPressed: () async {
              final user = _auth.currentUser;
              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Error: User not logged in")),
                );
                return;
              }

              if (controller.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("الملاحظة فارغة")),
                );
                return;
              }

              // Ensure we have a date
              final dateToSave = _selectedDay ?? DateTime.now();

              try {
                if (existingNote != null) {
                  // Update existing
                  await _firestore
                      .collection('notes')
                      .doc(existingNote.id)
                      .update({
                    'content': controller.text.trim(),
                  });
                } else {
                  // Add new
                  await _firestore.collection('notes').add({
                    'userId': user.uid,
                    'content': controller.text.trim(),
                    'date': Timestamp.fromDate(dateToSave),
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                }

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("تم الحفظ بنجاح",
                            style: TextStyle(color: Colors.white)),
                        backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Error saving note: $e"),
                        backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  void _deleteNote(String noteId) async {
    await _firestore.collection('notes').doc(noteId).delete();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in to see your notes.")),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('notes')
          .where('userId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
              body: Center(child: Text("Something went wrong")));
        }

        List<NoteModel> allNotes = [];
        if (snapshot.hasData) {
          allNotes = snapshot.data!.docs
              .map((doc) => NoteModel.fromFirestore(doc))
              .toList();
        }

        final groupedNotes = _groupNotesByDate(allNotes);

        return Scaffold(
          backgroundColor: const Color(0xffd5e9ff),
          appBar: AppBar(
            backgroundColor: const Color(0xff3b8ef2),
            title: const Text("Care Code"),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Icon(Icons.medication_outlined,
                    color: Colors.white, size: 28),
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
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              AssetImage("assets/images/profile_picture.jpeg")),
                      Text(
                        user.displayName != null && user.displayName!.isNotEmpty
                            ? "Hello ${user.displayName!.split(' ')[0]}"
                            : "Hello Marina", // Fallback or use user name
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25)),
                  child: Column(
                    children: [
                      TableCalendar(
                        firstDay: DateTime.utc(2020),
                        lastDay: DateTime.utc(2030),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) =>
                            isSameDay(day, _selectedDay),
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
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
                            bool hasNote =
                                _getNotesForDay(day, groupedNotes).isNotEmpty;
                            return Container(
                              margin: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: hasNote
                                    ? Colors.purple[200]
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text('${day.day}',
                                  style: TextStyle(
                                      color: hasNote
                                          ? Colors.white
                                          : Colors.black)),
                            );
                          },
                          todayBuilder: (context, day, focusedDay) {
                            bool hasNote =
                                _getNotesForDay(day, groupedNotes).isNotEmpty;
                            return Container(
                              margin: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color:
                                    hasNote ? Colors.purple[300] : Colors.blue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text('${day.day}',
                                  style: const TextStyle(color: Colors.white)),
                            );
                          },
                          selectedBuilder: (context, day, focusedDay) {
                            return Container(
                              margin: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                  color: Colors.blueAccent,
                                  borderRadius: BorderRadius.circular(10)),
                              alignment: Alignment.center,
                              child: Text('${day.day}',
                                  style: const TextStyle(color: Colors.white)),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_selectedDay != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("الملاحظات:",
                                style: TextStyle(fontSize: 18)),
                            ..._getNotesForDay(_selectedDay!, groupedNotes).map(
                              (note) {
                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text(note.content)),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                size: 20, color: Colors.orange),
                                            onPressed: () => _addOrEditNote(
                                                existingNote: note),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                size: 20, color: Colors.red),
                                            onPressed: () =>
                                                _deleteNote(note.id),
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
            onPressed: () => _addOrEditNote(),
            backgroundColor: Colors.blue,
            child: const Icon(Icons.edit),
          ),
        );
      },
    );
  }
}
