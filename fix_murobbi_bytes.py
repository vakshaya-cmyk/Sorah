import re

with open('/Users/akshaya/sorah/lib/murobbi_home.dart', 'r') as f:
    content = f.read()

# Add import typed_data
imports_target = r"""import 'dart:io';"""
imports_replace = """import 'dart:io';
import 'dart:typed_data';"""
content = re.sub(imports_target, imports_replace, content)

# Fix putFile to putData
put_target = r"""                                final snapshot = await storageRef\.putFile\(File\(image\.path\)\);"""
put_replace = """                                final Uint8List imageBytes = await image.readAsBytes();
                                final snapshot = await storageRef.putData(imageBytes);"""
content = re.sub(put_target, put_replace, content)

with open('/Users/akshaya/sorah/lib/murobbi_home.dart', 'w') as f:
    f.write(content)
print("Updated murobbi_home.dart")
