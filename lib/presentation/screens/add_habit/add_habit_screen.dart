import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/habit_suggestions.dart';
import '../../../core/constants/bad_habit_configs.dart';
import '../../../core/constants/currencies.dart';
import '../../../core/utils/icon_suggestion_engine.dart';
import '../../../data/models/habit_model.dart';
import '../../../providers/habit_provider.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/glass_container.dart';

class AddHabitScreen extends StatefulWidget {
  final HabitModel? habitToEdit;

  const AddHabitScreen({super.key, this.habitToEdit});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _moneySavedController = TextEditingController();

  int _selectedIconIndex = 0;
  int _selectedColorIndex = 0;
  String _selectedCategory = AppConstants.habitCategories[0];
  List<int> _selectedDays = [0, 1, 2, 3, 4]; // Mon-Fri by default
  int _targetDaysPerWeek = 5;
  TimeOfDay? _reminderTime;
  bool _isLoading = false;
  late FocusNode _nameFocusNode;
  bool _isQuitHabit = false;
  BadHabitConfig? _selectedBadHabitConfig;
  Map<String, dynamic> _badHabitValues = {};
  String _currencySymbol = '\$';

  bool get isEditing => widget.habitToEdit != null;

  @override
  void initState() {
    super.initState();
    _nameFocusNode = FocusNode();
    _loadCurrency();
    if (isEditing) {
      _nameController.text = widget.habitToEdit!.name;
      _descriptionController.text = widget.habitToEdit!.description ?? '';
      _selectedIconIndex = widget.habitToEdit!.iconIndex;
      _selectedColorIndex = widget.habitToEdit!.colorIndex;
      _selectedCategory = widget.habitToEdit!.category;
      _selectedDays = List.from(widget.habitToEdit!.scheduledDays);
      _targetDaysPerWeek = widget.habitToEdit!.targetDaysPerWeek;
      _isQuitHabit = widget.habitToEdit!.isQuitHabit;
      if (widget.habitToEdit!.moneySavedPerDay != null) {
        _moneySavedController.text = widget.habitToEdit!.moneySavedPerDay.toString();
      }
      if (widget.habitToEdit!.reminderTime != null) {
        final parts = widget.habitToEdit!.reminderTime!.split(':');
        _reminderTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    }
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final currencyCode = prefs.getString('selected_currency') ?? 'USD';
    final currency = Currencies.getByCode(currencyCode);
    setState(() {
      _currencySymbol = currency.symbol;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _moneySavedController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final habitProvider = context.read<HabitProvider>();
    final reminderTimeStr = _reminderTime != null
        ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
        : null;

    // Calculate money saved based on bad habit config or use manual input
    double? moneySaved;
    if (_isQuitHabit && _selectedBadHabitConfig != null) {
      moneySaved = _selectedBadHabitConfig!.calculate(_badHabitValues);
    } else if (_moneySavedController.text.trim().isNotEmpty) {
      moneySaved = double.tryParse(_moneySavedController.text.trim());
    }

    if (isEditing) {
      final updatedHabit = widget.habitToEdit!.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        iconIndex: _selectedIconIndex,
        colorIndex: _selectedColorIndex,
        category: _selectedCategory,
        scheduledDays: _selectedDays,
        targetDaysPerWeek: _targetDaysPerWeek,
        reminderTime: reminderTimeStr,
        isQuitHabit: _isQuitHabit,
        moneySavedPerDay: moneySaved,
      );
      await habitProvider.updateHabit(updatedHabit);
    } else {
      await habitProvider.addHabit(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        iconIndex: _selectedIconIndex,
        colorIndex: _selectedColorIndex,
        category: _selectedCategory,
        scheduledDays: _selectedDays,
        targetDaysPerWeek: _targetDaysPerWeek,
        reminderTime: reminderTimeStr,
        isQuitHabit: _isQuitHabit,
        quitStartDate: _isQuitHabit ? DateTime.now() : null,
        moneySavedPerDay: moneySaved,
      );
    }

    setState(() => _isLoading = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Habit' : 'New Habit'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Build vs Quit toggle
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                child: _buildHabitTypeToggle(),
              ),
              const SizedBox(height: 20),
              // Name input with autocomplete
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: const Duration(milliseconds: 100),
                child: _buildHabitNameField(),
              ),
              const SizedBox(height: 20),
              // Description input
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: const Duration(milliseconds: 200),
                child: _buildTextField(
                  controller: _descriptionController,
                  label: 'Description (optional)',
                  hint: 'Add a description...',
                  maxLines: 2,
                ),
              ),
              const SizedBox(height: 20),
              // Smart bad habit fields (based on config)
              if (_isQuitHabit && _selectedBadHabitConfig != null)
                ..._buildBadHabitFields(),
              // Money saved field (only for quit habits without smart config)
              if (_isQuitHabit && _selectedBadHabitConfig == null)
                FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 250),
                  child: _buildTextField(
                    controller: _moneySavedController,
                    label: 'Money Saved Per Day (optional)',
                    hint: 'e.g., 10.00',
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final parsed = double.tryParse(value);
                        if (parsed == null || parsed < 0) {
                          return 'Please enter a valid positive number';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              if (_isQuitHabit) const SizedBox(height: 20),
              // Icon picker
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: Duration(milliseconds: _isQuitHabit ? 300 : 250),
                child: _buildIconPicker(),
              ),
              const SizedBox(height: 24),
              // Color picker
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: Duration(milliseconds: _isQuitHabit ? 350 : 300),
                child: _buildColorPicker(),
              ),
              const SizedBox(height: 24),
              // Category picker
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: Duration(milliseconds: _isQuitHabit ? 400 : 350),
                child: _buildCategoryPicker(),
              ),
              const SizedBox(height: 24),
              // Day selector
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: Duration(milliseconds: _isQuitHabit ? 450 : 400),
                child: _buildDaySelector(),
              ),
              const SizedBox(height: 24),
              // Target days slider
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: Duration(milliseconds: _isQuitHabit ? 500 : 450),
                child: _buildTargetSlider(),
              ),
              const SizedBox(height: 24),
              // Reminder time
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: Duration(milliseconds: _isQuitHabit ? 550 : 500),
                child: _buildReminderPicker(),
              ),
              const SizedBox(height: 32),
              // Save button
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: Duration(milliseconds: _isQuitHabit ? 600 : 550),
                child: GradientButton(
                  text: isEditing ? 'Save Changes' : 'Create Habit',
                  onPressed: _saveHabit,
                  isLoading: _isLoading,
                  width: double.infinity,
                  gradient: AppColors.habitGradients[_selectedColorIndex],
                  icon: isEditing ? Icons.save : Icons.add,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHabitNameField() {
    // Filter suggestions based on habit type
    final suggestions = _isQuitHabit
        ? HabitSuggestions.badHabits.map((h) => h.toMap()).toList()
        : HabitSuggestions.goodHabits.map((h) => h.toMap()).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Habit Name',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        RawAutocomplete<Map<String, dynamic>>(
          textEditingController: _nameController,
          focusNode: _nameFocusNode,
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<Map<String, dynamic>>.empty();
            }
            return suggestions.where((habit) {
              return (habit['name'] as String)
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          displayStringForOption: (Map<String, dynamic> option) =>
              option['name'] as String,
          onSelected: (Map<String, dynamic> selection) {
            _nameController.text = selection['name'] as String;
            // Auto-populate category
            if (selection['category'] != null) {
              setState(() {
                _selectedCategory = selection['category'] as String;
              });
            }
            // Check if this is a bad habit with a smart config
            if (_isQuitHabit && selection['configType'] != null) {
              final configType = selection['configType'] as String;
              setState(() {
                _selectedBadHabitConfig = BadHabitConfigs.configs[configType];
                _badHabitValues = {};
              });
            } else {
              setState(() {
                _selectedBadHabitConfig = null;
                _badHabitValues = {};
              });
            }
          },
          fieldViewBuilder: (BuildContext context,
              TextEditingController textEditingController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted) {
            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a habit name';
                }
                return null;
              },
              onChanged: (value) {
                // Auto-suggest categories based on name
                final suggestedCategories = HabitSuggestions.suggestCategories(value);
                if (suggestedCategories.isNotEmpty && 
                    AppConstants.habitCategories.contains(suggestedCategories.first)) {
                  setState(() {
                    _selectedCategory = suggestedCategories.first;
                  });
                }
                
                // Smart icon suggestion based on habit name
                if (value.isNotEmpty) {
                  final suggestions = IconSuggestionEngine.getIconIndices(value, count: 1);
                  if (suggestions.isNotEmpty) {
                    setState(() {
                      _selectedIconIndex = suggestions.first;
                    });
                  }
                }
                
                // Try to detect bad habit config
                if (_isQuitHabit) {
                  final config = BadHabitConfigs.getConfig(value);
                  if (config != null) {
                    setState(() {
                      _selectedBadHabitConfig = config;
                      _badHabitValues = {};
                    });
                  }
                }
              },
              decoration: InputDecoration(
                hintText: _isQuitHabit
                    ? 'e.g., Smoking, Social Media'
                    : 'e.g., Morning Exercise',
              ),
            );
          },
          optionsViewBuilder: (BuildContext context,
              AutocompleteOnSelected<Map<String, dynamic>> onSelected,
              Iterable<Map<String, dynamic>> options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200, maxWidth: 300),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final option = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(option),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withAlpha(25),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                option['icon'] as IconData,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      option['name'] as String,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${option['category']} ${_isQuitHabit ? '(Quit)' : '(Build)'}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withAlpha(153),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
          ),
        ),
      ],
    );
  }

  Widget _buildIconPicker() {
    // Get smart icon suggestions for current habit name
    final suggestions = _nameController.text.isNotEmpty
        ? IconSuggestionEngine.getTopSuggestions(_nameController.text)
        : <MapEntry<int, double>>[];
    
    // Show suggested icons first, then fill with common icons up to 24
    final suggestedIndices = suggestions.map((s) => s.key).toSet();
    final displayedIcons = <int>[...suggestedIndices];
    
    // Add common icons if we have less than 24
    for (int i = 0; i < AppConstants.habitIcons.length && displayedIcons.length < 24; i++) {
      if (!displayedIcons.contains(i)) {
        displayedIcons.add(i);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Icon',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (suggestions.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'AI Suggested',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Icon grid
        GlassContainer(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: displayedIcons.length,
                itemBuilder: (context, index) {
                  final iconIndex = displayedIcons[index];
                  final isSelected = iconIndex == _selectedIconIndex;
                  final isSuggested = suggestedIndices.contains(iconIndex);
                  
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIconIndex = iconIndex),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? AppColors.habitGradients[_selectedColorIndex]
                            : isSuggested
                                ? LinearGradient(
                                    colors: [
                                      AppColors.primaryPurple.withOpacity(0.3),
                                      AppColors.secondaryPink.withOpacity(0.3),
                                    ],
                                  )
                                : null,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 2)
                            : Border.all(
                                color: isSuggested
                                    ? AppColors.primaryPurple.withOpacity(0.5)
                                    : Theme.of(context).colorScheme.onSurface.withAlpha(25),
                                width: 1,
                              ),
                      ),
                      child: Icon(
                        AppConstants.habitIcons[iconIndex],
                        size: 26,
                        color: isSelected
                            ? Colors.white
                            : isSuggested
                                ? AppColors.primaryPurple
                                : Theme.of(context).colorScheme.onSurface.withAlpha(153),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              // Show all icons button
              TextButton.icon(
                onPressed: () => _showAllIconsPicker(),
                icon: const Icon(Icons.grid_view, size: 18),
                label: const Text('Browse All Icons'),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  void _showAllIconsPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                'All Icons',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: AppConstants.habitIcons.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedIconIndex;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedIconIndex = index);
                        Navigator.pop(context);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? AppColors.habitGradients[_selectedColorIndex]
                              : null,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 2)
                              : Border.all(
                                  color: Theme.of(context).colorScheme.onSurface.withAlpha(25),
                                ),
                        ),
                        child: Icon(
                          AppConstants.habitIcons[index],
                          size: 24,
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface.withAlpha(153),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: AppColors.habitGradients.length,
            itemBuilder: (context, index) {
              final isSelected = index == _selectedColorIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedColorIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    gradient: AppColors.habitGradients[index],
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.habitGradients[index].colors.first
                                  .withAlpha(102),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.habitCategories.map((category) {
            final isSelected = category == _selectedCategory;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? AppColors.habitGradients[_selectedColorIndex]
                      : null,
                  color: isSelected
                      ? null
                      : Theme.of(context).colorScheme.onSurface.withAlpha(13),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Schedule',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final isSelected = _selectedDays.contains(index);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedDays.remove(index);
                  } else {
                    _selectedDays.add(index);
                  }
                  _selectedDays.sort();
                  _targetDaysPerWeek = _selectedDays.length;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? AppColors.habitGradients[_selectedColorIndex]
                      : null,
                  color: isSelected
                      ? null
                      : Theme.of(context).colorScheme.onSurface.withAlpha(13),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    AppConstants.daysOfWeek[index][0],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTargetSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Target Days per Week',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppColors.habitGradients[_selectedColorIndex],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_targetDaysPerWeek days',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.habitGradients[_selectedColorIndex].colors.first,
            thumbColor: AppColors.habitGradients[_selectedColorIndex].colors.first,
          ),
          child: Slider(
            value: _targetDaysPerWeek.toDouble(),
            min: 1,
            max: 7,
            divisions: 6,
            onChanged: (value) {
              setState(() => _targetDaysPerWeek = value.toInt());
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReminderPicker() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      onTap: () => _selectReminderTime(),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.habitGradients[_selectedColorIndex],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.notifications, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reminder',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _reminderTime != null
                      ? _reminderTime!.format(context)
                      : 'No reminder set',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                  ),
                ),
              ],
            ),
          ),
          if (_reminderTime != null)
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () => setState(() => _reminderTime = null),
            ),
        ],
      ),
    );
  }

  Future<void> _selectReminderTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _reminderTime = time);
    }
  }

  Widget _buildHabitTypeToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Habit Type',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isQuitHabit = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: !_isQuitHabit ? AppColors.greenCyanGradient : null,
                    color: _isQuitHabit
                        ? Theme.of(context).colorScheme.onSurface.withAlpha(13)
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    border: !_isQuitHabit
                        ? null
                        : Border.all(
                            color: Theme.of(context).colorScheme.onSurface.withAlpha(25),
                          ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: !_isQuitHabit
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface.withAlpha(153),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Build Habit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: !_isQuitHabit ? FontWeight.bold : FontWeight.normal,
                          color: !_isQuitHabit
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isQuitHabit = true),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: _isQuitHabit ? AppColors.errorGradient : null,
                    color: !_isQuitHabit
                        ? Theme.of(context).colorScheme.onSurface.withAlpha(13)
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    border: _isQuitHabit
                        ? null
                        : Border.all(
                            color: Theme.of(context).colorScheme.onSurface.withAlpha(25),
                          ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.block,
                        color: _isQuitHabit
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface.withAlpha(153),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Quit Habit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: _isQuitHabit ? FontWeight.bold : FontWeight.normal,
                          color: _isQuitHabit
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildBadHabitFields() {
    if (_selectedBadHabitConfig == null) return [];

    final fields = <Widget>[];
    int delay = 250;

    for (var field in _selectedBadHabitConfig!.fields) {
      delay += 50;
      
      if (field.type == BadHabitFieldType.dropdown) {
        fields.add(
          FadeInUp(
            duration: const Duration(milliseconds: 400),
            delay: Duration(milliseconds: delay),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _badHabitValues[field.key] as String?,
                  items: field.options!.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _badHabitValues[field.key] = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: field.hint,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      } else {
        fields.add(
          FadeInUp(
            duration: const Duration(milliseconds: 400),
            delay: Duration(milliseconds: delay),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _badHabitValues[field.key]?.toString() ?? '',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    setState(() {
                      _badHabitValues[field.key] = parsed ?? 0.0;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: field.hint,
                    prefixText: field.type == BadHabitFieldType.money ? _currencySymbol : null,
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final parsed = double.tryParse(value);
                      if (parsed == null || parsed < 0) {
                        return 'Please enter a valid positive number';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }
    }

    return fields;
  }
}
