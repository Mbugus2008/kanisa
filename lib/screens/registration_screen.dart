import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kanisa/controllers/dimension_controller.dart';
import 'package:kanisa/controllers/registration_controller.dart';
import 'package:kanisa/models/account_model.dart';
import 'package:kanisa/models/dimensions.dart';

class RegistrationScreen extends StatelessWidget {
  final Customer? customer;

  final RegistrationController controller;

  final bool _ownsController;

  RegistrationScreen(
      {super.key, this.customer, RegistrationController? providedController})
      : controller = providedController ??
            RegistrationController(initialCustomer: customer),
        _ownsController = providedController == null {
    if (_ownsController) {
      Get.put(controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(_resolveTitle())),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          Obx(() => controller.canCreateDescendantObs.value
              ? IconButton(
                  tooltip: 'Add Child',
                  icon: const Icon(Icons.child_care),
                  onPressed: () =>
                      _handleAddDescendant(context, customerRole.child),
                )
              : const SizedBox.shrink()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          Customer? result = await controller.submitForm();

          debugPrint('=== Submit Result ===');
          debugPrint('result: $result');
          debugPrint('result?.No: ${result?.No}');
          debugPrint('result?.Name: ${result?.Name}');

          if (result != null) {
            // Update controller with registered customer data
            controller.updateAfterRegistration(result);

            debugPrint('After updateAfterRegistration:');
            debugPrint(
                'controller.canCreateDescendant: ${controller.canCreateDescendant}');
            debugPrint(
                'controller.relationship.value: ${controller.relationship.value}');
            debugPrint('=== END Submit Result ===');

            // Show success dialog with options
            await Get.dialog(
              AlertDialog(
                title: const Text('Registration Successful'),
                content:
                    Text('${result.Name} has been registered successfully.'),
                actions: [
                  if (controller.canCreateDescendant &&
                      controller.relationship.value == customerRole.primary)
                    TextButton(
                      onPressed: () {
                        Get.back(); // Close dialog
                        _handleAddDescendant(context, customerRole.child);
                      },
                      child: const Text('Add Child'),
                    ),
                  TextButton(
                    onPressed: () {
                      Get.back(); // Close dialog
                      Get.back(result: result); // Return to previous screen
                    },
                    child: const Text('Done'),
                  ),
                ],
              ),
              barrierDismissible: false,
            );
          }
        },
        label: Text('Submit'),
        icon: Icon(Icons.check),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Show relationship banner for spouse/child
            Obx(() {
              final role = controller.relationship.value;
              if (role == customerRole.spouse || role == customerRole.child) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: role == customerRole.spouse
                        ? Colors.pink.shade50
                        : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: role == customerRole.spouse
                          ? Colors.pink.shade200
                          : Colors.blue.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        role == customerRole.spouse
                            ? Icons.favorite
                            : Icons.child_care,
                        color: role == customerRole.spouse
                            ? Colors.pink
                            : Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          role == customerRole.spouse
                              ? 'Adding spouse to household'
                              : 'Adding child to household',
                          style: TextStyle(
                            color: role == customerRole.spouse
                                ? Colors.pink.shade700
                                : Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            _buildTextField(context, 'Name', Icons.person_outline,
                controller.nameController,
                required: true),

            _buildTextField(context, 'Phone Number', Icons.phone,
                controller.phoneController,
                required: true),

            _buildGenderSelector(context, 'Gender', Icons.person,
                required: true),

            _buildTextField(
                context, 'Email', Icons.email, controller.emailController),

            // Hide occupation for children
            Obx(() => controller.relationship.value != customerRole.child
                ? _buildTextField(context, 'Occupation', Icons.work_outline,
                    controller.occupationController)
                : const SizedBox.shrink()),

            _buildDatePicker(context, 'Date of Birth', Icons.calendar_today,
                controller.dateOfBirthController,
                required: true),

            _buildDropdown(
                context,
                'Select District',
                Get.find<DimensionController>().districtDimensions,
                Get.find<DimensionController>().selectedDistrictDimension),

            _buildGroupSelector(context),

            _buildCheckbox(context, 'Are you baptized?',
                Icons.water_drop_outlined, controller.isBaptized),

            Obx(() => controller.isBaptized.value
                ? Column(
                    children: [
                      _buildDatePicker(
                          context,
                          'Baptism Date',
                          Icons.calendar_today,
                          controller.baptismDateController),
                      _buildTextField(
                          context,
                          'Baptized By',
                          Icons.person_outline,
                          controller.baptizedByController),
                    ],
                  )
                : SizedBox.shrink()),

            _buildConfirmationSelector(context, ' Are you confirmed?',
                Icons.check_circle_outline, controller.isConfirmed,
                required: true),

            Obx(() => controller.isConfirmed.value == true
                ? _buildDatePicker(
                    context,
                    'Confirmation Date',
                    Icons.calendar_today,
                    controller.confirmationDateController,
                    required: true,
                  )
                : const SizedBox.shrink()),

            _buildTextField(context, 'Other Information', Icons.info_outline,
                controller.otherInformationController),

            SizedBox(
                height:
                    60), // Extra space at the bottom for the floating action button
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, String label, IconData icon,
      TextEditingController controller,
      {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, child) {
          final bool isEmpty = value.text.isEmpty;

          final Color borderColor =
              isEmpty && required ? Colors.red.shade300 : Colors.green.shade300;

          final Color iconColor =
              isEmpty && required ? Colors.red : Colors.green;

          final Color labelColor =
              isEmpty && required ? Colors.red.shade800 : Colors.green.shade800;

          return TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: labelColor),
              prefixIcon: Icon(icon, color: iconColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: borderColor, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: borderColor, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: borderColor, width: 2.0),
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
            onChanged: (text) {
              // This is just to trigger a rebuild when text changes
            },
          );
        },
      ),
    );
  }

  Widget _buildConfirmationSelector(
      BuildContext context, String label, IconData icon, RxnBool value,
      {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Obx(() {
        final bool? selection = value.value;

        final bool isYes = selection == true;

        final bool isNo = selection == false;

        final bool hasSelection = selection != null;

        final bool showError = required && !hasSelection;

        final Color iconColor = showError
            ? Colors.red
            : isYes
                ? Colors.green
                : isNo
                    ? Colors.orange
                    : Colors.grey;

        final Color labelColor = showError
            ? Colors.red.shade800
            : isYes
                ? Colors.green.shade800
                : isNo
                    ? Colors.orange.shade800
                    : Colors.grey.shade800;

        final Color borderColor = showError
            ? Colors.red.shade300
            : hasSelection
                ? iconColor.withOpacity(0.5)
                : Colors.grey.shade400;

        final Color buttonFillColor = showError
            ? Colors.red.shade200
            : iconColor.withOpacity(hasSelection ? 0.2 : 0.1);

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 1.5),
            color: Colors.grey[200],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: labelColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ToggleButtons(
                isSelected: [isYes, isNo],
                onPressed: (index) {
                  if (index == 0) {
                    value.value = isYes ? null : true;
                  } else {
                    value.value = isNo ? null : false;
                  }

                  if (value.value != true) {
                    controller.confirmationDateController.clear();
                  }
                },
                borderRadius: BorderRadius.circular(8),
                color: Colors.black87,
                selectedColor: Colors.white,
                fillColor: buttonFillColor,
                borderColor: borderColor,
                selectedBorderColor: iconColor,
                constraints: const BoxConstraints(minHeight: 36, minWidth: 64),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text('Yes'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text('No'),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCheckbox(
      BuildContext context, String label, IconData icon, RxBool value,
      {bool required = false}) {
    final bool isEmpty = value.value;

    final Color borderColor =
        isEmpty && required ? Colors.red.shade300 : Colors.green.shade300;

    final Color iconColor = isEmpty && required ? Colors.red : Colors.green;

    final Color labelColor =
        isEmpty && required ? Colors.red.shade800 : Colors.green.shade800;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Obx(() => Container(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: 1.5),
              color: Colors.grey[200],
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: labelColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Checkbox(
                  value: value.value,
                  onChanged: (newValue) {
                    value.value = newValue ?? false;
                  },
                  activeColor: Colors.green,
                  checkColor: Colors.white,
                ),
              ],
            ),
          )),
    );
  }

  Widget _buildDatePicker(BuildContext context, String label, IconData icon,
      TextEditingController controller,
      {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, child) {
          final bool isEmpty = value.text.isEmpty;

          final Color borderColor =
              isEmpty && required ? Colors.red.shade300 : Colors.green.shade300;

          final Color iconColor =
              isEmpty && required ? Colors.red : Colors.green;

          final Color labelColor =
              isEmpty && required ? Colors.red.shade800 : Colors.green.shade800;

          return TextField(
            controller: controller,

            readOnly: true, // Prevents keyboard from appearing

            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: labelColor),
              prefixIcon: Icon(icon, color: iconColor),
              suffixIcon: IconButton(
                icon: Icon(Icons.calendar_month, color: iconColor),
                onPressed: () async {
                  DateTime initialDate;

                  try {
                    if (controller.text.isNotEmpty) {
                      initialDate =
                          DateFormat('dd-MMM-yyyy').parse(controller.text);

                      if (initialDate.isBefore(DateTime(1900))) {
                        initialDate = DateTime.now();
                      }
                    } else {
                      initialDate = DateTime.now();
                    }
                  } catch (e) {
                    // In case of bad format

                    initialDate = DateTime.now();
                  }

                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: initialDate,
                    firstDate: DateTime(1900),
                    lastDate: initialDate.isAfter(DateTime.now())
                        ? initialDate
                        : DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Theme.of(context).primaryColor,
                            onPrimary: Colors.white,
                            onSurface: Colors.black,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (pickedDate != null) {
                    // Format the date as YYYY-MM-DD

                    String formattedDate =
                        DateFormat('dd-MMM-yyyy').format(pickedDate);

                    controller.text = formattedDate;
                  }
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: borderColor, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: borderColor, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: borderColor, width: 2.0),
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),

            onTap: () async {
              // Show date picker when the field is tapped

              DateTime initialDate;

              try {
                if (controller.text.isNotEmpty) {
                  initialDate =
                      DateFormat('dd-MMM-yyyy').parse(controller.text);

                  if (initialDate.isBefore(DateTime(1900))) {
                    initialDate = DateTime.now();
                  }
                } else {
                  initialDate = DateTime.now();
                }
              } catch (e) {
                // In case of bad format

                initialDate = DateTime.now();
              }

              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: initialDate,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Theme.of(context).primaryColor,
                        onPrimary: Colors.white,
                        onSurface: Colors.black,
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (pickedDate != null) {
                // Format the date as YYYY-MM-DD

                String formattedDate =
                    DateFormat('dd-MMM-yyyy').format(pickedDate);

                controller.text = formattedDate;
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildGenderSelector(BuildContext context, String label, IconData icon,
      {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Obx(() {
        final bool isEmpty = controller.selectedGender.value == null;

        final Color borderColor =
            isEmpty && required ? Colors.red.shade300 : Colors.green.shade300;

        final Color iconColor = isEmpty && required ? Colors.red : Colors.green;

        final Color labelColor =
            isEmpty && required ? Colors.red.shade800 : Colors.green.shade800;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 1.5),
            color: Colors.grey[200],
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: labelColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: RadioListTile<gender>(
                        title: const Text('Male'),
                        value: gender.Male,
                        groupValue: controller.selectedGender.value,
                        onChanged: (gender? value) {
                          controller.selectedGender.value = value;
                        },
                        activeColor: Colors.green,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<gender>(
                        title: const Text('Female'),
                        value: gender.Female,
                        groupValue: controller.selectedGender.value,
                        onChanged: (gender? value) {
                          controller.selectedGender.value = value;
                        },
                        activeColor: Colors.green,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildGroupSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Obx(() {
        final selectedGroups =
            Get.find<DimensionController>().selectedGroupDimensions;

        final bool isEmpty = selectedGroups.isEmpty;

        final Color borderColor =
            isEmpty ? Colors.red.shade300 : Colors.green.shade300;

        final Color iconColor = isEmpty ? Colors.red : Colors.green;

        final Color textColor =
            isEmpty ? Colors.red.shade800 : Colors.green.shade800;

        return InkWell(
          onTap: () => _showGroupSelectionDialog(context),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: 1.5),
              color: Colors.grey[200],
            ),
            child: Row(
              children: [
                Icon(Icons.group, color: iconColor),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Groups',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (selectedGroups.isNotEmpty) ...[
                        SizedBox(height: 4),
                        Text(
                          '${selectedGroups.length} Groups: ${selectedGroups.map((group) => _formatGroupName(group.Name)).join(', ')}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: iconColor, size: 16),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Use the formatGroupName method from the controller

  String _formatGroupName(String name) {
    return controller.formatGroupName(name);
  }

  void _showGroupSelectionDialog(BuildContext context) {
    final dimensions = Get.find<DimensionController>().groupDimensions;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Your Groups',
            style: TextStyle(color: Theme.of(context).primaryColor)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('You can select multiple groups',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700])),
              SizedBox(height: 16),
              Container(
                constraints: BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  child: Obx(() => Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: dimensions.map((dimension) {
                          bool isSelected = Get.find<DimensionController>()
                              .selectedGroupDimensions
                              .contains(dimension);

                          return FilterChip(
                            label: Text(_formatGroupName(dimension.Name)),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                Get.find<DimensionController>()
                                    .selectedGroupDimensions
                                    .add(dimension);

                                // Update the single selection for backward compatibility

                                if (Get.find<DimensionController>()
                                        .selectedGroupDimensions
                                        .length ==
                                    1) {
                                  Get.find<DimensionController>()
                                      .selectedGroupDimension
                                      .value = dimension;
                                }
                              } else {
                                Get.find<DimensionController>()
                                    .selectedGroupDimensions
                                    .remove(dimension);

                                // Update the single selection for backward compatibility

                                if (Get.find<DimensionController>()
                                        .selectedGroupDimension
                                        .value ==
                                    dimension) {
                                  Get.find<DimensionController>()
                                      .selectedGroupDimension
                                      .value = Get.find<DimensionController>()
                                          .selectedGroupDimensions
                                          .isNotEmpty
                                      ? Get.find<DimensionController>()
                                          .selectedGroupDimensions
                                          .first
                                      : null;
                                }
                              }
                            },
                            backgroundColor: Colors.grey[200],
                            selectedColor: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.3),
                            checkmarkColor:
                                Theme.of(context).colorScheme.secondary,
                          );
                        }).toList(),
                      )),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Done',
                style: TextStyle(color: Theme.of(context).primaryColor)),
          ),
        ],
      ),
    );
  }

  String _resolveTitle() {
    final role = controller.relationship.value;

    switch (role) {
      case customerRole.primary:
        return customer == null ? 'Register' : 'Edit Profile';

      case customerRole.spouse:
        return (customer?.Name?.isNotEmpty ??
                controller.nameController.text.isNotEmpty)
            ? 'Edit Spouse'
            : 'Add Spouse';

      case customerRole.child:
      default:
        return (customer?.Name?.isNotEmpty ??
                controller.nameController.text.isNotEmpty)
            ? 'Edit Child'
            : 'Add Child';
    }
  }

  Future<void> _handleAddDescendant(
      BuildContext context, customerRole role) async {
    final anchor = controller.householdAnchor;

    if (anchor == null || anchor.isEmpty) {
      Get.snackbar(
        'Link Required',
        'Save the main account before adding descendants.',
        backgroundColor: Colors.orangeAccent,
      );
      return;
    }

    controller.assignHouseholdPrimary(anchor);

    final draft = controller.buildDescendantDraft(role);

    if (draft.Household_Primary_No == null ||
        draft.Household_Primary_No!.isEmpty) {
      Get.snackbar(
        'Missing Household',
        'Unable to determine the household reference for the descendant.',
        backgroundColor: Colors.red,
      );
      return;
    }

    final newController = RegistrationController(initialCustomer: draft);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistrationScreen(
          customer: draft,
          providedController: newController,
        ),
      ),
    );
  }

  Widget _buildDropdown(BuildContext context, String hint,
      RxList<Dimension> dimensions, Rx<Dimension?> selectedDimension) {
    return Obx(() {
      final bool isEmpty = selectedDimension.value == null;

      final Color borderColor =
          isEmpty ? Colors.red.shade300 : Colors.green.shade300;

      final Color iconColor = isEmpty ? Colors.red : Colors.green;

      final Color labelColor =
          isEmpty ? Colors.red.shade800 : Colors.green.shade800;

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 2),
          color: Colors.white,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Dimension>(
            isExpanded: true,
            hint: Text(hint,
                style: TextStyle(color: Theme.of(context).primaryColor)),
            value: selectedDimension.value,
            icon: Icon(Icons.arrow_drop_down, color: iconColor),
            onChanged: (newValue) {
              selectedDimension.value = newValue;
            },
            items: dimensions.map((dimension) {
              return DropdownMenuItem<Dimension>(
                value: dimension,
                child:
                    Text(dimension.Name, style: TextStyle(color: labelColor)),
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  // Widget _buildDropdown(BuildContext context, String hint, RxList<Dimension> dimensions, Rx<Dimension?> selectedDimension) {

  //   return Container(

  //     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),

  //     decoration: BoxDecoration(

  //       borderRadius: BorderRadius.circular(10),

  //       border: Border.all(color: Theme.of(context).colorScheme.secondary, width: 2),

  //       color: Colors.white,

  //     ),

  //     child: DropdownButtonHideUnderline(

  //       child: DropdownButton<Dimension>(

  //         isExpanded: true,

  //         hint: Text(hint, style: TextStyle(color: Theme.of(context).primaryColor)),

  //         value: selectedDimension.value,

  //         icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).primaryColor),

  //         onChanged: (newValue) {

  //           selectedDimension.value = newValue;

  //         },

  //         items: dimensions.map((dimension) {

  //           return DropdownMenuItem<Dimension>(

  //             value: dimension,

  //             child: Text(dimension.Name, style: TextStyle(color: Theme.of(context).primaryColor)),

  //           );

  //         }).toList(),

  //       ),

  //     ),

  //   );

  // }
}
