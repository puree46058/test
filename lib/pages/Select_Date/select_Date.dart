import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class SelectDatePage extends StatefulWidget {
  const SelectDatePage({super.key});

  @override
  State<SelectDatePage> createState() => _SelectDatePageState();
}

class _SelectDatePageState extends State<SelectDatePage> {
  String? selectedYear;
  String? selectedMonth;
  String? selectedDay;
  bool showCake = false;

  final List<String> years = List.generate(
    100,
    (index) =>
        (DateTime.now().year - index + 543).toString(), // ใช้ปี พ.ศ. โดยตรง
  );

  List<String> getLocalizedMonths(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return [
      localizations.january,
      localizations.february,
      localizations.march,
      localizations.april,
      localizations.may,
      localizations.june,
      localizations.july,
      localizations.august,
      localizations.september,
      localizations.october,
      localizations.november,
      localizations.december,
    ];
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        showCake = true;
      });
    });
  }

  List<String> days =
      List.generate(31, (index) => (index + 1).toString().padLeft(2, '0'));
  void updateDays() {
    if (selectedYear != null && selectedMonth != null) {
      // แปลงปี พ.ศ. เป็น ค.ศ.
      int yearInCE = int.parse(selectedYear!) - 543;

      // แปลงชื่อเดือนเป็นเลขเดือน
      final months = getLocalizedMonths(context);
      int monthIndex = months.indexOf(selectedMonth!) + 1;

      // ตรวจสอบจำนวนวันในเดือนที่เลือก
      int daysInMonth = DateTime(yearInCE, monthIndex + 1, 0).day;

      setState(() {
        days = List.generate(
            daysInMonth, (index) => (index + 1).toString().padLeft(2, '0'));

        // รีเซ็ตวันที่ที่เลือก หากวันที่ที่เลือกเกินจำนวนวันในเดือน
        if (selectedDay != null && int.parse(selectedDay!) > daysInMonth) {
          selectedDay = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black, // เปลี่ยนสีไอคอนเป็นสีขาว
          ),
          onPressed: () {
            context.go('/');
          },
        ),
        toolbarHeight: 150,
        flexibleSpace: Container(
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30), // มุมโค้งซ้ายล่าง
                bottomRight: Radius.circular(30), // มุมโค้งขวาล่าง
              ),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white, // สีดำ
                Colors.black, // สีขาว
              ],
            ),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 15),
                    Text(
                      localizations.selectDateHeader,
                      style: const TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      localizations.selectDateSubHeader,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(280), // เพิ่มความสูงของ bottom
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    // Dropdown ปี
                    Expanded(
                      child: DropdownButtonFormField2<String>(
                        decoration: InputDecoration(
                          labelText: localizations.yearLabel,
                          labelStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Colors.white, width: 2),
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 8,
                          ),
                        ),
                        value: selectedYear,
                        isExpanded: true,
                        items: years.map((year) {
                          return DropdownMenuItem<String>(
                            value: year,
                            child: Text(
                              year,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white), // ใช้ style ตรงนี้
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedYear = value;
                          });
                          updateDays();
                        },
                        buttonStyleData: const ButtonStyleData(
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          height: 45,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 200,
                          offset: const Offset(0, -6),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 36,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Dropdown เดือน
                    Expanded(
                      child: DropdownButtonFormField2<String>(
                        decoration: InputDecoration(
                          labelText: localizations.monthLabel,
                          labelStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Colors.white, width: 2),
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 5,
                          ),
                        ),
                        value: selectedMonth,
                        isExpanded: true,
                        items: getLocalizedMonths(context).map((month) {
                          return DropdownMenuItem<String>(
                            value: month,
                            child: Text(
                              month,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white), // ใช้ style ตรงนี้
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedMonth = value;
                          });
                          updateDays();
                        },
                        buttonStyleData: const ButtonStyleData(
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          height: 45,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 200,
                          offset: const Offset(0, -6),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 36,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Dropdown วัน
                    Expanded(
                      child: DropdownButtonFormField2<String>(
                        decoration: InputDecoration(
                          labelText: localizations.dayLabel,
                          labelStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Colors.white, width: 2),
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 8,
                          ),
                        ),
                        value: selectedDay,
                        isExpanded: true,
                        items: days.map((day) {
                          return DropdownMenuItem<String>(
                            value: day,
                            child: Text(
                              day,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white), // ใช้ style ตรงนี้
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDay = value;
                          });
                        },
                        buttonStyleData: const ButtonStyleData(
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          height: 45,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 200,
                          offset: const Offset(0, -6),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 36,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50), // เพิ่ม Padding ด้านล่างของ AppBar
            ],
          ),
        ),
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 200,
              child: SizedBox(
                width: 250, // ปรับความกว้างของปุ่ม
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 18), // ปรับขนาด padding ให้ใหญ่ขึ้น
                    backgroundColor: Colors.white, // พื้นหลังสีขาว
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // มุมโค้งขึ้นเล็กน้อย
                    ),
                    elevation: 5, // เพิ่มเงาเล็กน้อยให้ดูโดดเด่น
                  ),
                  onPressed: (selectedYear != null &&
                          selectedMonth != null &&
                          selectedDay != null)
                      ? () {
                          print({
                            'year': selectedYear,
                            'month': selectedMonth,
                            'day': selectedDay,
                          });

                          GoRouter.of(context).go(
                            '/description',
                            extra: {
                              'year': selectedYear,
                              'month': selectedMonth,
                              'day': selectedDay,
                            },
                          );
                        }
                      : null,
                  child: Text(
                    AppLocalizations.of(context)!.nextButton,
                    style: const TextStyle(
                      fontSize: 20, // เพิ่มขนาดตัวหนังสือ
                      color: Colors.black, // เปลี่ยนเป็นสีดำ
                      fontWeight: FontWeight.bold, // ทำให้ตัวหนาขึ้น
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }
}
