import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart' as pdp;

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  final nameController = TextEditingController();
  final lastController = TextEditingController();
  final feeController = TextEditingController();
  final typeController = TextEditingController();
  final periodController = TextEditingController(text: "1");
  final debtorController = TextEditingController(text: "0");

  String dropdownValue = 'Month';
  DateTime? _selectedDate;
  static const Color trophyGold = Color(0xFFF59E0B);

  Future<void> _selectDate(BuildContext context) async {
    final pdp.Jalali? picked = await pdp.showPersianDatePicker(
      context: context,
      initialDate: pdp.Jalali.now(),
      firstDate: pdp.Jalali(1403, 1),
      lastDate: pdp.Jalali(1429),
    );
    if (picked != null) setState(() => _selectedDate = picked.toDateTime());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          _buildMeshBackground(isDark),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(isDark),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildSectionHeader("مشخصات فردی", Icons.sports_soccer, isDark),
                        _buildGlassCard(isDark, [
                          _buildTextField(nameController, "نام", Icons.person, isDark),
                          const SizedBox(height: 16),
                          _buildTextField(lastController, "تخلص", Icons.badge, isDark),
                        ]),
                        const SizedBox(height: 24),
                        _buildSectionHeader("جزئیات اشتراک", Icons.workspace_premium, isDark),
                        _buildGlassCard(isDark, [
                          _buildDropdownField(isDark),
                          const SizedBox(height: 16),
                          _buildTextField(feeController, "مبلغ (AFN)", Icons.payments, isDark, isNum: true),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildUnitDropdown(isDark)),
                              const SizedBox(width: 12),
                              Expanded(flex: 2, child: _buildTextField(periodController, "مدت", Icons.timer, isDark, isNum: true)),
                            ],
                          ),
                        ]),
                        const SizedBox(height: 24),
                        _buildSectionHeader("تاریخ و وضعیت مالی", Icons.account_balance_wallet, isDark),
                        _buildGlassCard(isDark, [
                          _buildTextField(debtorController, "قرض / باقیمانده", Icons.money_off, isDark, isNum: true),
                          const SizedBox(height: 16),
                          _buildDatePicker(isDark),
                        ]),
                        const SizedBox(height: 40),
                        _buildSubmitButton(isDark),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeshBackground(bool isDark) {
    return Positioned.fill(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
              ? [const Color(0xFF1E293B), const Color(0xFF020617), const Color(0xFF0F172A)]
              : [Colors.white, const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(bool isDark) {
    return SliverAppBar(
      // expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      elevation: 0,
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          "ثبت نام ورزشکار",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(title, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Icon(icon, color: Colors.blueAccent, size: 20),
        ],
      ),
    );
  }

  Widget _buildGlassCard(bool isDark, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: .8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool isDark, {bool isNum = false}) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.right,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black45),
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        filled: true,
        fillColor: isDark ? Colors.black26 : Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.blueAccent, width: 1)),
      ),
      validator: (v) => v!.isEmpty ? "الزامی" : null,
    );
  }

  Widget _buildDropdownField(bool isDark) {
    return DropdownButtonFormField<String>(
      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: "تایم تمرینی",
        prefixIcon: const Icon(Icons.fitness_center, color: Colors.blueAccent),
        filled: true,
        fillColor: isDark ? Colors.black26 : Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
      items: ['صبح', 'بعد از ظهر', 'VIP', 'نوجوانان'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
      onChanged: (val) => typeController.text = val!,
    );
  }

  Widget _buildUnitDropdown(bool isDark) {
    return DropdownButtonFormField<String>(
      value: dropdownValue,
      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark ? Colors.black26 : Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
      items: ['Month', 'Week'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
      onChanged: (v) => setState(() => dropdownValue = v!),
    );
  }

  Widget _buildDatePicker(bool isDark) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: isDark ? Colors.black26 : Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.calendar_today, color: Colors.blueAccent),
            Text(
              _selectedDate != null 
                  ? pdp.Jalali.fromDateTime(_selectedDate!).formatFullDate() 
                  : "تاریخ شروع قرارداد",
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isDark) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withValues(alpha: .3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveData,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isLoading 
            ? const CircularProgressIndicator(color: Colors.white) 
            : const Text("ثبت و تایید نهایی", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- Logic Layer ---
  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("لطفا تمامی فیلدها را پر کنید")));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final int period = int.parse(periodController.text);
      final int days = dropdownValue == 'Week' ? period * 7 : period * 30;
      final DateTime endDate = _selectedDate!.add(Duration(days: days));
      final int debt = int.tryParse(debtorController.text) ?? 0;

      final pdp.Jalali pStart = pdp.Jalali.fromDateTime(_selectedDate!);
      final pdp.Jalali pEnd = pdp.Jalali.fromDateTime(endDate);

      WriteBatch batch = FirebaseFirestore.instance.batch();
      DocumentReference playerRef = FirebaseFirestore.instance.collection('players').doc();

      batch.set(playerRef, {
        'Name': nameController.text,
        'Last Name': lastController.text,
        'Type': typeController.text,
        'Fee': feeController.text,
        'Debt': debt,
        'StartDate': {'y': pStart.year, 'm': pStart.month, 'd': pStart.day},
        'EndDate': {'y': pEnd.year, 'm': pEnd.month, 'd': pEnd.day},
        'Timestamp': FieldValue.serverTimestamp(),
      });

      if (debt > 0) {
        DocumentReference debtRef = FirebaseFirestore.instance.collection('Debtors').doc();
        batch.set(debtRef, {
          'Name': nameController.text,
          'Last Name': lastController.text,
          'Debt': debt,
          'PlayerID': playerRef.id,
        });
      }

      await batch.commit();
      _clearForm();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text("ثبت نام با موفقیت انجام شد")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("خطا: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    nameController.clear();
    lastController.clear();
    feeController.clear();
    debtorController.text = "0";
    setState(() => _selectedDate = null);
  }
}
