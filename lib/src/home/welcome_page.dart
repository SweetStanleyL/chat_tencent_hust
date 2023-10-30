import 'package:netease_common_ui/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../l10n/S.dart';

// 欢迎页
class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key, this.showButton = false, this.onPressed})
      : super(key: key);

  final bool showButton;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: 124, bottom: 15),
        child: SafeArea(
          child: Column(
            children: [
              Image.asset(
                'assets/chat_2.png',
                width: 120,
                height: 120,
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                S.of(context).appName,
                style: TextStyle(
                    fontSize: 24,
                    color: CommonColors.color_333333,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                S.of(context).yunxinDesc,
                style:
                    TextStyle(fontSize: 16, color: CommonColors.color_666666),
              ),
              if (showButton)
                Padding(
                  padding: const EdgeInsets.only(top: 127.0),
                  child: MaterialButton(
                    color: CommonColors.color_337eff,
                    onPressed: onPressed,
                    height: 50,
                    minWidth: 315,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: Text(
                      S.of(context).welcomeButton,
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ),
              Expanded(child: SizedBox()),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/chat.png',
                    width: 21,
                    height: 21,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    S.of(context).yunxinName,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
