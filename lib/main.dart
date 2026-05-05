import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Android notification settings
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // iOS notification settings
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      final payload = response.payload;
      if (payload != null && payload.isNotEmpty) {
        navigatorKey.currentState?.push(MaterialPageRoute(
          builder: (_) => WebViewScreen(payloadUrl: payload),
        ));
      }
    },
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'CAFM App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const WebViewScreen(),
    );
  }
}

class WebViewScreen extends StatefulWidget {
  final String? payloadUrl;

  const WebViewScreen({super.key, this.payloadUrl});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  String deviceId = '';
  bool isLoading = true;
  bool isInternetAvailable = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (mounted) setState(() => isLoading = true);
          },
          onPageFinished: (url) {
            if (mounted) setState(() => isLoading = false);
          },
          onWebResourceError: (error) {
            debugPrint('WebView error: ${error.description}');
            if (mounted) setState(() => isLoading = false);
          },
        ),
      )
      ..setBackgroundColor(Colors.white);

    _initApp();
  }

  Future<void> _initApp() async {
    await _checkInternetConnection();
    await _requestNotificationPermission();
    await getDeviceId();
  }

  Future<void> _checkInternetConnection() async {
    try {
      final List<ConnectivityResult> results =
          await Connectivity().checkConnectivity();
      if (mounted) {
        setState(() {
          isInternetAvailable =
              results.isNotEmpty && !results.contains(ConnectivityResult.none);
        });
      }
    } catch (e) {
      debugPrint('Connectivity check error: $e');
      if (mounted) setState(() => isInternetAvailable = true);
    }
  }

  Future<void> _requestNotificationPermission() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          await Permission.notification.request();
        }
      } else if (Platform.isIOS) {
        // Request iOS notification permission
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      }
    } catch (e) {
      debugPrint('Notification permission error: $e');
    }
  }

  Future<void> getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      String id;

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        id = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        id = iosInfo.identifierForVendor ?? 'Unknown';
      } else {
        id = 'Unsupported';
      }

      if (mounted) {
        setState(() {
          deviceId = id;
          isLoading = false;
        });
      }

      final String targetUrl = widget.payloadUrl ??
          'https://adb-server.com/CAFM/Jizan?device_id=$id';

      await _controller.loadRequest(Uri.parse(targetUrl));
      await fetchNotificationFromApi(id);
    } catch (e) {
      debugPrint('getDeviceId error: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> fetchNotificationFromApi(String id) async {
    if (id.isEmpty) return;

    final String apiUrl =
        'https://adb-server.com/CAFM/Jizan/mobile_app_notifications.php?device_id=$id';

    try {
      final response = await http.get(Uri.parse(apiUrl)).timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode == 200) {
        final String body = response.body.trim();
        if (body.isEmpty || body == 'null' || body == '[]') return;

        final dynamic decoded = json.decode(body);
        if (decoded is! List) return;

        for (var data in decoded) {
          if (data is! Map) continue;
          final title = (data['NOTIFICATION_TITLE'] ?? 'No Title').toString();
          final bodyText =
              (data['NOTIFICATION_BODY'] ?? 'No Content').toString();
          final myDeviceId = (data['DEVICE_ID'] ?? '').toString();
          final myNotificationId =
              (data['NOTIFICATION_ID'] ?? '').toString();

          final payload =
              'https://adb-server.com/CAFM/Jizan/received_single_notification.php?device_id=$myDeviceId&notification_id=$myNotificationId';

          await showNotification(
            title,
            bodyText,
            myNotificationId.hashCode,
            payload,
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    }
  }

  Future<void> showNotification(
      String title, String body, int notificationId, String payload) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'cafm_channel_id',
      'CAFM Notifications',
      channelDescription: 'CAFM app notification channel',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isInternetAvailable) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'No Internet Connection',
                style: TextStyle(fontSize: 20, color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await _checkInternetConnection();
                  if (isInternetAvailable) await _initApp();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}