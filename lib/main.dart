import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; // auto generated

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const LibraryManagerApp());
}

class LibraryManagerApp extends StatelessWidget {
  const LibraryManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Library Manager",
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepPurple),
          ),
        ),
      ),
      home: const UpdateBookScreen(),
    );
  }
}

class UpdateBookScreen extends StatefulWidget {
  const UpdateBookScreen({super.key});

  @override
  State<UpdateBookScreen> createState() => _UpdateBookScreenState();
}

class _UpdateBookScreenState extends State<UpdateBookScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _copiesController = TextEditingController();

  DocumentSnapshot? bookData;
  bool loading = false;
  String errorMessage = "";

  Future<void> searchBook() async {
    setState(() {
      loading = true;
      errorMessage = "";
      bookData = null;
    });

    try {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('books')
          .where('title', isEqualTo: _titleController.text.trim())
          .get();

      if (query.docs.isEmpty) {
        setState(() => errorMessage = "Book not found");
      } else {
        setState(() => bookData = query.docs.first);
      }
    } catch (e) {
      setState(() => errorMessage = e.toString());
    }

    setState(() => loading = false);
  }

  Future<void> updateCopies() async {
    if (bookData == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('books')
          .doc(bookData!.id)
          .update({
        'copies': int.parse(_copiesController.text.trim())
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Copies updated ✅")),
      );

      searchBook(); // refresh
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Library Manager"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Update Book Copies",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Enter Book Title",
              ),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: searchBook,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Search"),
            ),

            const SizedBox(height: 15),

            if (loading)
              const Center(
                  child: CircularProgressIndicator(color: Colors.deepPurple)),

            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: const TextStyle(color: Colors.red)),

            if (bookData != null) ...[
              const SizedBox(height: 10),
              Text("Book: ${bookData!['title']}",
                  style: const TextStyle(fontSize: 20)),
              Text("Copies: ${bookData!['copies']}",
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),

              TextField(
                controller: _copiesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Enter new copies"),
              ),
              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: updateCopies,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green),
                child: const Text("Update"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
