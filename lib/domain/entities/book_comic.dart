import 'package:uuid/uuid.dart';

class BookComic {
  final String id;
  String title;
  String author;
  String type;
  bool isReading;
  bool isWishlist;
  DateTime? startDate;
  DateTime? endDate;
  String? notes;
  String? imageUrl;
  String? edition;

  BookComic({
    required this.id,
    required this.title,
    required this.author,
    required this.type,
    this.isReading = false,
    this.isWishlist = false,
    this.startDate,
    this.endDate,
    this.notes,
    this.imageUrl,
    this.edition,
  });

  factory BookComic.create({
    required String title,
    required String author,
    required String type,
    bool isReading = false,
    bool isWishlist = false,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    String? imageUrl,
    String? edition,
  }) {
    final uuid = const Uuid();
    return BookComic(
      id: uuid.v4(),
      title: title,
      author: author,
      type: type,
      isReading: isReading,
      isWishlist: isWishlist,
      startDate: startDate,
      endDate: endDate,
      notes: notes,
      imageUrl: imageUrl,
      edition: edition,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'type': type,
      'isReading': isReading,
      'isWishlist': isWishlist,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'notes': notes,
      'imageUrl': imageUrl,
      'edition': edition,
    };
  }
  
  factory BookComic.fromJson(Map<String, dynamic> json) {
    return BookComic(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      type: json['type'] as String,
      isReading: json['isReading'] as bool,
      isWishlist: json['isWishlist'] as bool,
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'] as String)
          : null,
      notes: json['notes'] as String?,
      imageUrl: json['imageUrl'] as String?,
      edition: json['edition'] as String?,
    );
  }
  
  BookComic copyWith({
    String? id,
    String? title,
    String? author,
    String? type,
    bool? isReading,
    bool? isWishlist,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    String? imageUrl,
    String? edition,
  }) {
    return BookComic(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      type: type ?? this.type,
      isReading: isReading ?? this.isReading,
      isWishlist: isWishlist ?? this.isWishlist,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      edition: edition ?? this.edition,
    );
  }
}
