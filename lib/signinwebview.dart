import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

class SignInWebView extends StatelessWidget {
  const SignInWebView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => InAppWebView(
        initialUrlRequest: URLRequest(
          url: Uri.parse(
              "https://global.transak.com?fiatCurrency=GBP&walletAddress=0x6353D15E8A61df4eD412746654D44B8188a737C1&fiatAmount=35"),
        ),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            mediaPlaybackRequiresUserGesture: false,
          ),
          android: AndroidInAppWebViewOptions(useHybridComposition: true),
          ios: IOSInAppWebViewOptions(
            allowsInlineMediaPlayback: true,
          ),
        ),
        androidOnPermissionRequest: (controller, origin, resources) async {
          final granted = await _requestCamera();

          return PermissionRequestResponse(
            resources: resources,
            action: granted
                ? PermissionRequestResponseAction.GRANT
                : PermissionRequestResponseAction.DENY,
          );
        },
      );

  Future<bool> _requestCamera() async {
    print("requesting camera");
    PermissionStatus statuses = await Permission.camera.request();

    if (statuses == PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }
}
