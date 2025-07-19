import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:gibidex/core/app_constants.dart';
import 'package:gibidex/domain/entities/book_comic.dart';

abstract class BookComicLocalDataSource {
  Future<List<BookComic>> getAllBookComics();
  Future<void> saveAllBookComics(List<BookComic> bookComics);
  Future<void> addBookComic(BookComic bookComic);
  Future<void> updateBookComic(BookComic bookComic);
  Future<void> deleteBookComic(String id);
}

class BookComicLocalDataSourceImpl implements BookComicLocalDataSource {
  final Box<String> bookComicBox;

  BookComicLocalDataSourceImpl({required this.bookComicBox});

  @override
  Future<List<BookComic>> getAllBookComics() async {
    final List<String> jsonStrings = bookComicBox.values.toList();
    if (jsonStrings.isNotEmpty) {
      return jsonStrings.map((jsonString) => BookComic.fromJson(json.decode(jsonString))).toList();
    }
    return [];
  }

  @override
  Future<void> saveAllBookComics(List<BookComic> bookComics) async {
    await bookComicBox.clear();
    for (var item in bookComics) {
      await bookComicBox.put(item.id, json.encode(item.toJson()));
    }
  }

  @override
  Future<void> addBookComic(BookComic bookComic) async {
    await bookComicBox.put(bookComic.id, json.encode(bookComic.toJson()));
  }

  @override
  Future<void> updateBookComic(BookComic bookComic) async {
    await bookComicBox.put(bookComic.id, json.encode(bookComic.toJson()));
  }

  @override
  Future<void> deleteBookComic(String id) async {
    await bookComicBox.delete(id);
  }
}