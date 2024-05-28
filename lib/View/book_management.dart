
import 'package:flutter/material.dart';
import 'package:my_library/controller/book.dart';
import 'package:my_library/model/book.dart';
import 'package:my_library/View/add_book.dart';
import 'package:my_library/View/books.dart';

class BookManagementApp extends StatelessWidget {
  const BookManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Management',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: const BookListPage(),
    );
  }
}

class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  _BookListPageState createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  bool _isLibraryView = true;
  List<Book> books = [];
  var isLoaded = false;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    books = await GetBooks().getBooks();
    if (books.isNotEmpty) {
      setState(() {
        isLoaded = true;
      });
    }
  }

  List<Book> getFilteredBooks() {
    if (_searchText.isEmpty) {
      return books;
    } else {
      return books
          .where((book) =>
              book.title.toLowerCase().contains(_searchText.toLowerCase()) ||
              book.author!.toLowerCase().contains(_searchText.toLowerCase()))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Management'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLibraryView = true;
                  });
                },
                style: ElevatedButton.styleFrom(),
                child: const Text('Libreria'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLibraryView = false;
                  });
                },
                style: ElevatedButton.styleFrom(),
                child: const Text('Tabella'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _isLibraryView
                ? LibraryView(getFilteredBooks())
                : TableView(getFilteredBooks()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBookView()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
