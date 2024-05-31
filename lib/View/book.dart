
import 'package:flutter/material.dart';
import 'package:my_library/model/account_book.dart';
import 'package:my_library/controller/book.dart';

class BookView extends StatefulWidget {
  final AccountBookResponse accountBookResponse;

  const BookView(this.accountBookResponse, {Key? key}) : super(key: key);

  @override
  _BookViewState createState() => _BookViewState();
}

class _BookViewState extends State<BookView> {
  bool isEditing = false;
  late TextEditingController titleController;
  late TextEditingController authorController;
  late TextEditingController publicationDateController;
  late TextEditingController ratingController;
  late TextEditingController notesController;
  late TextEditingController isPhysicalController;
  late AccountBookResponse currentResponse;

  @override
  void initState() {
    super.initState();
    currentResponse = widget.accountBookResponse;
    titleController = TextEditingController(text: currentResponse.book.title);
    authorController = TextEditingController(text: currentResponse.book.author);
    publicationDateController = TextEditingController(text: currentResponse.book.publicationDate?.toString());
    ratingController = TextEditingController(text: currentResponse.accountBook.rating?.toString());
    notesController = TextEditingController(text: currentResponse.accountBook.notes);
    isPhysicalController = TextEditingController(text: currentResponse.accountBook.isPhysical?.toString());
  }

  void editAccountBook() async {
    AccountBookResponse updatedResponse = AccountBookResponse(
      idAccountBook: currentResponse.idAccountBook,
      book: currentResponse.book.copyWith(
        title: titleController.text,
        author: authorController.text,
        publicationDate: DateTime.tryParse(publicationDateController.text),
        cover: currentResponse.book.cover,
      ),
      accountBook: currentResponse.accountBook.copyWith(
        rating: int.tryParse(ratingController.text),
        notes: notesController.text,
        isPhysical: isPhysicalController.text.toLowerCase() == 'true',
      ),
    );

    // Call the editBook function and update the state with the new response.
    AccountBookResponse newResponse = await Books().editBook(updatedResponse);
    setState(() {
      currentResponse = newResponse;
      isEditing = false;
      // Update controllers with new response data
      titleController.text = currentResponse.book.title;
      authorController.text = currentResponse.book.author;
      publicationDateController.text = currentResponse.book.publicationDate?.toString() ?? '';
      ratingController.text = currentResponse.accountBook.rating?.toString() ?? '';
      notesController.text = currentResponse.accountBook.notes ?? '';
      isPhysicalController.text = currentResponse.accountBook.isPhysical?.toString() ?? '';
    });
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
        ],
      ),
      body: SingleChildScrollView(
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
          ],
        ),
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
