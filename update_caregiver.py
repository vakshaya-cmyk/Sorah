import re

with open('/Users/akshaya/sorah/lib/caregiver_dash.dart', 'r') as f:
    content = f.read()

# 1. Imports
imports = """import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';"""

content = re.sub(r"import 'package:flutter/material\.dart';\nimport 'package:cloud_firestore/cloud_firestore\.dart';", imports, content)


# 2. Add Completed Tasks Log at the bottom of the column
# Look for the device security PIN section, it's at the end of the children array
# Let's find:
#             Container(
#               padding: const EdgeInsets.all(24.0),
#               decoration: BoxDecoration(
#                 color: cardBgSage,
#                 borderRadius: BorderRadius.circular(16.0),
#                 border: Border.all(color: borderColor, width: 4.0),
#               ),
#               child: Column(
#                 crossAxisAlignment: CrossAxisAlignment.start,
#                 children: [
#                   Text(deviceSecTitle, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: darkSage)),

device_sec_target = r"""            Container\(
              padding: const EdgeInsets\.all\(24\.0\),
              decoration: BoxDecoration\(
                color: cardBgSage,
                borderRadius: BorderRadius\.circular\(16\.0\),
                border: Border\.all\(color: borderColor, width: 4\.0\),
              \),
              child: Column\(
                crossAxisAlignment: CrossAxisAlignment\.start,
                children: \[
                  Text\(deviceSecTitle, style: TextStyle\(fontSize: 28, fontWeight: FontWeight\.bold, color: darkSage\)\),
                  const SizedBox\(height: 12\),
                  Row\(
                    mainAxisAlignment: MainAxisAlignment\.spaceBetween,
                    children: \[
                      Text\(pinSubtitle, style: TextStyle\(fontSize: 18, fontWeight: FontWeight\.w600, color: darkSage\)\),
                      Container\(
                        padding: const EdgeInsets\.symmetric\(horizontal: 20, vertical: 8\),
                        decoration: BoxDecoration\(
                          color: primarySage,
                          borderRadius: BorderRadius\.circular\(12\),
                        \),
                        child: Text\("724089", style: TextStyle\(fontSize: 32, letterSpacing: 4, fontWeight: FontWeight\.bold, color: Colors\.white\)\),
                      \),
                    \],
                  \),
                \],
              \),
            \),"""

completed_tasks_log = """            Container(
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
                      Text(pinSubtitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: darkSage)),
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
                                                Image.network(photoUrl, fit: BoxFit.contain),
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
                                          image: DecorationImage(image: NetworkImage(photoUrl), fit: BoxFit.cover),
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
            ),"""

content = re.sub(device_sec_target, completed_tasks_log, content)

# 3. Hook up "Upload Photos" button
grid_target = r"""                _buildActionTile\(btn3, Icons\.add_a_photo, cardBgSage, borderColor, darkSage\),"""
grid_replacement = """                _buildActionTile(btn3, Icons.add_a_photo, cardBgSage, borderColor, darkSage, onTap: () => _showManagePhotosDialog(context, isAs, cardBgSage, borderColor, darkSage)),"""
content = re.sub(grid_target, grid_replacement, content)

# 4. Add _showManagePhotosDialog logic at the end of the class
manage_photos_code = """
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
                setDialogState(() => isUploading = true);
                try {
                  final storageRef = FirebaseStorage.instance.ref().child('sih_demo/gallery/${DateTime.now().millisecondsSinceEpoch}.jpg');
                  await storageRef.putFile(File(image.path));
                  final downloadUrl = await storageRef.getDownloadURL();
                  
                  await FirebaseFirestore.instance.collection('sih_demo_photos').add({
                    'url': downloadUrl,
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
                }
                setDialogState(() => isUploading = false);
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
                                    child: Image.network(url, fit: BoxFit.cover),
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
"""

content = re.sub(r"\}\n$", manage_photos_code, content)

with open('/Users/akshaya/sorah/lib/caregiver_dash.dart', 'w') as f:
    f.write(content)

print("Caregiver Dash fully updated.")
