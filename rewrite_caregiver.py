import re

with open('/Users/akshaya/sorah/lib/caregiver_dash.dart', 'r') as f:
    content = f.read()

# 1. Remove schedulesEn and schedulesAs
content = re.sub(
    r'List<String> schedulesEn = \[.*?\];\s*List<String> schedulesAs = \[.*?\];',
    '',
    content,
    flags=re.DOTALL
)

# Remove final schedules = ...
content = re.sub(
    r'final schedules = isAs \? schedulesAs : schedulesEn;\s*',
    '',
    content
)

# 2. Replace ListView.builder for schedules and add StreamBuilders
list_view_target = r"""            ListView\.builder\(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics\(\),
              itemCount: schedules\.length,
              itemBuilder: \(context, index\) \{
                return Padding\(
                  padding: const EdgeInsets\.only\(bottom: 12\.0\),
                  child: ListTile\(
                    tileColor: cardBgSage,
                    shape: RoundedRectangleBorder\(
                      borderRadius: BorderRadius\.circular\(12\),
                      side: BorderSide\(color: borderColor, width: 2\),
                    \),
                    title: Text\(schedules\[index\], style: TextStyle\(fontWeight: FontWeight\.bold, color: darkSage\)\),
                    trailing: Row\(
                      mainAxisSize: MainAxisSize\.min,
                      children: \[
                        Icon\(Icons\.edit, color: darkSage\),
                        const SizedBox\(width: 16\),
                        Icon\(Icons\.delete, color: Colors\.red\.shade700\),
                      \],
                    \),
                  \),
                \);
              \},
            \),"""

list_view_replacement = """            StreamBuilder<QuerySnapshot>(
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
            ),"""
content = re.sub(list_view_target, list_view_replacement, content)


# 3. Update GridView titles
grid_target = r"""                _buildActionTile\(btn1, Icons\.alarm_add, cardBgSage, borderColor, darkSage\),
                _buildActionTile\(btn2, Icons\.add_task, cardBgSage, borderColor, darkSage\),
                _buildActionTile\(btn3, Icons\.add_a_photo, cardBgSage, borderColor, darkSage\),
                _buildActionTile\(btn4, Icons\.settings, cardBgSage, borderColor, darkSage\),"""

grid_replacement = """                _buildActionTile(btn1, Icons.alarm_add, cardBgSage, borderColor, darkSage, onTap: () => _showAddReminderBottomSheet(context, isAs)),
                _buildActionTile(btn2, Icons.add_task, cardBgSage, borderColor, darkSage, onTap: () => _showAddCustomTaskBottomSheet(context, isAs)),
                _buildActionTile(btn3, Icons.add_a_photo, cardBgSage, borderColor, darkSage),
                _buildActionTile(btn4, Icons.settings, cardBgSage, borderColor, darkSage),"""
content = re.sub(grid_target, grid_replacement, content)


# 4. Update _buildActionTile signature
action_tile_target = r"""  Widget _buildActionTile\(String title, IconData icon, Color bgColor, Color borderCol, Color textColor\) \{
    return Container\(
      decoration: BoxDecoration\(
        color: bgColor,
        borderRadius: BorderRadius\.circular\(16\.0\),
        border: Border\.all\(color: borderCol, width: 4\.0\),
      \),
      child: InkWell\(
        onTap: \(\) \{\},"""

action_tile_replacement = """  Widget _buildActionTile(String title, IconData icon, Color bgColor, Color borderCol, Color textColor, {VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderCol, width: 4.0),
      ),
      child: InkWell(
        onTap: onTap ?? () {},"""
content = re.sub(action_tile_target, action_tile_replacement, content)


# 5. Replace _showAddReminderBottomSheet completely and append _showAddCustomTaskBottomSheet
bottom_sheet_target = r"""  void _showAddReminderBottomSheet\(BuildContext context, bool isAs\) \{.*"""
bottom_sheet_replacement = """  void _showAddReminderBottomSheet(BuildContext context, bool isAs, {String? docId, Map<String, dynamic>? existingData}) {
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
}
"""

content = re.sub(bottom_sheet_target, bottom_sheet_replacement, content, flags=re.DOTALL)

with open('/Users/akshaya/sorah/lib/caregiver_dash.dart', 'w') as f:
    f.write(content)

print("Caregiver Dash Rewritten!")
