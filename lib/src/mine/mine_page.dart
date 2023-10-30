import 'dart:async';
import 'package:netease_common_ui/ui/avatar.dart';
import 'package:netease_common_ui/utils/color_utils.dart';
import 'package:netease_corekit_im/service_locator.dart';
import 'package:netease_corekit_im/services/login/login_service.dart';
import 'package:flutter/material.dart';
import 'package:chat_tencent_hust/l10n/S.dart';
import 'package:flutter_svg/svg.dart';
import 'package:chat_tencent_hust/src/mine/setting/mine_setting.dart';
import 'package:chat_tencent_hust/src/mine/user_info_page.dart';
import 'package:nim_core/nim_core.dart';

class MinePage extends StatefulWidget {
  // 我的页面
  const MinePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  NIMUser? _userInfo; // 用户信息

  LoginService _loginService = getIt<LoginService>(); // 登录服务

  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();

    //请求更新信息
    if (getIt<LoginService>().status == NIMAuthStatus.dataSyncFinish) {
      _refreshUserInfo();
    } else {
      _sub = getIt<LoginService>().loginStatus?.listen((event) {
        if (event == NIMAuthStatus.dataSyncFinish) {
          _refreshUserInfo();
        }
      });
    }
  }

  // 函数：刷新用户信息
  void _refreshUserInfo() {
    _loginService.getUserInfo().then((value) {
      setState(() {
        _userInfo = value;
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  } // 函数：释放资源

  @override
  Widget build(BuildContext context) {
    Widget arrow = SvgPicture.asset(
      'assets/ic_right_arrow.svg',
      height: 16,
      width: 16,
    );

    var nick = _loginService.userInfo?.nick?.trim().isNotEmpty == true
        ? _loginService.userInfo?.nick?.trim()
        : null;
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // 创建顶部区域，颜色及字样
          Container(
              height: 80,
              color: Color.fromARGB(108, 198, 249, 252),
              child: Row(children: [
                const SizedBox(
                  width: 72,
                ),
                Column(children: [
                  const SizedBox(
                    height: 37,
                  ),
                  Text(
                    '有信',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: CommonColors.color_333333, // 设置文字颜色为白色
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ])
              ])),
          // 创建用户信息区域
          InkWell(
            // 创建点击区
            onTap: () {
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UserInfoPage()))
                  .then((value) {
                setState(() {});
              }); // 跳转到用户信息页面
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  Avatar(
                    // 显示头像
                    height: 60,
                    width: 60,
                    name: _loginService.userInfo?.nick ?? _userInfo?.nick,
                    fontSize: 22,
                    avatar: _loginService.userInfo?.avatar ?? _userInfo?.avatar,
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          // 显示昵称
                          nick ?? _loginService.userInfo?.userId ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 22,
                              color: CommonColors.color_333333,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          // 显示账号
                          S.of(context).tabMineAccount(
                              _loginService.userInfo?.userId ?? ''),
                          style: const TextStyle(
                              fontSize: 16, color: CommonColors.color_333333),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    // 显示箭头
                    padding: const EdgeInsets.only(right: 36.0),
                    child: arrow,
                  )
                ],
              ),
            ),
          ),
          const Divider(
            // 创建分割线
            height: 6,
            thickness: 6,
            color: Color(0xffeff1f4),
          ),
          ...ListTile.divideTiles(context: context, tiles: [
            // 设置按钮
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: SvgPicture.asset('assets/ic_user_setting.svg'),
              title: Text(S.of(context).mineSetting),
              trailing: arrow,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const MineSettingPage())); // 切换到库：设置界面
              },
            ),
          ]).toList(),
        ],
      ),
    );
  }
}
