import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visita/constants.dart';
import 'package:visita/pages/root_app.dart';
import 'package:visita/services/helper.dart';
import 'package:visita/theme/colors.dart';
import 'package:visita/ui/auth/authentication_bloc.dart';
import 'package:visita/ui/auth/login/login_bloc.dart';
import 'package:visita/ui/auth/resetPasswordScreen/reset_password_screen.dart';
import 'package:visita/ui/home/home_screen.dart';
import 'package:visita/ui/loading_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State createState() {
    return _LoginScreen();
  }
}

class _LoginScreen extends State<LoginScreen> {
  final GlobalKey<FormState> _key = GlobalKey();
  AutovalidateMode _validate = AutovalidateMode.disabled;
  String? email, password;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (context) => LoginBloc(),
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(
                color: isDarkMode(context) ? Colors.white : Colors.black),
            elevation: 0.0,
          ),
          body: MultiBlocListener(
            listeners: [
              BlocListener<AuthenticationBloc, AuthenticationState>(
                listener: (context, state) async {
                  if (state.authState == AuthState.authenticated) {
                    if (!mounted) return;
                    pushAndRemoveUntil(
                        context, RootApp(user: state.user!), false);
                  } else {
                    if (!mounted) return;
                    showSnackBar(context,
                        state.message ?? 'Couldn\'t login, Please try again.');
                  }
                },
              ),
              BlocListener<LoginBloc, LoginState>(
                listener: (context, state) async {
                  if (state is ValidLoginFields) {
                    await context.read<LoadingCubit>().showLoading(
                        context, 'Logging in, Please wait...', false);
                    if (!mounted) return;
                    context.read<AuthenticationBloc>().add(
                          LoginWithEmailAndPasswordEvent(
                            email: email!,
                            password: password!,
                          ),
                        );
                  }
                },
              ),
            ],
            child: BlocBuilder<LoginBloc, LoginState>(
              buildWhen: (old, current) =>
                  current is LoginFailureState && old != current,
              builder: (context, state) {
                if (state is LoginFailureState) {
                  _validate = AutovalidateMode.onUserInteraction;
                }
                return Form(
                  key: _key,
                  autovalidateMode: _validate,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: 32.0, right: 16.0, left: 40.0),
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                  color: Color(colorPrimary),
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 32.0, right: 24.0, left: 24.0),
                          child: TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              textInputAction: TextInputAction.next,
                              validator: validateEmail,
                              onSaved: (String? val) {
                                email = val;
                              },
                              style: const TextStyle(fontSize: 18.0),
                              keyboardType: TextInputType.emailAddress,
                              cursorColor: const Color(colorPrimary),
                              decoration: getInputDecoration(
                                  hint: 'Email Address',
                                  darkMode: isDarkMode(context),
                                  errorColor: Theme.of(context).errorColor)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 32.0, right: 24.0, left: 24.0),
                          child: TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              obscureText: true,
                              validator: validatePassword,
                              onSaved: (String? val) {
                                password = val;
                              },
                              onFieldSubmitted: (password) => context
                                  .read<LoginBloc>()
                                  .add(ValidateLoginFieldsEvent(_key)),
                              textInputAction: TextInputAction.done,
                              style: const TextStyle(fontSize: 18.0),
                              cursorColor: const Color(colorPrimary),
                              decoration: getInputDecoration(
                                  hint: 'Password',
                                  darkMode: isDarkMode(context),
                                  errorColor: Theme.of(context).errorColor)),
                        ),

                        /// forgot password text, navigates user to ResetPasswordScreen
                        /// and this is only visible when logging with email and password
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                              maxWidth: 720, minWidth: 200),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16, right: 24),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () =>
                                    push(context, const ResetPasswordScreen()),
                                child: const Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                      color: Color(colorPrimary),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      letterSpacing: 1),
                                ),
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                              right: 40.0, left: 40.0, top: 40),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size.fromWidth(
                                  MediaQuery.of(context).size.width / 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: const Color(colorPrimary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                side: const BorderSide(
                                  color: Color(colorPrimary),
                                ),
                              ),
                            ),
                            child: const Text(
                              'Log In',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () => context
                                .read<LoginBloc>()
                                .add(ValidateLoginFieldsEvent(_key)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(
                            child: Text(
                              'OR',
                              style: TextStyle(
                                  color: isDarkMode(context)
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 40.0, left: 40.0, bottom: 20),
                          child: ElevatedButton.icon(
                            label: const Text(
                              'Google Login',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            icon: Image.asset(
                              'assets/images/google-logo.png',
                              color: Colors.white,
                              height: 24,
                              width: 24,
                            ),
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size.fromWidth(
                                  MediaQuery.of(context).size.width / 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: const Color(facebookButtonColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                side: const BorderSide(
                                  color: Color(facebookButtonColor),
                                ),
                              ),
                            ),
                            onPressed: () async {
                              if (!mounted) return;
                              context
                                  .read<AuthenticationBloc>()
                                  .add(LoginWithGoogleEvent(context: context));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}
