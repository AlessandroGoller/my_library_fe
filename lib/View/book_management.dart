import 'package:flutter/material.dart';
import 'package:my_library/controller/book.dart';
import 'package:my_library/model/account_book.dart';
import 'package:my_library/View/add_book.dart';
import 'package:my_library/View/book.dart';
import 'package:my_library/View/auth.dart';
import 'package:my_library/Services/util.dart';
import 'package:my_library/Services/auth.dart';
import 'package:my_library/View/header.dart';
import 'package:my_library/model/tag.dart';
import 'package:my_library/Services/books_info.dart';



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
  List<AccountBookResponse> accountBookResponses = [];
  List<String> tags = [];
  var isLoaded = false;
  String _searchText = '';

  // filter variables
  String? _selectedTag;
  int? _selectedYear;
  int? _selectedRating;
  bool? _filterPhysicalBook;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getData();
  }

  getData() async {
    try {
      List<TagResponse> tagresponse = await BooksInfo().updateTags();
      tags = tagresponse.map((e) => e.name).toList();

      accountBookResponses = await BooksInfo().updateBooks();
      if (accountBookResponses.isNotEmpty) {
        setState(() {
          isLoaded = true;
        });
      }
    } catch (e) {
      showCustomDialog(context, 'Error in getting books', e.toString());
    }
  }

  List<AccountBookResponse> getFilteredBooks() {
    List<AccountBookResponse> filteredBooks = accountBookResponses;

    // Filtra per testo di ricerca
    if (_searchText.isNotEmpty) {
      filteredBooks = filteredBooks.where((accountBookResponse) {
        final book = accountBookResponse.book;
        final titleMatch = book.title.toLowerCase().contains(_searchText.toLowerCase());
        final authorMatch = book.author?.toLowerCase().contains(_searchText.toLowerCase()) ?? false;
        return titleMatch || authorMatch;
      }).toList();
    }

    // Filtra per tag
    if (_selectedTag != null) {
      filteredBooks = filteredBooks.where((accountBookResponse) {
        final accountBook = accountBookResponse.accountBook;
        final tagMatch = accountBook.tags?.contains(_selectedTag) ?? false;
        return tagMatch;
      }).toList();
    }

    // Filtra per anno di lettura
    if (_selectedYear != null) {
      filteredBooks = filteredBooks.where((accountBookResponse) {
        final readedAt = accountBookResponse.accountBook.readedAt;
        return readedAt?.year == _selectedYear;
      }).toList();
    }

    // Filtra per rating
    if (_selectedRating != null) {
      filteredBooks = filteredBooks.where((accountBookResponse) {
        final rating = accountBookResponse.accountBook.rating;
        return rating == _selectedRating;
      }).toList();
    }

    // Filtra per stato fisico
    if (_filterPhysicalBook != null) {
      filteredBooks = filteredBooks.where((accountBookResponse) {
        final isPhysical = accountBookResponse.accountBook.isPhysical;
        return isPhysical == _filterPhysicalBook;
      }).toList();
    }

    return filteredBooks;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Filtra Libri"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Filtro per tag
                DropdownButton<String>(
                  value: _selectedTag,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedTag = newValue;
                    });
                    Navigator.of(context).pop();
                  },
                  items: tags.map((String tag) {
                    return DropdownMenuItem<String>(
                      value: tag,
                      child: Text(tag),
                    );
                  }).toList(),
                  hint: Text('Seleziona un tag'),
                ),
                // Filtro per anno di lettura
                DropdownButton<int>(
                  value: _selectedYear,
                  items: List.generate(50, (index) {
                    int year = DateTime.now().year - index;
                    return DropdownMenuItem(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      _selectedYear = value;
                    });
                    Navigator.of(context).pop();
                  },
                  hint: Text('Seleziona anno di lettura'),
                ),
                // Filtro per rating
                DropdownButton<int>(
                  value: _selectedRating,
                  items: List.generate(5, (index) {
                    return DropdownMenuItem(
                      value: index + 1,
                      child: Text((index + 1).toString()),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      _selectedRating = value;
                    });
                    Navigator.of(context).pop();
                  },
                  hint: Text('Seleziona rating'),
                ),
                // Filtro per stato fisico
                DropdownButton<bool>(
                  value: _filterPhysicalBook,
                  items: [
                    DropdownMenuItem(
                      value: true,
                      child: Text('Fisico'),
                    ),
                    DropdownMenuItem(
                      value: false,
                      child: Text('Digitale'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filterPhysicalBook = value;
                    });
                    Navigator.of(context).pop();
                  },
                  hint: Text('Seleziona tipo di libro'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Reset'),
              onPressed: () {
                setState(() {
                  _selectedTag = null;
                  _selectedYear = null;
                  _selectedRating = null;
                  _filterPhysicalBook = null;
                });
                getFilteredBooks();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
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
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _showFilterDialog();
                  },
                  style: ElevatedButton.styleFrom(),
                  child: const Text('Filtra'),
                ),
              ],
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
      // total number of books
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Text('Total books: ${getFilteredBooks().length}'),
        ),
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16,
            left: 16,
            child: FloatingActionButton(
              onPressed: getData,
              child: const Icon(Icons.refresh),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddBookView()),
                );
              },
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}