import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: TextButton(
          child: const Text("Open Web-view"),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const MyWebView(url: "https://gnjw4f.csb.app/"),
          )),
        ),
      ),
    );
  }
}

class MyWebView extends StatefulWidget {
  final String url;

  const MyWebView({Key? key, required this.url}) : super(key: key);

  @override
  _MyWebViewState createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  late WebViewViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = WebViewViewModel(url: widget.url);
    viewModel.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web View'),
      ),
      body: Stack(
        children: [
          WebViewWidget(
            controller: viewModel.webViewController,
          ),
          if (viewModel.isLoading)
            const Positioned.fill(
                child: Center(child: LinearProgressIndicator())),
        ],
      ),
    );
  }
}

class WebViewViewModel extends ChangeNotifier {
  WebViewViewModel({required this.url}) {
    createController();
  }

  final String url;
  late WebViewController webViewController;
  bool isLoading = true;

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
        WebViewController.fromPlatformCreationParams(params);

    if (controller.platform is AndroidWebViewController) {
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(true);
    }

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));

    controller.setNavigationDelegate(_getNavigationDelegate);
    webViewController = controller;
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
