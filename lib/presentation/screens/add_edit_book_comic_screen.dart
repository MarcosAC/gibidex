import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gibidex/domain/entities/book_comic.dart';
import 'package:gibidex/presentation/providers/book_comic_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddEditBookComicScreen extends StatefulWidget {
  final BookComic? bookComic;

  const AddEditBookComicScreen({super.key, this.bookComic});

  @override
  State<AddEditBookComicScreen> createState() => _AddEditBookComicScreenState();
}

class _AddEditBookComicScreenState extends State<AddEditBookComicScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  String? _selectedType;
  late bool _isReading;
  late bool _isWishlist;
  late TextEditingController _notesController;
  String? _editionController;
  File? _imageFile; 

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.bookComic?.title ?? '');
    _authorController = TextEditingController(text: widget.bookComic?.author ?? '');
    _selectedType = widget.bookComic?.type;
    _isReading = widget.bookComic?.isReading ?? false;
    _isWishlist = widget.bookComic?.isWishlist ?? false;
    _notesController = TextEditingController(text: widget.bookComic?.notes ?? '');
    _editionController = widget.bookComic?.edition;

    if (widget.bookComic?.imageUrl != null) {
      _imageFile = File(widget.bookComic!.imageUrl!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _saveBookComic() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final provider = Provider.of<BookComicProvider>(context, listen: false);

      if (widget.bookComic == null) {
        provider.addNewBookComic(
          _titleController.text,
          _authorController.text,
          _selectedType!,
          _isReading,
          _isWishlist,
          _notesController.text.isNotEmpty ? _notesController.text : null,
          _imageFile?.path,
          _editionController,
        );
      } else {
        final updatedBookComic = widget.bookComic!.copyWith(
          title: _titleController.text,
          author: _authorController.text,
          type: _selectedType,
          isReading: _isReading,
          isWishlist: _isWishlist,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
          startDate: _isReading && widget.bookComic!.startDate == null && !widget.bookComic!.isReading
              ? DateTime.now()
              : widget.bookComic!.startDate,
          endDate: !_isReading && widget.bookComic!.isReading && widget.bookComic!.endDate == null
              ? DateTime.now()
              : widget.bookComic!.endDate,
          imageUrl: _imageFile?.path,
          edition: _editionController,
        );
        provider.updateExistingBookComic(updatedBookComic);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hintColor = Theme.of(context).hintColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bookComic == null ? 'Adicionar Nova Crônica' : 'Editar Crônica'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext contex) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.photo_library),
                                title: const Text('Galeria'),
                                onTap: () {
                                  _pickImage(ImageSource.gallery);
                                  Navigator.of(context).pop();
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.camera_alt),
                                title: const Text('Câmera'),
                                onTap: () {
                                  _pickImage(ImageSource.camera);
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        );
                      }
                    );
                  },
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(context).cardColor,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : null,
                    child: _imageFile == null
                        ? Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: hintColor,
                          )
                        : null,
                  ),                  
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Título da Crônica',
                  hintText: 'Ex: A Sociedade do Anel',
                  prefixIcon: Icon(Icons.menu_book, color: hintColor),
                ),
                style: textTheme.bodyLarge,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Invoca o título desta crônica, aventureiro!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(
                  labelText: 'Autor/Criador',
                  hintText: 'Ex: J.R.R. Tolkien',
                  prefixIcon: Icon(Icons.create, color: hintColor),
                ),
                style: textTheme.bodyLarge,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Quem forjou esta crônica? É crucial!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Tipo de Tomo',
                  hintText: 'Selecione o tipo',
                  prefixIcon: Icon(Icons.category, color: hintColor),
                ),
                dropdownColor: Theme.of(context).cardColor,
                style: textTheme.bodyLarge,
                items: <String>['Livro', 'Gibi'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: textTheme.bodyLarge),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedType = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Qual a natureza deste tomo? Livro ou Gibi?';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              if (_selectedType == 'Gibi') ...[
                TextFormField(
                  initialValue: _editionController,
                  decoration: InputDecoration(
                    labelText: 'Número da Edição (Gibi)',
                    hintText: 'Ex: #123',
                    prefixIcon: Icon(Icons.numbers, color: hintColor),
                  ),
                  style: textTheme.bodyLarge,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _editionController = value.isNotEmpty ? value : null; 
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],
              SwitchListTile(
                title: Text('Desvendando Atualmente', style: textTheme.bodyLarge),
                value: _isReading,
                onChanged: (bool value) {
                  setState(() {
                    _isReading = value;
                    if (_isReading && _isWishlist) {
                      _isWishlist = false;
                    }
                  });
                },
                activeColor: const Color(0xFF27AE60),                
                inactiveTrackColor: Theme.of(context).cardColor.withAlpha(
                  ((Theme.of(context).cardColor.a * 255.0).round() * 0.6).round() & 0xff,
                ),
                activeTrackColor: const Color(0x9927AE60),
                thumbColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return const Color(0xFF27AE60);
                    }
                    return Theme.of(context).dividerColor;
                  },
                ),
              ),
              SwitchListTile(
                title: Text('No Grimório de Desejos', style: textTheme.bodyLarge),
                value: _isWishlist,
                onChanged: (bool value) {
                  setState(() {
                    _isWishlist = value;
                    if (_isWishlist && _isReading) {
                      _isReading = false;
                    }
                  });
                },
                activeColor: const Color(0xFF8E44AD),                
                inactiveTrackColor: Theme.of(context).cardColor.withAlpha(
                  ((Theme.of(context).cardColor.a * 255.0).round() * 0.6).round() & 0xff,
                ),
                activeTrackColor: const Color(0x998E44AD),
                thumbColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return const Color(0xFF8E44AD);
                    }
                    return Theme.of(context).dividerColor;
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Anotações do Aventureiro (Opcional)',
                  hintText: 'Ex: Personagens favoritos, trechos marcantes...',
                  prefixIcon: Icon(Icons.description, color: hintColor), // Changed to description for a more common icon
                ),
                style: textTheme.bodyLarge,
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value != null && value.length > 200) {
                    return 'Suas anotações são muito extensas para este pergaminho. Max: 200 caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveBookComic,
                child: Text(
                  widget.bookComic == null ? 'Registrar Nova Crônica' : 'Atualizar Tomo',
                  style: textTheme.labelLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}