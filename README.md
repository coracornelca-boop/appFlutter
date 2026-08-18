# 🍳 PyCook — Application de recettes

PyCook est une application de gestion et de consultation de recettes développée avec *Flutter* et *Supabase*.

L'application permet aux utilisateurs authentifiés de consulter les recettes disponibles, d'ajouter leurs propres recettes, de modifier et de supprimer leurs recettes, avec gestion des images via Supabase Storage.

---

## 🚀 Technologies utilisées

- *Flutter*
- *Dart*
- *Supabase*
- *Supabase Auth*
- *PostgreSQL*
- *Supabase Storage*
- *Row Level Security (RLS)*

---

## ✨ Fonctionnalités

### 🔐 Authentification

- Création de compte avec email et mot de passe
- Connexion
- Déconnexion
- Gestion de la session utilisateur avec Supabase Auth

### 🍽️ Gestion des recettes

Les utilisateurs authentifiés peuvent :

- Consulter toutes les recettes disponibles
- Ajouter une recette
- Ajouter une image à une recette
- Modifier une recette
- Modifier son image
- Supprimer une recette
- Actualiser la liste des recettes
- Consulter le détail d'une recette

### 🖼️ Gestion des images

Les images sont stockées dans *Supabase Storage*.

Lorsqu'une image est remplacée :

1. La nouvelle image est envoyée dans Storage.
2. L'URL de la nouvelle image est enregistrée dans PostgreSQL.
3. L'ancienne image est supprimée de Storage.

---

## 🔒 Sécurité

La sécurité des données est assurée par *Row Level Security (RLS)* dans Supabase.

Les règles principales sont :

- Les utilisateurs authentifiés peuvent consulter les recettes.
- Un utilisateur peut modifier uniquement ses propres recettes.
- Un utilisateur peut supprimer uniquement ses propres recettes.
- Les opérations sensibles sont contrôlées côté base de données et non uniquement côté interface Flutter.

---

## 🗄️ Structure des données

La table principale utilisée par l'application est :

### recipes

| Colonne | Description |
|---|---|
| id | Identifiant unique de la recette |
| name | Nom de la recette |
| description | Description de la recette |
| image_url | URL de l'image stockée dans Supabase Storage |
| user_id | Identifiant de l'utilisateur ayant créé la recette |
| created_at | Date de création |

---

## 📦 Supabase Storage

Un bucket dédié aux images des recettes est utilisé pour stocker les fichiers.

Les URLs publiques des images sont enregistrées dans la colonne :

```
image_url
```

de la table `recipes`.

---

## 🏗️ Architecture du projet

```
lib/
│
├── main.dart
│
├── services/
│   ├── auth_service.dart
│   ├── recipe_service.dart
│   └── storage_service.dart
│
└── screens/
    │
    ├── auth/
    │   ├── login_screen.dart
    │   └── register_screen.dart
    │
    └── recipes/
        ├── recipes_screen.dart
        ├── recipe_detail_screen.dart
        └── add_recipe_screen.dart
```

---

## Services

### auth_service.dart

Gère :

- l'inscription ;
- la connexion ;
- la déconnexion ;
- la session utilisateur.

### recipe_service.dart

Gère les opérations sur les recettes :

- récupération ;
- création ;
- modification ;
- suppression.

### storage_service.dart

Gère :

- l'envoi des images ;
- la gestion des fichiers dans Supabase Storage ;
- la suppression des anciennes images.

---

## 🖥️ Interface

L'application possède notamment :

- une interface de connexion ;
- une interface d'inscription ;
- une liste des recettes ;
- une page de détail ;
- une interface d'ajout ;
- une interface de modification ;
- des actions de suppression ;
- une interface adaptée aux différents états de l'application.

---

## ⚙️ Installation

### 1. Cloner le projet

```bash
git clone https://github.com/coracornelca-boop/appFlutter.git
```

Puis :

```bash
cd appFlutter
```

### 2. Installer les dépendances

```bash
flutter pub get
```

### 3. Configurer Supabase

Le projet utilise Supabase pour :

- l'authentification ;
- la base PostgreSQL ;
- le stockage des images.

Les paramètres Supabase doivent être configurés dans le projet Flutter.

### 4. Lancer l'application

Pour Chrome :

```bash
flutter run -d chrome
```

Pour Android :

```bash
flutter run
```

---

## 🧪 Vérification

Pour analyser le projet :

```bash
flutter analyze
```

Pour exécuter les tests :

```bash
flutter test
```

---

## 🔄 Fonctionnement général

```
Utilisateur
     │
     ▼
Connexion / Inscription
     │
     ▼
Supabase Auth
     │
     ▼
Liste des recettes
     │
     ├───────────────┐
     ▼               ▼
Consulter        Ajouter
     │               │
     ▼               ▼
Détail          Image + données
                     │
                     ▼
              Supabase Storage
                     │
                     ▼
                PostgreSQL
                     │
                     ▼
                    RLS
```

---

## 👤 Gestion des utilisateurs

Chaque recette est associée à l'utilisateur qui l'a créée grâce à :

```
user_id
```

Cela permet à Supabase RLS de contrôler les opérations de modification et de suppression.

---

## 🛡️ Row Level Security

La sécurité ne repose pas uniquement sur l'interface Flutter.

Les politiques RLS de PostgreSQL contrôlent directement l'accès aux données.

Cela permet notamment d'empêcher un utilisateur d'effectuer directement une opération non autorisée via l'API Supabase.

---

## 📱 Plateformes

Le projet Flutter peut être exécuté notamment sur :

- Android
- Web
- Windows

---

## 📌 État du projet

### Fonctionnalités terminées

- [x] Inscription
- [x] Connexion
- [x] Déconnexion
- [x] Session utilisateur
- [x] Liste des recettes
- [x] Détail d'une recette
- [x] Ajout d'une recette
- [x] Upload d'image
- [x] Modification d'une recette
- [x] Suppression d'une recette
- [x] Remplacement d'image
- [x] Suppression de l'ancienne image
- [x] Supabase Auth
- [x] PostgreSQL
- [x] Supabase Storage
- [x] RLS
- [x] Interface utilisateur PyCook

---

## 👨‍💻 Développement

Projet réalisé avec :

```
Flutter + Dart + Supabase
```

L'objectif est de démontrer la capacité à développer une application mobile complète avec authentification, gestion des données, stockage de fichiers et sécurisation des accès.

---

## 📄 Licence

Projet réalisé dans le cadre d'une évaluation technique.
