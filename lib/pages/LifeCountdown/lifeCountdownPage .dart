import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:go_router/go_router.dart';
import 'package:life_countdown/pages/AboutUs/AboutUsPage%20.dart';
import 'package:life_countdown/pages/Support/supportPage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart'; // เพิ่มการ import
import 'package:life_countdown/pages/PROVIDERS/consent_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class LifeCountdownPage extends StatefulWidget {
  final DateTime deathDate;
  final DateTime birthDate;

  const LifeCountdownPage({
    Key? key,
    required this.deathDate,
    required this.birthDate,
  }) : super(key: key);

  @override
  _LifeCountdownPageState createState() => _LifeCountdownPageState();
}

class _LifeCountdownPageState extends State<LifeCountdownPage>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late Duration _timeRemaining;
  late Duration _totalLifeSpan;
  final PageController _pageController = PageController();
  final GlobalKey _captureKey = GlobalKey(); // สร้าง Key สำหรับ RepaintBoundary
  bool _showCaptureText = false;
  late AnimationController _controller;

  int _selectedPageIndex = 0; // เก็บสถานะหน้าที่ถูกเลือก
  bool _isAnimating = false; // ป้องกันการทำงานซ้ำซ้อนระหว่างเปลี่ยนหน้า

  final _consentManager = ConsentManager();
  var _isMobileAdsInitializeCalled = false;
  var _isPrivacyOptionsRequired = false;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  double _bannerHeight = 50; // ค่าเริ่มต้น

  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;
  double _adAspectRatioMedium = (370 / 355);
  /// Loads a native ad.
  void _loadAd() async {
    print("📡 Attempting to load Interstitial Ad...");

    var canRequestAds = await _consentManager.canRequestAds();
    if (!canRequestAds) {
      print("🚫 Can't request ads due to consent.");
      return;
    }

    InterstitialAd.load(
      adUnitId: "ca-app-pub-3940256099942544/1033173712",
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          setState(() {
            _interstitialAd = ad;
            _isInterstitialAdReady = true;
          });
          print("✅ Interstitial Ad Loaded Successfully");
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('❌ Interstitial Ad failed to load: $error');
          setState(() {
            _isInterstitialAdReady = false;
          });
        },
      ),
    );
  }

  void _showInterstitialAd() {
    print("📡 Checking if interstitial ad is ready...");

    if (_isInterstitialAdReady && _interstitialAd != null) {
      print("🚀 Showing Interstitial Ad...");

      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          print("✅ Interstitial Ad Dismissed");
          ad.dispose();
          _loadAd(); // โหลดโฆษณาใหม่
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          print("❌ Interstitial Ad Failed to Show: ${error.message}");
          ad.dispose();
          _loadAd();
        },
      );

      _interstitialAd!.show();
      setState(() {
        _isInterstitialAdReady = false;
      });
    } else {
      print("⚠️ Interstitial Ad Not Ready");
    }
  }

  void _loadNativeAd() async {
    var canRequestAds = await _consentManager.canRequestAds();
    if (!canRequestAds) {
      print("🚫 Can't request ads due to consent.");
      return;
    }

    setState(() {
      _nativeAdIsLoaded = false;
    });

    _nativeAd = NativeAd(
        adUnitId: 'ca-app-pub-3940256099942544/2247696110',
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            // ignore: avoid_print
            print('$NativeAd loaded.');
            setState(() {
              _nativeAdIsLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            // ignore: avoid_print
            print('$NativeAd failedToLoad: $error');
            ad.dispose();
          },
          onAdClicked: (ad) {},
          onAdImpression: (ad) {},
          onAdClosed: (ad) {},
          onAdOpened: (ad) {},
          onAdWillDismissScreen: (ad) {},
          onPaidEvent: (ad, valueMicros, precision, currencyCode) {},
        ),
        request: const AdRequest(),
        nativeTemplateStyle: NativeTemplateStyle(
            templateType: TemplateType.medium,
            mainBackgroundColor: const Color(0xfffffbed),
            callToActionTextStyle: NativeTemplateTextStyle(
                textColor: Colors.white,
                style: NativeTemplateFontStyle.monospace,
                size: 16.0),
            primaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.black,
                style: NativeTemplateFontStyle.bold,
                size: 16.0),
            secondaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.black,
                style: NativeTemplateFontStyle.italic,
                size: 16.0),
            tertiaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.black,
                style: NativeTemplateFontStyle.normal,
                size: 16.0)))
      ..load();
  }

  /// Redraw the app bar actions if a privacy options entry point is required.
  void _getIsPrivacyOptionsRequired() async {
    if (await _consentManager.isPrivacyOptionsRequired()) {
      setState(() {
        _isPrivacyOptionsRequired = true;
      });
    }
  }

  /// Initialize the Mobile Ads SDK if the SDK has gathered consent aligned with
  /// the app's configured messages.
  void _initializeMobileAdsSDK() async {
    if (_isMobileAdsInitializeCalled) {
      return;
    }

    if (await _consentManager.canRequestAds()) {
      _isMobileAdsInitializeCalled = true;

      // Initialize the Mobile Ads SDK.
      MobileAds.instance.initialize();

      // Load an ad.
      _loadAd();
      _loadAdaptiveBannerAd();
      _loadNativeAd();
    }
  }

  Future<void> _loadAdaptiveBannerAd() async {
    print("📡 Attempting to load Banner Ad...");

    var canRequestAds = await _consentManager.canRequestAds();
    if (!canRequestAds) {
      print("🚫 Can't request ads due to consent.");
      return;
    }

    final AdSize? adaptiveSize = await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait,
      MediaQuery.of(context).size.width.toInt(),
    );

    if (adaptiveSize != null) {
      setState(() {
        if (mounted) {
          _bannerHeight = adaptiveSize.height.toDouble();
        }
      });

      _bannerAd = BannerAd(
        adUnitId: 'ca-app-pub-3940256099942544/6300978111', // AdMob Test Banner
        size: adaptiveSize,
        request: AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            setState(() {
              _isBannerAdLoaded = true;
            });
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print("Ad failed to load: $error");
            ad.dispose();
          },
        ),
      )..load();
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // ระยะเวลาแอนิเมชัน
    )..repeat(reverse: true); // เล่นแอนิเมชันซ้ำไปมา

    _timeRemaining = widget.deathDate.difference(DateTime.now());
    _totalLifeSpan = widget.deathDate.difference(widget.birthDate);
    _startTimer();

    _consentManager.gatherConsent((consentGatheringError) {
      if (consentGatheringError != null) {
        // Consent not obtained in current session.
        debugPrint(
            "${consentGatheringError.errorCode}: ${consentGatheringError.message}");
      }

      // Check if a privacy options entry point is required.
      _getIsPrivacyOptionsRequired();

      // Attempt to initialize the Mobile Ads SDK.
      _initializeMobileAdsSDK();
    });

    // This sample attempts to load ads using consent obtained in the previous session.
    _initializeMobileAdsSDK();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAdaptiveBannerAd();
  }

///////////////////////////////////////////////////////////////////////////
  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final photosPermission = await Permission.photos.request();
      final storagePermission = await Permission.storage.request();

      if (photosPermission.isGranted || storagePermission.isGranted) {
        debugPrint("Permission granted");
      } else if (photosPermission.isPermanentlyDenied ||
          storagePermission.isPermanentlyDenied) {
        debugPrint("Permission permanently denied");
        openAppSettings();
      } else {
        debugPrint("Permission denied");
      }
    } else if (Platform.isIOS) {
      final photosPermission = await Permission.photos.request();
      if (!photosPermission.isGranted) {
        debugPrint("Permission denied");
        openAppSettings();
      }
    }
  }

// ฟังก์ชันช่วยจัดการผลลัพธ์ของ Permission

///////////////////////////////////////////////////////////////////////////
  Future<ui.Image> _captureWidget() async {
    if (_captureKey.currentContext == null) {
      throw Exception("RepaintBoundary ไม่พร้อมใช้งาน");
    }
    RenderRepaintBoundary boundary =
        _captureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    return await boundary.toImage(pixelRatio: 2.0);
  }

  Future<void> _saveImage(Uint8List pngBytes) async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath =
          "${directory.path}/screenshot_${DateTime.now().millisecondsSinceEpoch}.png";
      final file = File(filePath);

      await file.writeAsBytes(pngBytes);
      debugPrint("ไฟล์ถูกสร้างที่: $filePath");

      final result = await GallerySaver.saveImage(filePath);
      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("บันทึกภาพสำเร็จ!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ไม่สามารถบันทึกภาพได้!")),
        );
      }
    } catch (e) {
      debugPrint("เกิดข้อผิดพลาด: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาด: $e")),
      );
    }
  }

  Future<Uint8List> processImage(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _captureAndSaveImage() async {
    try {
      setState(() {
        _showCaptureText = true; // เปิดการแสดงข้อความ
      });

      // หยุดแอนิเมชันทั้งหมดก่อนจับภาพ
      _controller.stop();

      // รอให้ UI render เสร็จ
      await Future.delayed(const Duration(milliseconds: 100));

      // จับภาพหน้าจอ
      final image = await _captureWidget();
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final pngBytes = byteData.buffer.asUint8List();
        await _showSaveImageDialog(pngBytes);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาดในการจับภาพ: $e")),
      );
    } finally {
      setState(() {
        _showCaptureText = false; // ซ่อนข้อความหลังจับภาพ
      });

      // เริ่มแอนิเมชันอีกครั้งหลังจับภาพเสร็จ
      _controller.forward();
    }
  }

  Future<void> _showSaveImageDialog(Uint8List pngBytes) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // หัวข้อ
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!
                          .shareTitle, // ใช้ข้อความจาก Localization
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // แสดงระยะเวลาที่ฟอร์แมตไว้

                const SizedBox(height: 10),

                // แสดงภาพที่จับได้
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    pngBytes,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 10),

                // ปุ่ม "ปิด" และ "บันทึกรูป"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                        ),
                        child: Text(
                            AppLocalizations.of(context)!.closeButtonLabel),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await _saveImage(pngBytes);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                            AppLocalizations.of(context)!.saveImageButtonLabel),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeRemaining = widget.deathDate.difference(DateTime.now());
        if (_timeRemaining.isNegative) {
          _timer.cancel();
          _pageController.dispose(); // อย่าลืมลบ PageController
        }
      });
    });
  }

  void _onPageSelected(int pageIndex) {
    if (_selectedPageIndex != pageIndex && !_isAnimating) {
      setState(() {
        _selectedPageIndex = pageIndex;
        _isAnimating = true;
      });

      if (_pageController.hasClients) {
        _pageController
            .animateToPage(
          pageIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
            .then((_) {
          setState(() {
            _isAnimating = false; // รีเซ็ตสถานะเมื่อเปลี่ยนหน้าเสร็จ
          });
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // ลบ AnimationController
    _timer.cancel(); // ลบ Timer
    _pageController.dispose(); // ลบ PageController
    _interstitialAd?.dispose();
    _bannerAd?.dispose();
    _nativeAd?.dispose();
    super.dispose();
  }

  String formatYearsAndDays(Duration duration) {
    final years = duration.inDays ~/ 365;
    final days = duration.inDays % 365;
    return "$years ปี $days วัน";
  }

  String formatDuration(Duration duration) {
    final localizations = AppLocalizations.of(context)!;

    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    // ประกอบข้อความเอง
    return "${days} ${localizations.dayLabel} "
        "${hours} ${localizations.hourLabel} "
        "${minutes} ${localizations.minuteLabel} "
        "${seconds} ${localizations.secondLabel}";
  }

  @override
  Widget build(BuildContext context) {
    final Color defaultColor = Theme.of(context).colorScheme.onBackground;

    final elapsedLifeSpan = _totalLifeSpan - _timeRemaining;
    final double percentagePassed =
        ((_totalLifeSpan.inSeconds - _timeRemaining.inSeconds) /
                _totalLifeSpan.inSeconds *
                100)
            .clamp(0, 100)
            .toDouble();

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          centerTitle: true, // จัด title ให้อยู่ตรงกลาง
          elevation: 0,
          title: Row(
            mainAxisSize: MainAxisSize.min, // จัดขนาด Row ให้พอดีกับเนื้อหา
            children: [
              Container(
                width: 50, // ขนาดของพื้นที่รอบรูปภาพ
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const ui.Color.fromARGB(
                          255, 255, 255, 255) // สีพื้นหลังในโหมดมืด
                      : Colors.black, // สีพื้นหลังในโหมดสว่าง
                  borderRadius: BorderRadius.circular(12), // มุมมน
                ),

                child: Padding(
                  padding: const EdgeInsets.all(8.0), // เพิ่ม padding ให้รูปภาพ
                  child: Image.asset(
                    'assets/images/hourglass.png', // ใช้รูปภาพที่อัปโหลด
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black // สีในโหมดมืด
                        : Colors.white, // สีในโหมดสว่าง
                    fit: BoxFit.contain, // ปรับให้รูปอยู่ในกรอบ
                  ),
                ),
              ),
              const SizedBox(width: 8), // เพิ่มระยะห่างระหว่างรูปภาพกับข้อความ
              Text(
                AppLocalizations.of(context)!
                    .appTitle, // ดึงข้อความจาก localization
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min, // ป้องกันการขยายเกินไป
            children: [
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!
                    .timeRemainingTitle, // ดึงข้อความจาก localization
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                formatDuration(_timeRemaining),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(
                      0, 20.0, 10.0, 0.0), // ระยะห่างจากขอบ
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // ปุ่มแรก
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: _selectedPageIndex == 0
                              ? Colors.orange
                              : Colors.transparent,
                          border: Border.all(color: Colors.orange, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () => _onPageSelected(0),
                          icon: const Icon(Icons.donut_small),
                          color: _selectedPageIndex == 0
                              ? Colors.white
                              : Colors.orange,
                        ),
                      ),
                      // ปุ่มที่สอง
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: _selectedPageIndex == 1
                              ? Colors.orange
                              : Colors.transparent,
                          border: Border.all(color: Colors.orange, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () => _onPageSelected(1),
                          icon: const Icon(Icons.grid_view),
                          color: _selectedPageIndex == 1
                              ? Colors.white
                              : Colors.orange,
                        ),
                      ),
                      // ปุ่มที่สาม
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: _selectedPageIndex == 2
                              ? Colors.orange
                              : Colors.transparent,
                          border: Border.all(color: Colors.orange, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () => _onPageSelected(2),
                          icon: const Icon(Icons.local_fire_department),
                          color: _selectedPageIndex == 2
                              ? Colors.white
                              : Colors.orange,
                        ),
                      ),
                    ],
                  )),
              SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.6, // กำหนดความสูงชัดเจน
                  child: RepaintBoundary(
                    key: _captureKey, // ใช้ GlobalKey สำหรับการจับภาพ
                    child: Padding(
                      padding: const EdgeInsets.all(
                          7.0), // เพิ่ม Padding รอบ PageView
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black // พื้นหลังในโหมดมืด
                              : Colors.white, // พื้นหลังในโหมดสว่าง
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey // สีกรอบในโหมดมืด
                                    : Colors.orange, // สีกรอบในโหมดสว่าง
                            width: 2.0, // ความหนาของกรอบ
                          ),
                          borderRadius: BorderRadius.circular(
                              20.0), // มุมโค้งของกรอบภายนอก
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              18.0), // มุมโค้งของขอบด้านใน
                          child: Flexible(
                            fit: FlexFit.loose,
                            child: PageView(
                              controller: _pageController,
                              onPageChanged: (pageIndex) {
                                if (_selectedPageIndex != pageIndex &&
                                    !_isAnimating) {
                                  setState(() {
                                    _selectedPageIndex = pageIndex;
                                  });
                                }
                              },
                              children: [
                                // หน้าแรก
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    double width = constraints.maxWidth;
                                    double height = constraints.maxHeight;

                                    double circleSize = width *
                                        0.6; // ปรับขนาดวงกลมให้สัมพันธ์กับหน้าจอ
                                    double iconSize = width *
                                        0.1; // ปรับขนาดไอคอนให้สัมพันธ์กับหน้าจอ
                                    double fontSize =
                                        width * 0.05; // ปรับขนาดตัวอักษร
                                    double percentageFontSize = width * 0.08;

                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        if (_showCaptureText) ...[
                                          SizedBox(height: height * 0.05),
                                          Text(
                                            AppLocalizations.of(context)!
                                                .timeRemainingTitle,
                                            style: TextStyle(
                                              fontSize: fontSize,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange,
                                            ),
                                          ),
                                          SizedBox(height: height * 0.01),
                                          Text(
                                            formatDuration(_timeRemaining),
                                            style: TextStyle(
                                              fontSize: fontSize * 0.8,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                        SizedBox(height: height * 0.18),
                                        SizedBox(
                                          height: circleSize,
                                          width: circleSize * 1.4,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Positioned(
                                                width: circleSize,
                                                height: circleSize,
                                                child: CustomPaint(
                                                  painter:
                                                      HalfCircleProgressPainter(
                                                    percentage:
                                                        percentagePassed,
                                                    context: context,
                                                  ),
                                                ),
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                      height: height * 0.02),
                                                  Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .timeElapsedTitle,
                                                    style: TextStyle(
                                                      fontSize: fontSize * 0.8,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height: height * 0.01),
                                                  Text(
                                                    "${percentagePassed.toStringAsFixed(1)}%",
                                                    style: TextStyle(
                                                      fontSize:
                                                          percentageFontSize,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.orange,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Positioned(
                                                bottom: 0,
                                                left: width * 0.04,
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      width: iconSize * 1.6,
                                                      height: iconSize * 1.4,
                                                      decoration: BoxDecoration(
                                                        color: Colors.orange
                                                            .withOpacity(0.3),
                                                        borderRadius:
                                                            BorderRadius.vertical(
                                                                bottom: Radius
                                                                    .circular(
                                                                        32)),
                                                      ),
                                                      child: Icon(
                                                          FontAwesomeIcons.baby,
                                                          size: iconSize),
                                                    ),
                                                    SizedBox(
                                                        height: height * 0.005),
                                                    Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .birthTitle,
                                                      style: TextStyle(
                                                          fontSize:
                                                              fontSize * 0.7),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 0,
                                                right: width * 0.04,
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      width: iconSize * 1.6,
                                                      height: iconSize * 1.4,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey
                                                            .withOpacity(0.3),
                                                        borderRadius:
                                                            BorderRadius.vertical(
                                                                bottom: Radius
                                                                    .circular(
                                                                        32)),
                                                      ),
                                                      child: Stack(
                                                        alignment:
                                                            Alignment.center,
                                                        children: [
                                                          Container(
                                                            width: iconSize,
                                                            height: iconSize,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .transparent,
                                                              border:
                                                                  Border.all(
                                                                color:
                                                                    Colors.grey,
                                                                width: 2,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                          ),
                                                          Icon(Icons.person,
                                                              size: iconSize),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        height: height * 0.005),
                                                    Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .deathTitle,
                                                      style: TextStyle(
                                                          fontSize:
                                                              fontSize * 0.7),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),

                                // หน้าอื่นๆ
                                Scaffold(
                                  body: LayoutBuilder(
                                    builder: (context, constraints) {
                                      double width = constraints.maxWidth;
                                      double height = constraints.maxHeight;

                                      double fontSizeTitle =
                                          width * 0.06; // ปรับขนาดตัวอักษรตามจอ
                                      double fontSizeDuration = fontSizeTitle *
                                          0.6; // ขนาดตัวอักษรของเวลา

                                      return Center(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          child: Container(
                                            padding: EdgeInsets.all(width *
                                                0.08), // ปรับ padding ตามหน้าจอ
                                            width: width *
                                                1, // ป้องกันการขยายเกินขอบจอ
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                if (_showCaptureText) ...[
                                                  Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .timeRemainingTitle,
                                                    style: TextStyle(
                                                      fontSize: fontSizeTitle,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.orange,
                                                    ),
                                                    textAlign: TextAlign
                                                        .center, // ป้องกันข้อความล้น
                                                  ),
                                                  SizedBox(
                                                      height: height * 0.01),
                                                  Text(
                                                    formatDuration(
                                                        _timeRemaining),
                                                    style: TextStyle(
                                                      fontSize:
                                                          fontSizeDuration,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                                SizedBox(height: height * 0.02),
                                                Flexible(
                                                  fit: FlexFit.loose,
                                                  child: SingleChildScrollView(
                                                    child: YearGrid(
                                                      startYear:
                                                          widget.birthDate.year,
                                                      endYear:
                                                          widget.deathDate.year,
                                                      currentYear:
                                                          DateTime.now().year,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    double width = constraints.maxWidth;
                                    double height = constraints.maxHeight;

                                    double fontSizeTitle =
                                        width * 0.06; // ขนาดตัวอักษรของหัวข้อ
                                    double fontSizeDuration = fontSizeTitle *
                                        0.6; // ขนาดตัวอักษรของเวลา

                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (_showCaptureText) ...[
                                          SizedBox(height: height * 0.01),
                                          Text(
                                            AppLocalizations.of(context)!
                                                .timeRemainingTitle,
                                            style: TextStyle(
                                              fontSize: fontSizeTitle,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: height * 0.005),
                                          Text(
                                            formatDuration(_timeRemaining),
                                            style: TextStyle(
                                              fontSize: fontSizeDuration,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                        Expanded(
                                          child: Container(
                                            width: width *
                                                1, // ปรับให้เหมาะกับขนาดหน้าจอ
                                            decoration: BoxDecoration(
                                              color: const Color.fromRGBO(
                                                  15, 37, 66, 1),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            child: Center(
                                              child: CandleWidget(
                                                remainingPercentage:
                                                    (_timeRemaining.inSeconds /
                                                            _totalLifeSpan
                                                                .inSeconds) *
                                                        100,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                  bottom: 80.0,
                  left: 40.0,
                  right: 50.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        await requestPermissions();
                        await _captureAndSaveImage();
                      },
                      icon: const Icon(Icons.save),
                      label: Text(
                        AppLocalizations.of(context)!.saveImage,
                      ),
                    ),

                    /////////////////////////////////////////////////////
                    ElevatedButton.icon(
                      onPressed: () {
                        _showInterstitialAd();
                        context.go('/'); // ย้อนกลับไปยังหน้าแรก
                      },
                      icon: const Icon(Icons.refresh), // ไอคอนลูกศรย้อนกลับ
                      label: Text(
                        AppLocalizations.of(context)!
                            .resetButton, // ดึงข้อความจาก localization
                      ),
                      // ข้อความ "เริ่มใหม่"
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300], // สีพื้นหลังของปุ่ม
                        foregroundColor: Colors.black, // สีข้อความและไอคอน
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min, // ป้องกันการขยายเกินไป
                children: [
                  // Widget อื่นๆ
                  _nativeAdIsLoaded
                      ? IntrinsicHeight(
                          child: Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.width * _adAspectRatioMedium,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: AdWidget(ad: _nativeAd!),
                          ),
                        )
                      : SizedBox.shrink(),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              if (_isBannerAdLoaded)
                Container(
                  width: double.infinity,
                  height: _bannerHeight,
                  child: AdWidget(ad: _bannerAd!),
                ),
            ],
          ),
        ));
  }
}
////////////////////////////////////////////////////////////////////////////////////////

class HalfCircleProgressPainter extends CustomPainter {
  final double percentage;
  final double startLineOffset; // ระยะขยับของเส้นเริ่มต้น
  final double endLineOffset; // ระยะขยับของเส้นสุดท้าย
  final double startLineLengthInner; // ความยาวเส้นด้านในของจุดเริ่มต้น
  final double startLineLengthOuter; // ความยาวเส้นด้านนอกของจุดเริ่มต้น
  final double endLineLengthInner; // ความยาวเส้นด้านในของจุดสุดท้าย
  final double endLineLengthOuter; // ความยาวเส้นด้านนอกของจุดสุดท้าย
  final BuildContext context; // เพิ่ม context เพื่อเช็คธีม

  HalfCircleProgressPainter({
    required this.percentage,
    required this.context, // รับ context

    this.startLineOffset = 1.9,
    this.endLineOffset = 1.9,
    this.startLineLengthInner = 33.4, //ปรับความยาวเส้นเริ่มต้น
    this.startLineLengthOuter = 53,
    this.endLineLengthInner = 32.2, //ปรับความยาวเส้นท้ายสุด
    this.endLineLengthOuter = 53,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double yOffset = 35; // ระยะเลื่อนลงในแกน Y
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Paint createPaint(Color color, PaintingStyle style, double strokeWidth,
        {StrokeCap? strokeCap}) {
      return Paint()
        ..color = color
        ..style = style
        ..strokeWidth = strokeWidth
        ..strokeCap = strokeCap ?? StrokeCap.butt;
    }

    final Color backgroundColor = isDarkMode
        ? const ui.Color.fromARGB(255, 181, 179, 179)!
        : Colors.grey[300]!;
    final Color progressColor = isDarkMode ? Colors.orange : Colors.orange;
    final Color borderColor = isDarkMode ? Colors.white : Colors.black;
    final Color needleColor = isDarkMode ? Colors.white : Colors.black;
    // สร้าง Paint สำหรับ background, progress และ border
// สร้าง Paint สำหรับแต่ละส่วน
    final Paint backgroundPaint =
        createPaint(backgroundColor, PaintingStyle.stroke, 63);

    final Paint progressPaint =
        createPaint(progressColor, PaintingStyle.stroke, 60);

    final Paint borderPaint =
        createPaint(borderColor, PaintingStyle.stroke, 3); // ขอบเส้นประ

    final Paint innerBorderPaint =
        // ignore: deprecated_member_use
        createPaint(borderColor.withOpacity(0.7), PaintingStyle.stroke, 3);

    final Paint needlePaint =
        createPaint(needleColor, PaintingStyle.fill, 0); // เข็ม

    final Paint linePaint =
        // ignore: deprecated_member_use
        createPaint(needleColor.withOpacity(0.7), PaintingStyle.stroke, 3);

    final Paint startEndLinePaint =
        createPaint(needleColor, PaintingStyle.stroke, 3);

    // คำนวณค่าที่จำเป็น
    final double startAngle = -math.pi; // เริ่มจาก -180 องศา
    final double radius = size.width / 2; // รัศมีของครึ่งวงกลม
    final double needleRadiusFactor = 1.36; // ระยะที่เข็มอยู่ด้านนอก
    final double lineLengthFactor = 0.76; // ความยาวของเส้นเข็มลดลง

    // จุดศูนย์กลางของวงกลม
    final Offset center = Offset(size.width / 2, size.height / 2 + yOffset);

    // คำนวณมุม sweepAngle
    final double needlePaddingAngle =
        (0 / (radius * needleRadiusFactor)); // มุมระยะเผื่อ
    final double sweepAngle = math.pi * (percentage / 100) - needlePaddingAngle;

    // คำนวณมุมและตำแหน่งเข็ม
    final double needleAngle = startAngle + math.pi * (percentage / 100);

    // ตำแหน่งปลายเข็ม
    final Offset needlePosition = Offset(
      center.dx + (radius * needleRadiusFactor) * math.cos(needleAngle),
      center.dy + (radius * needleRadiusFactor) * math.sin(needleAngle),
    );

    // ตำแหน่งเริ่มต้นของเส้นเข็ม (ลดจากจุดศูนย์กลาง)
    final Offset startPoint = Offset(
      center.dx + (radius * lineLengthFactor) * math.cos(needleAngle),
      center.dy + (radius * lineLengthFactor) * math.sin(needleAngle),
    );

    // วาดพื้นหลังของวงกลม
    final Rect rect = Rect.fromLTWH(0, yOffset, size.width, size.height);
    canvas.drawArc(rect, startAngle, math.pi, false, backgroundPaint);

    // ปรับ rect สำหรับขอบสีแดงให้อยู่ด้านนอก
    final Rect borderRect = Rect.fromLTWH(
      -45, // เพิ่มขอบให้อยู่ด้านนอก
      -45 + yOffset,
      size.width + 90,
      size.height + 97,
    );

    // สร้างเส้นประสำหรับ borderPaint
    final Path borderPath = Path();
    const double dashWidth = 12; // ความยาวของเส้น
    const double dashSpace = 6; // ความกว้างของช่องว่าง

    for (double i = 0; i < math.pi * radius * 2; i += dashWidth + dashSpace) {
      final double startAngleDash = startAngle + (i / radius);
      final double endAngleDash = startAngle + ((i + dashWidth) / radius);

      // ตรวจสอบมุมเพื่อไม่ให้เกินครึ่งวงกลม
      if (endAngleDash > startAngle + math.pi) {
        break;
      }

      borderPath.addArc(
        borderRect,
        startAngleDash,
        endAngleDash - startAngleDash,
      );
    }

    // วาด border เส้นประ
    canvas.drawPath(borderPath, borderPaint);

    // วาดขอบเส้นเต็มด้านใน
    final Rect innerBorderRect = Rect.fromLTWH(
      32, // ลดขนาดให้อยู่ด้านใน
      32 + yOffset,
      size.width - 63,
      size.height - 63,
    );
    canvas.drawArc(
        innerBorderRect, startAngle, math.pi, false, innerBorderPaint);

    // วาดเส้นตรงที่จุดเริ่มต้น
    final Offset startLineStart = Offset(
      center.dx + (radius - startLineLengthInner) * math.cos(startAngle),
      center.dy +
          (radius - startLineLengthInner) * math.sin(startAngle) +
          startLineOffset,
    );
    final Offset startLineEnd = Offset(
      center.dx + (radius + startLineLengthOuter) * math.cos(startAngle),
      center.dy +
          (radius + startLineLengthOuter) * math.sin(startAngle) +
          startLineOffset,
    );
    canvas.drawLine(startLineStart, startLineEnd, startEndLinePaint);

    // วาดเส้นตรงที่จุดสุดท้าย
    final double endAngle = startAngle + math.pi;
    final Offset endLineStart = Offset(
      center.dx + (radius - endLineLengthInner) * math.cos(endAngle),
      center.dy +
          (radius - endLineLengthInner) * math.sin(endAngle) +
          endLineOffset,
    );
    final Offset endLineEnd = Offset(
      center.dx + (radius + endLineLengthOuter) * math.cos(endAngle),
      center.dy +
          (radius + endLineLengthOuter) * math.sin(endAngle) +
          endLineOffset,
    );
    canvas.drawLine(endLineStart, endLineEnd, startEndLinePaint);

    // วาด progress
    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);

    // วาดเส้นเข็ม
    canvas.drawLine(startPoint, needlePosition, linePaint);

    // วาดวงกลมที่ปลายเข็ม (วงกลมนอก)
    canvas.drawCircle(needlePosition, 15, needlePaint);

    // วาดวงกลมด้านในที่ปลายเข็ม (วงกลมใน)
    final Paint innerCirclePaint = createPaint(
        const Color.fromARGB(255, 255, 255, 255)
            .withOpacity(1), // สีของวงกลมแรกด้านใน
        PaintingStyle.fill,
        0); // ไม่ต้องการ strokeWidth
    final double innerCircleRadius1 = 12; // ขนาดของวงกลมแรกด้านใน
    canvas.drawCircle(needlePosition, innerCircleRadius1, innerCirclePaint);

    // วาดวงกลมที่สองด้านใน (เพิ่มวงกลมใหม่)
    final Paint secondInnerCirclePaint = createPaint(
        Colors.orange.withOpacity(1), // สีของวงกลมที่สองด้านใน
        PaintingStyle.fill,
        0); // ไม่ต้องการ strokeWidth
    final double innerCircleRadius2 = 8.5; // ขนาดของวงกลมที่สองด้านใน
    canvas.drawCircle(
        needlePosition, innerCircleRadius2, secondInnerCirclePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

////////////////////////////////////////////////////////////////////////////////////////
class YearGrid extends StatelessWidget {
  final int startYear; // ปีเกิด (ปีเริ่มต้น)
  final int endYear; // ปีสุดท้าย
  final int currentYear; // ปีปัจจุบัน

  const YearGrid({
    super.key,
    required this.startYear,
    required this.endYear,
    required this.currentYear,
  });

  @override
  Widget build(BuildContext context) {
    final totalYears = endYear - startYear - 1;
    final elapsedYears = currentYear - startYear - 1;

    // คำนวณขนาดของแต่ละช่องตามความกว้างของหน้าจอ
    final screenWidth = MediaQuery.of(context).size.width;
    final maxColumns = 9; // เพิ่มจำนวนคอลัมน์สูงสุด
    final boxSize = screenWidth / maxColumns - 4; // ลด spacing ให้มากขึ้น

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 8.0, vertical: 12.0), // ลด padding รอบๆ
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 0), // ลดระยะห่างด้านบน
          SizedBox(
            height: 320, // กำหนดความสูงที่แน่นอนให้กับ Scrollable area
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 4, // ลดระยะห่างระหว่างคอลัมน์
                runSpacing: 4, // ลดระยะห่างระหว่างแถว
                children: List.generate(totalYears + 2, (index) {
                  final isFirst = index == 0;
                  final isLast = index == totalYears + 1;
                  final isElapsed =
                      !isFirst && !isLast && index - 1 <= elapsedYears;
                  final isCurrent =
                      !isFirst && !isLast && index - 1 == elapsedYears;
                  final isFinalYear = currentYear == endYear;

                  return Container(
                    alignment: Alignment.center,
                    width: isFirst || isLast
                        ? boxSize * 2.1
                        : boxSize, // ลดขนาดความกว้าง
                    height: boxSize * 0.6, // ลดความสูงของช่อง
                    decoration: BoxDecoration(
                      color: isFirst
                          ? Colors.orange
                          : isLast
                              ? (isFinalYear
                                  ? Color.fromRGBO(46, 82, 156, 0.5)
                                  : const Color.fromRGBO(46, 82, 156, 1.0))
                              : isCurrent
                                  ? const Color.fromRGBO(46, 82, 156, 1.0)
                                  : isElapsed
                                      ? Colors.orange
                                      : Colors.grey[300],
                      borderRadius: BorderRadius.circular(3), // ลดความโค้งมุม
                      boxShadow: isCurrent || isFinalYear
                          ? [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.4), // ลดความเข้มของเงา
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : [],
                    ),
                    child: isFirst
                        ? Text(
                            AppLocalizations.of(context)!.birthTitle,
                            style: const TextStyle(color: Colors.black),
                          )
                        : isLast
                            ? (isFinalYear
                                ? Icon(
                                    Icons.radio_button_on,
                                    color: Colors.orange,
                                    size: boxSize * 0.4, // ลดขนาดไอคอน
                                  )
                                : Text(
                                    AppLocalizations.of(context)!
                                        .deathTitle, // ดึงข้อความจาก localization
                                    style: const TextStyle(color: Colors.black),
                                  ))
                            : isCurrent
                                ? Icon(
                                    Icons.arrow_circle_right_outlined,
                                    color: Colors.orange,
                                    size: boxSize * 0.4, // ลดขนาดไอคอน
                                  )
                                : Container(),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////////////

class CandlePainter extends CustomPainter {
  final double remainingPercentage;
  final double flameScale;
  final double innerFlameScale;
  final double smallestFlameScale;

  CandlePainter(
    this.remainingPercentage, {
    required this.flameScale,
    required this.innerFlameScale,
    required this.smallestFlameScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ความสูงของเทียน
    final candleHeight = size.height * 0.5 * (remainingPercentage / 100);
    // วาดสี่เหลี่ยมเส้นประ
    _drawDashedRoundedRectangle(canvas, size); // วาดฐานเทียน
    _drawCandleBase(canvas, size);

    // วาดตัวเทียน
    _drawCandleBody(canvas, size, candleHeight);

    // วาดเส้นแนวตั้ง (เป็นส่วนหนึ่งของเทียน)
    _drawCandleLine(canvas, size, candleHeight);

    // วาดส่วนที่ละลาย (เป็นส่วนหนึ่งของเทียน)
    _drawMeltedWax(canvas, size, candleHeight);

    // วาดส่วนประกอบอื่น ๆ ที่เชื่อมโยงกับเทียน
    _drawAdditionalParts(canvas, size, candleHeight);
  }

  //////////////////////////////////////////////////////ฐานเทียน
  void _drawCandleBase(Canvas canvas, Size size) {
    final basePaint = Paint()..color = Colors.orange;
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.1,
        size.height * 0.8,
        size.width * 0.8,
        size.height * 0.05,
      ),
      Radius.circular(20), // มุมโค้งทั้ง 4 มุม
    );
    canvas.drawRRect(baseRect, basePaint);
  }

  //////////////////////////////////////////////////////ฐานเทียน
  ///
  ///
  /// //////////////////////////////////////////////////////เหลี่ยมเส้นประ
  void _drawDashedRoundedRectangle(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 163, 160, 160)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dashWidth = 7.0; // ความยาวของเส้น
    final dashSpace = 4.0; // ระยะห่างระหว่างเส้น
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.39,
        size.height * 0.3, // ความสูงเริ่มต้น
        size.width * 0.2,
        size.height * 0.5, // ความสูงสูงสุดของเทียน
      ),
      Radius.circular(10), // มุมโค้ง
    );

    final path = Path();
    path.addRRect(rrect);

    final dashedPath = _createDashedPath(path, dashWidth, dashSpace);
    canvas.drawPath(dashedPath, paint);
  }

  Path _createDashedPath(Path path, double dashWidth, double dashSpace) {
    final dashedPath = Path();
    for (PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final segmentLength = dashWidth + dashSpace;
        final start = distance;
        final end = (distance + dashWidth).clamp(0.0, pathMetric.length);
        dashedPath.addPath(pathMetric.extractPath(start, end), Offset.zero);
        distance += segmentLength;
      }
    }
    return dashedPath;
  }

  //////////////////////////////////////////////////////เหลี่ยมเส้นประ
  void _drawCandleBody(Canvas canvas, Size size, double candleHeight) {
    final candleBodyPaint = Paint()..color = Colors.orangeAccent;
    final candleBody = Rect.fromLTWH(
      size.width * 0.4,
      size.height * 0.3 + (size.height * 0.5 - candleHeight),
      size.width * 0.2,
      candleHeight,
    );
    canvas.drawRect(candleBody, candleBodyPaint);
  }

  void _drawCandleLine(Canvas canvas, Size size, double candleHeight) {
    final linePaint = Paint()
      ..color = const Color.fromARGB(255, 248, 189, 112)
      ..strokeWidth = size.width * 0.04;

    final lineStartX = size.width * 0.4;
    final lineStartY = size.height * 0.3 + (size.height * 0.5 - candleHeight);
    final lineEndY = size.height * 0.3 + size.height * 0.5;

    canvas.drawLine(
      Offset(lineStartX, lineStartY),
      Offset(lineStartX, lineEndY),
      linePaint,
    );
  }

  void _drawMeltedWax(Canvas canvas, Size size, double candleHeight) {
    final meltedPaint = Paint()
      ..color = const Color.fromARGB(255, 245, 208, 152)
      ..style = PaintingStyle.fill;

    final meltedPath = Path();
    meltedPath.addRRect(RRect.fromRectAndCorners(
      Rect.fromLTWH(
        size.width * 0.35,
        size.height * 0.3 + (size.height * 0.5 - candleHeight),
        size.width * 0.3,
        size.height * 0.08,
      ),
      topLeft: Radius.circular(10),
      topRight: Radius.circular(10),
    ));
    canvas.drawPath(meltedPath, meltedPaint);
  }

  void _drawAdditionalParts(Canvas canvas, Size size, double candleHeight) {
    // สี่เหลี่ยมด้านล่างสุด (เป็นส่วนหนึ่งของเทียน)
    _drawRoundedRect(
      canvas,
      size,
      size.width * 0.39,
      size.height * 0.3 +
          (size.height * 0.5 - candleHeight) +
          size.height * 0.08,
      size.width * 0.18,
      size.height * 0.04,
      10,
      Colors.grey.withOpacity(0.3),
    );

    // สี่เหลี่ยมแนวตั้งที่มีมุมโค้งทุกมุม (เป็นส่วนหนึ่งของเทียน)
    final roundedPaint = Paint()
      ..color = const Color.fromARGB(255, 245, 208, 152)
      ..style = PaintingStyle.fill;

    final roundedRectPath = Path();
    roundedRectPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.35,
        size.height * 0.35 +
            (size.height * 0.5 - candleHeight) -
            size.height * 0.05,
        size.width * 0.1,
        size.height * 0.15,
      ),
      Radius.circular(20),
    ));
    canvas.drawPath(roundedRectPath, roundedPaint);

    // สี่เหลี่ยมเล็กเพิ่มเติม (สัมพันธ์กับเทียน)
    final roundedPaint1 = Paint()
      ..color = const Color.fromARGB(255, 245, 208, 152)
      ..style = PaintingStyle.fill;

    final roundedRectPath1 = Path();
    roundedRectPath1.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.52,
        size.height * 0.35 +
            (size.height * 0.5 - candleHeight) -
            size.height * 0.05,
        size.width * 0.13,
        size.height * 0.12,
      ),
      Radius.circular(15),
    ));
    canvas.drawPath(roundedRectPath1, roundedPaint1);

    // สี่เหลี่ยมแนวนอน (สัมพันธ์กับเทียน)
    final roundedPaint2 = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255)
      ..style = PaintingStyle.fill;

    final roundedRectPath2 = Path();
    roundedRectPath2.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.4,
        size.height * 0.36 +
            (size.height * 0.5 - candleHeight) -
            size.height * 0.04,
        size.width * 0.2,
        size.height * 0.02,
      ),
      Radius.circular(15),
    ));
    canvas.drawPath(roundedRectPath2, roundedPaint2);

    ////////////////////////////////////////////////////////////////////////////
    // วาดเปลวไฟและไส้เทียนเฉพาะเมื่อ remainingPercentage > 10
    if (remainingPercentage > 2) {
      // วาดไส้เทียน (ให้อยู่ด้านหลังเปลวไฟ)
      final wickPaint = Paint()
        ..color = const Color.fromARGB(255, 255, 255, 255)
        ..strokeWidth = 4.0;
      final wickOffset = Offset(
        size.width * 0.5,
        size.height * 0.3 + (size.height * 0.5 - candleHeight) - 20,
      );
      canvas.drawLine(
        wickOffset,
        Offset(
          size.width * 0.5,
          size.height * 0.3 + (size.height * 0.5 - candleHeight),
        ),
        wickPaint,
      );

      // วาดแสงรอบเปลวไฟ
      final lightRadius = 100 * flameScale; // ขนาดรัศมีของแสงรอบเปลวไฟ
      final lightPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.orange.withOpacity(0.5), // สีใกล้เปลวไฟ
            Colors.yellow.withOpacity(0.2), // สีไกลออกไป
            Colors.transparent, // ขอบเขตนอกสุดของแสง
          ],
          stops: [0.0, 0.6, 1.0], // ตำแหน่งการเปลี่ยนสี
        ).createShader(Rect.fromCircle(
          center: Offset(
            wickOffset.dx, // ตำแหน่ง X ไม่เปลี่ยน
            wickOffset.dy - 30, // ขยับขึ้นในแกน Y (เพิ่มค่าลบ)
          ),
          radius: lightRadius,
        ));

      // วาดวงกลมแสงรอบเปลวไฟ
      canvas.drawCircle(
        Offset(
          wickOffset.dx, // ตำแหน่ง X
          wickOffset.dy - 30, // ตำแหน่ง Y ขยับขึ้น
        ),
        lightRadius,
        lightPaint,
      );

      /////////////////////////////////////////////////////
      final flamePath = Path();
      const flameOffset = 20.0; // เลื่อนเปลวไฟใหญ่ลง
      flamePath.moveTo(
        size.width * 0.5,
        size.height * 0.3 +
            (size.height * 0.5 - candleHeight) -
            120 * flameScale +
            flameOffset,
      );
      flamePath.quadraticBezierTo(
        size.width * 0.5 - 50 * flameScale,
        size.height * 0.3 +
            (size.height * 0.5 - candleHeight) -
            40 * flameScale +
            flameOffset,
        size.width * 0.5,
        size.height * 0.3 +
            (size.height * 0.5 - candleHeight) -
            40 * flameScale +
            flameOffset,
      );
      flamePath.quadraticBezierTo(
        size.width * 0.5 + 50 * flameScale,
        size.height * 0.3 +
            (size.height * 0.5 - candleHeight) -
            40 * flameScale +
            flameOffset,
        size.width * 0.5,
        size.height * 0.3 +
            (size.height * 0.5 - candleHeight) -
            120 * flameScale +
            flameOffset,
      );

      final flamePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.orange, Colors.yellow, Colors.white],
        ).createShader(Rect.fromCircle(
          center: Offset(
              size.width * 0.5,
              size.height * 0.3 +
                  (size.height * 0.5 - candleHeight) -
                  60 +
                  flameOffset),
          radius: 50,
        ));

      canvas.drawPath(flamePath, flamePaint);

      // เปลวไฟด้านใน
      final innerFlamePath = Path();
      innerFlamePath.moveTo(
        size.width * 0.5,
        size.height * 0.3 +
            (size.height * 0.5 - candleHeight) -
            80 * innerFlameScale,
      );
      innerFlamePath.quadraticBezierTo(
        size.width * 0.5 - 35 * innerFlameScale,
        size.height * 0.3 +
            (size.height * 0.5 - candleHeight) -
            20 * innerFlameScale,
        size.width * 0.5,
        size.height * 0.3 +
            (size.height * 0.5 - candleHeight) -
            20 * innerFlameScale,
      );
      innerFlamePath.quadraticBezierTo(
        size.width * 0.5 + 35 * innerFlameScale,
        size.height * 0.3 +
            (size.height * 0.5 - candleHeight) -
            20 * innerFlameScale,
        size.width * 0.5,
        size.height * 0.3 +
            (size.height * 0.5 - candleHeight) -
            80 * innerFlameScale,
      );

      final innerFlamePaint = Paint()
        ..color = Color.fromRGBO(255, 209, 155, 1.0);
      canvas.drawPath(innerFlamePath, innerFlamePaint);

      // เปลวไฟลูกที่สาม (เล็กที่สุด)
      final smallestFlamePath = Path();
      smallestFlamePath.moveTo(
        size.width * 0.5,
        size.height * 0.3 +
            (size.height * 0.5 - candleHeight) -
            60 * smallestFlameScale,
      );
      smallestFlamePath.quadraticBezierTo(
        size.width * 0.5 - 22 * smallestFlameScale,
        size.height * 0.3 +
            (size.height * 0.5 - candleHeight) -
            30 * smallestFlameScale,
        size.width * 0.5,
        size.height * 0.3 +
            (size.height * 0.5 - candleHeight) -
            20 * smallestFlameScale,
      );
      smallestFlamePath.quadraticBezierTo(
        size.width * 0.5 + 22 * smallestFlameScale,
        size.height * 0.3 +
            (size.height * 0.5 - candleHeight) -
            30 * smallestFlameScale,
        size.width * 0.5,
        size.height * 0.3 +
            (size.height * 0.5 - candleHeight) -
            60 * smallestFlameScale,
      );

      final smallestFlamePaint = Paint()..color = Colors.white;
      canvas.drawPath(smallestFlamePath, smallestFlamePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

////////////////////////////////////////////////
/// ฟังก์ชันสำหรับวาดสี่เหลี่ยมพร้อมมุมโค้ง
void _drawRoundedRect(Canvas canvas, Size size, double x, double y,
    double width, double height, double radius, Color color) {
  final paint = Paint()
    ..color = color
    ..style = PaintingStyle.fill;

  final path = Path();
  path.addRRect(RRect.fromRectAndRadius(
    Rect.fromLTWH(x, y, width, height),
    Radius.circular(radius),
  ));
  canvas.drawPath(path, paint);
}

////////////////////////////////////////////////
class CandleWidget extends StatefulWidget {
  final double remainingPercentage;

  const CandleWidget({Key? key, required this.remainingPercentage})
      : super(key: key);

  @override
  _CandleWidgetState createState() => _CandleWidgetState();
}

class _CandleWidgetState extends State<CandleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flameAnimation;
  late Animation<double> _innerFlameAnimation;
  late Animation<double> _smallestFlameAnimation;

  @override
  void initState() {
    super.initState();

    // สร้าง AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // ระยะเวลาการเคลื่อนไหว
    )..repeat(reverse: true);

    // สร้าง Animation ต่าง ๆ สำหรับเปลวไฟ
    _flameAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _innerFlameAnimation = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _smallestFlameAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // ลบ controller เมื่อเลิกใช้งาน
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(280, 300), // ขนาดของเทียน
          painter: CandlePainter(
            widget.remainingPercentage, // เปอร์เซ็นต์ของเทียนที่เหลือ
            flameScale: _flameAnimation.value, // ขนาดของเปลวไฟใหญ่
            innerFlameScale: _innerFlameAnimation.value, // ขนาดของเปลวไฟด้านใน
            smallestFlameScale:
                _smallestFlameAnimation.value, // ขนาดของเปลวไฟเล็กสุด
          ),
        );
      },
    );
  }
}
