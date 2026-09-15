import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';

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
    
    final String btn1 = isAs ? 'অনুসূচী\nস্মাৰক' : 'Schedule\nReminders';
    final String btn2 = isAs ? 'নতুন\nকাৰ্য্য সৃষ্টি' : 'Create\nCustom Tasks';
    final String btn3 = isAs ? 'ফটো\nআপল\'ড' : 'Upload\nPhotos';
    final String btn4 = isAs ? 'ৰোগীৰ\nছেটিংছ' : 'Patient\nSettings';
    
    final String deviceSecTitle = isAs ? 'ডিভাইচ সুৰক্ষা' : 'Device Security';
    final String pinSubtitle = isAs ? 'মুৰব্বী টেবলেট আনলক পিন' : 'Murobbi Tablet Unlock PIN';

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
            _buildAnalyticsSection(cardBgSage, borderColor, darkSage, primarySage, isAs),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 80,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9E5B4F),
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
                                    'active': true,
                                    'isInstant': true
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
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('sih_demo_schedules').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Text("No schedules yet.");
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final docId = docs[index].id;
                    final title = data['title'] ?? 'No Title';
                    final time = data['time'] ?? '';
                    final cat = data['category'] ?? '';
                    final freq = data['frequency'] ?? '';
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: ListTile(
                        tileColor: cardBgSage,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: borderColor, width: 2),
                        ),
                        title: Text('$cat $title - $time', style: TextStyle(fontWeight: FontWeight.bold, color: darkSage, fontSize: 18)),
                        subtitle: Text('Frequency: $freq', style: TextStyle(color: darkSage)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: darkSage),
                              onPressed: () {
                                _showAddReminderBottomSheet(context, isAs, docId: docId, existingData: data);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red.shade700),
                              onPressed: () {
                                FirebaseFirestore.instance.collection('sih_demo_schedules').doc(docId).delete();
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Schedule deleted')));
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            ),
            const SizedBox(height: 32),
            Text(
              isAs ? 'কাষ্টম কাৰ্য্যসমূহ' : 'Custom Tasks',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkSage),
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('sih_demo_tasks').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Text("No tasks yet.");
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final docId = docs[index].id;
                    final title = data['name'] ?? 'No Name';
                    final effort = data['effort'] ?? '';
                    final reqPhoto = data['requirePhoto'] ?? false;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: ListTile(
                        tileColor: cardBgSage,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: borderColor, width: 2),
                        ),
                        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: darkSage, fontSize: 18)),
                        subtitle: Text('Effort: $effort | Photo Req: ${reqPhoto ? "Yes" : "No"}', style: TextStyle(color: darkSage)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: darkSage),
                              onPressed: () {
                                _showAddCustomTaskBottomSheet(context, isAs, docId: docId, existingData: data);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red.shade700),
                              onPressed: () {
                                FirebaseFirestore.instance.collection('sih_demo_tasks').doc(docId).delete();
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task deleted')));
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
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
                onPressed: () {
                  _showAddReminderBottomSheet(context, isAs);
                },
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
                _buildActionTile(btn1, Icons.alarm_add, cardBgSage, borderColor, darkSage, onTap: () => _showAddReminderBottomSheet(context, isAs)),
                _buildActionTile(btn2, Icons.add_task, cardBgSage, borderColor, darkSage, onTap: () => _showAddCustomTaskBottomSheet(context, isAs)),
                _buildActionTile(btn3, Icons.add_a_photo, cardBgSage, borderColor, darkSage, onTap: () => _showManagePhotosDialog(context, isAs, cardBgSage, borderColor, darkSage)),
                _buildActionTile(btn4, Icons.settings, cardBgSage, borderColor, darkSage),
              ],
            ),
            const SizedBox(height: 32),
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
                  Text(deviceSecTitle, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: darkSage)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(pinSubtitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: darkSage))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: primarySage,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text("724089", style: TextStyle(fontSize: 32, letterSpacing: 4, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Card(
              color: cardBgSage,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: borderColor, width: 4)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAs ? 'সম্পূৰ্ণ হোৱা কাৰ্য্যৰ লগ' : 'Completed Tasks Log',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: darkSage),
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('sih_demo_tasks').orderBy('timestamp', descending: true).snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                        
                        // Client-side filter to avoid composite index requirements
                        final completedDocs = snapshot.data!.docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return data['status'] == 'completed';
                        }).toList();
                        
                        if (completedDocs.isEmpty) return const Text("No completed tasks yet.");
                        
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: completedDocs.length,
                          itemBuilder: (context, index) {
                            final data = completedDocs[index].data() as Map<String, dynamic>;
                            final title = data['name'] ?? 'Task';
                            final photoUrl = data['proofPhotoUrl'];
                            
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: darkSage, fontSize: 18)),
                              trailing: photoUrl != null
                                  ? GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => Dialog(
                                            child: Stack(
                                              alignment: Alignment.topRight,
                                              children: [
                                                Image.network(
                                                  photoUrl,
                                                  fit: BoxFit.contain,
                                                  loadingBuilder: (context, child, loadingProgress) {
                                                    if (loadingProgress == null) return child;
                                                    return Center(
                                                      child: CircularProgressIndicator(
                                                        value: loadingProgress.expectedTotalBytes != null
                                                            ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                                            : null,
                                                      ),
                                                    );
                                                  },
                                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.close, color: Colors.red, size: 32),
                                                  onPressed: () => Navigator.pop(context),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: darkSage, width: 2),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
                                          child: Image.network(
                                            photoUrl,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, loadingProgress) => loadingProgress == null ? child : const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 30, color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                    )
                                  : const Icon(Icons.check_circle, color: Colors.green),
                            );
                          },
                        );
                      }
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsSection(Color cardBgSage, Color borderColor, Color darkSage, Color primarySage, bool isAs) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('sih_demo').doc('analytics').collection('cognitive_logs').snapshots(),
      builder: (context, cogSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('sih_demo').doc('analytics').collection('med_logs').snapshots(),
          builder: (context, medSnapshot) {
            
            // Calculate Cognitive Stats
            double avgTimePerQuestion = 0.0;
            int totalSkips = 0;
            int totalChallenges = 0;
            
            if (cogSnapshot.hasData && cogSnapshot.data!.docs.isNotEmpty) {
              final docs = cogSnapshot.data!.docs;
              totalChallenges = docs.length;
              int totalQuestions = 0;
              int totalTimeSum = 0;
              
              for (var doc in docs) {
                final data = doc.data() as Map<String, dynamic>;
                final stats = List<Map<String, dynamic>>.from(data['stats'] ?? []);
                for (var stat in stats) {
                  if (stat['skipped'] == true) {
                    totalSkips++;
                  } else {
                    totalQuestions++;
                    totalTimeSum += (stat['time'] as int? ?? 0);
                  }
                }
              }
              if (totalQuestions > 0) {
                avgTimePerQuestion = totalTimeSum / totalQuestions;
              }
            } else {
              // Dummy Fallback
              avgTimePerQuestion = 14.5;
              totalSkips = 2;
              totalChallenges = 5;
            }
            
            // Calculate Med Stats
            double scheduledAvg = 0.0;
            double instantAvg = 0.0;
            
            if (medSnapshot.hasData && medSnapshot.data!.docs.isNotEmpty) {
              final docs = medSnapshot.data!.docs;
              int scheduledSum = 0, scheduledCount = 0;
              int instantSum = 0, instantCount = 0;
              
              for (var doc in docs) {
                final data = doc.data() as Map<String, dynamic>;
                final int responseTime = data['responseTime'] ?? 0;
                final bool isInst = data['isInstant'] ?? false;
                
                if (isInst) {
                  instantSum += responseTime;
                  instantCount++;
                } else {
                  scheduledSum += responseTime;
                  scheduledCount++;
                }
              }
              
              if (scheduledCount > 0) scheduledAvg = scheduledSum / scheduledCount;
              if (instantCount > 0) instantAvg = instantSum / instantCount;
            } else {
              // Dummy Fallback
              scheduledAvg = 45.0;
              instantAvg = 12.0;
            }

            final String analyticsTitle = isAs ? 'বিশ্লেষণ আৰু প্ৰগতি' : 'Analytics & Progress';
            final String cogTitle = isAs ? '১. জ্ঞানীয় প্ৰদৰ্শন' : '1. Cognitive Performance';
            final String alertRespTitle = isAs ? '২. সতৰ্কবাণীৰ সঁহাৰিৰ সময়' : '2. Alert Response Time';
            final String avgTimeStr = isAs ? 'গড় সময়/প্ৰশ্ন' : 'Avg Time/Question';
            final String totalSkipsStr = isAs ? 'মুঠ স্কিপ' : 'Total Skips Today';
            final String totalChallStr = isAs ? 'সম্পূৰ্ণ প্ৰত্যাহ্বান' : 'Total Challenges';
            final String scheduledStr = isAs ? 'অনুসূচিত' : 'Scheduled';
            final String instantStr = isAs ? 'তাত্ক্ষণিক' : 'Instant';
            
            // Normalize for bars. Max time for cognitive could be e.g. 30s. Max for med response e.g. 60s.
            double cogWidthFactor = (avgTimePerQuestion / 30.0).clamp(0.0, 1.0);
            double schedHeightFactor = (scheduledAvg / 60.0).clamp(0.05, 1.0);
            double instHeightFactor = (instantAvg / 60.0).clamp(0.05, 1.0);
            
            return Container(
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
                  
                  // Graph 1: Cognitive
                  Text(cogTitle, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkSage)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      SizedBox(width: 140, child: Text(avgTimeStr, style: TextStyle(color: darkSage, fontWeight: FontWeight.bold))),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Container(
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white60,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: constraints.maxWidth * cogWidthFactor,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: primarySage,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('${avgTimePerQuestion.toStringAsFixed(1)}s', style: TextStyle(color: darkSage, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$totalSkipsStr: $totalSkips', style: TextStyle(color: darkSage, fontWeight: FontWeight.bold)),
                      Text('$totalChallStr: $totalChallenges', style: TextStyle(color: darkSage, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Graph 2: Adherence
                  Text(alertRespTitle, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkSage)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 150,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildVerticalBar(scheduledStr, scheduledAvg, schedHeightFactor, const Color(0xFF4A5D23), darkSage),
                        _buildVerticalBar(instantStr, instantAvg, instHeightFactor, const Color(0xFFC4A46C), darkSage),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }

  Widget _buildVerticalBar(String label, double value, double heightFactor, Color color, Color textColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('${value.toStringAsFixed(1)}s', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 8),
        Container(
          width: 50,
          height: 100 * heightFactor,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
      ],
    );
  }

  Widget _buildActionTile(String title, IconData icon, Color bgColor, Color borderCol, Color textColor, {VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderCol, width: 4.0),
      ),
      child: InkWell(
        onTap: onTap ?? () {},
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

  void _showAddReminderBottomSheet(BuildContext context, bool isAs, {String? docId, Map<String, dynamic>? existingData}) {
    final darkSage = const Color(0xFF2C4A33);
    final bgSage = const Color(0xFFE8EFE9);
    final cardBgSage = const Color(0xFFC2D5C4);
    final borderColor = const Color(0xFF8DB08C);

    final titleController = TextEditingController(text: existingData?['title'] ?? '');
    TimeOfDay? selectedTime;
    
    if (existingData != null && existingData['time'] != null) {
      try {
        final timeParts = existingData['time'].split(RegExp(r'[: ]'));
        if (timeParts.length >= 2) {
          int h = int.parse(timeParts[0]);
          int m = int.parse(timeParts[1]);
          if (existingData['time'].contains('PM') && h < 12) h += 12;
          selectedTime = TimeOfDay(hour: h, minute: m);
        }
      } catch (e) {}
    }

    String selectedFreq = existingData?['frequency'] ?? 'Just Once';
    String selectedCat = existingData?['category'] ?? '💊 Medication';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgSage,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final String sheetTitle = docId == null 
              ? (isAs ? 'নতুন স্মাৰক' : 'New Reminder')
              : (isAs ? 'স্মাৰক সম্পাদনা' : 'Edit Reminder');
            final String hintStr = isAs ? 'যেনে, জিৰা, লং আৰু ধনিয়া গুটি ৰাতিটো তিয়াই থব' : 'e.g., Soak cumin, cloves, and coriander seeds overnight';
            final String timeStr = selectedTime != null ? selectedTime!.format(context) : (isAs ? 'সময় নিৰ্বাচন কৰক' : 'Select Time');
            final String saveStr = docId == null ? (isAs ? 'ছেভ কৰক' : 'Save to Schedule') : (isAs ? 'আপডেট কৰক' : 'Update');

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sheetTitle,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkSage),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: hintStr,
                      hintStyle: TextStyle(color: darkSage.withOpacity(0.6)),
                      filled: true,
                      fillColor: cardBgSage,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor, width: 2)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor, width: 2)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: darkSage, width: 2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    tileColor: cardBgSage,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: borderColor, width: 2)),
                    leading: Icon(Icons.access_time, color: darkSage),
                    title: Text(timeStr, style: TextStyle(color: darkSage, fontWeight: FontWeight.bold)),
                    onTap: () async {
                      final TimeOfDay? time = await showTimePicker(context: context, initialTime: selectedTime ?? TimeOfDay.now());
                      if (time != null) setModalState(() => selectedTime = time);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedFreq,
                          decoration: InputDecoration(
                            filled: true, fillColor: cardBgSage,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor, width: 2)),
                          ),
                          items: ['Just Once', 'Daily', 'Weekly'].map((String v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                          onChanged: (v) => setModalState(() => selectedFreq = v!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedCat,
                          decoration: InputDecoration(
                            filled: true, fillColor: cardBgSage,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor, width: 2)),
                          ),
                          items: ['💊 Medication', '💧 Hydration', '🩺 Appointment', '🍎 Meal'].map((String v) => DropdownMenuItem(value: v, child: Text(v, overflow: TextOverflow.ellipsis))).toList(),
                          onChanged: (v) => setModalState(() => selectedCat = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkSage,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (titleController.text.isNotEmpty && selectedTime != null) {
                          final data = {
                            'title': titleController.text,
                            'time': selectedTime!.format(context),
                            'frequency': selectedFreq,
                            'category': selectedCat,
                            'timestamp': FieldValue.serverTimestamp(),
                          };
                          
                          if (docId == null) {
                            FirebaseFirestore.instance.collection('sih_demo_schedules').add(data);
                          } else {
                            FirebaseFirestore.instance.collection('sih_demo_schedules').doc(docId).update(data);
                          }
                          Navigator.pop(context);
                        }
                      },
                      child: Text(saveStr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddCustomTaskBottomSheet(BuildContext context, bool isAs, {String? docId, Map<String, dynamic>? existingData}) {
    final darkSage = const Color(0xFF2C4A33);
    final bgSage = const Color(0xFFE8EFE9);
    final cardBgSage = const Color(0xFFC2D5C4);
    final borderColor = const Color(0xFF8DB08C);

    final titleController = TextEditingController(text: existingData?['name'] ?? '');
    String selectedEffort = existingData?['effort'] ?? 'Medium';
    bool requirePhoto = existingData?['requirePhoto'] ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgSage,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final String sheetTitle = docId == null ? 'Create Custom Task' : 'Edit Custom Task';
            final String saveStr = docId == null ? 'Save Task' : 'Update Task';

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sheetTitle, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkSage)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'e.g., Water the plants',
                      filled: true,
                      fillColor: cardBgSage,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor, width: 2)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor, width: 2)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: darkSage, width: 2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedEffort,
                    decoration: InputDecoration(
                      labelText: 'Effort Level',
                      filled: true, fillColor: cardBgSage,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor, width: 2)),
                    ),
                    items: ['Low', 'Medium', 'High'].map((String v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                    onChanged: (v) => setModalState(() => selectedEffort = v!),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Require Photo Acknowledgment'),
                    value: requirePhoto,
                    activeColor: darkSage,
                    onChanged: (v) => setModalState(() => requirePhoto = v),
                    tileColor: cardBgSage,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: borderColor, width: 2)),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkSage,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (titleController.text.isNotEmpty) {
                          final data = {
                            'name': titleController.text,
                            'effort': selectedEffort,
                            'requirePhoto': requirePhoto,
                            'timestamp': FieldValue.serverTimestamp(),
                          };
                          
                          if (docId == null) {
                            FirebaseFirestore.instance.collection('sih_demo_tasks').add(data);
                          } else {
                            FirebaseFirestore.instance.collection('sih_demo_tasks').doc(docId).update(data);
                          }
                          Navigator.pop(context);
                        }
                      },
                      child: Text(saveStr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showManagePhotosDialog(BuildContext context, bool isAs, Color cardBgSage, Color borderColor, Color darkSage) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            bool isUploading = false;

            Future<void> pickAndUpload() async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
              
              if (image != null) {
                try {
                  setDialogState(() { isUploading = true; });
                  String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
                  final storageRef = FirebaseStorage.instance.ref().child('sih_demo/gallery/$fileName');
                  
                  // Read the file as raw bytes to bypass path permission issues
                  final Uint8List imageBytes = await image.readAsBytes();
                  
                  // Upload the raw data
                  final uploadTask = storageRef.putData(imageBytes);
                  
                  // Wait for completion
                  final snapshot = await uploadTask.whenComplete(() => null);
                  
                  // Verify it actually succeeded before getting the URL
                  if (snapshot.state == TaskState.success) {
                    final downloadUrl = await snapshot.ref.getDownloadURL();
                    
                    await FirebaseFirestore.instance.collection('sih_demo_photos').add({
                      'url': downloadUrl,
                      'timestamp': FieldValue.serverTimestamp(),
                    });
                    
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload Successful')));
                  } else {
                    throw Exception('Upload failed with state: ${snapshot.state}');
                  }
                } on FirebaseException catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Firebase Error: ${e.code}')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
                } finally {
                  setDialogState(() { isUploading = false; });
                }
              }
            }

            return Dialog(
              backgroundColor: const Color(0xFFE8EFE9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                width: 600,
                height: 600,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isAs ? 'ফটো পৰিচালনা কৰক' : 'Manage Photos',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkSage),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 32),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkSage,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: isUploading ? null : pickAndUpload,
                      icon: isUploading 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                          : const Icon(Icons.upload),
                      label: Text(
                        isAs ? 'নতুন ফটো আপলোড কৰক' : 'Upload New Photo',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('sih_demo_photos').orderBy('timestamp', descending: true).snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                          final docs = snapshot.data!.docs;
                          if (docs.isEmpty) return const Center(child: Text('No photos uploaded yet.'));

                          return GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final doc = docs[index];
                              final data = doc.data() as Map<String, dynamic>;
                              final url = data['url'];

                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      url,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(child: CircularProgressIndicator());
                                      },
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () async {
                                        try {
                                          await FirebaseStorage.instance.refFromURL(url).delete();
                                          await doc.reference.delete();
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.white70,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.delete, color: Colors.red),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
