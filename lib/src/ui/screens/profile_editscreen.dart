import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class ProfileEditscreen extends StatefulWidget {
  const ProfileEditscreen({super.key});

  @override
  State<ProfileEditscreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditscreen> {
  final TextEditingController _cityController = TextEditingController();

  String? _selectedGender;
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _phoneNumber = '';
  DateTime? _selectedDate;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  String? _fullName;

  // Хранение первоначальных данных для проверки не сохранённых изменений.
  String _initialCity = '';
  String _initialDob = '';

  String? _initialGender;
  String _initialPhone = '';
  String _initialFirstName = '';
  String _initialLastName = '';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Загружает данные пользователя из Firestore по UID.
  /// Если документ не найден (новый аккаунт), поля остаются пустыми.
  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final rawPhone = data['phone'] as String? ?? '';
        _phoneController.text = rawPhone;
        _phoneNumber = rawPhone;
        _initialPhone = rawPhone; // сравниваем без '+'

        setState(() {
          _cityController.text = data['city'] ?? '';
          _dobController.text = data['date_of_birth'] ?? '';
          _selectedGender = data['gender'];
          _phoneNumber = data['phone'] ?? '';
          User? user = FirebaseAuth.instance.currentUser;
          String displayName = user?.displayName ?? '';
          List<String> parts = displayName.split(' ');
          _firstNameController.text = parts.isNotEmpty ? parts[0] : '';
          _lastNameController.text =
              parts.length > 1 ? parts.sublist(1).join(' ') : '';
          // _phoneController.text = fullPhone;
          // _phoneNumber = fullPhone;
          _initialCity = _cityController.text.trim();
          _initialDob = _dobController.text.trim();
          _initialGender = _selectedGender;
          _initialFirstName = _firstNameController.text.trim();
          _initialLastName = _lastNameController.text.trim();

          _initialPhone = _phoneNumber.trim();
        });
      } else {
        setState(() {
          _cityController.text = '';
          _dobController.text = '';
          _selectedGender = null;
          _phoneNumber = '';
          _initialCity = '';
          _initialDob = '';
          _initialGender = null;
          _initialPhone = '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при загрузке данных пользователя: $e'),
        ),
      );
    }
  }

  /// Проверяет, изменены ли данные, которые ещё не сохранены.
  bool _hasUnsavedChanges() {
    return _cityController.text.trim() != _initialCity ||
        _dobController.text.trim() != _initialDob ||
        _selectedGender != _initialGender ||
        _phoneNumber.trim() != _initialPhone;
  }

  /// Выбор даты рождения через диалог выбора даты
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  /// Сохраняет профиль пользователя в Firestore

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Собираем новое имя
    final newDisplayName = '${_firstNameController.text.trim()} '
        '${_lastNameController.text.trim()}';

    try {
      // Обновляем displayName в Firebase Auth
      await user.updateDisplayName(newDisplayName);
      // final rawToSave = _phoneNumber.replaceAll('+', '');
        final rawToSave = _phoneNumber;
      // Сохраняем в Firestore
      final data = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'displayName': newDisplayName,
        'phone': rawToSave,
        'city': _cityController.text.trim(),
        'gender': _selectedGender,
        'date_of_birth': _dobController.text.trim(),
        'email': user.email,
      };
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(data, SetOptions(merge: true));

      // Обновляем «initial»-значения и показываем успех
      setState(() {
        _initialFirstName = _firstNameController.text.trim();
        _initialLastName = _lastNameController.text.trim();
        _initialPhone = _phoneNumber.trim();
        _initialCity = _cityController.text.trim();
        _initialDob = _dobController.text.trim();
        _initialGender = _selectedGender;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Профиль успешно обновлён")),
      );
    } catch (e) {
      // А вот сюда теперь «поймается» любая ошибка
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка при сохранении: $e")),
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges()) {
      bool? exit = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('Внимание'),
            content: const Text(
                'Данные не сохранены и будут утеряны. Вы действительно хотите выйти?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Остаться'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Выйти'),
              ),
            ],
          );
        },
      );
      return exit ?? false;
    }
    return true;
  }

  @override
  void dispose() {
    _cityController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  /// Виджет для оформления полей ввода с обёрткой
  Widget _buildInputField({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Профиль'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Аватар с синей рамкой
                  Container(
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blueAccent, width: 3.0),
                    ),
                    child: const CircleAvatar(
                      radius: 50.0,
                      backgroundImage: AssetImage('assets/images/profile.png'),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Имя и почта
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'Имя не установлено',
                        style: GoogleFonts.oswald(
                          textStyle: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? 'Почта не указана',
                        style: GoogleFonts.oswald(
                          textStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),

                  _buildInputField(
                    child: IntlPhoneField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Номер телефона',
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      initialCountryCode: 'RU',
                      initialValue: _phoneController.text, // ← здесь
                      onChanged: (phone) => _phoneNumber = phone.number,
                      onSaved: (phone) => _phoneNumber = phone?.number ?? '',
                      validator: (phone) =>
                          phone == null || phone.number.isEmpty
                              ? 'Введите номер телефона'
                              : null,
                    ),
                  ),
                  // Поле для Имени
                  _buildInputField(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          hintText: 'Имя',
                          border: InputBorder.none,
                        ),
                        validator: (v) =>
                            v!.trim().isEmpty ? 'Введите имя' : null,
                      ),
                    ),
                  ),
                  _buildInputField(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          hintText: 'Фамилия',
                          border: InputBorder.none,
                        ),
                        validator: (v) =>
                            v!.trim().isEmpty ? 'Введите фамилию' : null,
                      ),
                    ),
                  ),

                  // Поле для ввода города
                  _buildInputField(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          hintText: 'Город',
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Введите город';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  // Выпадающий список для выбора пола
                  _buildInputField(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          hintText: 'Пол',
                          border: InputBorder.none,
                        ),
                        value: _selectedGender,
                        items: const [
                          DropdownMenuItem(
                            value: 'male',
                            child: Text('Мужской'),
                          ),
                          DropdownMenuItem(
                            value: 'female',
                            child: Text('Женский'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Выберите пол';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  // Поле для выбора даты рождения
                  _buildInputField(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: TextFormField(
                        controller: _dobController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Дата рождения',
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(context),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Выберите дату рождения';
                          }
                          return null;
                        },
                        onTap: () => _selectDate(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  // Кнопка "Сохранить" в требуемом стиле
                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 35, vertical: 16),
                      child: Text(
                        'Сохранить',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
