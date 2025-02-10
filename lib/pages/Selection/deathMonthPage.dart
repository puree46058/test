import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DeathMonthPage extends StatefulWidget {
  final Function(int) onSelected;

  const DeathMonthPage({super.key, required this.onSelected});

  @override
  State<DeathMonthPage> createState() => _DeathMonthPageState();
}

class _DeathMonthPageState extends State<DeathMonthPage> {
  int? selectedMonthKey;

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // จัดข้อความชิดซ้าย
            children: [
              Text(
                AppLocalizations.of(context)!.deathMonthTitle,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black // ใช้สีขาวในโหมดมืด
                      : Colors.black, // ใช้สีดำในโหมดสว่าง
                ),
              ),
              Text(
                AppLocalizations.of(context)!.deathMonthQuestion,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black // ใช้สีขาวในโหมดมืด
                      : Colors.black, // ใช้สีดำในโหมดสว่าง
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 10), // เพิ่ม padding รอบ GridView
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // จำนวนคอลัมน์ในแต่ละแถว
              crossAxisSpacing: 20, // ระยะห่างแนวนอนระหว่างกล่อง
              mainAxisSpacing: 20, // ระยะห่างแนวตั้งระหว่างกล่อง
              childAspectRatio: 3, // อัตราส่วนความกว้างต่อความสูงของกล่อง
            ),
            itemCount: months.length,
            itemBuilder: (context, index) {
              final month = months[index];
              final isSelected = month['key'] == selectedMonthKey;
              return GestureDetector(
                key: Key(month['key'].toString()),
                onTap: () {
                  setState(() {
                    selectedMonthKey = month['key'];
                  });
                  print('Selected key (month number): ${month['key']}');
                  widget.onSelected(month['key']);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : const Color.fromARGB(255, 223, 223, 223))
                        : (Theme.of(context).brightness == Brightness.light
                            ? Colors.white
                            : Colors.black),
                    border: Border.all(
                      color: isSelected
                          ? (Theme.of(context).brightness == Brightness.light
                              ? const Color.fromARGB(255, 180, 170, 170)
                              : Colors.white)
                          : Colors.grey,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    month['value'],
                    style: TextStyle(
                      fontSize: 18,
                      color: isSelected
                          ? (Theme.of(context).brightness == Brightness.light
                              ? Colors.white
                              : Colors.black)
                          : (Theme.of(context).brightness == Brightness.light
                              ? Colors.black
                              : Colors.white),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
