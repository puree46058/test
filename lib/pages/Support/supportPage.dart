import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({Key? key}) : super(key: key);

  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  bool isLoading = true;
  String remoteMessage = "Loading...";
  String remoteMessage2 = "Loading...";
  String imageUrl = ""; // ค่า URL ที่จะใช้แสดงรูป
  String remoteMessage3 = "Loading...";
  String number_bank = "Loading...";
  String name_Account = "Loading...";

  @override
  void initState() {
    super.initState();
    _initRemoteConfig();
  }

  Future<void> _initRemoteConfig() async {
    setState(() {
      isLoading = true;
    });

    try {
      // ตั้งค่า fetch
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(seconds: 10),
      ));

      // ดึงค่าจาก Remote Config
      await _remoteConfig.fetchAndActivate();

      setState(() {
        remoteMessage = _remoteConfig.getString("name"); // โหลดค่า name
        remoteMessage2 = _remoteConfig.getString("name_2"); // โหลดค่า name_2
        imageUrl = _remoteConfig.getString("image_1"); // ดึงค่า URL
        remoteMessage3 = _remoteConfig.getString("name_bank"); // โหลดค่า name_2
        number_bank = _remoteConfig.getString("number_bank"); // โหลดค่า name_2
        name_Account =
            _remoteConfig.getString("name_Account"); // โหลดค่า name_2
      });
    } catch (e) {
      print("Error fetching remote config: $e");
      setState(() {
        remoteMessage = "Error fetching data.";
        remoteMessage2 = "Error fetching data.";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode
            ? Colors.grey[900]
            : const Color.fromARGB(255, 255, 255, 255),
        title: Text(
          AppLocalizations.of(context)!.back,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context); // ย้อนกลับไปยังหน้าก่อนหน้าใน stack
          },
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    const Divider(),
                    const SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context)!.supportButton,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 3.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          remoteMessage2, // แสดงค่า name_2 จาก Remote Config
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: isDarkMode
                                ? Colors.grey[300]
                                : const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 3.0, right: 0.0, top: 0.0, bottom: 0.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          remoteMessage,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: isDarkMode
                                ? Colors.grey[300]
                                : const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Image.network(
                          imageUrl, // โหลดรูปจาก URL ที่ได้จาก Firebase Remote Config
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          remoteMessage3,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      number_bank,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name_Account,
                      style: TextStyle(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 200),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // Action สำหรับปุ่มเริ่มต้น
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode
                              ? Colors.blueGrey
                              : const Color.fromARGB(255, 1, 1, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 100,
                            vertical: 15,
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.agree,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
