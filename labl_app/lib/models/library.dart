import 'user.dart'; 

abstract class LibraryItem {
  String title;
  String? author;
  DateTime? publishDate;
  
  User? borrower;
  DateTime? dueDate;

  LibraryItem({
    required this.title,
    this.author,
    this.publishDate,
  });
}


class Book extends LibraryItem {
  int? pageCount;
  String? isbn;

  
  Book({
    required super.title,
    super.author,
    super.publishDate,
    this.pageCount,
    this.isbn,
  });
}


class Magazine extends LibraryItem {
  int? issueNumber;
  String? publisher;

  Magazine({
    required super.title,
    super.author,
    super.publishDate,
    this.issueNumber,
    this.publisher,
  });
}


class Library {
  List<LibraryItem> items = [];

 
  void addItem(LibraryItem item) {
    if (item.title.isNotEmpty) {
      items.add(item);
    }
  }

 
 List<LibraryItem> searchByTitle(String query) {
    return items.where((item) => item.title.toLowerCase().contains(query.toLowerCase())).toList();
  }

  List<LibraryItem> getItemsByAuthor(String authorName) {
    return items.where((item) => item.author?.toLowerCase() == authorName.toLowerCase()).toList();
  }

  List<LibraryItem> getRecentItems() {
    return items.where((item) => item.publishDate != null).toList();
  }

 
  bool borrowItem(LibraryItem item, User user, DateTime due) {
    if (item.borrower != null) {
      return false; 
    }
    item.borrower = user;
    item.dueDate = due;
    return true; 
  }

  void returnItem(LibraryItem item) {
   
    item.borrower = null;
    item.dueDate = null;
  }
}