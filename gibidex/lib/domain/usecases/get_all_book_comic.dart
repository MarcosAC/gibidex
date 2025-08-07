import 'package:gibidex/domain/entities/book_comic.dart';
import 'package:gibidex/domain/repositories/book_comic_repository.dart';

class GetAllBookComics {
  final BookComicRepository repository;

  GetAllBookComics(this.repository);

  Future<List<BookComic>> call() async {
    return await repository.getAllBookComics();
  }
}