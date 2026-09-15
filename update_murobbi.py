import re

with open('/Users/akshaya/sorah/lib/murobbi_home.dart', 'r') as f:
    content = f.read()

# 1. Imports
imports = """import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';"""

content = re.sub(r"import 'package:flutter/material\.dart';\nimport 'package:cloud_firestore/cloud_firestore\.dart';\nimport 'dart:async';", imports, content)


# 2. Add onTap to card1 (Photos)
card1_target = r"""                        _buildDashboardCard\(card1Title, Icons\.photo_album, cardBgColor, borderColor, textColor\),"""
card1_replacement = """                        _buildDashboardCard(card1Title, Icons.photo_album, cardBgColor, borderColor, textColor, onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => GalleryScreen(isAs: isAs)));
                        }),"""
content = re.sub(card1_target, card1_replacement, content)


# 3. Update Custom Tasks in RemindersScreen
# Looking for the task list builder in RemindersScreen:
task_list_target = r"""                    return Card\(
                      color: cardBgColor,
                      shape: RoundedRectangleBorder\(borderRadius: BorderRadius\.circular\(12\), side: BorderSide\(color: borderColor, width: 2\)\),
                      margin: const EdgeInsets\.only\(bottom: 12\),
                      child: ListTile\(
                        title: Text\(title, style: TextStyle\(fontWeight: FontWeight\.bold, color: textColor, fontSize: 22\)\),
                        subtitle: Text\('Effort: \$effort', style: TextStyle\(color: textColor, fontSize: 18\)\),
                        trailing: reqPhoto \? const Icon\(Icons\.camera_alt, size: 32\) : null,
                      \),
                    \);"""

task_list_replacement = """                    final String status = data['status'] ?? 'pending';
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
                                final storageRef = FirebaseStorage.instance.ref().child('sih_demo/task_proofs/${DateTime.now().millisecondsSinceEpoch}.jpg');
                                await storageRef.putFile(File(image.path));
                                final url = await storageRef.getDownloadURL();
                                
                                await FirebaseFirestore.instance.collection('sih_demo_tasks').doc(docs[index].id).update({
                                  'status': 'completed',
                                  'proofPhotoUrl': url,
                                  'completedAt': FieldValue.serverTimestamp(),
                                });
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isAs ? 'কাৰ্য্য সম্পূৰ্ণ হ\'ল!' : 'Task Completed!', style: const TextStyle(fontSize: 20))));
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                              }
                            }
                          } else {
                            await FirebaseFirestore.instance.collection('sih_demo_tasks').doc(docs[index].id).update({
                              'status': 'completed',
                              'completedAt': FieldValue.serverTimestamp(),
                            });
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isAs ? 'কাৰ্য্য সম্পূৰ্ণ হ\'ল!' : 'Task Completed!', style: const TextStyle(fontSize: 20))));
                          }
                        },
                      ),
                    );"""
content = re.sub(task_list_target, task_list_replacement, content)


# 4. Append GalleryScreen
gallery_code = """
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
                child: Image.network(url, fit: BoxFit.contain),
              );
            },
          );
        }
      ),
    );
  }
}
"""

content = re.sub(r"\}\n$", "}\n" + gallery_code, content)

with open('/Users/akshaya/sorah/lib/murobbi_home.dart', 'w') as f:
    f.write(content)

print("Murobbi Home fully updated.")
