import 'dart:ui';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:life_countdown/pages/Selection/deathDayPage.dart';
import 'package:life_countdown/pages/Selection/deathMonthPage.dart';
import 'package:life_countdown/pages/Selection/deathTimePage.dart';
import 'package:life_countdown/pages/Selection/deathYearPage.dart';

class SelectionPage extends StatefulWidget {
  final String? year;
  final String? month;
  final String? day;
  final Function(Map<String, dynamic>) onNext;

  const SelectionPage({
    super.key,
    this.year,
    this.month,
    this.day,
    required this.onNext,
  });

  @override
  State<SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage>
    with SingleTickerProviderStateMixin {
  int topSheetIndex = 3; // กำหนดแผ่นที่ 4 อยู่บนสุดเริ่มต้น
  String selectedYear = "";
  String selectedMonth = "";
  String selectedDay = "";
  String selectedTime = "";
  int? selectedMonthNumber; // เก็บเลขเดือนที่เลือก (1-12)

  late AnimationController _imageController;
  late Animation<double> _imageAnimation;

  final List<Map<String, String>> times = [
    {'key': '0', 'value': 'เที่ยงคืน'},
    {'key': '3', 'value': 'ตี 3'},
    {'key': '6', 'value': '6 โมงเช้า'},
    {'key': '9', 'value': '9 โมงเช้า'},
    {'key': '12', 'value': 'เที่ยงวัน'},
    {'key': '15', 'value': 'บ่าย 3'},
    {'key': '18', 'value': '6 โมงเย็น'},
    {'key': '21', 'value': '3 ทุ่ม'},
    {'key': '-1', 'value': 'กำหนดเวลาเอง'},
  ];

  @override
  void initState() {
    super.initState();
    selectedYear = widget.year ?? "";
    selectedMonth = widget.month ?? "";
    selectedDay = widget.day ?? "";

    // AnimationController สำหรับ Progress Bar และรูปภาพ
    _imageController = AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 1200), // กำหนดความเร็วของการเคลื่อนที่
    )..repeat(reverse: true); // เพิ่มการดิ้นของรูปภาพ

    _imageAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _imageController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _imageController.dispose(); // ปิด AnimationController เมื่อ State ถูกทำลาย
    super.dispose();
  }

  void printSelectedTime(String key) {
    final selectedTimeEntry = times.firstWhere(
      (time) => time['key'] == key,
      orElse: () => {'key': key, 'value': 'ไม่พบข้อมูล'},
    );

    print('Selected Key: ${selectedTimeEntry['key']}');
    print('Selected Value: ${selectedTimeEntry['value']}');
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final List<Map<String, dynamic>> months = [
      {'key': 1, 'value': localizations.january},
      {'key': 2, 'value': localizations.february},
      {'key': 3, 'value': localizations.march},
      {'key': 4, 'value': localizations.april},
      {'key': 5, 'value': localizations.may},
      {'key': 6, 'value': localizations.june},
      {'key': 7, 'value': localizations.july},
      {'key': 8, 'value': localizations.august},
      {'key': 9, 'value': localizations.september},
      {'key': 10, 'value': localizations.october},
      {'key': 11, 'value': localizations.november},
      {'key': 12, 'value': localizations.december},
    ];

    final List<Map<String, dynamic>> sheets = [
      {
        'title': 'แผ่นที่ 1',
        'color': Theme.of(context).brightness == Brightness.light
            ? Colors.grey[900]
            : const Color.fromARGB(255, 166, 166, 166),
        'icon': Icons.timer,
        'iconTop': 100.0, // ความสูงของไอคอนสำหรับแผ่นที่ 1
        'maxChildSize': 0.9,
        'initialChildSize': 0.9,
        'minChildSize': 0.3,
        'isDeathTimePage': true,
      },
      {
        'title': 'แผ่นที่ 2',
        'color': Theme.of(context).brightness == Brightness.light
            ? Colors.grey[900]
            : const Color.fromARGB(255, 166, 166, 166),
        'icon': Icons.calendar_today,
        'iconTop': 20.0, // ความสูงของไอคอนสำหรับแผ่นที่ 2
        'maxChildSize': 0.9,
        'initialChildSize': 0.9,
        'minChildSize': 0.3,
        'isDeathDayPage': true,
      },
      {
        'title': 'แผ่นที่ 3',
        'color': Theme.of(context).brightness == Brightness.light
            ? Colors.grey[900]
            : const Color.fromARGB(255, 166, 166, 166),
        'icon': Icons.event_note,
        'iconTop': 40.0, // ความสูงของไอคอนสำหรับแผ่นที่ 3
        'maxChildSize': 0.9,
        'initialChildSize': 0.9,
        'minChildSize': 0.3,
        'isDeathMonthPage': true,
      },
      {
        'title': 'แผ่นที่ 4',
        'color': Theme.of(context).brightness == Brightness.light
            ? Colors.grey[900]
            : const Color.fromARGB(255, 166, 166, 166),
        'icon': Icons.star,
        'iconTop': 50.0, // ความสูงของไอคอนสำหรับแผ่นที่ 4
        'maxChildSize': 0.9,
        'initialChildSize': 0.9,
        'minChildSize': 0.3,
        'isDeathYearPage': true,
      },
    ];

    void bringNextSheetToFront() {
      setState(() {
        topSheetIndex = (topSheetIndex - 1 + sheets.length) % sheets.length;
      });
    }

    void bringPreviousSheetToFront() {
      setState(() {
        topSheetIndex = (topSheetIndex + 1) % sheets.length;
      });
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool isConfirmButtonEnabled = (topSheetIndex == 3 &&
            selectedYear.isNotEmpty) || // ต้องเลือกปี
        (topSheetIndex == 2 && selectedMonth.isNotEmpty) || // ต้องเลือกเดือน
        (topSheetIndex == 1 &&
            selectedDay.isNotEmpty &&
            selectedMonthNumber != null) || // ต้องเลือกวันและมีเดือน
        (topSheetIndex == 0 && selectedTime.isNotEmpty); // ต้องเลือกเวลา

    final bool isBackButtonEnabled = topSheetIndex < 3;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        title: Text(
          AppLocalizations.of(context)!.back,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () {
            context.go('/description');
          },
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: kToolbarHeight - 40,
            left: MediaQuery.of(context).size.width * 0.1,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // พื้นหลังของ Progress Bar
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // Progress Bar ที่มีไล่สีแดง
                AnimatedContainer(
                  duration:
                      const Duration(milliseconds: 500), // ระยะเวลาเคลื่อนที่
                  curve: Curves.easeInOut,
                  width: MediaQuery.of(context).size.width *
                      0.8 *
                      ((sheets.length - topSheetIndex) / sheets.length),
                  height: 35,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 235, 86, 76).withOpacity(0.3),
                        const Color.fromARGB(255, 212, 49, 37).withOpacity(0.6),
                        const Color.fromARGB(255, 159, 20, 10).withOpacity(1.0),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      stops: [0.0, 0.5, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // รูปภาพที่เคลื่อนที่ไปพร้อมกับ Progress Bar
                AnimatedBuilder(
                  animation: _imageController,
                  builder: (context, child) {
                    // คำนวณตำแหน่ง Progress Bar
                    final double progressWidth =
                        MediaQuery.of(context).size.width *
                            0.8 *
                            ((sheets.length - topSheetIndex) / sheets.length);

                    return Transform.translate(
                      // ตำแหน่งรูปภาพสัมพันธ์กับ Progress Bar พร้อมกับ Animation
                      offset: Offset(
                          progressWidth - 25 + _imageAnimation.value, -15),
                      child: child,
                    );
                  },
                  child: Image.asset(
                    'assets/images/scared_2367127.png',
                    height: 50,
                  ),
                ),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1000),
            child: DraggableScrollableSheet(
              key: ValueKey<int>(topSheetIndex),
              initialChildSize: sheets[topSheetIndex]['initialChildSize'],
              minChildSize: sheets[topSheetIndex]['minChildSize'],
              maxChildSize: sheets[topSheetIndex]['maxChildSize'],
              builder:
                  (BuildContext context, ScrollController scrollController) {
                final isDarkMode =
                    Theme.of(context).brightness == Brightness.dark;

                final isDeathYearPage =
                    sheets[topSheetIndex]['isDeathYearPage'] ?? false;
                final isDeathMonthPage =
                    sheets[topSheetIndex]['isDeathMonthPage'] ?? false;
                final isDeathDayPage =
                    sheets[topSheetIndex]['isDeathDayPage'] ?? false;
                final isDeathTimePage =
                    sheets[topSheetIndex]['isDeathTimePage'] ?? false;

                return ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.7)
                            : Colors.black.withOpacity(0.2),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50),
                        ),
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.8)
                              : Colors.black.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          // ข้อความและปุ่มในแถวเดียวกัน
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceBetween, // จัดตำแหน่งปุ่ม
                              children: [
                                // ปุ่มย้อนกลับ (อยู่ทางซ้าย)
                                SizedBox(
                                  width: 120, // ความกว้างของปุ่ม
                                  height: 50, // ความสูงของปุ่ม
                                  child: ElevatedButton(
                                    onPressed: isBackButtonEnabled
                                        ? () {
                                            bringPreviousSheetToFront();
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isBackButtonEnabled
                                          ? (Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors
                                                  .black) // เปลี่ยนสีตามโหมด
                                          : Colors.grey,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10), // เพิ่มมุมโค้ง 20
                                      ),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.appBarTitle,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors
                                                .black // ตัวอักษรสีดำในโหมดมืด
                                            : Colors.white,
                                        // ตัวอักษรสีขาวในโหมดสว่าง
                                      ),
                                    ),
                                  ),
                                ),

                                // ปุ่มตกลง (อยู่ทางขวา)
                                SizedBox(
                                  width: 130, // ความกว้างของปุ่ม
                                  height: 50, // ความสูงของปุ่ม
                                  child: ElevatedButton(
                                    onPressed: isConfirmButtonEnabled
                                        ? () {
                                            if (topSheetIndex == 3) {
                                              setState(() {
                                                topSheetIndex = 2;
                                              });
                                            } else if (topSheetIndex == 2) {
                                              setState(() {
                                                topSheetIndex = 1;
                                              });
                                            } else if (topSheetIndex == 1) {
                                              setState(() {
                                                topSheetIndex = 0;
                                              });
                                            } else if (topSheetIndex == 0) {
                                              context.go(
                                                '/resultPage',
                                                extra: {
                                                  'fromSelectDate': {
                                                    'year': widget.year,
                                                    'month': widget.month,
                                                    'day': widget.day,
                                                  },
                                                  'fromSelectionPage': {
                                                    'selectedYear':
                                                        selectedYear,
                                                    'selectedMonth':
                                                        selectedMonth,
                                                    'selectedMonthNumber':
                                                        selectedMonthNumber,
                                                    'selectedDay': selectedDay,
                                                    'selectedTime':
                                                        selectedTime,
                                                    'times': times,
                                                  },
                                                  'summary':
                                                      'วันที่เลือก: $selectedDay $selectedMonth ($selectedMonthNumber) พ.ศ. $selectedYear เวลา: $selectedTime',
                                                },
                                              );
                                            }
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isConfirmButtonEnabled
                                          ? (Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors
                                                  .black) // เปลี่ยนสีตามโหมด
                                          : Colors.grey,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10), // เพิ่มมุมโค้ง 20
                                      ),
                                    ),
                                    child: Text(
                                      topSheetIndex == 3 &&
                                              selectedYear.isNotEmpty
                                          ? AppLocalizations.of(context)!.agree
                                          : topSheetIndex == 2 &&
                                                  selectedMonth.isNotEmpty
                                              ? AppLocalizations.of(context)!
                                                  .agree
                                              : topSheetIndex == 1 &&
                                                      selectedDay.isNotEmpty &&
                                                      selectedMonthNumber !=
                                                          null
                                                  ? AppLocalizations.of(
                                                          context)!
                                                      .agree
                                                  : topSheetIndex == 0 &&
                                                          selectedTime
                                                              .isNotEmpty
                                                      ? AppLocalizations.of(
                                                              context)!
                                                          .confirm
                                                      : AppLocalizations.of(
                                                              context)!
                                                          .selectAll,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Expanded(
                            child: isDeathYearPage
                                ? DeathYearPage(
                                    onSelected: (value) {
                                      setState(() {
                                        selectedYear = value.toString();
                                      });
                                    },
                                    birthYear:
                                        int.tryParse(widget.year ?? '') ?? 0,
                                  )
                                : isDeathMonthPage
                                    ? DeathMonthPage(
                                        onSelected: (monthNumber) {
                                          setState(() {
                                            selectedMonthNumber = monthNumber;
                                            selectedMonth = months.firstWhere(
                                                    (m) =>
                                                        m['key'] ==
                                                        monthNumber)['value']
                                                as String;
                                          });
                                        },
                                      )
                                    : isDeathDayPage
                                        ? (selectedMonthNumber != null
                                            ? DeathDayPage(
                                                month: selectedMonthNumber!,
                                                monthName: selectedMonth!,
                                                year: selectedYear.isEmpty
                                                    ? 2025
                                                    : int.parse(selectedYear),
                                                onSelected: (value) {
                                                  setState(() {
                                                    selectedDay = value;
                                                  });
                                                },
                                              )
                                            : Center(
                                                child: Text(
                                                  AppLocalizations.of(context)!
                                                      .pleaseSelectMonth,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ))
                                        : isDeathTimePage
                                            ? DeathTimePage(
                                                onSelected: (value) {
                                                  setState(() {
                                                    selectedTime = value;
                                                    printSelectedTime(value);
                                                  });
                                                },
                                              )
                                            : Center(
                                                child: Text(
                                                  sheets[topSheetIndex]
                                                      ['title'],
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white,
                                                  ),
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
        ],
      ),
    );
  }
}
