import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/recipe_service.dart';
import '../../services/storage_service.dart';

class AddRecipeScreen extends StatefulWidget {
  final Map<String, dynamic>? recipe;

  const AddRecipeScreen({
    super.key,
    this.recipe,
  });

  bool get isEditing => recipe != null;

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  final RecipeService _recipeService = RecipeService();
  final StorageService _storageService = StorageService();

  Uint8List? _imageBytes;
  String? _imageName;

  String? _oldImageUrl;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.recipe != null) {
      _nameController.text =
          widget.recipe!['name']?.toString() ?? '';

      _descriptionController.text =
          widget.recipe!['description']?.toString() ?? '';

      _oldImageUrl =
          widget.recipe!['image_url']?.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();

      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      setState(() {
        _imageBytes = bytes;
        _imageName = image.name;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors de la sélection : $e',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // En ajout, l'image est obligatoire.
    if (!widget.isEditing &&
        (_imageBytes == null || _imageName == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez sélectionner une image.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl = _oldImageUrl;

      // Si une nouvelle image est sélectionnée,
      // on l'upload.
      if (_imageBytes != null && _imageName != null) {
        imageUrl = await _storageService.uploadImage(
          bytes: _imageBytes!,
          fileName: _imageName!,
        );

        // Supprimer l'ancienne image après
        // avoir réussi le nouvel upload.
        if (widget.isEditing &&
            _oldImageUrl != null &&
            _oldImageUrl!.isNotEmpty) {
          try {
            await _storageService.deleteImage(
              _oldImageUrl!,
            );
          } catch (_) {
            // L'image en base reste valide même si
            // la suppression Storage échoue.
          }
        }
      }

      if (widget.isEditing) {
        await _recipeService.updateRecipe(
          recipeId: widget.recipe!['id'].toString(),
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          imageUrl: imageUrl ?? '',
        );
      } else {
        await _recipeService.createRecipe(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          imageUrl: imageUrl ?? '',
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Recette modifiée avec succès !'
                : 'Recette ajoutée avec succès !',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      final msg = e.toString().toLowerCase();

      String message;

      if (widget.isEditing) {
        if (msg.contains('permission') || msg.contains('denied') || msg.contains('rls')) {
          message = 'Vous n\'avez pas les droits pour modifier cette recette.';
        } else if (msg.contains('not found') || msg.contains('row')) {
          message = 'Cette recette n\'existe plus.';
        } else {
          message = 'Erreur lors de la modification. Réessayez.';
        }
      } else {
        if (msg.contains('permission') || msg.contains('denied') || msg.contains('rls')) {
          message = 'Vous n\'avez pas les droits pour ajouter une recette.';
        } else {
          message = 'Erreur lors de l\'ajout. Réessayez.';
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;

    return Scaffold(
      backgroundColor: const Color(0xFF080A10),

      appBar: AppBar(
        backgroundColor: const Color(0xFF080A10),
        elevation: 0,

        leading: IconButton(
          onPressed: _isLoading
              ? null
              : () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
        ),

        title: Text(
          isEditing
              ? 'Modifier la recette'
              : 'Ajouter une recette',

          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            35,
          ),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Photo de la recette',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                _buildImagePicker(),

                const SizedBox(height: 25),

                const Text(
                  'Informations',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                _buildNameField(),

                const SizedBox(height: 16),

                _buildDescriptionField(),

                const SizedBox(height: 28),

                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _isLoading ? null : _pickImage,

      child: Container(
        width: double.infinity,
        height: 230,

        decoration: BoxDecoration(
          color: const Color(0xFF11131B),
          borderRadius: BorderRadius.circular(22),

          border: Border.all(
            color: const Color(0xFFFF8A00)
                .withValues(alpha: 0.35),
          ),
        ),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),

          child: _imageBytes != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(
                      _imageBytes!,
                      fit: BoxFit.cover,
                    ),

                    _buildImageOverlay(),
                  ],
                )
              : widget.isEditing &&
                      _oldImageUrl != null &&
                      _oldImageUrl!.isNotEmpty
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          _oldImageUrl!,
                          fit: BoxFit.cover,

                          errorBuilder:
                              (context, error, stackTrace) {
                            return _emptyImage();
                          },
                        ),

                        _buildImageOverlay(),
                      ],
                    )
                  : _emptyImage(),
        ),
      ),
    );
  }

  Widget _emptyImage() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          color: Color(0xFFFF8A00),
          size: 55,
        ),

        SizedBox(height: 12),

        Text(
          'Sélectionner une image',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),

        SizedBox(height: 5),

        Text(
          'Appuyez pour choisir une photo',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildImageOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.25),

      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
              size: 35,
            ),

            SizedBox(height: 8),

            Text(
              'Changer la photo',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,

      style: const TextStyle(
        color: Colors.white,
      ),

      decoration: _inputDecoration(
        label: 'Nom de la recette',
        icon: Icons.restaurant_menu_rounded,
      ),

      validator: (value) {
        if (value == null ||
            value.trim().isEmpty) {
          return 'Veuillez entrer le nom de la recette';
        }

        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,

      maxLines: 6,

      style: const TextStyle(
        color: Colors.white,
      ),

      decoration: _inputDecoration(
        label: 'Description',
        icon: Icons.description_outlined,
      ),

      validator: (value) {
        if (value == null ||
            value.trim().isEmpty) {
          return 'Veuillez entrer une description';
        }

        return null;
      },
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,

      labelStyle: const TextStyle(
        color: Colors.white54,
      ),

      prefixIcon: Icon(
        icon,
        color: const Color(0xFFFF8A00),
      ),

      filled: true,
      fillColor: const Color(0xFF24242D),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFFFF8A00),
          width: 1.5,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,

      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFA000),
              Color(0xFFFF6500),
            ],
          ),

          borderRadius: BorderRadius.circular(18),

          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF7600)
                  .withValues(alpha: 0.25),

              blurRadius: 18,

              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: ElevatedButton(
          onPressed: _isLoading
              ? null
              : _saveRecipe,

          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor:
                Colors.transparent,

            shadowColor: Colors.transparent,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),

          child: _isLoading
              ? const SizedBox(
                  width: 23,
                  height: 23,

                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [
                    Icon(
                      widget.isEditing
                          ? Icons.save_outlined
                          : Icons.add_rounded,
                      color: Colors.white,
                    ),

                    const SizedBox(width: 10),

                    Text(
                      widget.isEditing
                          ? 'Enregistrer les modifications'
                          : 'Ajouter la recette',

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}