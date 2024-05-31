import 'package:flutter/material.dart';
import 'package:my_library/controller/book.dart';
import 'package:my_library/model/book_google.dart';
import 'package:my_library/Services/util.dart';
import 'package:my_library/model/book.dart';
import 'package:my_library/model/account_book.dart';


class AddBookView extends StatefulWidget {
  const AddBookView({Key? key}) : super(key: key);

  @override
  _AddBookViewState createState() => _AddBookViewState();
}

class _AddBookViewState extends State<AddBookView> {
  final TextEditingController _controller = TextEditingController();
  List<BookGoogle> _books = [];
  bool _isLoading = false;

  Future<void> _searchBook() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userInput = _controller.text;
      final books = await Books().searchBook(userInput);
      setState(() {
        _books = books;
      });
    } catch (e) {
      showCustomDialog(context, 'Error in search book', e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openAddBookPage(BookGoogle bookGoogle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBookPage(bookGoogle: bookGoogle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aggiungi un libro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Inserisci il titolo del libro',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchBook,
                ),
              ],
            ),
            if (_isLoading) 
              Center(child: CircularProgressIndicator()),
            if (!_isLoading && _books.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _books.length,
                  itemBuilder: (context, index) {
                    final book = _books[index];
                    return ListTile(
                      leading: book.imageLinks != null && book.imageLinks!.isNotEmpty
                          ? Image.network(
                              book.imageLinks!,
                              fit: BoxFit.cover,
                              width: 50,
                              height: 50,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.error, color: Colors.red);
                              },
                            )
                          : Icon(Icons.book),
                      title: Text(book.title),
                      subtitle: Text(book.authors?.join(', ') ?? 'Autore sconosciuto'),
                      trailing: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => _openAddBookPage(book),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AddBookPage extends StatelessWidget {
  final BookGoogle bookGoogle;

  AddBookPage({required this.bookGoogle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aggiungi informazioni a ${bookGoogle.title}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<AccountBookResponse>(
              future: Books().addBook(bookGoogle),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Errore: ${snapshot.error}');
                } else {
                  final accountBookResponse = snapshot.data!;
                  final idAccountBook = accountBookResponse.idAccountBook;
                  final book = accountBookResponse.book;
                  final accountBookBasic = accountBookResponse.accountBook;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID Account Book: $idAccountBook'),
                      Text('Titolo del libro: ${book.title}'),
                      Text('Autore: ${book.author}'),
                      if (book.cover != null) Image.network(book.cover!), // Mostra la copertina se disponibile
                      if (accountBookBasic.isFavorite != null)
                        Text('Preferito: ${accountBookBasic.isFavorite! ? 'Sì' : 'No'}'),
                      if (accountBookBasic.isWishlist != null)
                        Text('Nella lista dei desideri: ${accountBookBasic.isWishlist! ? 'Sì' : 'No'}'),
                      if (accountBookBasic.notes != null) Text('Note: ${accountBookBasic.notes}'),
                      if (accountBookBasic.rating != null) Text('Valutazione: ${accountBookBasic.rating}'),
                      if (accountBookBasic.isPhysical != null)
                        Text('Copia fisica: ${accountBookBasic.isPhysical! ? 'Sì' : 'No'}'),
                      if (accountBookBasic.readedAt != null) Text('Letto il: ${accountBookBasic.readedAt}'),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}