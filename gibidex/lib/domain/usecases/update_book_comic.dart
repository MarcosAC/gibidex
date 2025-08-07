import 'package:gibidex/domain/entities/book_comic.dart';
import 'package:gibidex/domain/repositories/book_comic_repository.dart';

class UpdateBookComic {
  final BookComicRepository repository;

  UpdateBookComic(this.repository);

  Future<void> call(BookComic bookComic) async {
    return await repository.updateBookComic(bookComic);
  }
}