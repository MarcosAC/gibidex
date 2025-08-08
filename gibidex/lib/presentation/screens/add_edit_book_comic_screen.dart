import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gibidex/domain/entities/book_comic.dart';
import 'package:gibidex/presentation/providers/book_comic_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gibidex/presentation/services/book_cover_service.dart';
import 'dart:async';

class AddEditBookComicScreen extends StatefulWidget {
  final BookComic? bookComic;

  const AddEditBookComicScreen({super.key, this.bookComic});

  @override
  State<AddEditBookComicScreen> createState() => _AddEditBookComicScreenState();
}

class _AddEditBookComicScreenState extends State<AddEditBookComicScreen> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  String? _selectedType;
  late bool _isReading;
  late bool _isWishlist;
  late TextEditingController _notesController;
  String? _editionController;
  String? _selectedLocalImagePath;

  static const String _tempImagePathKey = 'temp_image_path';
  Timer? _debounceTimer;
  bool _isSearchingCover = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);    

    _titleController = TextEditingController(text: widget.bookComic?.title ?? '');
    _authorController = TextEditingController(text: widget.bookComic?.author ?? '');
    _selectedType = widget.bookComic?.type;
    _isReading = widget.bookComic?.isReading ?? false;
    _isWishlist = widget.bookComic?.isWishlist ?? false;
    _notesController = TextEditingController(text: widget.bookComic?.notes ?? '');
    _editionController = widget.bookComic?.edition;

    _loadInitialImage();

    _titleController.addListener(_onFormFieldsChanged);
    _authorController.addListener(_onFormFieldsChanged);
  }  

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);    
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {      
      if (_selectedLocalImagePath != null) {
        _saveTempImage(_selectedLocalImagePath);
      }
    }
  }

  void _onFormFieldsChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (_titleController.text.isNotEmpty && !_isSearchingCover) {
        _performAutomaticSearch();
      }
    });
  }

  void _performAutomaticSearch() async {
    setState(() {
      _isSearchingCover = true;
    });
    
    final String? newImagePath = await _searchCoverAutomatically();

    if (mounted) {
      setState(() {
        if (newImagePath != null) {
          _selectedLocalImagePath = newImagePath;
          _saveTempImage(_selectedLocalImagePath);         
        } else {
          if (widget.bookComic?.imageUrl == null || (widget.bookComic?.imageUrl != _selectedLocalImagePath)) {
            _selectedLocalImagePath = null;
          }
        }
        _isSearchingCover = false;
      });
    }
  }

  void _loadInitialImage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tempPath = prefs.getString(_tempImagePathKey);

    String? imageToLoad;

    if (widget.bookComic != null) {
      if (widget.bookComic!.imageUrl != null && File(widget.bookComic!.imageUrl!).existsSync()) {
        imageToLoad = widget.bookComic!.imageUrl!;        
      } else {
        imageToLoad = null;
      }
      if (tempPath != null) {
        prefs.remove(_tempImagePathKey);
      }
    }    
    else {
      if (tempPath != null && File(tempPath).existsSync()) {
        imageToLoad = tempPath;
        prefs.remove(_tempImagePathKey);
      } else {
        imageToLoad = null;
        if (tempPath != null) {
          prefs.remove(_tempImagePathKey);
        }
      }
    }

    if (mounted) {
      setState(() {
        _selectedLocalImagePath = imageToLoad;
      });
    }
  }

  void _saveTempImage(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    if (path != null) {
      prefs.setString(_tempImagePathKey, path);
    } else {
      prefs.remove(_tempImagePathKey);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant AddEditBookComicScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _titleController.removeListener(_onFormFieldsChanged);
    _authorController.removeListener(_onFormFieldsChanged);
    _titleController.dispose();
    _authorController.dispose();
    _notesController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<String?> _pickImage(ImageSource source) async {
    PermissionStatus status;

    if (source == ImageSource.gallery) {
      if (await Permission.photos.request().isGranted || await Permission.storage.request().isGranted) {
        status = PermissionStatus.granted;
      } else {
        status = PermissionStatus.denied;
      }

      if (!status.isGranted) {
        if (status.isPermanentlyDenied) {
          openAppSettings();
        }
        return null;
      }
    } else {
      return null;
    }

    final picker = ImagePicker();
    XFile? pickedFile;

    try {
      pickedFile = await picker.pickImage(source: source);
    } catch (e) {
      return null;
    }

    if (pickedFile != null) {
      return pickedFile.path;
    } else {
      return null;
    }
  }

  Future<String?> _downloadAndSaveImageFromUrl(String imageUrl) async {
    HttpClient? client;
    try {
      client = HttpClient();
      final request = await client.getUrl(Uri.parse(imageUrl));
      final response = await request.close();

      if (response.statusCode == 200) {
        final Directory tempDir = await getTemporaryDirectory();
        final String fileName = p.basename(Uri.parse(imageUrl).path);
        final String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
        final File tempFile = File(p.join(tempDir.path, uniqueFileName));
        await tempFile.writeAsBytes(await response.fold<List<int>>([], (prev, element) => prev..addAll(element)));
        return tempFile.path;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    } finally {
      client?.close();
    }
  }

  Future<String?> _searchCoverAutomatically() async {
    final String title = _titleController.text;
    final String author = _authorController.text;

    if (title.isEmpty) {
      return null;
    }
    
    final BookCoverService coverService = BookCoverService();
    String? imageUrl = await coverService.searchBookCover(title, author);

    if (imageUrl != null) {      
      return await _downloadAndSaveImageFromUrl(imageUrl);
    } else {
      imageUrl = await coverService.searchWebImage('$title $author');

      if (imageUrl != null) {
        return await _downloadAndSaveImageFromUrl(imageUrl);
      } else {
        return null;
      }
    }
  }

  void _saveBookComic() async {
    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (!_formKey.currentState!.validate()) {
        return;
      }
      _formKey.currentState!.save();

      final provider = Provider.of<BookComicProvider>(context, listen: false);

      String? finalImageUrl = _selectedLocalImagePath;

      if (finalImageUrl != null && File(finalImageUrl).existsSync()) {
        final appDocDir = await getApplicationDocumentsDirectory();
        final String fileName = p.basename(finalImageUrl);
        final String persistentPath = p.join(appDocDir.path, fileName);

        if (finalImageUrl != persistentPath) {
          try {
            final File newImage = await File(finalImageUrl).copy(persistentPath);
            finalImageUrl = newImage.path;
            _saveTempImage(null);
          } catch (e) {
            finalImageUrl = null;
          }
        } else {
          _saveTempImage(null);
        }
      } else {
        finalImageUrl = null;
        _saveTempImage(null);
      }

      if (widget.bookComic == null) {
        provider.addNewBookComic(
          _titleController.text,
          _authorController.text,
          _selectedType!,
          _isReading,
          _isWishlist,
          _notesController.text.isNotEmpty ? _notesController.text : null,
          finalImageUrl,
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
          imageUrl: finalImageUrl,
          edition: _editionController,
        );
        provider.updateExistingBookComic(updatedBookComic);
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
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
            children: <Widget>[
              Center(
                child: GestureDetector(
                  onTap: () async {
                    final String? pickedResultPath = await showModalBottomSheet<String?>(
                      context: context,
                      builder: (BuildContext sheetContext) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                leading: const Icon(Icons.photo_library),
                                title: const Text('Galeria'),
                                onTap: () async {
                                  final String? imagePath = await _pickImage(ImageSource.gallery);
                                  if (!sheetContext.mounted) return;
                                  if (imagePath != null) {                                    
                                    Navigator.of(sheetContext).pop(imagePath);
                                  } else {
                                    Navigator.of(sheetContext).pop(null);
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );

                    if (!mounted) return;
                    if (pickedResultPath != null) {
                      setState(() {
                        _selectedLocalImagePath = pickedResultPath;
                      });                      
                      _saveTempImage(_selectedLocalImagePath);
                    } 
                  },
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(context).cardColor,
                    backgroundImage: _selectedLocalImagePath != null && File(_selectedLocalImagePath!).existsSync()
                        ? FileImage(File(_selectedLocalImagePath!))
                        : null,
                    child: _isSearchingCover
                        ? CircularProgressIndicator(color: hintColor)
                        : (_selectedLocalImagePath == null || !File(_selectedLocalImagePath!).existsSync()
                            ? Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: hintColor,
                              )
                            : null),
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
                  prefixIcon: Icon(Icons.description, color: hintColor),
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
                onPressed: _isSaving ? null : () {
                  _saveBookComic();
                },
                child: _isSaving
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.onPrimary,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
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