import 'dart:developer' as developer;
import 'package:traffic/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:traffic/core/widgets/service_screen_appbar.dart';

import 'package:traffic/core/widgets/app_drawer.dart';

class PaymentWebviewScreen extends StatefulWidget {
  final String paymentUrl;
  final String merchantOrderId;
  final String paymentId;
  final String? requestNumber;

  const PaymentWebviewScreen({
    super.key,
    required this.paymentUrl,
    required this.merchantOrderId,
    required this.paymentId,
    this.requestNumber,
  });

  @override
  State<PaymentWebviewScreen> createState() => _PaymentWebviewScreenState();
}

class _PaymentWebviewScreenState extends State<PaymentWebviewScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;

  late InAppWebViewSettings settings;
  bool _isLoading = true;
  double progress = 0;
  bool _paymentResult = false;
  bool _detectionTriggered = false;

  @override
  void initState() {
    super.initState();

    settings = InAppWebViewSettings(
      supportMultipleWindows: true,
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
    );

    final rawUrl = widget.paymentUrl;
    developer.log('FORENSIC_A_RAW_URL: $rawUrl', name: 'PaymentWebviewScreen');
    developer.log(
      'FORENSIC_B_CODEUNITS: ${rawUrl.codeUnits}',
      name: 'PaymentWebviewScreen',
    );
  }

  bool _checkUrlForCompletion(String url) {
    if (_detectionTriggered) return true;

    final lowerUrl = url.toLowerCase();

    // Check failure cases first:
    // 1. success=false
    // 2. txn_response_code=failed, txn_response_code=declined, txn_response_code=rejected
    // 3. approved=false
    // 4. canceled, cancelled, failed, declined, rejected
    if (lowerUrl.contains('success=false') ||
        lowerUrl.contains('txn_response_code=failed') ||
        lowerUrl.contains('txn_response_code=declined') ||
        lowerUrl.contains('txn_response_code=rejected') ||
        (lowerUrl.contains('approved=false') &&
            !lowerUrl.contains('approved=true')) ||
        lowerUrl.contains('canceled') ||
        lowerUrl.contains('cancelled') ||
        lowerUrl.contains('declined') ||
        lowerUrl.contains('rejected')) {
      developer.log(
        'Payment Failed/Canceled detected: $url',
        name: 'PaymentWebviewScreen',
      );
      _paymentResult = false;
      _detectionTriggered = true;
      if (mounted) {
        Navigator.pop(context, {'paymentSuccess': false});
      }
      return true;
    }

    // Check success cases:
    // 1. success=true
    // 2. callback_success
    // 3. txn_response_code=approved
    // 4. approved=true or (approved is present but approved=false is not present)
    if (lowerUrl.contains('success=true') ||
        lowerUrl.contains('callback_success') ||
        lowerUrl.contains('txn_response_code=approved') ||
        lowerUrl.contains('approved=true') ||
        (lowerUrl.contains('approved') &&
            !lowerUrl.contains('approved=false'))) {
      developer.log(
        'Payment Success detected: $url',
        name: 'PaymentWebviewScreen',
      );
      _paymentResult = true;
      _detectionTriggered = true;
      if (mounted) {
        Navigator.pop(context, {'paymentSuccess': true});
      }
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    var sanitizedUrl = widget.paymentUrl;
    if (sanitizedUrl.endsWith('&')) {
      sanitizedUrl = sanitizedUrl.substring(0, sanitizedUrl.length - 1);
    }
    if (sanitizedUrl.contains('&&')) {
      sanitizedUrl = sanitizedUrl.replaceAll('&&', '&');
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            ServiceScreenAppBar(
              title: 'بوابة الدفع',
              onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
              onBackPressed: () {
                Navigator.pop(context, {'paymentSuccess': _paymentResult});
              },
            ),
            if (_isLoading)
              LinearProgressIndicator(
                value: progress,
                color: AppColors.primary,
                backgroundColor: AppColors.successLight,
              ),
            Expanded(
              child: PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, result) {
                  if (didPop) return;
                  Navigator.pop(context, {'paymentSuccess': _paymentResult});
                },
                child: InAppWebView(
                  key: webViewKey,
                  initialUrlRequest: URLRequest(url: WebUri(sanitizedUrl)),
                  initialSettings: settings,
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    developer.log(
                      'onLoadStart: $url',
                      name: 'PaymentWebviewScreen',
                    );
                    if (mounted) {
                      setState(() {
                        _isLoading = true;
                      });
                    }
                  },
                  onLoadStop: (controller, url) async {
                    developer.log(
                      'onLoadStop: $url',
                      name: 'PaymentWebviewScreen',
                    );
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                    if (url != null) {
                      _checkUrlForCompletion(url.toString());
                    }
                  },
                  onUpdateVisitedHistory: (controller, url, androidIsReload) {
                    developer.log(
                      'onUpdateVisitedHistory: $url',
                      name: 'PaymentWebviewScreen',
                    );
                    if (url != null) {
                      _checkUrlForCompletion(url.toString());
                    }
                  },
                  onReceivedError: (controller, request, error) {
                    developer.log(
                      'onReceivedError: ${error.description}',
                      name: 'PaymentWebviewScreen',
                    );
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                  onProgressChanged: (controller, progressPercentage) {
                    if (mounted) {
                      setState(() {
                        progress = progressPercentage / 100;
                      });
                    }
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                        final request = navigationAction.request;
                        final url = request.url?.toString() ?? '';
                        developer.log(
                          'shouldOverrideUrlLoading: $url',
                          name: 'PaymentWebviewScreen',
                        );

                        if (url.isNotEmpty) {
                          _checkUrlForCompletion(url);
                          // Don't cancel, let the user see the page if it loads
                        }

                        return NavigationActionPolicy.ALLOW;
                      },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
