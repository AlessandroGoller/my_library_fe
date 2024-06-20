
import 'package:flutter/material.dart';
import 'package:my_library/model/account_book.dart';
import 'package:my_library/controller/book.dart';
import 'package:my_library/controller/tag.dart';
import 'package:my_library/Services/tag.dart';
import 'package:my_library/Services/util.dart';
import 'package:my_library/model/tag.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:html_unescape/html_unescape.dart';


class BookView extends StatefulWidget {
  final AccountBookResponse accountBookResponse;

  const BookView(this.accountBookResponse, {Key? key}) : super(key: key);

  @override
  _BookViewState createState() => _BookViewState();
}

class _BookViewState extends State<BookView> {
  late Future<List<String>> _tagsFuture;
  bool isEditing = false;
  bool showTags = false;
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
  late DateTime selectedDate;
  late Future<List<TagResponse>> _existingTagsFuture;

  @override
  void initState() {
    super.initState();
    currentResponse = widget.accountBookResponse;
    currentTags = [];
    _tagsFuture = getBooksTagsByIdAccountBook(currentResponse.idAccountBook);
    _existingTagsFuture = getTags();
    titleController = TextEditingController(text: currentResponse.book.title);
    authorController = TextEditingController(text: currentResponse.book.author);
    publicationDateController = TextEditingController(text: currentResponse.book.publicationDate?.toString());
    ratingController = TextEditingController(text: currentResponse.accountBook.rating?.toString());
    notesController = TextEditingController(text: currentResponse.accountBook.notes);
    isPhysicalController = TextEditingController(text: currentResponse.accountBook.isPhysical?.toString());
    selectedDate = currentResponse.accountBook.readedAt ?? DateTime.now();
    readedatController = TextEditingController(text: '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}');
    tagsController = TextEditingController();
  }

  void _showStorylineDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Trama'),
          content: SingleChildScrollView(
            child: HtmlWidget(
              HtmlUnescape().convert(currentResponse.book.storyline ?? ''),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Chiudi'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  void toggleTagVisibility() {
    setState(() {
      showTags = !showTags;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        readedatController.text = '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}';
      });
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

    AccountBookResponse newResponse = await Books().editBook(updatedResponse);
    setState(() {
      currentResponse = newResponse;
      isEditing = false;
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
        bool deleting = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Delete Tag'),
              content: deleting
                  ? Center(child: CircularProgressIndicator())
                  : Text('Are you sure you want to delete this tag: $tag ?'),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Delete'),
                  onPressed: deleting
                      ? null
                      : () async {
                          setState(() {
                            deleting = true;
                          });

                          try {
                            await Tag().deleteBooksTagsByNameTagAndIdAccountBook(tag, currentResponse.idAccountBook);
                          } catch (e) {
                            showCustomDialog(context, 'Error in deleting tag', e.toString());
                          }

                          setState(() {
                            deleting = false;
                          });

                          Navigator.of(context).pop();
                          Navigator.pop(context);
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
        bool deleting = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Delete Book'),
              content: deleting
                  ? Center(child: CircularProgressIndicator())
                  : Text('Are you sure you want to delete this book?'),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Delete'),
                  onPressed: deleting
                      ? null
                      : () async {
                          setState(() {
                            deleting = true;
                          });

                          try {
                            await Books().deleteBook(currentResponse.idAccountBook);
                          } catch (e) {
                            showCustomDialog(context, 'Error in deleting Book', e.toString());
                          }

                          setState(() {
                            deleting = false;
                          });

                          Navigator.of(context).pop();
                          Navigator.pop(context);
                        },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> addTag(String tagName) async {
    if (tagName.isNotEmpty) {
      try {
        CreateBooksTags createBooksTags = CreateBooksTags(
          nameTag: tagName,
          idAccountBook: currentResponse.idAccountBook,
        );
        BooksTagsResponse addedtag = await Tag().addBooksTags(createBooksTags);

        setState(() {
          currentTags.add(addedtag.tag.name);
          tagsController.clear();
        });
      } catch (e) {
        showCustomDialog(context, 'Error in adding tag', e.toString());
      }
    }
  }


  void deleteTag(TagResponse tag) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Tag'),
          content: Text('Are you sure you want to delete this tag: ${tag.name}?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await Tag().deleteTag(tag.idTag);
        setState(() {
          _existingTagsFuture = getTags(); // Refresh the tag list
        });
      } catch (e) {
        showCustomDialog(context, 'Error in deleting tag', e.toString());
      }
    }
  }

  void _showTagDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select a Tag'),
          content: FutureBuilder<List<TagResponse>>(
            future: _existingTagsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No tags available');
              } else {
                return Wrap(
                  children: snapshot.data!.map((tag) => InkWell(
                    onTap: () {
                      addTag(tag.name);
                      Navigator.of(context).pop(); // Chiudi il dialogo dopo aver aggiunto il tag
                    },
                    child: Chip(
                      label: Text(tag.name),
                      deleteIcon: Icon(Icons.close),
                      onDeleted: () => deleteTag(tag),
                    ),
                  )).toList(),
                );
              }
            },
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  showTags = false;
                });
              },
            ),
          ],
        );
      },
    );
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
          currentTags = snapshot.data ?? [];
          return Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40),
                  SizedBox(
                    width: screenWidth * 0.4,
                    height: screenHeight * 0.3,
                    child: Image.network(
                      currentResponse.book.cover ?? '',
                      fit: BoxFit.cover,
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
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    currentResponse.book.author ?? '',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Published: ${currentResponse.book.publicationDate?.day.toString().padLeft(2, '0')}/${currentResponse.book.publicationDate?.month.toString().padLeft(2, '0')}/${currentResponse.book.publicationDate?.year}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showStorylineDialog,
                    child: Text('Mostra Trama'),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                        children: currentTags.map((tag) => Chip(
                          label: Text(tag),
                          onDeleted: () => deleteBooksTags(tag),
                        )).toList(),
                      ),
                  
                  if (isEditing) 
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: _showTagDialog, // Chiama la funzione per mostrare il dialogo
                          child: Text('Select Tag'),
                        ),
                        TextField(
                          controller: tagsController,
                          decoration: InputDecoration(
                            labelText: 'Add a new tag',
                            suffixIcon: IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () => addTag(tagsController.text),
                            ),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 10),
                  RatingBar.builder(
                    initialRating: currentResponse.accountBook.rating?.toDouble() ?? 0,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    ignoreGestures: !isEditing,  // Disabilita le modifiche quando non è in modalità di modifica
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      if (isEditing) {
                        setState(() {
                          currentResponse = currentResponse.copyWith(
                            accountBook: currentResponse.accountBook.copyWith(rating: rating.toInt()),
                          );
                        });
                      }
                    },
                  ),
                  SizedBox(height: 10),
                  isEditing
                    ? TextField(
                        controller: notesController,
                        decoration: InputDecoration(labelText: 'Notes'),
                      )
                    : Text(
                        'Notes: ${currentResponse.accountBook.notes ?? ''}',
                        style: TextStyle(fontSize: 18),
                      ),
                  SizedBox(height: 10),
                  isEditing
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Is Physical: '),
                          Checkbox(
                            value: currentResponse.accountBook.isPhysical,
                            onChanged: (bool? value) {
                              setState(() {
                                currentResponse = currentResponse.copyWith(
                                  accountBook: currentResponse.accountBook.copyWith(isPhysical: value ?? false),
                                );
                              });
                            },
                          ),
                        ],
                      )
                    : Text(
                        'Is Physical?: ${currentResponse.accountBook.isPhysical == true ? '✔️' : '❌'}',
                        style: TextStyle(fontSize: 18),
                      ),
                  SizedBox(height: 10),
                  isEditing
                    ? TextField(
                        controller: readedatController,
                        decoration: InputDecoration(labelText: 'Readed At'),
                        readOnly: true,
                        onTap: () async {
                          await _selectDate(context);
                        },
                      )
                    : Text(
                        'Readed At: ${currentResponse.accountBook.readedAt?.day.toString().padLeft(2, '0')}/${currentResponse.accountBook.readedAt?.month.toString().padLeft(2, '0')}/${currentResponse.accountBook.readedAt?.year}',
                        style: TextStyle(fontSize: 18),
                      ),
                ],
              ),
            ),
          );
        }
      },
    ),
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
