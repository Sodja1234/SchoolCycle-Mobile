import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/business/models/user/registerUser.dart';
import 'package:odc_mobile_template/pages/auth/register/registerCtrl.dart';
import 'package:odc_mobile_template/pages/auth/register/registerState.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // Contrôles de visibilité des mots de passe
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Contrôleurs de texte pour les champs
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(RegisterCtrlProvider);

    return Material(
      color: Colors.grey[100],
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
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
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(Icons.person_add, color: Colors.white, size: 32),
                      const SizedBox(height: 20),
                      const Text(
                        'Créer un compte',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Remplissez les champs pour vous inscrire',
                        style: TextStyle(color: Colors.orange[100], fontSize: 16),
                      ),
                    ],
                  ),
                ),

                // ===== FORMULAIRE D'INSCRIPTION =====
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        // === Nom et Email ===
                        Row(
                          children: [
                            // Champ Nom
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Nom'),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _nameCtrl,
                                    decoration: _inputDecoration('John Doe'),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return "Le nom est requis";
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Champ Email
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Email'),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _emailCtrl,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: _inputDecoration('exemple@mail.com'),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return "L'email est requis";
                                      }
                                      final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
                                      if (!emailRegex.hasMatch(value.trim())) {
                                        return "Email invalide";
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // === Mot de passe et confirmation ===
                        Row(
                          children: [
                            // Mot de passe
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Mot de passe'),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _passwordCtrl,
                                    obscureText: _obscurePassword,
                                    decoration: _passwordInputDecoration(_obscurePassword, () {
                                      setState(() => _obscurePassword = !_obscurePassword);
                                    }),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return "Mot de passe requis";
                                      }
                                      if (value.length < 6) {
                                        return "Au moins 6 caractères";
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Confirmation
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Confirmation'),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _confirmPasswordCtrl,
                                    obscureText: _obscureConfirmPassword,
                                    decoration: _passwordInputDecoration(_obscureConfirmPassword, () {
                                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                                    }),
                                    validator: (value) {
                                      if (value != _passwordCtrl.text) {
                                        return "Les mots de passe ne correspondent pas";
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // === Bouton S'inscrire ===
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: registerState.isSubmited == false
                                ? null
                                : () {
                              FocusScope.of(context).unfocus();
                              if (_formKey.currentState!.validate()) {
                                final newUser = RegisterUser(
                                  name: _nameCtrl.text.trim(),
                                  email: _emailCtrl.text.trim(),
                                  password: _passwordCtrl.text,
                                  passwordConfirmation: _confirmPasswordCtrl.text,
                                );

                                ref.read(RegisterCtrlProvider.notifier).register(newUser);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[500],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: registerState.isSubmited == true
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                              'S\'inscrire',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // === Message de succès / erreur ===
                        if (registerState.successMessage != null)
                          Text(
                            registerState.successMessage!,
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        if (registerState.errorMessage != null)
                          Text(
                            registerState.errorMessage!,
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),

                        const SizedBox(height: 16),

                        // === Lien vers Connexion ===
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Déjà un compte ? '),
                            GestureDetector(
                              onTap: () {
                                // TODO: Navigation vers page de connexion
                              },
                              child: Text(
                                'Connectez-vous',
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

  // Décoration pour les champs standards
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.blue[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  // Décoration pour les champs de mot de passe
  InputDecoration _passwordInputDecoration(bool obscure, VoidCallback toggle) {
    return InputDecoration(
      hintText: '******',
      filled: true,
      fillColor: Colors.blue[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      suffixIcon: IconButton(
        icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
        onPressed: toggle,
      ),
    );
  }
}
