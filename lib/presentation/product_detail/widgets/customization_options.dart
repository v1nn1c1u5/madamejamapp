import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class CustomizationOptions extends StatefulWidget {
  final List<Map<String, dynamic>> options;
  final Function(Map<String, dynamic>) onCustomizationChanged;

  const CustomizationOptions({
    super.key,
    required this.options,
    required this.onCustomizationChanged,
  });

  @override
  State<CustomizationOptions> createState() => _CustomizationOptionsState();
}

class _CustomizationOptionsState extends State<CustomizationOptions> {
  final Map<String, dynamic> _selectedOptions = {};
  final Map<String, bool> _expandedSections = {};

  @override
  void initState() {
    super.initState();
    // Initialize expanded state for all sections
    for (var option in widget.options) {
      final String key = option['title'] as String? ?? '';
      _expandedSections[key] = false;
    }
  }

  void _updateSelection(String optionKey, dynamic value) {
    setState(() {
      _selectedOptions[optionKey] = value;
    });
    widget.onCustomizationChanged(_selectedOptions);
  }

  void _toggleSection(String key) {
    setState(() {
      _expandedSections[key] = !(_expandedSections[key] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.options.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Opções de Personalização',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          ...widget.options.map<Widget>((option) {
            final String title = option['title'] as String? ?? '';
            final bool isRequired = option['required'] as bool? ?? false;
            final bool isExpanded = _expandedSections[title] ?? false;

            return Container(
              margin: EdgeInsets.only(bottom: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(3.w),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.lightTheme.colorScheme.shadow,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  GestureDetector(
                    onTap: () => _toggleSection(title),
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  title,
                                  style: AppTheme
                                      .lightTheme.textTheme.titleSmall
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface,
                                  ),
                                ),
                                if (isRequired) ...[
                                  SizedBox(width: 1.w),
                                  Text(
                                    '*',
                                    style: AppTheme
                                        .lightTheme.textTheme.titleSmall
                                        ?.copyWith(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          CustomIconWidget(
                            iconName:
                                isExpanded ? 'expand_less' : 'expand_more',
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            size: 6.w,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Content
                  if (isExpanded) ...[
                    Divider(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                      height: 1,
                    ),
                    Container(
                      padding: EdgeInsets.all(4.w),
                      child: _buildOptionContent(option),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOptionContent(Map<String, dynamic> option) {
    final String type = option['type'] as String? ?? 'text';
    final String title = option['title'] as String? ?? '';

    switch (type) {
      case 'text':
        return _buildTextOption(title, option);
      case 'select':
        return _buildSelectOption(title, option);
      case 'checkbox':
        return _buildCheckboxOption(title, option);
      case 'radio':
        return _buildRadioOption(title, option);
      default:
        return _buildTextOption(title, option);
    }
  }

  Widget _buildTextOption(String key, Map<String, dynamic> option) {
    final String placeholder =
        option['placeholder'] as String? ?? 'Digite sua preferência...';

    return TextFormField(
      decoration: InputDecoration(
        hintText: placeholder,
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      ),
      onChanged: (value) => _updateSelection(key, value),
      maxLines: 3,
      minLines: 1,
    );
  }

  Widget _buildSelectOption(String key, Map<String, dynamic> option) {
    final List<dynamic> choices = option['choices'] as List<dynamic>? ?? [];
    final String currentValue = _selectedOptions[key] as String? ?? '';

    return Column(
      children: choices.map<Widget>((choice) {
        final String choiceValue = choice as String;
        final bool isSelected = currentValue == choiceValue;

        return GestureDetector(
          onTap: () => _updateSelection(key, choiceValue),
          child: Container(
            margin: EdgeInsets.only(bottom: 1.h),
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primaryContainer
                  : AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(2.w),
              border: Border.all(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: isSelected
                      ? 'radio_button_checked'
                      : 'radio_button_unchecked',
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    choiceValue,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.onPrimaryContainer
                          : AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCheckboxOption(String key, Map<String, dynamic> option) {
    final List<dynamic> choices = option['choices'] as List<dynamic>? ?? [];
    final List<String> currentValues =
        (_selectedOptions[key] as List<dynamic>?)?.cast<String>() ?? [];

    return Column(
      children: choices.map<Widget>((choice) {
        final String choiceValue = choice as String;
        final bool isSelected = currentValues.contains(choiceValue);

        return GestureDetector(
          onTap: () {
            List<String> newValues = List.from(currentValues);
            if (isSelected) {
              newValues.remove(choiceValue);
            } else {
              newValues.add(choiceValue);
            }
            _updateSelection(key, newValues);
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 1.h),
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(2.w),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName:
                      isSelected ? 'check_box' : 'check_box_outline_blank',
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    choiceValue,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRadioOption(String key, Map<String, dynamic> option) {
    return _buildSelectOption(key, option); // Same as select for single choice
  }
}
