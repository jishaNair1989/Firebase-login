import 'package:firebae_log/view/screens/register_screen.dart';
import 'package:firebae_log/view/util/routs.dart';
import 'package:firebae_log/view/widgets/img_style.dart';
import 'package:firebae_log/view/widgets/textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/auth_service.dart';
import '../../controller/provider/login_provider.dart';

class ScreenLogin extends StatelessWidget {
  const ScreenLogin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      key: context.read<LoginProv>().scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const WaveStyle(
            imgPath: 'assets/loginimg.png',
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: w,
                  child: const Text(
                    'hello',
                    style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: w,
                  child: const Text(
                    'Sign into your account',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                CommonTextField(
                  hintText: 'Your email',
                  icon: Icons.email,
                  controller: context.read<LoginProv>().emailController,
                ),
                const SizedBox(
                  height: 20,
                ),
                CommonTextField(
                  hintText: 'Your password',
                  icon: Icons.lock,
                  controller: context.read<LoginProv>().passwordController,
                ),
                const SizedBox(
                  height: 15,
                ),
                // Row(
                //   children: const [
                //     Spacer(),
                //     Text(
                //       "forgot your password?",
                //       style: TextStyle(fontSize: 18, color: Colors.grey),
                //     )
                //   ],
                // )
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          InkWell(
            child: Container(
              width: w * .5,
              height: h * 0.07,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                image: const DecorationImage(
                    image: AssetImage('assets/loginbtn.png'), fit: BoxFit.cover),
              ),
              child: Center(
                child: Consumer<AuthService>(
                  builder: (__, value, _) => value.loading == true
                      ? const Text(
                    'Loading..',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  )
                      : const Text(
                    'Sign in',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
            onTap: () async {
              await context.read<LoginProv>().onSignInButtonPress(context);
            },
          ),
          const SizedBox(
            height: 40,
          ),
          GestureDetector(
            child: RichText(
              text: const TextSpan(
                  text: "Don't have an account?",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                  children: [
                    TextSpan(
                      text: " Create",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ]),
            ),
            onTap: () => Routes
                .push( screen: const ScreenSignUP()),
          ),
        ],
      ),
    );
  }
}
