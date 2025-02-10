import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  bool isLoading = true;
  String name_title_aboutUs = "Loading...";
  String text_aboutUs = "Loading...";
  String image_2 = ""; // ค่า URL ที่จะใช้แสดงรูป
  String text_by = "Loading...";
  String text_support = "Loading...";

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
      // ตั้งค่า Remote Config
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(seconds: 10),
      ));

      // ดึงค่าจาก Remote Config
      await _remoteConfig.fetchAndActivate();

      // อัปเดตค่าจาก Remote Config
      setState(() {
        name_title_aboutUs = _remoteConfig.getString("name_title_aboutUs");
        text_aboutUs = _remoteConfig.getString("text_aboutUs");
        image_2 = _remoteConfig.getString("image_2");
        text_by = _remoteConfig.getString("text_by");
        text_support = _remoteConfig.getString("text_support");
      });
    } catch (e) {
      print("Error fetching remote config: $e");
      setState(() {
        name_title_aboutUs = "Error fetching data.";
        text_aboutUs = "Error fetching data.";
        text_by = "Error fetching data.";
        text_support = "Error fetching data.";
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
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(), // แสดง Loading Indicator
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.aboutUsButton,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: image_2.isNotEmpty
                        ? Image.network(
                            image_2,
                            height: 150,
                            width: 150,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/logo.png',
                                height: 100,
                                width: 100,
                              );
                            },
                          )
                        : Image.asset(
                            'assets/images/logo.png',
                            height: 100,
                            width: 100,
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name_title_aboutUs,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    text_aboutUs,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.created_by,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        text_by,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.sponsored_by,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        text_support,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
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
                          horizontal: 130,
                          vertical: 15,
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.agree,
                        style: TextStyle(
                          fontSize: 24,
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
    );
  }
}
