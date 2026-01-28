import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kanisa/Network/Apis.dart';
import 'package:kanisa/Utils/util.dart';
import 'package:kanisa/controllers/dimension_controller.dart';
import 'package:kanisa/models/account_model.dart';

class RegistrationController extends GetxController {
  Customer? initialCustomer;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController occupationController = TextEditingController();
  final TextEditingController baptismDateController = TextEditingController();
  final TextEditingController baptizedByController = TextEditingController();
  final TextEditingController otherInformationController =
      TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController confirmationDateController =
      TextEditingController();

  // Observable values
  final RxnBool isConfirmed = RxnBool();
  final RxBool isBaptized = false.obs;
  final Rx<gender?> selectedGender = Rx<gender?>(null);
  final Rx<customerRole> relationship = customerRole.primary.obs;
  final RxBool canCreateDescendantObs = false.obs;

  String? householdPrimaryNo;

  RegistrationController({this.initialCustomer}) {
    relationship.value = initialCustomer?.Relationship ?? customerRole.primary;
    householdPrimaryNo = initialCustomer?.Household_Primary_No;
    // Treat null Relationship as primary (existing members without relationship set are head of household)
    if (householdPrimaryNo == null &&
        (initialCustomer?.Relationship == null ||
            initialCustomer?.Relationship == customerRole.primary)) {
      householdPrimaryNo = initialCustomer?.No;
    }
    if (initialCustomer != null) {
      loadCustomerData(initialCustomer!);
    }
    updateCanCreateDescendant();
  }

  @override
  void onClose() {
    // Dispose controllers to prevent memory leaks
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    occupationController.dispose();
    baptismDateController.dispose();
    baptizedByController.dispose();
    otherInformationController.dispose();
    dateOfBirthController.dispose();
    confirmationDateController.dispose();
    super.onClose();
  }

  void loadCustomerData(Customer customer) {
    relationship.value = customer.Relationship ?? relationship.value;
    householdPrimaryNo = customer.Household_Primary_No ?? householdPrimaryNo;
    if (householdPrimaryNo == null &&
        (customer.Relationship ?? customerRole.primary) ==
            customerRole.primary) {
      householdPrimaryNo = customer.No;
    }

    nameController.text = customer.Name ?? '';
    phoneController.text = customer.Phone_No ?? '';
    emailController.text = customer.E_Mail ?? '';
    occupationController.text = customer.Occupation ?? '';
    isConfirmed.value = customer.Confirmed;
    isBaptized.value = customer.Baptism_Date != null;
    baptizedByController.text = customer.Baptised_by ?? '';
    selectedGender.value = customer.Gender;
    otherInformationController.text = customer.Other_Information ?? '';

    if (customer.Baptism_Date != null) {
      baptismDateController.text = formattedDDMM.format(customer.Baptism_Date!);
    }

    if (customer.Date_of_Birth != null) {
      dateOfBirthController.text =
          formattedDDMM.format(customer.Date_of_Birth!);
    }

    if (customer.Confirmation_Date != null) {
      confirmationDateController.text =
          formattedDDMM.format(customer.Confirmation_Date!);
    }

    final dimensionController = Get.find<DimensionController>();
    for (final district in dimensionController.districtDimensions) {
      if (district.Code == customer.Global_Dimension_1_Code) {
        dimensionController.selectedDistrictDimension.value = district;
        break;
      }
    }

    dimensionController.selectedGroupDimensions.clear();
    for (final group in dimensionController.groupDimensions) {
      final belongs = customer.MembersGroups?.any(
            (member) => member.Global_Dimension_2_Code == group.Code,
          ) ??
          false;
      if (belongs) {
        dimensionController.selectedGroupDimensions.add(group);
      }
    }
  }

  // Format group names for display while preserving original case in data
  String formatGroupName(String name) {
    if (name.isEmpty) return name;

    final words = name.split(RegExp(r'[\s_-]+')).map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() +
          (word.length > 1 ? word.substring(1).toLowerCase() : '');
    }).toList();

    return words.join(' ');
  }

  String? get householdAnchor {
    if (householdPrimaryNo != null && householdPrimaryNo!.isNotEmpty) {
      return householdPrimaryNo;
    }
    if (initialCustomer?.Relationship == customerRole.primary) {
      return initialCustomer?.No;
    }
    return initialCustomer?.Household_Primary_No;
  }

  bool get canCreateDescendant {
    // Children cannot add other children - only primary and spouse can
    if (relationship.value == customerRole.child) {
      return false;
    }
    return householdAnchor != null && householdAnchor!.isNotEmpty;
  }

  void updateCanCreateDescendant() {
    canCreateDescendantObs.value = canCreateDescendant;
  }

  void updateAfterRegistration(Customer registeredCustomer) {
    initialCustomer = registeredCustomer;
    if (registeredCustomer.Relationship == customerRole.primary) {
      householdPrimaryNo = registeredCustomer.No;
    }
    updateCanCreateDescendant();
  }

  Customer buildDescendantDraft(customerRole role) {
    final anchor = householdAnchor;
    final dimensionController = Get.find<DimensionController>();

    // For children: use primary's phone, empty groups
    // For spouse: inherit groups from primary
    final selectedGroups = role == customerRole.child
        ? <MemberGroups>[]
        : dimensionController.selectedGroupDimensions
            .map((dimension) =>
                MemberGroups(Global_Dimension_2_Code: dimension.Code))
            .toList();

    return Customer(
      Relationship: role,
      Household_Primary_No: anchor,
      // For children, use the primary's phone number
      Phone_No: role == customerRole.child ? initialCustomer?.Phone_No : null,
      Global_Dimension_1_Code:
          dimensionController.selectedDistrictDimension.value?.Code ??
              initialCustomer?.Global_Dimension_1_Code,
      MembersGroups: role == customerRole.child
          ? []
          : (selectedGroups.isNotEmpty
              ? selectedGroups
              : initialCustomer?.MembersGroups),
    );
  }

  void setRelationship(customerRole role) {
    relationship.value = role;
  }

  void assignHouseholdPrimary(String? anchor) {
    householdPrimaryNo = anchor;
  }

  bool validateForm() {
    if (nameController.text.isEmpty) {
      Get.snackbar('Error', 'Name is required', backgroundColor: Colors.red);
      return false;
    }
    if (nameController.text.trim().split(' ').length < 2) {
      Get.snackbar('Error', 'Name must contain at least two words',
          backgroundColor: Colors.red);
      return false;
    }
    if (phoneController.text.isEmpty) {
      Get.snackbar('Error', 'Phone number is required',
          backgroundColor: Colors.red);
      return false;
    }
    if (selectedGender.value == null) {
      Get.snackbar('Error', 'Please select your gender',
          backgroundColor: Colors.red);
      return false;
    }
    if (isConfirmed.value == null) {
      Get.snackbar('Error', 'Please indicate if you are confirmed',
          backgroundColor: Colors.red);
      return false;
    }
    if (isConfirmed.value == true && confirmationDateController.text.isEmpty) {
      Get.snackbar('Error', 'Please select your confirmation date',
          backgroundColor: Colors.red);
      return false;
    }
    if (Get.find<DimensionController>().selectedDistrictDimension.value ==
        null) {
      Get.snackbar('Error', 'Please select your district',
          backgroundColor: Colors.red);
      return false;
    }
    if (dateOfBirthController.text.isEmpty) {
      Get.snackbar('Error', 'Please select your date of birth',
          backgroundColor: Colors.red);
      return false;
    }
    return true;
  }

  static Customer mockRegistration() {
    return Customer(
      No: '${DateTime.now().millisecondsSinceEpoch}',
      Name: 'John Doe',
      Phone_No: '1234567890',
      E_Mail: 'johndoe@example.com',
      Occupation: 'Software Engineer',
      Confirmed: true,
      Date_of_Birth: DateTime.now()
          .subtract(const Duration(days: 365 * 25))
          .toUtc()
          .copyWith(
              hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0),
      Gender: gender.Male,
      Global_Dimension_1_Code: 'BRIGADE',
      Baptism_Date: DateTime.now()
          .subtract(const Duration(days: 365 * 5))
          .toUtc()
          .copyWith(
              hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0),
      Baptised_by: 'Pastor Smith',
      Other_Information: 'No additional information',
      MembersGroups: [
        MemberGroups(
          Global_Dimension_2_Code: 'Adults',
        ),
      ],
    );
  }

  Future<Customer?> submitForm() async {
    if (!validateForm()) {
      return null;
    }

    try {
      final dimensionController = Get.find<DimensionController>();
      final DateFormat inputFormat = DateFormat('dd-MMM-yyyy');

      final customerData = Customer(
        Key: initialCustomer?.Key,
        No: initialCustomer?.No,
        Name: formatGroupName(nameController.text),
        Phone_No: phoneController.text,
        E_Mail: emailController.text,
        Occupation: occupationController.text,
        Confirmed: isConfirmed.value,
        Confirmation_Date: isConfirmed.value == true &&
                confirmationDateController.text.isNotEmpty
            ? inputFormat.parse(confirmationDateController.text)
            : null,
        Date_of_Birth: dateOfBirthController.text.isNotEmpty
            ? inputFormat.parse(dateOfBirthController.text)
            : null,
        Gender: selectedGender.value,
        Global_Dimension_1_Code:
            dimensionController.selectedDistrictDimension.value?.Code,
        Baptism_Date: isBaptized.value && baptismDateController.text.isNotEmpty
            ? inputFormat.parse(baptismDateController.text)
            : null,
        Baptised_by: isBaptized.value ? baptizedByController.text : null,
        Other_Information: otherInformationController.text,
        MembersGroups: dimensionController.selectedGroupDimensions
            .map((dimension) =>
                MemberGroups(Global_Dimension_2_Code: dimension.Code))
            .toList(),
        Relationship: relationship.value,
        Household_Primary_No: householdPrimaryNo ??
            initialCustomer?.Household_Primary_No ??
            (relationship.value == customerRole.primary
                ? initialCustomer?.No
                : householdPrimaryNo),
      );

      Get.dialog(const Center(child: CircularProgressIndicator()),
          barrierDismissible: false);

      try {
        final result = await ApiClient().registerCustomer(customerData);
        Get.back();
        return result;
      } catch (apiError) {
        Get.back();
        Get.snackbar('API Error', 'Failed to register: $apiError',
            backgroundColor: Colors.red);
        return null;
      }
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'Failed to register: $e',
          backgroundColor: Colors.red);
      return null;
    }
  }
}
