import 'dart:convert';
import 'package:http/http.dart' as http;

class BookCoverService {
  // Busca uma capa de livro/gibi na Google Books API
  // Retorna a URL da imagem da capa ou null se não encontrar
  Future<String?> searchBookCover(String title, String author) async {
    final String query = '$title ${author.isNotEmpty ? 'by $author' : ''}';
    final String encodedQuery = Uri.encodeComponent(query);
    final String apiUrl = 'https://www.googleapis.com/books/v1/volumes?q=$encodedQuery&maxResults=1';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['items'] != null && data['items'].isNotEmpty) {
          final volumeInfo = data['items'][0]['volumeInfo'];
          if (volumeInfo != null && volumeInfo['imageLinks'] != null) {
            String? imageUrl = volumeInfo['imageLinks']['thumbnail'] ?? volumeInfo['imageLinks']['smallThumbnail'];
            if (imageUrl != null && imageUrl.startsWith('http://')) {
              imageUrl = imageUrl.replaceFirst('http://', 'https://');
            }            
            return imageUrl;
          }
        }        
        return null;
      } else {        
        return null;
      }
    } catch (e) {      
      return null;
    }
  }

  // Simula uma pesquisa de imagem geral na web.
  // Em uma aplicação real, isso envolveria:
  // 1. Uma API de busca de imagens (ex: Google Custom Search API, Bing Image Search API).
  // 2. Ou um serviço de backend que faça web scraping de forma controlada e legal.
  // Direto do Flutter, web scraping de motores de busca é frágil e não recomendado.
  Future<String?> searchWebImage(String query) async {    
    await Future.delayed(const Duration(seconds: 2)); // Simula um atraso de rede

    if (query.toLowerCase().contains('gibi') || query.toLowerCase().contains('comic')) {
      return 'https://placehold.co/400x600/FF5733/FFFFFF?text=Gibi+Web';
    } else if (query.toLowerCase().contains('livro') || query.toLowerCase().contains('book')) {
      return 'https://placehold.co/400x600/3366FF/FFFFFF?text=Livro+Web';
    }

    return 'https://placehold.co/400x600/000000/FFFFFF?text=Capa+Web'; // Placeholder genérico
  }
}