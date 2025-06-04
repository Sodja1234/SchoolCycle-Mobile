import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Import du modèle Authentication contenant email et mot de passe
import 'package:odc_mobile_template/business/models/user/authentication.dart';
// Import du contrôleur de connexion (loginCtrl)
import 'package:odc_mobile_template/pages/auth/login/loginCtrl.dart';
// Import de la page d'accueil pour la redirection après connexion
import 'package:odc_mobile_template/pages/home/homePage.dart';

// Widget Stateful avec accès au Provider Riverpod via ConsumerStatefulWidget
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

// État associé au widget LoginPage
class _LoginPageState extends ConsumerState<LoginPage> {
  // Controller pour récupérer et gérer le texte du champ email
  final TextEditingController _emailController =
  TextEditingController(text: 'gigi@gmail.com'); // Valeur par défaut pour tests

  // Controller pour récupérer et gérer le texte du champ mot de passe
  final TextEditingController _passwordController = TextEditingController();

  // Booléen pour afficher ou cacher le mot de passe
  bool _obscurePassword = true;

  // Clé pour identifier et valider le formulaire
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // On écoute l'état du Login via le provider
    final loginState = ref.watch(LoginCtrlProvider);
    final isLoading = loginState.isLoading;

    // Si l'utilisateur est connecté et un message de succès existe,
    // on redirige automatiquement vers la HomePage
    if (loginState.user != null && loginState.successMessage != null) {
      // Utilisation de Future.delayed(Duration.zero) pour éviter un conflit
      // avec le cycle de build actuel de Flutter
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ===== EN-TÊTE ORANGE =====
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange[400]!, Colors.orange[500]!],
                    ),
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.book, color: Colors.white, size: 32),
                      SizedBox(height: 20),
                      Text(
                        'Bienvenue sur SchoolCycle',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Connectez-vous pour accéder à votre compte',
                        style: TextStyle(
                          color: Colors.orange[100],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                // ===== FORMULAIRE DE CONNEXION =====
                Padding(
                  padding: EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    // Valide automatiquement les champs dès que l'utilisateur interagit
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Affiche un message d'erreur si présent dans l'état
                        if (loginState.errorMessage != null)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            margin: EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red[300]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    loginState.errorMessage!,
                                    style: TextStyle(color: Colors.red[700]),
                                  ),
                                ),
                                // Bouton pour fermer le message d'erreur
                                IconButton(
                                  icon: Icon(Icons.close, size: 16),
                                  onPressed: () {
                                    // Appel du contrôleur pour réinitialiser les messages
                                    ref.read(LoginCtrlProvider.notifier).resetMessages();
                                  },
                                  color: Colors.red[300],
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                ),
                              ],
                            ),
                          ),

                        // Affiche un message de succès si présent dans l'état
                        if (loginState.successMessage != null)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            margin: EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green[300]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle_outline, color: Colors.green),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    loginState.successMessage!,
                                    style: TextStyle(color: Colors.green[700]),
                                  ),
                                ),
                                // Bouton pour fermer le message de succès
                                IconButton(
                                  icon: Icon(Icons.close, size: 16),
                                  onPressed: () {
                                    ref.read(LoginCtrlProvider.notifier).resetMessages();
                                  },
                                  color: Colors.green[300],
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                ),
                              ],
                            ),
                          ),

                        // Label et champ email
                        Text('Email', style: TextStyle(fontWeight: FontWeight.w500)),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'exemple@mail.com',
                            filled: true,
                            fillColor: Colors.blue[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          // Validation du champ email
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "L'email est requis";
                            }
                            final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
                            if (!emailRegex.hasMatch(value.trim())) {
                              return "Format de l'email invalide";
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 10),

                        // Ligne contenant label "Mot de passe" et lien "Mot de passe oublié?"
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Mot de passe', style: TextStyle(fontWeight: FontWeight.w500)),
                            GestureDetector(
                              onTap: () {
                                // TODO : Ajouter la navigation vers la page mot de passe oublié
                              },
                              child: Text(
                                'Mot de passe oublié?',
                                style: TextStyle(color: Colors.orange[500]),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 8),

                        // Champ mot de passe avec visibilité contrôlable
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword, // masque le texte du mot de passe
                          decoration: InputDecoration(
                            hintText: 'Votre mot de passe',
                            filled: true,
                            fillColor: Colors.blue[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            // Icône pour afficher ou masquer le mot de passe
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () {
                                // Change l'état pour afficher ou cacher le mot de passe
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          // Validation du mot de passe
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Le mot de passe est requis";
                            }
                            if (value.trim().length < 6) {
                              return "Le mot de passe doit contenir au moins 6 caractères";
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 20),

                        // Bouton de connexion
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null // désactive le bouton pendant le chargement
                                : () async {
                              FocusScope.of(context).unfocus(); // Fermer le clavier
                              if (_formKey.currentState!.validate()) {
                                // Récupérer le contrôleur pour lancer la connexion
                                final ctrl = ref.read(LoginCtrlProvider.notifier);

                                // Création de l'objet Authentication avec les champs saisis
                                final data = Authentication(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                );

                                // Appel asynchrone à la méthode login
                                await ctrl.loginForm(data);
                                // Les messages d'erreur ou succès sont gérés via l'état
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[500],
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: isLoading
                                ? CircularProgressIndicator(color: Colors.white) // Loader pendant chargement
                                : Text(
                              'Se connecter',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Texte pour rediriger vers la page d'inscription
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Pas encore de compte ? '),
                            GestureDetector(
                              onTap: () {
                                // TODO : Ajouter navigation vers la page d'inscription
                              },
                              child: Text(
                                'Inscrivez-vous',
                                style: TextStyle(
                                  color: Colors.orange[500],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
