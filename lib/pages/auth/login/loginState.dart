// Importation du modèle User qui contient les informations de l'utilisateur connecté
import '../../../business/models/user/user.dart';

// Classe représentant l'état de l'écran de connexion (login)
class LoginState {
  // Indique si une opération est en cours (chargement)
  final bool isLoading;

  // Message d'erreur à afficher à l'utilisateur, s'il y en a
  final String? errorMessage;

  // Message de succès à afficher à l'utilisateur, s'il y en a
  final String? successMessage;

  // Données de l'utilisateur connecté (null si non connecté)
  final User? user;

  // Constructeur de la classe avec des paramètres nommés
  LoginState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.user,
  });

  // Méthode pour créer une nouvelle version modifiée de l’état actuel
  LoginState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    User? user,
  }) {
    return LoginState(
      // Si une nouvelle valeur est fournie, on l’utilise ; sinon, on garde l’ancienne
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      user: user ?? this.user,
    );
  }

  // Fabrique un état initial (valeurs par défaut)
  factory LoginState.initial() {
    return LoginState(
      isLoading: false,
      errorMessage: null,
      successMessage: null,
      user: null,
    );
  }

  // Propriété dérivée : indique si le formulaire est valide (basé ici sur la présence d’un user)
  bool get isFormValid => user != null;
}
