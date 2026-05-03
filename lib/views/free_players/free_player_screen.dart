// ignore_for_file: use_build_context_synchronously
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart' as pdp;

class FreePlayer extends StatefulWidget {
  const FreePlayer({super.key});

  @override
  State<FreePlayer> createState() => _FreePlayerState();
}

class _FreePlayerState extends State<FreePlayer> {
  pdp.Jalali? _selectedDate;
  bool _isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastController = TextEditingController();

  Widget _glassWidget({required Widget child, double opacity = 0.08}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: opacity)
                : Colors.black.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("ثبت نام رایگان",
            style: TextStyle(
                fontWeight: FontWeight.w900, fontFamily: "TrajanPro")),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            _buildMeshBackground(isDark),
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                children: [
                  const SizedBox(height: 20),
                  _buildHeaderSection(),
                  const SizedBox(height: 30),

                  // Form Card
                  _glassWidget(
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        children: [
                          _buildTextField(nameController, "نام بازیکن",
                              Icons.person_add_alt_1_rounded, isDark),
                          const SizedBox(height: 18),
                          _buildTextField(lastController, "نام خانوادگی",
                              Icons.badge_rounded, isDark),
                          const SizedBox(height: 18),
                          _buildDateTile(isDark),
                          const SizedBox(height: 25),
                          _buildSubmitButton(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),
                  const Text("لیست بازیکنان اخیر",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent)),
                  const SizedBox(height: 15),

                  _buildRealTimeList(isDark),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blueAccent.withValues(alpha: 0.15),
            boxShadow: [
              BoxShadow(
                  color: Colors.blueAccent.withValues(alpha: 0.2),
                  blurRadius: 20)
            ],
          ),
          child: const Icon(Icons.sports_soccer_rounded,
              size: 60, color: Colors.blueAccent),
        ),
        const SizedBox(height: 12),
        const Text("ثبت نام جدید",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, bool isDark) {
    return TextField(
      controller: controller,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.blueAccent, fontSize: 14),
        suffixIcon: Icon(icon, color: Colors.blueAccent, size: 22),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
      ),
    );
  }

  Widget _buildDateTile(bool isDark) {
    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white24 : Colors.black12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded, color: Colors.blueAccent),
            const SizedBox(width: 12),
            Text(
              _selectedDate != null
                  ? _selectedDate!.formatFullDate()
                  : "انتخاب تاریخ عضویت",
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _isLoading ? null : createRecord,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 5,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("ذخیره اطلاعات بازیکن",
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
      ),
    );
  }

  Widget _buildRealTimeList(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Free_Player')
          .orderBy('CreatedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text("خطا در بارگذاری");
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            return Dismissible(
              key: Key(doc.id),
              direction: DismissDirection.startToEnd,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(22)),
                child: const Icon(Icons.delete_sweep_rounded,
                    color: Colors.white, size: 30),
              ),
              onDismissed: (direction) => doc.reference.delete(),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _glassWidget(
                  opacity: 0.04,
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    leading: const CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.person, color: Colors.white)),
                    title: Text("${doc['Name']} ${doc['Last Name']}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text("بازیکن فعال",
                        style:
                            TextStyle(color: Colors.blueAccent, fontSize: 12)),
                    trailing: const Icon(Icons.chevron_left_rounded,
                        color: Colors.blueAccent),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMeshBackground(bool isDark) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF020617)]
                : [Colors.white, const Color(0xFFF1F5F9)],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final pdp.Jalali? picked = await pdp.showPersianDatePicker(
      context: context,
      initialDate: pdp.Jalali.now(),
      firstDate: pdp.Jalali(1400, 1),
      lastDate: pdp.Jalali(1450, 12),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void createRecord() async {
    if (nameController.text.isEmpty || _selectedDate == null) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('Free_Player').add({
        'Name': nameController.text.trim(),
        'Last Name': lastController.text.trim(),
        'Date': [_selectedDate!.year, _selectedDate!.month, _selectedDate!.day],
        'CreatedAt': FieldValue.serverTimestamp(),
      });
      nameController.clear();
      lastController.clear();
      setState(() => _selectedDate = null);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("بازیکن با موفقیت افزوده شد")));
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
