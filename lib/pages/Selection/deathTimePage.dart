import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DeathTimePage extends StatefulWidget {
  final Function(String) onSelected; // Callback สำหรับส่งค่าที่เลือก

  const DeathTimePage({super.key, required this.onSelected});

  @override
  State<DeathTimePage> createState() => _DeathTimePageState();
}

class _DeathTimePageState extends State<DeathTimePage> {
  String? selectedTime; // เก็บเวลาที่เลือก

  void _showCustomTimeDialog() {
    TextEditingController hourController = TextEditingController();
    TextEditingController minuteController = TextEditingController();
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            localizations.customTimeDialogTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: hourController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 2,
                      decoration: const InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(),
                        hintText: 'HH',
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      ':',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: minuteController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 2,
                      decoration: const InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(),
                        hintText: 'MM',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                localizations.customTimeDialogHint,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(localizations.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final hour = hourController.text.trim();
                final minute = minuteController.text.trim();

                if (_validateTime(hour, minute)) {
                  final customTime = '$hour:$minute';
                  setState(() {
                    selectedTime = customTime; // บันทึกเวลาในรูปแบบ 24 ชั่วโมง
                  });
                  widget.onSelected(customTime);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(localizations.invalidTimeFormat),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text(localizations.confirm),
            ),
          ],
        );
      },
    );
  }

  bool _validateTime(String hour, String minute) {
    if (hour.length != 2 || minute.length != 2) return false;

    final hourValue = int.tryParse(hour);
    final minuteValue = int.tryParse(minute);

    if (hourValue == null || minuteValue == null) return false;
    if (hourValue < 0 || hourValue > 23) return false;
    if (minuteValue < 0 || minuteValue > 59) return false;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final List<Map<String, String>> times = [
      {'key': '0', 'value': localizations.midnight},
      {'key': '3', 'value': localizations.threeAM},
      {'key': '6', 'value': localizations.sixAM},
      {'key': '9', 'value': localizations.nineAM},
      {'key': '12', 'value': localizations.noon},
      {'key': '15', 'value': localizations.threePM},
      {'key': '18', 'value': localizations.sixPM},
      {'key': '21', 'value': localizations.ninePM},
      {'key': '-1', 'value': localizations.customTime},
    ];
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryColor = isDarkMode ? Colors.black : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.deathTimeTitle,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                localizations.deathTimeQuestion,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Column(
            children: [
              // ปุ่ม "กำหนดเวลาเอง" แยกออกมาและจัดให้อยู่ตรงกลาง
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: GestureDetector(
                    onTap: _showCustomTimeDialog,
                    child: Container(
                      width: MediaQuery.of(context).size.width *
                          0.8, // ความกว้าง 80% ของหน้าจอ
                      height: 50, // ความสูงของปุ่ม
                      decoration: BoxDecoration(
                        color: selectedTime == 'กำหนดเวลาเอง'
                            ? primaryColor
                            : secondaryColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selectedTime == 'กำหนดเวลาเอง'
                              ? Colors.grey
                              : secondaryColor,
                          width: selectedTime == 'กำหนดเวลาเอง' ? 3 : 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        localizations.customTimeDialogTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: selectedTime == 'กำหนดเวลาเอง'
                              ? secondaryColor
                              : primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // กริดสำหรับปุ่มอื่นๆ
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 3.5,
                    ),
                    itemCount: times.length -
                        1, // ลดจำนวนปุ่มในกริดลง 1 (ไม่รวม "กำหนดเวลาเอง")
                    itemBuilder: (context, index) {
                      final timeKey = times[index]['key'];
                      final timeValue = times[index]['value'];
                      final isSelected = timeValue == selectedTime;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTime = timeValue;
                          });
                          widget.onSelected(timeValue!);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? primaryColor : secondaryColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? Colors.grey : secondaryColor,
                              width: isSelected ? 3 : 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            timeValue!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? secondaryColor : primaryColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
