import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class MurobbiHome extends StatefulWidget {
  const MurobbiHome({super.key});

  @override
  State<MurobbiHome> createState() => _MurobbiHomeState();
}

class _MurobbiHomeState extends State<MurobbiHome> {
  late Timer _timer;
  DateTime _currentTime = DateTime.now();
  String currentLang = 'EN';

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final ampm = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  String _formatDate(DateTime time) {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    
    if (currentLang == 'AS') {
      const weekdaysAs = ['সোমবাৰ', 'মঙলবাৰ', 'বুধবাৰ', 'বৃহস্পতিবাৰ', 'শুক্ৰবাৰ', 'শনিবাৰ', 'দেওবাৰ'];
      const monthsAs = ['জানুৱাৰী', 'ফেব্ৰুৱাৰী', 'মাৰ্চ', 'এপ্ৰিল', 'মে', 'জুন', 'জুলাই', 'আগষ্ট', 'ছেপ্টেম্বৰ', 'অক্টোবৰ', 'নৱেম্বৰ', 'ডিচেম্বৰ'];
      return '${weekdaysAs[time.weekday - 1]}, ${time.day} ${monthsAs[time.month - 1]} ${time.year}';
    }
    
    return '${weekdays[time.weekday - 1]}, ${time.day} ${months[time.month - 1]} ${time.year}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;
    final isTablet = screenWidth >= 600;

    int crossAxisCount;
    if (isTablet) {
      crossAxisCount = orientation == Orientation.portrait ? 3 : 4;
    } else {
      crossAxisCount = orientation == Orientation.portrait ? 2 : 3;
    }

    final Color bgColor = const Color(0xFFFBE4D4);
    final Color cardBgColor = const Color(0xFFF4CBA6);
    final Color borderColor = const Color(0xFFD48A64);
    final Color textColor = const Color(0xFF2E2218);

    // Translation Map
    final isAs = currentLang == 'AS';
    final String greeting = isAs ? 'স্বাগতম, অমলা!' : 'Welcome, Amala!';
    final String todayIs = isAs ? 'আজি ${_formatDate(_currentTime)}.' : 'Today is ${_formatDate(_currentTime)}.';
    final String weatherDesc = isAs ? 'আংশিক ৰৌদ্ৰোজ্জ্বল, ২১°C। উত্তৰ পূবৰ বতৰ।' : 'Partly Sunny, 21°C. North East Weather.';
    
    final String card1Title = isAs ? 'ফটো' : 'Photos';
    final String card2Title = isAs ? 'স্মাৰক\n(ঔষধ, পানী)' : 'Reminders\n(Meds, Water)';
    final String card3Title = isAs ? 'দৈনিক প্ৰত্যাহ্বান\n(খেলক)' : 'Daily Challenge\n(Play)';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 40, errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image)),
            const SizedBox(width: 12),
            Flexible(
              child: Text(isAs ? 'ডেশ্ববৰ্ড' : 'Dashboard', style: TextStyle(color: textColor, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                currentLang = isAs ? 'EN' : 'AS';
              });
            },
            child: Text(
              isAs ? 'EN' : 'অসমীয়া',
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          )
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('sih_demo').doc('live_alert').snapshots(),
        builder: (context, snapshot) {
          bool isActive = false;
          String alertMessage = '';
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>?;
            if (data != null) {
              isActive = data['active'] ?? false;
              String rawMessage = data['message'] ?? 'Alert';
              if (isAs) {
                if (rawMessage == 'Drink Water') alertMessage = 'পানী খাওক';
                else if (rawMessage == 'Take Medicine') alertMessage = 'ঔষধ খাওক';
                else if (rawMessage == 'Time for Lunch') alertMessage = 'দুপৰীয়াৰ আহাৰৰ সময়';
                else if (rawMessage == 'Call Me') alertMessage = 'মোক কল কৰক';
                else alertMessage = rawMessage;
              } else {
                alertMessage = rawMessage;
              }
            }
          }

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(color: borderColor, width: 4.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            greeting,
                            style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: textColor),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            todayIs,
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _formatTime(_currentTime),
                            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: textColor),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(Icons.wb_cloudy_outlined, size: 48, color: textColor),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  weatherDesc,
                                  style: TextStyle(fontSize: 24, color: textColor, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: 0.55,
                      children: [
                        _buildDashboardCard(card1Title, Icons.photo_album, cardBgColor, borderColor, textColor),
                        _buildDashboardCard(card2Title, Icons.alarm, cardBgColor, borderColor, textColor),
                        _buildDashboardCard(card3Title, Icons.extension, cardBgColor, borderColor, textColor),
                      ],
                    ),
                  ],
                ),
              ),
              if (isActive)
                Container(
                  color: Colors.black87,
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.warning_rounded, color: Colors.redAccent, size: 120),
                          const SizedBox(height: 40),
                          Text(
                            alertMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 60),
                          SizedBox(
                            width: double.infinity,
                            height: 100,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              ),
                              onPressed: () {
                                FirebaseFirestore.instance.collection('sih_demo').doc('live_alert').update({
                                  'active': false,
                                });
                              },
                              child: Text(
                                isAs ? 'হয়' : 'YES', 
                                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDashboardCard(String title, IconData icon, Color bgColor, Color borderColor, Color textColor) {
    final parts = title.split('\n');
    final mainTitle = parts[0];
    final subTitle = parts.length > 1 ? parts[1] : null;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderColor, width: 4.0),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 35, color: textColor),
              const SizedBox(height: 24),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  mainTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textColor),
                ),
              ),
              if (subTitle != null)
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      subTitle,
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
