import 'package:gibidex/domain/entities/book_comic.dart';

abstract class BookComicRepository {
  Future<void> addBookComic(BookComic bookComic);
  Future<List<BookComic>> getAllBookComics();
  Future<void> updateBookComic(BookComic bookComic);
  Future<void> deleteBookComic(String id);  
}