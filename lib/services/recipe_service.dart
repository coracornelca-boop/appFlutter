import 'package:supabase_flutter/supabase_flutter.dart';

class RecipeService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Récupérer toutes les recettes
  Future<List<Map<String, dynamic>>> getRecipes() async {
    final response = await _supabase
        .from('recipes')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Ajouter une recette
  Future<Map<String, dynamic>> createRecipe({
    required String name,
    required String description,
    required String imageUrl,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }

    final response = await _supabase
        .from('recipes')
        .insert({
          'name': name,
          'description': description,
          'image_url': imageUrl,
          'user_id': user.id,
        })
        .select()
        .single();

    return response;
  }

  // Modifier une recette
  Future<Map<String, dynamic>> updateRecipe({
    required String recipeId,
    required String name,
    required String description,
    required String imageUrl,
  }) async {
    final response = await _supabase
        .from('recipes')
        .update({
          'name': name,
          'description': description,
          'image_url': imageUrl,
        })
        .eq('id', recipeId)
        .select()
        .single();

    return response;
  }

  // Supprimer une recette
  Future<void> deleteRecipe(String recipeId) async {
    await _supabase
        .from('recipes')
        .delete()
        .eq('id', recipeId);
  }
}