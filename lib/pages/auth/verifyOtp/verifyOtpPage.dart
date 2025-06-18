import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/business/models/user/verifyOtp.dart';
import 'package:odc_mobile_template/pages/auth/register/registerCtrl.dart';
import 'package:odc_mobile_template/pages/auth/register/registerState.dart';
import 'package:odc_mobile_template/pages/auth/verifyOtp/verifyOtpCtrl.dart';
import 'package:odc_mobile_template/utils/navigationUtils.dart';

import '../../../main.dart';

class VerifyOtpPage extends ConsumerStatefulWidget {
  var email ;
  VerifyOtpPage({super.key, this.email});

  @override
  ConsumerState<VerifyOtpPage> createState() => _OtpValidationPageState();
}

class _OtpValidationPageState extends ConsumerState<VerifyOtpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final verifyOtpState = ref.watch(VerifyOtpCtrlProvider);
    var navigation = getIt.get<NavigationUtils>();

    final registerState = ref.watch(RegisterCtrlProvider);
    final _email = registerState.email;

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
                      const Icon(Icons.verified_user, color: Colors.white, size: 32),
                      const SizedBox(height: 20),
                      const Text(
                        'Vérification OTP',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Entrez le code reçu par email',
                        style: TextStyle(color: Colors.orange[100], fontSize: 16),
                      ),
                    ],
                  ),
                ),

                // ===== FORMULAIRE OTP =====
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Affiche un message de succès si présent dans l'état
                        if (verifyOtpState.successMessage != null)
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
                                    verifyOtpState.successMessage!,
                                    style: TextStyle(color: Colors.green[700]),
                                  ),
                                ),
                                // Bouton pour fermer le message de succès
                                IconButton(
                                  icon: Icon(Icons.close, size: 16),
                                  onPressed: () {
                                    ref.read(VerifyOtpCtrlProvider.notifier).resetMessages();
                                  },
                                  color: Colors.green[300],
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                ),
                              ],
                            ),
                          ),

                        // Affiche un message d'erreur si présent dans l'état
                        if (verifyOtpState.errorMessage != null)
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
                                    verifyOtpState.errorMessage!,
                                    style: TextStyle(color: Colors.red[700]),
                                  ),
                                ),
                                // Bouton pour fermer le message d'erreur
                                IconButton(
                                  icon: Icon(Icons.close, size: 16),
                                  onPressed: () {
                                    ref.read(VerifyOtpCtrlProvider.notifier).resetMessages();
                                  },
                                  color: Colors.red[300],
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                ),
                              ],
                            ),
                          ),

                        const Text('Code OTP'),
                        Text('Code envoyé à ${_email}'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _otpCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('000000'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Le code est requis";
                            }
                            if (value.length != 6) {
                              return "Le code doit contenir 6 chiffres";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // === Bouton Vérifier ===
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: verifyOtpState.isSubmited == true
                                ? null
                                : () async {
                              FocusScope.of(context).unfocus();
                              if (_formKey.currentState!.validate()) {
                                final user = VerifyOtp(
                                    email: _email,
                                    otp: _otpCtrl.text
                                );

                                // ✅ Attendez le résultat avec await
                                final result = await ref.read(VerifyOtpCtrlProvider.notifier).verifyOtp(user);

                                // ✅ Vérifiez le résultat après l'attente
                                if (result == true) {
                                  Future.delayed(Duration(seconds: 2),(){
                                    navigation.replace('/public/auth/loginPage');
                                  });
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[500],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: verifyOtpState.isSubmited == true
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                              'Vérifier',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // === Lien pour renvoyer le code ===
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Pas reçu le code ? "),
                            GestureDetector(
                              onTap: () async{
                                final user = VerifyOtp(
                                    email: _email
                                );
                                await ref.read(VerifyOtpCtrlProvider.notifier).resendOtp(user);
                              },
                              child: Text(
                                'Renvoyer',
                                style: TextStyle(
                                  color: Colors.orange[500],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10,),
                        //== rediriger vers login si lien verifié dans le web
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Email deja verifié ? "),
                            GestureDetector(
                              onTap: () async{
                                navigation.replace('/public/auth/loginPage');
                              },
                              child: Text(
                                'Se connecter',
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
}