
import 'package:flutter/material.dart';
import 'package:my_library/controller/book.dart';
import 'package:my_library/model/book.dart';
import 'package:my_library/View/add_book.dart';
import 'package:my_library/View/books.dart';
import 'package:my_library/View/auth.dart';

import 'package:my_library/Services/auth.dart';
import 'package:my_library/View/header.dart';

class BookManagementApp extends StatefulWidget {
  const BookManagementApp({Key? key}) : super(key: key);

  @override
  _BookManagementAppState createState() => _BookManagementAppState();
}

class _BookManagementAppState extends State<BookManagementApp> {
  bool? logged;

  @override
  void initState() {
    super.initState();
    _load();
  }

  _load() async {
    logged = await Auth().isLoggedIn();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (logged == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (logged == true) {
      return Scaffold(
          appBar: MyHeader(),
          body: const BookListPage(),
        );
    } else {
      return LoginScreen();
    }
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
