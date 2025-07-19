import 'package:gibidex/domain/repositories/book_comic_repository.dart';

class DeleteBookComic {
  final BookComicRepository repository;

  DeleteBookComic(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteBookComic(id);
  }
}