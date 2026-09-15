import re

# Fix caregiver_dash.dart
with open('/Users/akshaya/sorah/lib/caregiver_dash.dart', 'r') as f:
    content = f.read()

# Fix Image.network in Completed Tasks (line ~302)
completed_img_target = r"""                                                Image\.network\(photoUrl, fit: BoxFit\.contain\),"""
completed_img_replace = """                                                Image.network(
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
                                                ),"""
content = re.sub(completed_img_target, completed_img_replace, content)

# Fix thumbnail Image.network in Completed Tasks (line ~315)
thumb_img_target = r"""                                          image: DecorationImage\(image: NetworkImage\(photoUrl\), fit: BoxFit\.cover\),"""
# DecorationImage doesn't have loadingBuilder/errorBuilder easily accessible. 
# We'll replace it with a ClipRRect around Image.network
thumb_container_target = r"""                                      child: Container\(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration\(
                                          borderRadius: BorderRadius\.circular\(8\),
                                          border: Border\.all\(color: darkSage, width: 2\),
                                          image: DecorationImage\(image: NetworkImage\(photoUrl\), fit: BoxFit\.cover\),
                                        \),
                                      \),"""
thumb_container_replace = """                                      child: Container(
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
                                      ),"""
content = re.sub(thumb_container_target, thumb_container_replace, content)

# Fix upload logic in caregiver_dash.dart
upload_target = r"""                  final storageRef = FirebaseStorage\.instance\.ref\(\)\.child\('sih_demo/gallery/\$\{DateTime\.now\(\)\.millisecondsSinceEpoch\}\.jpg'\);
                  await storageRef\.putFile\(File\(image\.path\)\);
                  final downloadUrl = await storageRef\.getDownloadURL\(\);"""
upload_replace = """                  String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
                  final storageRef = FirebaseStorage.instance.ref().child('sih_demo/gallery/$fileName');
                  await storageRef.putFile(File(image.path));
                  final downloadUrl = await storageRef.getDownloadURL();"""
content = re.sub(upload_target, upload_replace, content)


# Fix Image.network in Manage Photos Grid (line ~996)
grid_img_target = r"""                                    child: Image\.network\(url, fit: BoxFit\.cover\),"""
grid_img_replace = """                                    child: Image.network(
                                      url,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(child: CircularProgressIndicator());
                                      },
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                                    ),"""
content = re.sub(grid_img_target, grid_img_replace, content)

with open('/Users/akshaya/sorah/lib/caregiver_dash.dart', 'w') as f:
    f.write(content)

# Fix murobbi_home.dart
with open('/Users/akshaya/sorah/lib/murobbi_home.dart', 'r') as f:
    murobbi_content = f.read()

# Fix Image.network in GalleryScreen
gallery_img_target = r"""              return InteractiveViewer\(
                child: Image\.network\(url, fit: BoxFit\.contain\),
              \);"""
gallery_img_replace = """              return InteractiveViewer(
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
              );"""
murobbi_content = re.sub(gallery_img_target, gallery_img_replace, murobbi_content)

# Fix Murobbi camera upload logic
murobbi_upload_target = r"""                                final storageRef = FirebaseStorage\.instance\.ref\(\)\.child\('sih_demo/task_proofs/\$\{DateTime\.now\(\)\.millisecondsSinceEpoch\}\.jpg'\);
                                await storageRef\.putFile\(File\(image\.path\)\);
                                final url = await storageRef\.getDownloadURL\(\);"""
murobbi_upload_replace = """                                String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
                                final storageRef = FirebaseStorage.instance.ref().child('sih_demo/task_proofs/$fileName');
                                await storageRef.putFile(File(image.path));
                                final url = await storageRef.getDownloadURL();"""
murobbi_content = re.sub(murobbi_upload_target, murobbi_upload_replace, murobbi_content)

with open('/Users/akshaya/sorah/lib/murobbi_home.dart', 'w') as f:
    f.write(murobbi_content)

print("Updates applied to both files.")
