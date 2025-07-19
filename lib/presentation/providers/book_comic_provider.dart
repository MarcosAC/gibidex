import 'package:flutter/material.dart';
import 'package:gibidex/domain/entities/book_comic.dart';
import 'package:gibidex/domain/usecases/add_book_comic.dart';
import 'package:gibidex/domain/usecases/get_all_book_comic.dart';
import 'package:gibidex/domain/usecases/update_book_comic.dart';
import 'package:gibidex/domain/usecases/delete_book_comic.dart';
import 'package:gibidex/domain/usecases/schedule_reading_reminder.dart';
import 'package:gibidex/domain/usecases/cancel_reading_reminder.dart';
import 'package:uuid/uuid.dart';

class BookComicProvider with ChangeNotifier {
  final AddBookComic addBookComicUseCase;
  final GetAllBookComics getAllBookComicsUseCase;
  final UpdateBookComic updateBookComicUseCase;
  final DeleteBookComic deleteBookComicUseCase;
  final ScheduleReadingReminder scheduleReadingReminderUseCase;
  final CancelReadingReminder cancelReadingReminderUseCase;
  final Uuid uuid;

  List<BookComic> _bookComics = [];
  String _searchQuery = '';

  List<BookComic> get bookComics => _bookComics;

  List<BookComic> get readingItems {
    return _bookComics
        .where((item) => item.isReading &&
               (item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                item.author.toLowerCase().contains(_searchQuery.toLowerCase())))
        .toList();
  }

  List<BookComic> get wishlistItems {
    return _bookComics
        .where((item) => item.isWishlist &&
               (item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                item.author.toLowerCase().contains(_searchQuery.toLowerCase())))
        .toList();
  }

  BookComicProvider({
    required this.addBookComicUseCase,
    required this.getAllBookComicsUseCase,
    required this.updateBookComicUseCase,
    required this.deleteBookComicUseCase,
    required this.scheduleReadingReminderUseCase,
    required this.cancelReadingReminderUseCase,
    required this.uuid,    
  }); 

  Future<void> loadBookComics() async {
    _bookComics = await getAllBookComicsUseCase.call();
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addNewBookComic(String title, String author, String type, bool isReading, bool isWishlist, String? notes, String? imageUrl, String? edition) async {
    final newBookComic = BookComic(
      id: uuid.v4(),
      title: title,
      author: author,
      type: type,
      isReading: isReading,
      isWishlist: isWishlist,
      startDate: isReading ? DateTime.now() : null,
      notes: notes,
      imageUrl: imageUrl,
      edition: edition,
    );
    await addBookComicUseCase.call(newBookComic);
    await loadBookComics();
  }

  Future<void> updateExistingBookComic(BookComic updatedItem) async {
    await updateBookComicUseCase.call(updatedItem);
    await loadBookComics();
  }

  Future<void> toggleReadingStatus(BookComic item) async {
    item.isReading = !item.isReading;
    item.startDate = item.isReading ? (item.startDate ?? DateTime.now()) : null;
    item.endDate = !item.isReading ? DateTime.now() : null;

    if (item.isReading) {
      item.isWishlist = false;
    } else {
      await cancelReadingReminderUseCase.call(item);
    }
    await updateBookComicUseCase.call(item);
    await loadBookComics();
  }

  Future<void> toggleWishlistStatus(BookComic item) async {
    item.isWishlist = !item.isWishlist;

    if (item.isWishlist) {
      item.isReading = false;
      item.startDate = null;
      item.endDate = null;
      await cancelReadingReminderUseCase.call(item);
    }
    await updateBookComicUseCase.call(item);
    await loadBookComics();
  }

  Future<void> removeBookComic(String id) async {
    final itemToRemove = _bookComics.firstWhere((item) => item.id == id);
    if (itemToRemove.isReading) {
      await cancelReadingReminderUseCase.call(itemToRemove);
    }
    await deleteBookComicUseCase.call(id);
    await loadBookComics();
  }

  // Métodos de Autenticação Removidos
  // Future<void> signInAnonymously() async { ... }
  // Future<void> signOut() async { ... }

  Future<void> scheduleReminder(BookComic bookComic, DateTime scheduledTime) async {
    await scheduleReadingReminderUseCase.call(bookComic, scheduledTime);
  }
}