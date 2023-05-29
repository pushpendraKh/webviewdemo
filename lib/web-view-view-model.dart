import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class WebViewViewModel extends ChangeNotifier {
  WebViewViewModel({required this.url}) {
    createController();
  }

  final String url;
  late WebViewController webViewController;
  bool isLoading = true;

  final permissionResourceTypes = [
    WebViewPermissionResourceType.camera,
    WebViewPermissionResourceType.microphone
  ];

  void createController() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(
      params,
      onPermissionRequest: onPermissionRequest,
    );

    if (controller.platform is AndroidWebViewController) {
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));

    controller.setNavigationDelegate(_getNavigationDelegate);
    webViewController = controller;
  }

  Future<void> onPermissionRequest(WebViewPermissionRequest request) async {
    // for each requested type
    for (var type in request.types) {
      debugPrint("Permission Requested for ${type.name}");

      // if we are allowing the permission
      if (permissionResourceTypes.contains(type)) {
        if (type == WebViewPermissionResourceType.microphone) {
          _requestMicrophone(request);
        } else if (type == WebViewPermissionResourceType.camera) {
          await _requestCamera(request);
          await _requestMicrophone(request);
        }
      } else {
        print("We do not grant permission Requested for $type");
      }
    }
  }

  Future<void> _requestCamera(WebViewPermissionRequest request) async {
    print("requesting camera");
    PermissionStatus statuses = await Permission.camera.request();

    if (statuses == PermissionStatus.granted) {
      await request.grant();
    } else {
      await request.deny();
    }
  }

  Future<void> _requestMicrophone(WebViewPermissionRequest request) async {
    print("requesting microphone");
    PermissionStatus statuses = await Permission.microphone.request();
    if (statuses == PermissionStatus.granted) {
      await request.grant();
    } else {
      await request.deny();
    }
  }

  NavigationDelegate get _getNavigationDelegate {
    return NavigationDelegate(
      onNavigationRequest: (request) {
        print(request.url);
        return NavigationDecision.navigate;
      },
      onPageStarted: (str) {
        print("onPageStarted :: $str");
      },
      onUrlChange: (urt) {
        print("onUrlChange :: ${urt.url}");
      },
      onPageFinished: (str) async {
        print("onPageFinished $str");
        isLoading = false;
        notifyListeners();
      },
      onWebResourceError: (error) {
        print("onWebResourceError $error");
        isLoading = false;
        notifyListeners();
      },
    );
  }
}
