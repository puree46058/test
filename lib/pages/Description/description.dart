import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class Description extends StatelessWidget {
  final String? year;
  final String? month;
  final String? day;

  const Description({
    super.key,
    this.year,
    this.month,
    this.day,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode
            ? Colors.grey[900] // สีพื้นหลังสำหรับโหมดมืด
            : const Color.fromARGB(
                255, 255, 255, 255), // สีพื้นหลังสำหรับโหมดสว่าง
        title: Text(
          AppLocalizations.of(context)!.back,
          style: TextStyle(
            color:
                isDarkMode ? Colors.white : Colors.black, // สีข้อความใน AppBar
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black, // สีของไอคอน
          ),
          onPressed: () {
            context.push('/select_Date'); // กลับไปยัง SelectDatePage
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
        ),
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.only(bottom: 24.0),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color.fromARGB(255, 0, 0, 0)
                        : Colors.grey[20],
                    border: Border.all(
                      color: isDarkMode
                          ? const Color.fromARGB(255, 255, 255, 255)!
                          : const Color.fromARGB(255, 0, 0, 0)!,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.nextStepDescription,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Divider(
                        thickness: 1.0,
                        height: 24.0,
                        color: Colors.grey,
                      ),
                      Text(
                        AppLocalizations.of(context)!.disclaimer,
                        style: TextStyle(
                          fontSize: 18,
                          color: isDarkMode
                              ? Colors.white
                              : const Color.fromARGB(255, 0, 0, 0),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        AppLocalizations.of(context)!.readyToStartCountdown,
                        style: TextStyle(
                          fontSize: 18,
                          color: isDarkMode
                              ? const Color.fromARGB(255, 255, 255, 255)
                              : const Color.fromARGB(255, 0, 0, 0),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // ปุ่มอยู่ด้านล่างสุด
                SizedBox(
                  width: 280,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push(
                        '/selection',
                        extra: {
                          'fromSelectDate': {
                            'year': year,
                            'month': month,
                            'day': day,
                          },
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode
                          ? const Color.fromARGB(255, 253, 253, 253)
                          : const Color.fromARGB(255, 0, 0, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.next,
                      style: TextStyle(
                        fontSize: 24,
                        color: isDarkMode ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
