import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';

class MurobbiHome extends StatefulWidget {
  const MurobbiHome({super.key});

  @override
  State<MurobbiHome> createState() => _MurobbiHomeState();
}

class _MurobbiHomeState extends State<MurobbiHome> {
  late Timer _timer;
  Timer? _pinTimer;
  DateTime _currentTime = DateTime.now();
  String currentLang = 'EN';
  DateTime? _alertDisplayedTime;
  bool isScreenPinned = false;

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
    _pinTimer?.cancel();
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

    return PopScope(
      canPop: !isScreenPinned,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onLongPress: () {
              if (isScreenPinned) {
                showDialog(
                  context: context,
                  builder: (context) => _PinUnlockDialog(
                    isAs: isAs,
                    title: isAs ? "স্ক্ৰীণ আনলক কৰিবলৈ পিন দিয়ক" : "Enter PIN to Unlock Screen",
                    onSuccess: () {
                      setState(() {
                        isScreenPinned = false;
                      });
                    },
                  ),
                );
              }
            },
            child: Row(
              children: [
                Image.asset('assets/logo.png', height: 40, errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image)),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(isAs ? 'ডেশ্ববৰ্ড' : 'Dashboard', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 32), overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onLongPress: () {
              if (isScreenPinned) {
                showDialog(
                  context: context,
                  builder: (context) => _PinUnlockDialog(
                    isAs: isAs,
                    title: isAs ? "স্ক্ৰীণ আনলক কৰিবলৈ পিন দিয়ক" : "Enter PIN to Unlock Screen",
                    onSuccess: () {
                      setState(() {
                        isScreenPinned = false;
                      });
                    },
                  ),
                );
              }
            },
            onTap: () {
              if (!isScreenPinned) {
                showDialog(
                  context: context,
                  builder: (context) => _PinUnlockDialog(
                    isAs: isAs,
                    title: isAs ? "স্ক্ৰীণ লক কৰিবলৈ পিন দিয়ক" : "Enter PIN to Lock Screen",
                    onSuccess: () {
                      setState(() {
                        isScreenPinned = true;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(isAs ? "স্ক্ৰীণ লক কৰা হ'ল" : "Screen Pinned", style: const TextStyle(fontSize: 24)),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ));
                    },
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(isScreenPinned ? Icons.lock : Icons.lock_open, size: 32, color: textColor),
            ),
          ),
          const SizedBox(width: 8),
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
          bool isInstant = false;
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>?;
            if (data != null) {
              isActive = data['active'] ?? false;
              isInstant = data['isInstant'] ?? false;
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

          if (isActive && _alertDisplayedTime == null) {
            _alertDisplayedTime = DateTime.now();
          } else if (!isActive) {
            _alertDisplayedTime = null;
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
                            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: textColor),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            todayIs,
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textColor),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _formatTime(_currentTime),
                            style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: textColor),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(Icons.wb_cloudy_outlined, size: 56, color: textColor),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  weatherDesc,
                                  style: TextStyle(fontSize: 28, color: textColor, fontWeight: FontWeight.w500),
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
                        _buildDashboardCard(card1Title, Icons.photo_album, cardBgColor, borderColor, textColor, onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => GalleryScreen(isAs: isAs)));
                        }),
                        _buildDashboardCard(
                          card2Title, 
                          Icons.alarm, 
                          cardBgColor, 
                          borderColor, 
                          textColor,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RemindersScreen(isAs: isAs)),
                            );
                          },
                        ),
                        _buildDashboardCard(
                          card3Title,
                          Icons.extension,
                          cardBgColor,
                          borderColor,
                          textColor,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CognitiveChallengeScreen(isAs: isAs)),
                            );
                          },
                        ),
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
                                if (_alertDisplayedTime != null) {
                                  final responseTime = DateTime.now().difference(_alertDisplayedTime!).inSeconds;
                                  FirebaseFirestore.instance.collection('sih_demo').doc('analytics').collection('med_logs').add({
                                    'responseTime': responseTime,
                                    'isInstant': isInstant,
                                    'timestamp': FieldValue.serverTimestamp(),
                                  });
                                }
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
    ));
  }

  Widget _buildDashboardCard(String title, IconData icon, Color bgColor, Color borderColor, Color textColor, {VoidCallback? onTap}) {
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
        onTap: onTap ?? () {},
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

class CognitiveChallengeScreen extends StatefulWidget {
  final bool isAs;
  const CognitiveChallengeScreen({super.key, required this.isAs});

  @override
  State<CognitiveChallengeScreen> createState() => _CognitiveChallengeScreenState();
}

class _CognitiveChallengeScreenState extends State<CognitiveChallengeScreen> {
  String? feedbackMessage;
  bool isSuccess = false;
  
  late final List<Map<String, dynamic>> questionsEn;
  late final List<Map<String, dynamic>> questionsAs;
  
  late List<Map<String, dynamic>> questionsQueue;
  int currentQuestionIndex = 0;
  late List<String> currentOptions;
  
  Stopwatch questionTimer = Stopwatch();
  List<Map<String, dynamic>> sessionStats = [];

  @override
  void initState() {
    super.initState();
    questionsEn = [
      {'target': 'Night', 'options': ['Light', 'Dark', 'Day'], 'answer': 'Light'},
      {'target': 'Moon', 'options': ['Tune', 'Star', 'Sun'], 'answer': 'Tune'},
      {'target': 'Sing', 'options': ['Ring', 'Talk', 'Bird'], 'answer': 'Ring'},
      {'target': 'Beat', 'options': ['Feet', 'Drum', 'Fast'], 'answer': 'Feet'},
      {'target': 'Flow', 'options': ['Glow', 'Water', 'Stop'], 'answer': 'Glow'},
    ];
    
    questionsAs = [
      {'target': 'ৰাতি', 'options': ['মাটি', 'আন্ধাৰ', 'দিন'], 'answer': 'মাটি'},
      {'target': 'জোন', 'options': ['সোন', 'তৰা', 'বেলি'], 'answer': 'সোন'},
      {'target': 'গান', 'options': ['কাণ', 'কথা', 'চৰাই'], 'answer': 'কাণ'},
      {'target': 'তাল', 'options': ['ডাল', 'ঢোল', 'খৰ'], 'answer': 'ডাল'},
      {'target': 'পানী', 'options': ['ৰাণী', 'নদী', 'বন্ধ'], 'answer': 'ৰাণী'},
    ];
    
    final baseQuestions = widget.isAs ? questionsAs : questionsEn;
    questionsQueue = List.from(baseQuestions)..shuffle();
    
    _loadCurrentQuestionOptions();
    questionTimer.start();
  }
  
  void _loadCurrentQuestionOptions() {
    if (currentQuestionIndex < questionsQueue.length) {
      currentOptions = List<String>.from(questionsQueue[currentQuestionIndex]['options']);
      currentOptions.shuffle();
    }
  }

  void _saveSessionData() {
    int totalTime = sessionStats.fold(0, (sum, stat) => sum + (stat['time'] as int));
    FirebaseFirestore.instance.collection('sih_demo').doc('analytics').collection('cognitive_logs').add({
      'timestamp': FieldValue.serverTimestamp(),
      'totalTime': totalTime,
      'stats': sessionStats,
    });
  }

  void _advanceToNext() {
    setState(() {
      currentQuestionIndex++;
      if (currentQuestionIndex >= questionsQueue.length) {
        _saveSessionData();
      } else {
        isSuccess = false;
        feedbackMessage = null;
        _loadCurrentQuestionOptions();
        questionTimer.reset();
        questionTimer.start();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = const Color(0xFFFBE4D4);
    final Color textColor = const Color(0xFF2E2218);

    if (currentQuestionIndex >= questionsQueue.length) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.stars, color: Colors.amber, size: 100),
              const SizedBox(height: 24),
              Text(
                widget.isAs ? "প্ৰত্যাহ্বান সম্পূৰ্ণ!" : "Challenge Complete!",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: textColor,
                  foregroundColor: bgColor,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: Text(widget.isAs ? "ডেশ্ববৰ্ডলৈ ঘূৰি যাওক" : "Back to Dashboard", style: const TextStyle(fontSize: 24)),
              )
            ],
          ),
        ),
      );
    }

    final String instruction = widget.isAs ? 'একে শুনা যোৱা শব্দটো বাছক' : 'Find the word that rhymes (sounds the same)';
    
    final currentQuestion = questionsQueue[currentQuestionIndex];
    final String targetWord = currentQuestion['target'];
    final String correctWord = currentQuestion['answer'];

    final String successMsg = widget.isAs ? 'বঢ়িয়া!' : 'Great Job!';
    final String tryAgainMsg = widget.isAs ? 'আকৌ চেষ্টা কৰক' : 'Try Again';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(widget.isAs ? 'দৈনিক প্ৰত্যাহ্বান' : 'Daily Challenge', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    if (isSuccess) return;
                    questionTimer.stop();
                    sessionStats.add({
                      'word': targetWord,
                      'time': questionTimer.elapsed.inSeconds,
                      'skipped': true,
                    });
                    _advanceToNext();
                  },
                  child: Text(
                    widget.isAs ? "এৰি যাওক" : "Skip",
                    style: TextStyle(fontSize: 20, color: textColor.withOpacity(0.6), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                instruction,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: textColor, width: 4),
                ),
                child: Center(
                  child: Text(
                    targetWord,
                    style: TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: textColor),
                  ),
                ),
              ),
              const SizedBox(height: 60),
              ...currentOptions.map((option) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: SizedBox(
                    height: 100,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: textColor,
                        foregroundColor: bgColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () {
                        if (isSuccess) return; // Prevent multiple taps after success
                        setState(() {
                          if (option == correctWord) {
                            questionTimer.stop();
                            sessionStats.add({
                              'word': targetWord,
                              'time': questionTimer.elapsed.inSeconds,
                              'skipped': false,
                            });
                            isSuccess = true;
                            feedbackMessage = successMsg;
                            
                            Future.delayed(const Duration(seconds: 2), () {
                              if (mounted) {
                                _advanceToNext();
                              }
                            });
                          } else {
                            isSuccess = false;
                            feedbackMessage = tryAgainMsg;
                            
                            Future.delayed(const Duration(seconds: 2), () {
                              if (mounted && !isSuccess && feedbackMessage == tryAgainMsg) {
                                setState(() {
                                  feedbackMessage = null;
                                });
                              }
                            });
                          }
                        });
                      },
                      child: Text(
                        option,
                        style: const TextStyle(fontSize: 52, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              }).toList(),
              
              if (feedbackMessage != null) ...[
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSuccess)
                      const Icon(Icons.check_circle, color: Colors.green, size: 48)
                    else
                      const Icon(Icons.refresh, color: Colors.orange, size: 48),
                    const SizedBox(width: 16),
                    Text(
                      feedbackMessage!,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isSuccess ? Colors.green.shade700 : Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinUnlockDialog extends StatefulWidget {
  final bool isAs;
  final String title;
  final VoidCallback onSuccess;
  
  const _PinUnlockDialog({required this.isAs, required this.title, required this.onSuccess});

  @override
  State<_PinUnlockDialog> createState() => _PinUnlockDialogState();
}

class _PinUnlockDialogState extends State<_PinUnlockDialog> {
  String enteredPin = "";
  bool isError = false;

  void _onKeyPress(String key) {
    if (isError) return;
    
    if (key == 'backspace') {
      if (enteredPin.isNotEmpty) {
        setState(() {
          enteredPin = enteredPin.substring(0, enteredPin.length - 1);
        });
      }
      return;
    }

    if (enteredPin.length < 6) {
      setState(() {
        enteredPin += key;
      });

      if (enteredPin.length == 6) {
        if (enteredPin == "724089") {
          widget.onSuccess();
          Navigator.pop(context);
        } else {
          setState(() {
            isError = true;
          });
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                enteredPin = "";
                isError = false;
              });
            }
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title;
    final errorTxt = widget.isAs ? "ভুল পিন" : "Incorrect PIN";
    
    final Color textColor = const Color(0xFF2E2218);
    final Color bgColor = const Color(0xFFFBE4D4);

    return Dialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            
            SizedBox(
              height: 40,
              child: isError 
                ? Text(errorTxt, style: const TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index < enteredPin.length ? textColor : Colors.transparent,
                          border: Border.all(color: textColor, width: 2),
                        ),
                      );
                    }),
                  ),
            ),
            
            const SizedBox(height: 32),
            
            SizedBox(
              width: 300,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.5,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  if (index == 9) return const SizedBox.shrink();
                  if (index == 11) {
                    return IconButton(
                      icon: Icon(Icons.backspace, color: textColor, size: 32),
                      onPressed: () => _onKeyPress('backspace'),
                    );
                  }
                  final number = index == 10 ? '0' : '${index + 1}';
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: textColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                    onPressed: () => _onKeyPress(number),
                    child: Text(number, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RemindersScreen extends StatelessWidget {
  final bool isAs;
  const RemindersScreen({super.key, required this.isAs});

  @override
  Widget build(BuildContext context) {
    final Color bgColor = const Color(0xFFFBE4D4);
    final Color cardBgColor = const Color(0xFFF4CBA6);
    final Color borderColor = const Color(0xFFD48A64);
    final Color textColor = const Color(0xFF2E2218);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(isAs ? 'স্মাৰক আৰু কাৰ্য্যসমূহ' : 'Reminders & Tasks', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(isAs ? 'সক্ৰিয় অনুসূচী' : 'Active Schedules', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('sih_demo_schedules').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return Text(isAs ? 'কোনো অনুসূচী নাই' : 'No schedules yet.', style: TextStyle(fontSize: 20, color: textColor));
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final title = data['title'] ?? '';
                    final time = data['time'] ?? '';
                    final cat = data['category'] ?? '';
                    final freq = data['frequency'] ?? '';
                    
                    return Card(
                      color: cardBgColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: borderColor, width: 2)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text('$cat $title - $time', style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 22)),
                        subtitle: Text(freq, style: TextStyle(color: textColor, fontSize: 18)),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 40),
            Text(isAs ? 'কাষ্টম কাৰ্য্যসমূহ' : 'Custom Tasks', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('sih_demo_tasks').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return Text(isAs ? 'কোনো কাৰ্য্য নাই' : 'No tasks yet.', style: TextStyle(fontSize: 20, color: textColor));
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final title = data['name'] ?? '';
                    final effort = data['effort'] ?? '';
                    final reqPhoto = data['requirePhoto'] ?? false;
                    
                    final String status = data['status'] ?? 'pending';
                    if (status == 'completed') return const SizedBox.shrink(); // hide completed
                    
                    return Card(
                      color: cardBgColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: borderColor, width: 2)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 22)),
                        subtitle: Text('Effort: $effort', style: TextStyle(color: textColor, fontSize: 18)),
                        trailing: reqPhoto ? const Icon(Icons.camera_alt, size: 32) : const Icon(Icons.check_circle_outline, size: 32),
                        onTap: () async {
                          if (reqPhoto) {
                            final picker = ImagePicker();
                            final image = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                            if (image != null) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isAs ? 'ফটো আপলোড কৰা হৈছে...' : 'Uploading proof...')));
                              try {
                                String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
                                final storageRef = FirebaseStorage.instance.ref().child('sih_demo/task_proofs/$fileName');
                                final Uint8List imageBytes = await image.readAsBytes();
                                final snapshot = await storageRef.putData(imageBytes);
                                final url = await snapshot.ref.getDownloadURL();
                                
                                await FirebaseFirestore.instance.collection('sih_demo_tasks').doc(docs[index].id).update({
                                  'status': 'completed',
                                  'proofPhotoUrl': url,
                                  'completedAt': FieldValue.serverTimestamp(),
                                });
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isAs ? "কাৰ্য্য সম্পূৰ্ণ হ'ল!" : "Task Completed!", style: const TextStyle(fontSize: 20))));
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                              }
                            }
                          } else {
                            await FirebaseFirestore.instance.collection('sih_demo_tasks').doc(docs[index].id).update({
                              'status': 'completed',
                              'completedAt': FieldValue.serverTimestamp(),
                            });
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isAs ? "কাৰ্য্য সম্পূৰ্ণ হ'ল!" : "Task Completed!", style: const TextStyle(fontSize: 20))));
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class GalleryScreen extends StatelessWidget {
  final bool isAs;
  const GalleryScreen({super.key, required this.isAs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(isAs ? 'ফটো গেলাৰী' : 'Photo Gallery', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('sih_demo_photos').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return Center(child: Text(isAs ? 'কোনো ফটো নাই' : 'No photos available', style: const TextStyle(color: Colors.white, fontSize: 24)));
          
          return PageView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final url = (docs[index].data() as Map<String, dynamic>)['url'];
              return InteractiveViewer(
                child: Image.network(
                  url,
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
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey, size: 80),
                ),
              );
            },
          );
        }
      ),
    );
  }
}
