class Book {
  String title;
  String author;
  double price;
  bool isBorrowed;

  Book(this.title, this.author, this.price, {this.isBorrowed = false});

  @override
  String toString() => "'$title' by $author";
}

class Library {
  final List<Book> _books = [];

  void addBook(Book book) => _books.add(book);

  List<Book> getAvailableBooks() {
    return _books.where((book) => !book.isBorrowed).toList();
  }

  double getTotalValue() {
    return _books.fold(0.0, (sum, book) => sum + book.price);
  }
}

abstract class MediaItem {
  String id;
  String title;
  double price;

  MediaItem(this.id, this.title, this.price);

  String getDetails();
}

mixin Downloadable {
  void download(String title) {
    print('Downloading: $title...');
  }
}

class Audiobook extends MediaItem with Downloadable {
  double durationHours;
  String narrator;

  Audiobook(super.id, super.title, super.price, this.durationHours, this.narrator);

  @override
  String getDetails() =>
      'Audiobook: $title ($durationHours h), Narrator: $narrator - \$$price';
}

class EBook extends MediaItem with Downloadable {
  double fileSizeMB;
  String author;

  EBook(super.id, super.title, super.price, this.fileSizeMB, this.author);

  @override
  String getDetails() =>
      'EBook: $title ($fileSizeMB MB), Author: $author - \$$price';
}

class ShoppingCart {
  final List<MediaItem> _items = [];

  void addItem(MediaItem item) => _items.add(item);

  double calculateTotalWithTax({double taxRate = 0.12}) {
    double subtotal = _items.fold(0.0, (sum, item) => sum + item.price);
    return subtotal + (subtotal * taxRate);
  }

  List<MediaItem> filterByMaxPrice(double maxPrice) {
    return _items.where((item) => item.price <= maxPrice).toList();
  }

  void printReceipt() {
    print('Receipt');
    for (var item in _items) {
      print(item.getDetails());
      if (item is Downloadable) {
        (item as Downloadable).download(item.title);
      }
    }
    print('Total (with 12% tax): \$${calculateTotalWithTax().toStringAsFixed(2)}');
  }
}

void main() {
  var library = Library();

  library.addBook(Book('Dart Basics', 'John Doe', 15.50));
  library.addBook(
      Book('Advanced Flutter', 'Jane Smith', 25.00, isBorrowed: true));
  library.addBook(Book('Clean Architecture', 'Uncle Bob', 30.00));

  print('Available books: ${library.getAvailableBooks()}');
  print('Total collection value: \$${library.getTotalValue()}\n');

  var cart = ShoppingCart();

  cart.addItem(EBook('1', 'Flutter UI', 15.0, 5.2, 'Alice'));
  cart.addItem(Audiobook('2', 'Dart Mastery', 20.0, 10.5, 'Bob'));

  cart.printReceipt();

  print('\nItems under \$18:');
  for (var item in cart.filterByMaxPrice(18.0)) {
    print(item.title);
  }
}