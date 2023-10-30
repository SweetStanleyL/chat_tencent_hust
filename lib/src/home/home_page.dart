import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:netease_corekit_im/router/imkit_router_factory.dart';
import 'package:netease_corekit_im/service_locator.dart';
import 'package:netease_corekit_im/services/login/login_service.dart';
import 'package:nim_chatkit_ui/chat_kit_client.dart';
import 'package:nim_chatkit_ui/view/chat_kit_message_list/item/chat_kit_message_item.dart';
import 'package:nim_chatkit_ui/view/input/actions.dart';
import 'package:nim_chatkit_ui/view_model/chat_view_model.dart';
import 'package:netease_common_ui/utils/color_utils.dart';
import 'package:nim_contactkit/repo/contact_repo.dart';
import 'package:nim_contactkit_ui/contact_kit_client.dart';
import 'package:nim_contactkit_ui/page/contact_page.dart';
import 'package:nim_conversationkit/repo/conversation_repo.dart';
import 'package:nim_conversationkit_ui/conversation_kit_client.dart';
import 'package:nim_conversationkit_ui/page/conversation_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:chat_tencent_hust/l10n/S.dart';
import 'package:chat_tencent_hust/src/mine/mine_page.dart';
import 'package:nim_core/nim_core.dart';
import 'package:provider/provider.dart';
import 'package:yunxin_alog/yunxin_alog.dart';

import '../config.dart';

const channelName = "com.netease.yunxin.app.flutter.im/channel";
const pushMethodName = "pushMessage";

class HomePage extends StatefulWidget {
  // 主页
  final int pageIndex;

  const HomePage({Key? key, this.pageIndex = 0}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

// 底部导航栏数据对象
class NavigationBarData {
  // 未选择时候的图标
  final Widget unselectedIcon;

  // 选择后的图标
  final Widget selectedIcon;

  // 标题内容
  final String title;

  // 页面组件
  final Widget widget;

  NavigationBarData({
    required this.unselectedIcon,
    required this.selectedIcon,
    required this.title,
    required this.widget,
  });
}

class _HomePageState extends State<HomePage> {
  // 下标与计数器
  int currentIndex = 0;

  int chatUnreadCount = 0;
  int contactUnreadCount = 0;

  initUnread() {
    // 初始化未读消息
    ConversationRepo.getMsgUnreadCount().then((value) {
      if (value.isSuccess && value.data != null) {
        setState(() {
          chatUnreadCount = value.data!;
        }); // 获取未读消息并显示
      }
    });
    ContactRepo.getNotificationUnreadCount().then((value) {
      if (value.isSuccess && value.data != null) {
        setState(() {
          contactUnreadCount = value.data!;
        }); // 获取未读通知并显示
      }
    });
    ContactRepo.registerNotificationUnreadCountObserver().listen((event) {
      setState(() {
        contactUnreadCount = event;
      }); // 监听未读通知并显示
    });
  }

// 函数：分发消息，跳转到聊天页面
  void _dispatchMessage(Map? params) {
    var sessionType = params?['sessionType'] as String?;
    var sessionId = params?['sessionId'] as String?;
    if (sessionType?.isNotEmpty == true && sessionId?.isNotEmpty == true) {
      if (sessionType == 'p2p') {
        goToP2pChat(context, sessionId!); // 跳转到p2p聊天页面
      } else if (sessionType == 'team') {
        goToTeamChat(context, sessionId!); // 跳转到group聊天页面
      }
    }
  }

  // 函数：处理方法调用
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == pushMethodName && call.arguments is Map) {
      _dispatchMessage(call.arguments); // 分发消息
    }
  }

  // 解析从Native端传递过来的消息，并分发
  void _handleMessageFromNative() {
    const channel = MethodChannel(channelName);

    // 注册回调，用于页面没有被销毁的时候的回调监听
    channel.setMethodCallHandler((call) => _handleMethodCall(call));

    // 方法调用，用于页面被销毁时候的情况
    channel.invokeMapMethod<String, dynamic>(pushMethodName).then((value) {
      Alog.d(tag: 'HomePage', content: "Message from Native is = $value}");
      _dispatchMessage(value);
    });
  }

// ---------------
// Chat 页面
// ---------------

  @override
  void initState() {
    super.initState();
    currentIndex = widget.pageIndex; // 设置当前页面
    initUnread();

    // chat config
    var messageBuilder = ChatKitMessageBuilder();
    // ChatKitClient.instance.aMapIOSKey = IMDemoConfig.AMapIOS;
    // ChatKitClient.instance.aMapAndroidKey = IMDemoConfig.AMapAndroid;
    //注册全局监听撤回消息
    ChatKitClient.instance.registerRevokedMessage();
    ChatKitClient.instance.chatUIConfig = ChatUIConfig(
        keepDefaultMoreAction: false,
        messageBuilder: messageBuilder,
        getPushPayload: _getPushPayload); // ChatUIConfig 自定义会话消息界面
    _handleMessageFromNative();
  } // 重写初始化

  @override
  void dispose() {
    super.dispose(); // 释放资源
    ChatKitClient.instance.unregisterRevokedMessage(); // 释放已经撤回的消息
  }

  //获取pushPayload
  Map<String, dynamic> _getPushPayload(NIMMessage message) {
    Map<String, dynamic> pushPayload = Map();
    var sessionId = message.sessionType == NIMSessionType.p2p
        ? getIt<LoginService>().userInfo?.userId // 如果是p2p，sessionId为对方的accid
        : message.sessionId; // 如果是team，sessionId为teamId
    var sessionType =
        message.sessionType == NIMSessionType.p2p ? "p2p" : "team"; // 会话类型

    //添加通用的参数
    pushPayload["sessionId"] = sessionId;
    pushPayload["sessionType"] = sessionType;
    return pushPayload;
  }

// ---------------
//conversation 页面
// ---------------

  Widget _getIcon(Widget tabIcon, {bool showRedPoint = false}) {
    if (!showRedPoint) {
      return tabIcon;
    } else {
      return Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          tabIcon,
          if (contactUnreadCount > 0 || chatUnreadCount > 0)
            Positioned(
              top: -2.0,
              right: -3.0,
              child: Offstage(
                offstage: false,
                child: Container(
                  height: 6,
                  width: 6,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            )
        ],
      );
    }
  } // 显示未读消息红点标记

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: bottomNavigatorList().map((res) => res.widget).toList(),
      ),
      bottomNavigationBar: Theme(
        // 底部导航栏
        data: ThemeData(
          brightness: Brightness.light,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: "#F6F8FA".toColor(),
          selectedFontSize: 10,
          unselectedFontSize: 10,
          elevation: 0,
          items: List.generate(
            // 生成底部导航栏
            bottomNavigatorList().length,
            (index) => BottomNavigationBarItem(
              icon: _getIcon(
                  // 查询是否点击导航栏图标，如点击则切换页面
                  index == currentIndex
                      ? bottomNavigatorList()[index].selectedIcon
                      : bottomNavigatorList()[index].unselectedIcon,
                  showRedPoint: (index == 1 && contactUnreadCount > 0) ||
                      (index == 0 && chatUnreadCount > 0)), // 底部显示未读消息红点标记
              label: bottomNavigatorList()[index].title,
            ),
          ),
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            _changePage(index); // 切换页面
          },
        ),
      ),
    );
  }

  //如果点击的导航页不是当前项，切换
  void _changePage(int index) {
    if (index != currentIndex) {
      setState(() {
        currentIndex = index;
      });
    }
  }

  // 函数：底部导航栏
  List<NavigationBarData> bottomNavigatorList() {
    return getBottomNavigatorList(context);
  }

  List<NavigationBarData> getBottomNavigatorList(BuildContext context) {
    final List<NavigationBarData> bottomNavigatorList = [
      // 消息图标
      NavigationBarData(
        widget: ConversationPage(
          onUnreadCountChanged: (unreadCount) {
            setState(() {
              chatUnreadCount = unreadCount;
            });
          },
          config: ConversationUIConfig(
              titleBarConfig: ConversationTitleBarConfig(
            titleBarTitle: '有信',
            titleBarLeftIcon: Image.asset(
              // 左侧图标：主题，其余为默认设置
              'assets/chat.png',
              width: 36,
              height: 36,
            ),
          )),
        ),
        title: S.of(context).message,
        selectedIcon: SvgPicture.asset(
          'assets/icon_session_selected.svg',
          width: 28,
          height: 28,
          color: Color.fromARGB(255, 57, 200, 42),
        ),
        unselectedIcon: SvgPicture.asset(
          'assets/icon_session_selected.svg',
          width: 28,
          height: 28,
          color: CommonColors.color_c5c9d2,
        ),
      ),

      // 点击通讯录图标，跳转到通讯录页面
      NavigationBarData(
        widget: const ContactPage(
            config: ContactUIConfig(
                contactTitleBarConfig: ContactTitleBarConfig(
          title: '有信',
        ))),
        title: S.of(context).contact,
        selectedIcon: SvgPicture.asset(
          'assets/icon_contact_selected.svg',
          width: 28,
          height: 28,
          color: Color.fromARGB(255, 57, 200, 42),
        ),
        unselectedIcon: SvgPicture.asset(
          'assets/icon_contact_unselected.svg',
          width: 28,
          height: 28,
          color: CommonColors.color_c5c9d2,
        ),
      ),

      // 点击我的图标，跳转到我的页面
      NavigationBarData(
        widget: const MinePage(),
        title: S.of(context).mine,
        selectedIcon: SvgPicture.asset(
          'assets/icon_my_selected.svg',
          width: 28,
          height: 28,
          color: Color.fromARGB(255, 57, 200, 42),
        ),
        unselectedIcon: SvgPicture.asset(
          'assets/icon_my_selected.svg',
          width: 28,
          height: 28,
          color: CommonColors.color_c5c9d2,
        ),
      ),
    ];

    return bottomNavigatorList;
  }
}
