# Studify - Gestion des Absences Étudiants

Application Flutter de gestion des absences étudiants avec accès parental.

## 📱 Fonctionnalités

- **Authentification multi-rôles** : Admin, Parent, Étudiant
- **Gestion des étudiants** : Les administrateurs peuvent ajouter et gérer les étudiants
- **Gestion des absences** : Enregistrement des absences avec type (justifiée, non justifiée, retard)
- **Accès parental** : Les parents peuvent consulter les absences de leurs enfants
- **Tableau de bord étudiant** : Les étudiants peuvent voir leurs propres absences
- **Base de données locale** : Utilise SQLite pour stocker les données

## 🚀 Installation

1. Assurez-vous d'avoir Flutter installé sur votre machine
2. Clonez le projet
3. Installez les dépendances :
```bash
flutter pub get
```

4. Lancez l'application :
```bash
flutter run
```

## 🔐 Comptes de test

L'application inclut des comptes de test pré-configurés :

- **Administrateur**
  - Username: `admin`
  - Password: `admin123`

- **Étudiant**
  - Username: `STU001`
  - Password: `student123`

- **Parent**
  - Username: `parent@example.com`
  - Password: `parent123`

## 🎯 Utilisation

### Pour les Administrateurs

1. Connectez-vous avec le compte admin
2. **Onglet Étudiants** : Ajoutez de nouveaux étudiants avec leur nom, ID et email parent optionnel
3. **Onglet Absences** : 
   - Sélectionnez un étudiant
   - Ajoutez des absences avec date, matière, raison et type
   - Supprimez des absences si nécessaire

### Pour les Parents

1. Connectez-vous avec votre email parent
2. Consultez la liste de vos enfants
3. Sélectionnez un enfant pour voir toutes ses absences
4. Les absences sont colorées selon leur type :
   - 🟢 Verte : Justifiée
   - 🔴 Rouge : Non justifiée
   - 🟠 Orange : Retard

### Pour les Étudiants

1. Connectez-vous avec votre ID étudiant
2. Consultez votre profil
3. Visualisez toutes vos absences avec les détails (date, matière, raison, type)

## 🛠️ Technologies utilisées

- **Flutter** : Framework de développement
- **SQLite** (sqflite) : Base de données locale
- **SharedPreferences** : Stockage des sessions utilisateur
- **Material Design 3** : Interface utilisateur moderne

## 📦 Structure du projet

```
lib/
├── models/          # Modèles de données (User, Student, Absence)
├── database/        # Gestion de la base de données SQLite
├── services/        # Services (Authentification)
└── screens/         # Écrans de l'application
    ├── login_screen.dart
    ├── student_dashboard.dart
    ├── parent_dashboard.dart
    └── admin_dashboard.dart
```

## 🔒 Sécurité

⚠️ **Note** : Cette application est destinée à des fins éducatives. Pour un environnement de production, vous devriez :
- Implémenter un hachage de mot de passe (bcrypt, argon2)
- Utiliser une authentification sécurisée (JWT, OAuth)
- Chiffrer la base de données
- Implémenter une API backend sécurisée

## 📄 Licence

Ce projet est à des fins éducatives.
