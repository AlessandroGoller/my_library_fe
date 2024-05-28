
import 'package:flutter/material.dart';
import '../model/book.dart';

class BookView extends StatelessWidget {
  final Book book;

  const BookView(this.book, {Key? key}) : super(key: key);

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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: screenWidth * 0.8,
              height: screenHeight * 0.4,
              child: Image.network(
                book.coverImageUrl ?? '',
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
              book.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(book.author ?? ''),
            SizedBox(height: 10),
            Text(book.publicationDate?.toString() ?? ''),
            SizedBox(height: 10),
            Text(book.rating?.toString() ?? ''),
            SizedBox(height: 10),
            Text(book.review ?? ''),
            SizedBox(height: 10),
            Text(book.notes ?? ''),
          ],
        ),
      ),
    );
  }
}


class LibraryView extends StatelessWidget {
  final List<Book> books;

  const LibraryView(this.books, {super.key});

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
      itemCount: books.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookView(books[index]),
              ),
            );
          },
          child: Column(
            children: [
              Expanded(
                child: Image.network(
                  books[index].coverImageUrl ?? '',
                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                    return Image.network(
                      'https://thumbs.dreamstime.com/b/stack-books-isolated-white-background-34637153.jpg',
                      scale: 1.0,
                    );
                  },
                ),
              ),
              Text(books[index].title),
            ],
          ),
        );
      },
    );
  }
}

class TableView extends StatefulWidget {
  final List<Book> books;

  const TableView(this.books, {super.key});

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
            for (var book in widget.books)
              DataRow(cells: [
                DataCell(Text(book.id.toString())),
                DataCell(Text(book.title)),
                DataCell(Text(book.author ?? '')),
                DataCell(Text(book.publicationDate.toString())),
                DataCell(Text(book.rating.toString())),
              ])
          ],
        ),
      ),
    );
  }

  void onSort(int columnIndex, bool ascending) {
    if (columnIndex == 0) {
      if (ascending) {
        widget.books.sort((a, b) => (a.id).compareTo(b.id));
      } else {
        widget.books.sort((a, b) => (b.id).compareTo(a.id));
      }
    } else if (columnIndex == 1) {
      if (ascending) {
        widget.books.sort((a, b) => (a.title).compareTo(b.title));
      } else {
        widget.books.sort((a, b) => (b.title).compareTo(a.title));
      }
    } else if (columnIndex == 2) {
      if (ascending) {
        widget.books.sort((a, b) => (a.author ?? '').compareTo(b.author ?? ''));
      } else {
        widget.books.sort((a, b) => (b.author ?? '').compareTo(a.author ?? ''));
      }
    } else if (columnIndex == 3) {
      if (ascending) {
        widget.books.sort((a, b) => (a.publicationDate ?? DateTime(0)).compareTo(b.publicationDate ?? DateTime(0)));
      } else {
        widget.books.sort((a, b) => (b.publicationDate ?? DateTime(0)).compareTo(a.publicationDate ?? DateTime(0)));
      }
    } else if (columnIndex == 4) {
      if (ascending) {
        widget.books.sort((a, b) => (a.rating ?? 0).compareTo(b.rating ?? 0));
      } else {
        widget.books.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
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
