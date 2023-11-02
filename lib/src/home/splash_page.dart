import 'package:chat_tencent_hust/src/home/login_page.dart';
import 'package:chat_tencent_hust/src/home/welcome_page.dart';
import 'package:chat_tencent_hust/src/mine/setting/mine_setting.dart';
import 'package:netease_corekit_im/im_kit_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:chat_tencent_hust/src/config.dart';
import 'package:chat_tencent_hust/src/home/home_page.dart';
import 'package:nim_core/nim_core.dart';
import 'package:yunxin_alog/yunxin_alog.dart';
import 'dart:io';
import 'dart:typed_data';

class SplashPage extends StatefulWidget {
  final Uint8List? deviceToken;

  const SplashPage({Key? key, this.deviceToken}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SplashState();
}

class _SplashState extends State<SplashPage> {
  bool toLogin = false;

  bool haveLogin = false;

  @override
  Widget build(BuildContext context) {
    if (haveLogin) {
      return const HomePage(); // 实现自动登录
    } else {
      return WelcomePage(
        // 欢迎界面
        showButton: true,
        onPressed: () {
          //_doInit(IMDemoConfig.AppKey, 'test1', '123456');
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LoginPage(
                      // 点击进入登录界面
                      deviceToken: widget.deviceToken,
                      onLogin: (account, token) {
                        return _doInit(IMDemoConfig.AppKey, account, token);
                      })));
        },
      );
    }
  }

  void updateAPNsToken() {
    if (NimCore.instance.isInitialized &&
        Platform.isIOS &&
        widget.deviceToken != null) {
      NimCore.instance.settingsService
          .updateAPNSToken(widget.deviceToken!, null);
    }
  } // IOS系统更新token

  /// init depends package for app
  void _doInit(String appKey, String account, String token) async {
    //如果使用自动登录可在初始化的时候传入loginInfo
    var options = await NIMSDKOptionsConfig.getSDKOptions(appKey);

    IMKitClient.init(appKey, options).then((success) {
      if (success) {
        startLogin(account, token);
      } else {
        Alog.d(content: "im init failed");
      }
    }).catchError((e) {
      Alog.d(content: 'im init failed with error ${e.toString()}');
    });
  }

  void startLogin(String account, String token) {
    // 可直接初始化
    IMKitClient.loginIM(NIMLoginInfo(account: account, token: token))
        .then((value) {
      if (value) {
        updateAPNsToken();
        setState(() {
          haveLogin = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        ); // 登录成功，切换到homepage
      }
    });
  }
}
