import re

with open('/Users/akshaya/sorah/lib/murobbi_home.dart', 'r') as f:
    content = f.read()

# Fix imports
imports_target = r"""import 'package:flutter/material\.dart';
import 'package:cloud_firestore/cloud_firestore\.dart';
import 'package:flutter/services\.dart';
import 'dart:async';
import 'dart:math';"""

imports_replacement = """import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';"""
content = re.sub(imports_target, imports_replacement, content)

# Fix strings
content = content.replace("SnackBar(content: Text(isAs ? 'কাৰ্য্য সম্পূৰ্ণ হ\\'ল!' : 'Task Completed!', style: const TextStyle(fontSize: 20))))", "SnackBar(content: Text(isAs ? \"কাৰ্য্য সম্পূৰ্ণ হ'ল!\" : \"Task Completed!\", style: const TextStyle(fontSize: 20))))")

with open('/Users/akshaya/sorah/lib/murobbi_home.dart', 'w') as f:
    f.write(content)
print("Fixed Murobbi")
