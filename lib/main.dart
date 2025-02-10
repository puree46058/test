import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:life_countdown/pages/AboutUs/AboutUsPage%20.dart';
import 'package:life_countdown/pages/Description/description.dart';
import 'package:life_countdown/pages/HOME/home_page.dart';
import 'package:life_countdown/pages/LifeCountdown/LifeCountdownPage%20.dart';
import 'package:life_countdown/pages/PROVIDERS/locale_provider.dart';
import 'package:life_countdown/pages/PROVIDERS/theme_provider.dart';
import 'package:life_countdown/pages/Result/resultPage.dart';
import 'package:life_countdown/pages/Select_Date/select_Date.dart';
import 'package:life_countdown/pages/Selection/deathDayPage.dart';
import 'package:life_countdown/pages/Selection/deathMonthPage.dart';
import 'package:life_countdown/pages/Selection/deathTimePage.dart';
import 'package:life_countdown/pages/Selection/deathYearPage.dart';
import 'package:life_countdown/pages/Selection/selection.dart';
import 'package:life_countdown/pages/Support/supportPage.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// 🟢 **แก้ไข**: โหลด Firebase ก่อนเริ่มแอป
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // สำคัญสำหรับ async operation

  // ✅ ใช้ Firebase แต่อย่าให้ AdMob เชื่อมต่อกับ Firebase Analytics
  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions.currentPlatform, // 🟢 ใช้ firebase_options.dart
  );

  await MobileAds.instance.initialize(); // ✅ แยกการ initialize AdMob

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleNotifier()),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      
      child: Builder(
        builder: (context) {
          
          return MyApp();
        },
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final localeNotifier = context.watch<LocaleNotifier>();
        final themeNotifier = context.watch<ThemeNotifier>();

        return MaterialApp.router(
          title: 'Flutter Demo',
          routerConfig: _router,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeNotifier.themeMode,
          locale: localeNotifier.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('th', ''),
          ],
        );
      },
    );
  }
}


// ตั้งค่า GoRouter
final GoRouter _router = GoRouter(
  initialLocation: '/', // กำหนดเส้นทางเริ่มต้น
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/select_Date',
      builder: (context, state) => const SelectDatePage(),
    ),
    GoRoute(
      path: '/support_Page',
      builder: (context, state) => SupportPage(),
    ),
    GoRoute(
      path: '/aboutUs_Page',
      builder: (context, state) => AboutUsPage(),
    ),
    GoRoute(
      path: '/description',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final year = extra['year'];
        final month = extra['month'];
        final day = extra['day'];

        return Description(
          year: year,
          month: month,
          day: day,
        );
      },
    ),
    GoRoute(
      path: '/selection',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>? ?? {};
        final fromSelectDate =
            args['fromSelectDate'] as Map<String, dynamic>? ?? {};

        print('Received in SelectionPage: $fromSelectDate');

        return SelectionPage(
          year: fromSelectDate['year'] ?? 'N/A',
          month: fromSelectDate['month'] ?? 'N/A',
          day: fromSelectDate['day'] ?? 'N/A',
          onNext: (selectionData) {
            GoRouter.of(context).go(
              '/resultPage',
              extra: {
                'fromSelectDate': fromSelectDate,
                'fromSelectionPage': selectionData,
              },
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/death_year',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?; // รับค่า extra
        final birthYear =
            int.parse(extra?['birthYear'] ?? '0'); // ดึง birthYear ที่ส่งมา

        return DeathYearPage(
          onSelected: (selectedYear) {
            // เมื่อเลือกปีสำเร็จ นำทางไปหน้า death_month
            GoRouter.of(context).go(
              '/death_month',
              extra: {
                'selectedYear': selectedYear, // ส่งปีที่เลือกไป
              },
            );
          },
          birthYear: birthYear, // ส่ง birthYear ไปยัง DeathYearPage
        );
      },
    ),
    GoRoute(
      path: '/death_month',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?; // รับค่า extra
        final selectedYear =
            extra?['selectedYear'] ?? DateTime.now().year; // รับปีที่ส่งมา

        return DeathMonthPage(
          onSelected: (selectedMonth) {
            // เมื่อเลือกเดือนสำเร็จ นำทางไปหน้า death_day
            context.go(
              '/death_day',
              extra: {
                'selectedMonth': selectedMonth, // ส่งเดือนที่เลือกไป
                'selectedYear': selectedYear, // ส่งปีที่เลือกไป
              },
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/death_day',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?; // รับค่า extra
        final selectedMonth =
            extra?['selectedMonth'] ?? 1; // เดือนในรูปแบบตัวเลข
        final selectedYear =
            extra?['selectedYear'] ?? DateTime.now().year; // ปีที่ส่งมา

        return DeathDayPage(
          month: selectedMonth,
          monthName: 'มกราคม', // ตัวอย่าง: สามารถส่งชื่อเดือนจริงได้
          year: selectedYear, // ใช้ปีที่ส่งมา
          onSelected: (selectedDay) {
            print('Selected day: $selectedDay');
          },
        );
      },
    ),
    GoRoute(
      path: '/death_time',
      builder: (context, state) => DeathTimePage(
        onSelected: (value) {
          // ดำเนินการเมื่อเลือกเวลา
          print('Selected time: $value');
        },
      ),
    ),
    GoRoute(
      path: '/resultPage',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>? ?? {};
        final fromSelectDate =
            args['fromSelectDate'] as Map<String, dynamic>? ?? {};
        final fromSelectionPage =
            args['fromSelectionPage'] as Map<String, dynamic>? ?? {};

        print('Navigated to ResultPage:');
        print('fromSelectDate: $fromSelectDate');
        print('fromSelectionPage: $fromSelectionPage');

        return ResultPage(
          fromSelectDate: fromSelectDate,
          fromSelectionPage: fromSelectionPage,
        );
      },
    ),
    GoRoute(
      path: '/lifeCount_downPage',
      builder: (context, state) {
        final data = state.extra as Map<String, DateTime>;
        return LifeCountdownPage(
          deathDate: data['deathDate']!,
          birthDate: data['birthDate']!,
        );
      },
    ),
  ],
);
