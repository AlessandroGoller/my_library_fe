
import 'package:flutter/material.dart';
import 'package:my_library/model/account_book.dart';
import 'package:my_library/controller/book.dart';
import 'package:my_library/controller/tag.dart';
import 'package:my_library/Services/tag.dart';
import 'package:my_library/Services/util.dart';
import 'package:my_library/model/tag.dart';


class BookView extends StatefulWidget {
  final AccountBookResponse accountBookResponse;

  const BookView(this.accountBookResponse, {Key? key}) : super(key: key);

  @override
  _BookViewState createState() => _BookViewState();
}

class _BookViewState extends State<BookView> {
  late Future<List<String>> _tagsFuture;
  bool isEditing = false;
  late TextEditingController titleController;
  late TextEditingController authorController;
  late TextEditingController publicationDateController;
  late TextEditingController ratingController;
  late TextEditingController notesController;
  late TextEditingController isPhysicalController;
  late TextEditingController readedatController;
  late TextEditingController tagsController;
  late AccountBookResponse currentResponse;
  late List<String> currentTags;

  @override
  void initState() {
    super.initState();
    currentResponse = widget.accountBookResponse;
    _tagsFuture = getBooksTagsByIdAccountBook(currentResponse.idAccountBook);
    // currentTags = await getBooksTagsByIdAccountBook(currentResponse.idAccountBook);
    titleController = TextEditingController(text: currentResponse.book.title);
    authorController = TextEditingController(text: currentResponse.book.author);
    publicationDateController = TextEditingController(text: currentResponse.book.publicationDate?.toString());
    ratingController = TextEditingController(text: currentResponse.accountBook.rating?.toString());
    notesController = TextEditingController(text: currentResponse.accountBook.notes);
    isPhysicalController = TextEditingController(text: currentResponse.accountBook.isPhysical?.toString());
    readedatController = TextEditingController(text: currentResponse.accountBook.readedAt?.toString());
    tagsController = TextEditingController();
  }

  void editAccountBook() async {
    AccountBookResponse updatedResponse = AccountBookResponse(
      idAccountBook: currentResponse.idAccountBook,
      book: currentResponse.book,
      accountBook: currentResponse.accountBook.copyWith(
        rating: int.tryParse(ratingController.text),
        notes: notesController.text,
        isPhysical: isPhysicalController.text.toLowerCase() == 'true',
        readedAt: DateTime.tryParse(readedatController.text),
      ),
    );

    // Call the editBook function and update the state with the new response.
    AccountBookResponse newResponse = await Books().editBook(updatedResponse);
    setState(() {
      currentResponse = newResponse;
      isEditing = false;
      // Update controllers with new response data
      publicationDateController.text = currentResponse.book.publicationDate?.toString() ?? '';
      ratingController.text = currentResponse.accountBook.rating?.toString() ?? '';
      notesController.text = currentResponse.accountBook.notes ?? '';
      isPhysicalController.text = currentResponse.accountBook.isPhysical?.toString() ?? '';
      readedatController.text = currentResponse.accountBook.readedAt?.toString() ?? '';
    });
  }

  void deleteBooksTags(String tag) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool deleting = false; // Variabile per tracciare lo stato dell'eliminazione
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Delete Tag'),
              content: deleting ? Center(child: CircularProgressIndicator()) : Text('Are you sure you want to delete this tag: $tag ?'),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Delete'),
                  onPressed: deleting ? null : () async {
                    // Imposta lo stato di eliminazione su true
                    setState(() {
                      deleting = true;
                    });
                    
                    try {
                      // Effettua la chiamata di eliminazione
                      await Tag().deleteBooksTagsByNameTagAndIdAccountBook(tag, currentResponse.idAccountBook);
                    } catch (e) {
                      // Gestisci l'errore
                      showCustomDialog(context, 'Error in deleting tag', e.toString());
                    }
                    
                    // Ripristina lo stato di eliminazione
                    setState(() {
                      deleting = false;
                    });
                    
                    Navigator.of(context).pop(); // Rimuovi il dialog
                    Navigator.pop(context); // Torna alla schermata precedente
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void deleteBook() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Book'),
          content: Text('Are you sure you want to delete this book?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                // Call the deleteBook function and update the state with the new response.
                await Books().deleteBook(currentResponse.idAccountBook);
                Navigator.of(context).pop();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> addTag() async {
    String newTag = tagsController.text.trim();
    if (newTag.isNotEmpty) {
      try {
        CreateBooksTags createBooksTags = CreateBooksTags(
          nameTag: newTag,
          idAccountBook: currentResponse.idAccountBook,
        );
        BooksTagsResponse addedtag = await Tag().addBooksTags(createBooksTags);
        
        setState(() {
          currentTags.add(addedtag.tag.name);
          tagsController.clear();
        });
      } catch (e) {
        // Handle the error accordingly
        showCustomDialog(context, 'Error in adding tag', e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          if (!isEditing)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
            ),
          if (isEditing)
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                setState(() {
                  isEditing = false;
                  editAccountBook();
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                deleteBook();
              },
            ),
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: _tagsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            currentTags = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: screenWidth * 0.8,
                    height: screenHeight * 0.4,
                    child: Image.network(
                      currentResponse.book.cover ?? '',
                      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                        return Image.network(
                          'https://thumbs.dreamstime.com/b/stack-books-isolated-white-background-34637153.jpg',
                          scale: 1.0,
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    currentResponse.book.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(currentResponse.book.author ?? ''),
                  SizedBox(height: 10),
                  Text(currentResponse.book.publicationDate?.toString() ?? ''),
                  SizedBox(height: 10),
                  isEditing
                      ? Column(
                          children: [
                            Wrap(
                              children: currentTags
                                  .map((tag) => Chip(
                                        label: Text(tag),
                                        deleteIcon: Icon(Icons.close),
                                        onDeleted: () => deleteBooksTags(tag),
                                      ))
                                  .toList(),
                            ),
                            TextField(
                              controller: tagsController,
                              decoration: InputDecoration(labelText: 'Add Tag'),
                              onSubmitted: (_) => addTag(),
                            ),
                            ElevatedButton(
                              onPressed: addTag,
                              child: Text('Add Tag'),
                            ),
                          ],
                        )
                      : Wrap(
                        children: currentTags
                            .map((tag) => Chip(label: Text(tag)))
                            .toList(),
                      ),
                  SizedBox(height: 10),
                  isEditing
                      ? TextField(
                          controller: ratingController,
                          decoration: InputDecoration(labelText: 'Rating'),
                        )
                      : Text('Rating: ${currentResponse.accountBook.rating?.toString() ?? ''}'),
                  SizedBox(height: 10),
                  isEditing
                      ? TextField(
                          controller: notesController,
                          decoration: InputDecoration(labelText: 'Notes'),
                        )
                      : Text('Notes: ${currentResponse.accountBook.notes ?? ''}'),
                  SizedBox(height: 10),
                  isEditing
                      ? TextField(
                          controller: isPhysicalController,
                          decoration: InputDecoration(labelText: 'is physical'),
                        )
                      : Text('Is Physical? : ${currentResponse.accountBook.isPhysical ?? ''}'),
                  SizedBox(height: 10),
                  isEditing
                      ? TextField(
                          controller: readedatController,
                          decoration: InputDecoration(labelText: 'Readed At'),
                        )
                      : Text('Readed At: ${currentResponse.accountBook.readedAt?.toString() ?? ''}'),
                ],
              ),
            );
          }
        }
      )
    );
  }
}

class LibraryView extends StatelessWidget {
  final List<AccountBookResponse> accountBookResponses;

  const LibraryView(this.accountBookResponses, {super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const itemWidth = 150; // Larghezza desiderata per ogni elemento

    final crossAxisCount = (screenWidth / itemWidth).floor();

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: accountBookResponses.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookView(accountBookResponses[index]),
              ),
            );
          },
          child: Column(
            children: [
              Expanded(
                child: Image.network(
                  accountBookResponses[index].book.cover ?? '',
                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                    return Image.network(
                      'https://thumbs.dreamstime.com/b/stack-books-isolated-white-background-34637153.jpg',
                      scale: 1.0,
                    );
                  },
                ),
              ),
              Text(accountBookResponses[index].book.title),
            ],
          ),
        );
      },
    );
  }
}

class TableView extends StatefulWidget {
  final List<AccountBookResponse> accountBookResponses;

  const TableView(this.accountBookResponses, {super.key});

  @override
  _TableViewState createState() => _TableViewState();
}

class _TableViewState extends State<TableView> {
  int sortColumnIndex = 0;
  bool sort = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 20.0,
          sortColumnIndex: sortColumnIndex,
          showCheckboxColumn: false,
          sortAscending: sort,
          border: TableBorder.all(width: 1.0, color: Colors.black),
          columns: [ 
            DataColumn(label: Text('ID'), onSort: onSort),
            DataColumn(label: Text('Title'), onSort: onSort),
            DataColumn(label: Text('Author'), onSort: onSort),
            DataColumn(label: Text('Publication Date'), onSort: onSort),
            DataColumn(label: Text('Rating'), onSort: onSort),
          ],
          rows: [
            for (var accountBookResponse in widget.accountBookResponses)
              DataRow(cells: [
                DataCell(Text(accountBookResponse.idAccountBook.toString())),
                DataCell(Text(accountBookResponse.book.title)),
                DataCell(Text(accountBookResponse.book.author ?? '')),
                DataCell(Text(accountBookResponse.book.publicationDate.toString())),
                DataCell(Text(accountBookResponse.accountBook.rating.toString())),
              ])
          ],
        ),
      ),
    );
  }

  void onSort(int columnIndex, bool ascending) {
    if (columnIndex == 0) {
      if (ascending) {
        widget.accountBookResponses.sort((a, b) => (a.idAccountBook).compareTo(b.idAccountBook));
      } else {
        widget.accountBookResponses.sort((a, b) => (b.idAccountBook).compareTo(a.idAccountBook));
      }
    } else if (columnIndex == 1) {
      if (ascending) {
        widget.accountBookResponses.sort((a, b) => (a.book.title).compareTo(b.book.title));
      } else {
        widget.accountBookResponses.sort((a, b) => (b.book.title).compareTo(a.book.title));
      }
    } else if (columnIndex == 2) {
      if (ascending) {
        widget.accountBookResponses.sort((a, b) => (a.book.author ?? '').compareTo(b.book.author ?? ''));
      } else {
        widget.accountBookResponses.sort((a, b) => (b.book.author ?? '').compareTo(a.book.author ?? ''));
      }
    } else if (columnIndex == 3) {
      if (ascending) {
        widget.accountBookResponses.sort((a, b) => (a.book.publicationDate ?? DateTime(0)).compareTo(b.book.publicationDate ?? DateTime(0)));
      } else {
        widget.accountBookResponses.sort((a, b) => (b.book.publicationDate ?? DateTime(0)).compareTo(a.book.publicationDate ?? DateTime(0)));
      }
    } else if (columnIndex == 4) {
      if (ascending) {
        widget.accountBookResponses.sort((a, b) => (a.accountBook.rating ?? 0).compareTo(b.accountBook.rating ?? 0));
      } else {
        widget.accountBookResponses.sort((a, b) => (b.accountBook.rating ?? 0).compareTo(a.accountBook.rating ?? 0));
      }
    }

    setState(() {
      if (columnIndex == sortColumnIndex) {
        sort = !sort;
      } else {
        sort = true;
      }
      sortColumnIndex = columnIndex;
    }); // Update the view
  }
}
