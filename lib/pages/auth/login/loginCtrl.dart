// Importation des bibliothèques nécessaires
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart'; // Pour la gestion d'état avec Riverpod
import 'package:odc_mobile_template/business/models/user/authentication.dart'; // Modèle représentant les données d'authentification
import 'package:odc_mobile_template/business/services/user/userLocalService.dart'; // Service pour stocker/récupérer l'utilisateur en local
import 'package:odc_mobile_template/business/services/user/userNetworkService.dart'; // Service pour les appels réseau liés à l'utilisateur
import 'package:odc_mobile_template/main.dart'; // Contient probablement l'instance de getIt (injection de dépendances)
import 'package:odc_mobile_template/pages/auth/login/loginState.dart';
import 'package:odc_mobile_template/utils/http/HttpRequestException.dart'; // Fichier contenant l'état du login

// Contrôleur de connexion, qui étend StateNotifier pour gérer l'état du login
class LoginCtrl extends StateNotifier<LoginState> {
  // Services pour la logique réseau (API) et locale (stockage)
  final UserNetworkService network = getIt.get<UserNetworkService>();
  final UserLocalService local = getIt.get<UserLocalService>();

  // Initialisation avec un état initial
  LoginCtrl() : super(LoginState.initial());

  // Fonction principale pour se connecter avec les données du formulaire
  Future<bool> loginForm(Authentication data) async {
    // Mise à jour de l'état : début du chargement, suppression des anciens messages
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    );

    // Vérifie si les champs sont vides
    if (data.email.isEmpty || data.password.isEmpty) {
      // Mise à jour de l'état avec un message d'erreur
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Veuillez remplir tous les champs.",
      );
      durationToast();
      return false; // Annulation du processus
    }


    try {
      // Appel de l'API pour tenter une connexion
      final user = await network.seConnecter(data);

      // Si l'utilisateur est valide
      if (user != null) {
        // Sauvegarde locale de l'utilisateur connecté
        final res = await local.sauvegarderUser(user);

        // Mise à jour de l'état avec l'utilisateur et un message de succès
        state = state.copyWith(
          isLoading: true,
          user: user,
          successMessage: "Connexion réussie !",
        );
        durationToast();
        return res; // Retourne true si la sauvegarde a fonctionné
      } else {
        // Si les identifiants sont incorrects
        state = state.copyWith(
          isLoading: false,
          errorMessage: "Identifiants incorrects.",
        );
        durationToast();
        return false;
      }
    }on HttpRequestException catch(e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '"${e.body}"',
      );
      durationToast();
      return false;
    }on TimeoutException catch (_) {
      // Gestion du cas où le serveur prend trop de temps à répondre
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Temps d'attente dépassé. Le serveur ne répond pas.",
      );
      durationToast();
      return false;
    } catch (e) {
      // Gestion des autres erreurs
      state = state.copyWith(
        isLoading: false,
        errorMessage: "${e}",
      );
      durationToast();
      return false;
    }

  }

  // Récupération de l'utilisateur sauvegardé localement (ex. pour rester connecté)
  Future<void> recupererUserLocal() async {
    final user = await local.recupererUser();
    state = state.copyWith(user: user);
  }

  // Nettoie les messages d'erreur et de succès (ex. après affichage)
  void resetMessages() {
    state = state.copyWith(
      errorMessage: null,
      successMessage: null,
    );
  }

  durationToast(){
    Future.delayed(Duration(seconds: 3),(){
      resetMessages();
    });
  }

}

// Déclaration du Provider Riverpod pour le LoginCtrl
final LoginCtrlProvider = StateNotifierProvider<LoginCtrl, LoginState>((ref) {
  ref.keepAlive(); // Permet de garder le provider actif en mémoire (utile dans une session de login)
  return LoginCtrl(); // Retourne une instance du contrôleur
});
