import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CaregiverDash extends StatefulWidget {
  const CaregiverDash({super.key});

  @override
  State<CaregiverDash> createState() => _CaregiverDashState();
}

class _CaregiverDashState extends State<CaregiverDash> {
  String currentLang = 'EN';

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
    
    final primarySage = const Color(0xFF7CA982);
    final darkSage = const Color(0xFF2C4A33); 
    final bgSage = const Color(0xFFE8EFE9);
    final cardBgSage = const Color(0xFFC2D5C4);
    final borderColor = const Color(0xFF8DB08C);

    final isAs = currentLang == 'AS';
    
    final String dashTitle = isAs ? 'কেয়াৰগিভাৰ ডেশ্ববৰ্ড' : 'Caregiver Dashboard';
    final String analyticsTitle = isAs ? 'বিশ্লেষণ আৰু প্ৰগতি' : 'Analytics & Progress';
    final String medsTitle = isAs ? 'গ্ৰহণ কৰা ঔষধ' : 'Meds Taken';
    final String challengesTitle = isAs ? 'সম্পূৰ্ণ কৰা প্ৰত্যাহ্বান' : 'Challenges Completed';
    final String actionsTitle = isAs ? 'কাৰ্য্যসমূহ' : 'Actions';
    final String sendAlertTitle = isAs ? 'তাত্ক্ষণিক সতৰ্কবাণী প্ৰেৰণ কৰক' : 'Send Instant Alert';
    final String activeSchedulesTitle = isAs ? 'সক্ৰিয় অনুসূচী' : 'Active Schedules';
    final String addNewReminderTitle = isAs ? 'নতুন স্মাৰক যোগ কৰক' : 'Add New Reminder';
    
    final List<String> schedulesEn = [
      "Morning Blood Pressure Pill - 8:00 AM",
      "Hydration - 12:00 PM",
      "Doctor Appointment - 4:00 PM"
    ];
    final List<String> schedulesAs = [
      "ৰাতিপুৱাৰ ৰক্তচাপৰ ঔষধ - ৮:০০ AM",
      "হাইড্ৰেচন - ১২:০০ PM",
      "ডাক্তৰৰ সৈতে সাক্ষাৎ - ৪:০০ PM"
    ];
    final schedules = isAs ? schedulesAs : schedulesEn;
    
    final String btn1 = isAs ? 'অনুসূচী\nস্মাৰক' : 'Schedule\nReminders';
    final String btn2 = isAs ? 'নতুন\nকাৰ্য্য সৃষ্টি' : 'Create\nCustom Tasks';
    final String btn3 = isAs ? 'ফটো\nআপল\'ড' : 'Upload\nPhotos';
    final String btn4 = isAs ? 'ৰোগীৰ\nছেটিংছ' : 'Patient\nSettings';

    return Scaffold(
      backgroundColor: bgSage,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 40, errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image)),
            const SizedBox(width: 12),
            Flexible(
              child: Text(dashTitle, style: TextStyle(color: darkSage, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        backgroundColor: bgSage,
        elevation: 0,
        iconTheme: IconThemeData(color: darkSage),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                currentLang = isAs ? 'EN' : 'AS';
              });
            },
            child: Text(
              isAs ? 'EN' : 'অসমীয়া',
              style: TextStyle(color: darkSage, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: cardBgSage,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: borderColor, width: 4.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    analyticsTitle,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: darkSage),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _buildStatBar(medsTitle, 0.85, primarySage, darkSage)),
                      const SizedBox(width: 24),
                      Expanded(child: _buildStatBar(challengesTitle, 0.60, primarySage, darkSage)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 80,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.warning_amber_rounded, size: 40),
                label: Text(
                  sendAlertTitle,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  String selectedOption = isAs ? 'পানী খাওক' : 'Drink Water';
                  final options = isAs ? ['পানী খাওক', 'ঔষধ খাওক', 'দুপৰীয়াৰ আহাৰৰ সময়', 'মোক কল কৰক'] : ['Drink Water', 'Take Medicine', 'Time for Lunch', 'Call Me'];
                  showDialog(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setDialogState) {
                          return AlertDialog(
                            title: Text(sendAlertTitle),
                            content: DropdownButton<String>(
                              value: selectedOption,
                              isExpanded: true,
                              items: options.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setDialogState(() {
                                  selectedOption = newValue!;
                                });
                              },
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(isAs ? 'বাতিল' : 'Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  FirebaseFirestore.instance.collection('sih_demo').doc('live_alert').set({
                                    'message': selectedOption, 
                                    'timestamp': FieldValue.serverTimestamp(), 
                                    'active': true
                                  });
                                  Navigator.pop(context);
                                },
                                child: Text(isAs ? 'প্ৰেৰণ কৰক' : 'Send'),
                              ),
                            ],
                          );
                        }
                      );
                    }
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            Text(
              activeSchedulesTitle,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkSage),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    tileColor: cardBgSage,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: borderColor, width: 2),
                    ),
                    title: Text(schedules[index], style: TextStyle(fontWeight: FontWeight.bold, color: darkSage)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit, color: darkSage),
                        const SizedBox(width: 16),
                        Icon(Icons.delete, color: Colors.red.shade700),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: darkSage,
                  side: BorderSide(color: darkSage, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.add),
                label: Text(addNewReminderTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                onPressed: () {},
              ),
            ),
            const SizedBox(height: 32),
            Text(
              actionsTitle,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkSage),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: [
                _buildActionTile(btn1, Icons.alarm_add, cardBgSage, borderColor, darkSage),
                _buildActionTile(btn2, Icons.add_task, cardBgSage, borderColor, darkSage),
                _buildActionTile(btn3, Icons.add_a_photo, cardBgSage, borderColor, darkSage),
                _buildActionTile(btn4, Icons.settings, cardBgSage, borderColor, darkSage),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBar(String title, double progress, Color progressColor, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white60,
          color: progressColor,
          minHeight: 12,
          borderRadius: BorderRadius.circular(6),
        ),
        const SizedBox(height: 8),
        Text(
          '${(progress * 100).toInt()}%',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        ),
      ],
    );
  }

  Widget _buildActionTile(String title, IconData icon, Color bgColor, Color borderCol, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderCol, width: 4.0),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: textColor),
              const SizedBox(height: 16),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
