import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert'; 

void main() {
  runApp(const MedicalDocumentsApp());
}

class MedicalDocumentsApp extends StatelessWidget {
  const MedicalDocumentsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Documents',
      theme: ThemeData(
        primaryColor: const Color(0xFF137FEC),
        scaffoldBackgroundColor: const Color(0xFFF6F7F8),
        fontFamily: 'Lexend',
      ),
      home: const DocumentsScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  List<Map<String, String>> documents = [];
  String searchQuery = '';
  String? selectedPdfDataUrl;

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredDocs = documents
        .where((doc) =>
            doc['title']!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medical Documents',
          style: TextStyle(
            color: Color(0xFF101922),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFFF6F7F8),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _infoCard('Last Doctor Visit', 'Oct 22, 2023'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _infoCard('Last Medication Change', 'Sep 15, 2023'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search documents...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Uploaded Documents',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF101922)),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: selectedPdfDataUrl != null
                  ? Column(
                      children: [
                        SizedBox(
                          height: 500,
                          child: SfPdfViewer.network(selectedPdfDataUrl!),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedPdfDataUrl = null;
                            });
                          },
                          child: const Text('Back to documents'),
                        ),
                      ],
                    )
                  : filteredDocs.isEmpty
                      ? const Center(child: Text('No documents found.'))
                      : ListView.builder(
                          itemCount: filteredDocs.length,
                          itemBuilder: (context, index) {
                            final doc = filteredDocs[index];
                            return DocumentItem(
                              title: doc['title']!,
                              type: doc['type']!,
                              date: doc['date']!,
                              onTap: () {
                                setState(() {
                                  selectedPdfDataUrl = doc['dataUrl'];
                                });
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['pdf'],
            withData: true,
          );

          if (result != null && result.files.isNotEmpty) {
            final file = result.files.first;

            String? dataUrl;
            if (file.bytes != null) {
              final base64Data = base64Encode(file.bytes!);
              dataUrl = 'data:application/pdf;base64,$base64Data';
            }

            setState(() {
              documents.add({
                'title': file.name,
                'type': 'Uploaded',
                'date': DateTime.now().toString().split(' ')[0],
                'dataUrl': dataUrl!,
              });
            });
          }
        },
        backgroundColor: const Color(0xFF137FEC),
        child: const Icon(Icons.upload_file),
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280))),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF101922))),
        ],
      ),
    );
  }
}

class DocumentItem extends StatelessWidget {
  final String title;
  final String type;
  final String date;
  final VoidCallback onTap;

  const DocumentItem(
      {super.key,
      required this.title,
      required this.type,
      required this.date,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE7F2FE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.picture_as_pdf, color: Color(0xFF137FEC)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.badge,
                              size: 16, color: Color(0xFF6B7280)),
                          const SizedBox(width: 4),
                          Text(type,
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF6B7280))),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 16, color: Color(0xFF6B7280)),
                          const SizedBox(width: 4),
                          Text(date,
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF6B7280))),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}