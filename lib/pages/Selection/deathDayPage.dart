import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DeathDayPage extends StatefulWidget {
  final int month; // เดือนในรูปแบบตัวเลข (1-12)
  final String monthName; // ชื่อเดือน
  final int year; // ปี (พ.ศ.)
  final Function(String) onSelected; // Callback สำหรับส่งวันที่ที่เลือก

  const DeathDayPage({
    super.key,
    required this.month,
    required this.monthName,
    required this.year,
    required this.onSelected,
  });

  @override
  State<DeathDayPage> createState() => _DeathDayPageState();
}

class _DeathDayPageState extends State<DeathDayPage> {
  int? selectedDay;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // แปลงปี พ.ศ. เป็น ค.ศ.
    final gregorianYear = widget.year - 543;

    // คำนวณจำนวนวันในเดือน
    final daysInMonth = DateTime(gregorianYear, widget.month + 1, 0).day;

    // วันแรกของเดือน
    final firstDayOfWeek = DateTime(gregorianYear, widget.month, 1).weekday;

    // ปรับวันแรกให้เริ่มต้นที่วันอาทิตย์ (1)
    final adjustedFirstDayOfWeek = (firstDayOfWeek % 7) + 1;

    // Debug: ตรวจสอบค่าต่างๆ
    debugPrint('Debug: ปีที่ใช้คำนวณ (ค.ศ.): $gregorianYear');
    debugPrint('Debug: เดือนที่ใช้คำนวณ: ${widget.month}');
    debugPrint('Debug: จำนวนวันในเดือน: $daysInMonth');
    debugPrint('Debug: วันแรกของเดือน: $adjustedFirstDayOfWeek');

    // สร้าง Widget สำหรับแสดงวันที่
    final List<Widget> dayWidgets = [];

    // เติมช่องว่างก่อนวันที่ 1 ให้ตรงกับวันในสัปดาห์ (เริ่มต้นวันอาทิตย์)
    for (int i = 1; i < adjustedFirstDayOfWeek; i++) {
      dayWidgets.add(const SizedBox());
    }

    // สร้างปุ่มสำหรับวันที่
    for (int day = 1; day <= daysInMonth; day++) {
      final isSelected = selectedDay == day;
      dayWidgets.add(GestureDetector(
        onTap: () {
          setState(() {
            selectedDay = day;
          });
          widget.onSelected('$day');
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange[100] : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: isSelected ? Colors.orange : Colors.grey, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 16,
              color: isSelected ? Colors.orange : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.deathDayTitle,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black
                      : Colors.black,
                ),
              ),
              Text(
                localizations.deathDayQuestion,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black
                      : Colors.black,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localizations.sunday,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red, // สีแดงสำหรับวันอาทิตย์
                ),
              ),
              Text(
                localizations.monday,
                style: const TextStyle(fontSize: 18, color: Colors.black),
              ),
              Text(
                localizations.tuesday,
                style: const TextStyle(fontSize: 18, color: Colors.black),
              ),
              Text(
                localizations.wednesday,
                style: const TextStyle(fontSize: 18, color: Colors.black),
              ),
              Text(
                localizations.thursday,
                style: const TextStyle(fontSize: 18, color: Colors.black),
              ),
              Text(
                localizations.friday,
                style: const TextStyle(fontSize: 18, color: Colors.black),
              ),
              Text(
                localizations.saturday,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue, // สีน้ำเงินสำหรับวันเสาร์
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: GridView.count(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.2,
              children: dayWidgets,
            ),
          ),
        ),
      ],
    );
  }
}
