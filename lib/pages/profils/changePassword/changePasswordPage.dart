import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/business/models/user/putPassword.dart';
import 'package:odc_mobile_template/pages/auth/login/loginCtrl.dart';
import 'package:odc_mobile_template/pages/profils/changePassword/changePasswordController.dart';
import 'package:odc_mobile_template/utils/navigationUtils.dart';
import '../../../main.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final NavigationUtils navigation = getIt.get<NavigationUtils>();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  final TextEditingController _currentPasswordCtrl = TextEditingController();
  final TextEditingController _newPasswordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    var state = ref.watch(changePasswordProvider);
    var user = ref.watch(LoginCtrlProvider).user;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(250, 255, 255, 255),
        title: const Text('Changer le mot de passe',style: TextStyle(color: Colors.orange,fontWeight: FontWeight.bold),),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,size: 25,),
          color: Colors.orange, // Couleur orange pour le leading
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [ 
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header avec icône
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.lock_reset, size: 64, color: Colors.orange[600]),
                      const SizedBox(height: 16),
                      Text(
                        'Mettez à jour votre mot de passe',
                        style: TextStyle(fontSize: 18, color: Colors.grey[700],fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
          
                // Formulaire
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // champ mot de passe actuel
                      _passwordField(
                        label: 'Mot de passe actuel',
                        controller: _currentPasswordCtrl,
                        obscureText: _obscureCurrentPassword,
                        onToggle:
                            () => setState(
                              () =>
                                  _obscureCurrentPassword =
                                      !_obscureCurrentPassword,
                            ),
                      ),
                      const SizedBox(height: 20),
          
                      // champ nouveau mot de passe
                      _passwordField(
                        label: 'Nouveau mot de passe',
                        controller: _newPasswordCtrl,
                        obscureText: _obscureNewPassword,
                        onToggle:
                            () => setState(
                              () => _obscureNewPassword = !_obscureNewPassword,
                            ),
                        validator: (value) {
                          if (value == _currentPasswordCtrl.text) {
                            return 'Doit être différent du mot de passe actuel';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
          
                      // champ confirmation mot de passe
                      _passwordField(
                        label: 'Confirmer le nouveau mot de passe',
                        controller: _confirmPasswordCtrl,
                        obscureText: _obscureConfirmPassword,
                        onToggle:
                            () => setState(
                              () =>
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword,
                            ),
                        validator: (value) {
                          if (value != _newPasswordCtrl.text) {
                            return 'Les mots de passe ne correspondent pas';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
          
                      // Bouton Valider
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async{
                            if (_formKey.currentState!.validate()){
                              var data = PutPassword(old_password: _currentPasswordCtrl.text, new_password: _newPasswordCtrl.text, password_confirmation: _confirmPasswordCtrl.text);
                              var ctrl = ref.read(changePasswordProvider.notifier);
                              var res = await ctrl.updatePassword(data, user?.token ?? "");
                              if(res){
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Mot de passe mis à jour avec succès'),
                                    backgroundColor: Colors.green[500],
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                                Navigator.of(context).pop();
                              }else{
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Une erreur est survenue'),
                                    backgroundColor: Colors.red[500],
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[500],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              // elevation: 2,
                            ),
                          ),
                          child: Text(
                            'METTRE À JOUR',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (state.isLoading)
          const Center(child: CircularProgressIndicator(color: Colors.orange,)),
        ]
      ),
    );
  }

// Champ de mot de passe générique
  Widget _passwordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
            fontSize: 16
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color.fromARGB(121, 150, 150, 150),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[600],
              ),
              onPressed: onToggle,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ce champ est obligatoire';
            }
            if (value.length < 6) {
              return 'Minimum 6 caractères';
            }
            if (validator != null) {
              return validator(value);
            }
            return null;
          },
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implémenter la logique de changement
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mot de passe mis à jour avec succès'),
          backgroundColor: Colors.green[500],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.of(context).pop();
    }
  }
}
