import 'package:flutter/gestures.dart';
import 'package:chat_tencent_hust/src/home/home_page.dart';
import 'package:netease_corekit_im/router/imkit_router.dart';
import 'package:netease_corekit_im/router/imkit_router_constants.dart';
import 'package:nim_chatkit_ui/chat_kit_client.dart';
import 'package:netease_common_ui/common_ui.dart';
import 'package:netease_common_ui/utils/color_utils.dart';
import 'package:nim_contactkit_ui/contact_kit_client.dart';
import 'package:nim_conversationkit_ui/conversation_kit_client.dart';
import 'package:netease_corekit_im/im_kit_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chat_tencent_hust/l10n/S.dart';
import 'package:chat_tencent_hust/src/home/splash_page.dart';
import 'package:chat_tencent_hust/src/mine/user_info_page.dart';
import 'package:provider/provider.dart';
import 'package:nim_searchkit_ui/search_kit_client.dart';
import 'package:nim_teamkit_ui/team_kit_client.dart';
import 'dart:io';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent)); // 透明状态栏
  runApp(const MainApp()); // 入口
} // 主函数

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  // 初始化IM SDK
  void _initPlugins() {
    ChatKitClient.init();
    TeamKitClient.init();
    ConversationKitClient.init();
    ContactKitClient.init();
    SearchKitClient.init();

    IMKitRouter.instance.registerRouter(
        RouterConstants.PATH_MINE_INFO_PAGE, (context) => UserInfoPage());
  }

  Uint8List? _deviceToken;

  void _updateTokenIOS() {
    if (Platform.isIOS) {
      MethodChannel(channelName).setMethodCallHandler((call) async {
        if (call.method == 'updateAPNsToken') {
          setState(() {
            _deviceToken = call.arguments as Uint8List;
          });
        }
        return null;
      });
    }
  } // IOS更新token

  @override
  void initState() {
    super.initState();
    _updateTokenIOS();
    _initPlugins();
    GestureBinding.instance.resamplingEnabled = true; // 打开触摸事件的抽样
  } // 重写初始化

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // 设计稿尺寸
      minTextAdapt: true, // 字体大小根据系统进行缩放
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return MaterialApp(
          // 设置顶层Widget
          onGenerateTitle: (BuildContext context) =>
              S.of(context).appName, // 设置标题
          localizationsDelegates: [
            S.delegate,
            CommonUILocalizations.delegate,
            ConversationKitClient.delegate,
            ChatKitClient.delegate,
            ContactKitClient.delegate,
            TeamKitClient.delegate,
            SearchKitClient.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ], // 设置语言代理
          navigatorObservers: [IMKitRouter.instance.routeObserver],
          supportedLocales: <Locale>[
            const Locale.fromSubtags(languageCode: 'zh')
          ], // 设置中文模式
          theme: ThemeData(
            primaryColor: Color.fromARGB(159, 17, 180, 63),
            pageTransitionsTheme: PageTransitionsTheme(builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            }),
            appBarTheme: const AppBarTheme(
                backgroundColor: Color.fromARGB(108, 198, 249, 252), // 顶部颜色
                elevation: 1,
                iconTheme: IconThemeData(
                    color: Color.fromARGB(183, 215, 28, 56)), // 按钮和点击效果颜色
                titleTextStyle:
                    TextStyle(fontSize: 16, color: CommonColors.color_333333),
                systemOverlayStyle: SystemUiOverlayStyle.dark),
          ),
          routes: IMKitRouter.instance.routes, // 路由表配置
          home: child,
        );
      },
      child: SplashPage(
        deviceToken: _deviceToken,
      ),
    );
  }
}
