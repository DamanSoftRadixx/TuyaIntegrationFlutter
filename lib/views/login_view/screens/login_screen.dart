import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

import '../controller/login_screen_controller.dart';

class LoginScreen extends GetView<LoginScreenController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Tuya integration'), backgroundColor: Colors.amber),
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () => controller.getToken(),
                      child: const Text('Get Token')),
                  ElevatedButton(
                      onPressed: () => controller.gernateSignKey(),
                      child: const Text('SignKeyGernate')),
                ],
              ),
              Center(
                child: Obx(() => controller.loading.value
                    ? const CircularProgressIndicator(color: Colors.amber)
                    : const SizedBox()),
              )
            ],
          ),
        ));
  }
}
