import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/recipe_service.dart';
import 'add_recipe_screen.dart';
import 'recipe_detail_screen.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final RecipeService _recipeService = RecipeService();

  late Future<List<Map<String, dynamic>>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  void _loadRecipes() {
    _recipesFuture = _recipeService.getRecipes();
  }

  Future<void> _logout() async {
    await AuthService().logout();

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _refreshRecipes() async {
    setState(() {
      _loadRecipes();
    });

    await _recipesFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080A10),

      appBar: AppBar(
        backgroundColor: const Color(0xFF080A10),
        elevation: 0,

        titleSpacing: 20,

        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF11151E),
                border: Border.all(
                  color: const Color(0xFFFF8A00),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.restaurant_rounded,
                color: Color(0xFFFF8A00),
                size: 22,
              ),
            ),

            const SizedBox(width: 12),

            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PyCook',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Découvrez les recettes',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip: 'Déconnexion',
            onPressed: _logout,
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.white70,
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _recipesFuture,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF8A00),
              ),
            );
          }

          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }

          final recipes = snapshot.data ?? [];

          if (recipes.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            color: const Color(0xFFFF8A00),
            onRefresh: _refreshRecipes,

            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                20,
                10,
                20,
                100,
              ),
              itemCount: recipes.length,

              itemBuilder: (context, index) {
                final recipe = recipes[index];

                return _buildRecipeCard(recipe);
              },
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFF8A00),

        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddRecipeScreen(),
            ),
          );

          // Recharge les recettes après ajout/modification.
          if (mounted) {
            setState(() {
              _loadRecipes();
            });
          }
        },

        icon: const Icon(
          Icons.add_rounded,
          color: Colors.white,
        ),

        label: const Text(
          'Ajouter une recette',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    final name = recipe['name']?.toString() ?? '';
    final description = recipe['description']?.toString() ?? '';
    final imageUrl = recipe['image_url']?.toString() ?? '';

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecipeDetailScreen(
              recipe: recipe,
            ),
          ),
        );

        if (result == true && mounted) {
          setState(() {
            _loadRecipes();
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF11131B),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.07),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRecipeImage(imageUrl),
              Padding(
                padding: const EdgeInsets.all(17),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(
                          Icons.restaurant_menu_rounded,
                          color: Color(0xFFFF8A00),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Recette PyCook',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        width: double.infinity,
        height: 200,

        color: const Color(0xFF24242D),

        child: const Icon(
          Icons.restaurant_menu_rounded,
          color: Colors.white24,
          size: 65,
        ),
      );
    }

    return Image.network(
      imageUrl,
      width: double.infinity,
      height: 200,
      fit: BoxFit.cover,

      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: double.infinity,
          height: 200,

          color: const Color(0xFF24242D),

          child: const Icon(
            Icons.broken_image_outlined,
            color: Colors.white24,
            size: 55,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      color: const Color(0xFFFF8A00),

      onRefresh: _refreshRecipes,

      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),

        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.25,
          ),

          const Icon(
            Icons.restaurant_menu_rounded,
            color: Color(0xFFFF8A00),
            size: 75,
          ),

          const SizedBox(height: 20),

          const Text(
            'Aucune recette',
            textAlign: TextAlign.center,

            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Soyez le premier à partager\nune recette avec la communauté.',
            textAlign: TextAlign.center,

            style: TextStyle(
              color: Colors.white54,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 60,
            ),

            const SizedBox(height: 20),

            const Text(
              'Impossible de charger les recettes',
              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              error,
              textAlign: TextAlign.center,

              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: _refreshRecipes,

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8A00),
                foregroundColor: Colors.white,

                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 13,
                ),
              ),

              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}