import 'dart:io';
import 'dart:typed_data';
import 'package:chat_tencent_hust/src/config.dart';
import 'package:netease_common_ui/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:netease_corekit_im/im_kit_client.dart';
import 'package:nim_core/nim_core.dart';
import 'package:yunxin_alog/yunxin_alog.dart';

class LoginPage extends StatefulWidget {
  final Function(String account, String token) onLogin;
  final Uint8List? deviceToken;

  const LoginPage({Key? key, this.deviceToken, required this.onLogin})
      : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late String _account;
  late String _token;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                const Text(
                  '欢迎登录',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '账号',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入账号';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _account = value!;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '密码',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入密码';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _token = value!;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      widget.onLogin(_account, _token);
                    } // 传输登录信息
                  },
                  child: const Text('登录'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
