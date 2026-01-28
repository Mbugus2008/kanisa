import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanisa/Network/Apis.dart';
import 'package:kanisa/models/account_model.dart';
import 'package:kanisa/screens/payment_history_screen.dart';
import 'package:kanisa/screens/payment_screen.dart';
import 'package:kanisa/screens/registration_screen.dart';
import 'package:kanisa/services/logger.dart';
import 'package:kanisa/splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MyAccountScreen extends StatelessWidget {
  final Rx<Customer> customer = Rx<Customer>(Customer());
  final RxList<Customer> householdMembers = <Customer>[].obs;
  final RxBool isLoadingHousehold = false.obs;
  Customer? cust;
  final ApiClient api = ApiClient();
  final LoggerService logger = Get.find();
  MyAccountScreen({
    super.key,
    this.cust,
  }) {
    customer.value = cust!;
    _loadHouseholdMembers();
  }

  /// Gets the household primary number based on relationship
  String? get _householdPrimaryNo {
    if (customer.value.Relationship == customerRole.spouse) {
      // Spouse uses their linked primary's number
      return customer.value.Household_Primary_No;
    } else {
      // Primary member uses their own number
      return customer.value.No;
    }
  }

  /// Check if user can view/manage household (primary or spouse)
  bool get _canManageHousehold {
    final relationship = customer.value.Relationship;
    return relationship == null ||
        relationship == customerRole.primary ||
        relationship == customerRole.spouse;
  }

  Future<void> _loadHouseholdMembers() async {
    // Load household members for primary members and spouses
    if (_canManageHousehold) {
      final primaryNo = _householdPrimaryNo;
      if (primaryNo != null && primaryNo.isNotEmpty) {
        isLoadingHousehold.value = true;
        try {
          final members = await api.getHouseholdMembers(primaryNo);
          // Filter out the current user from the list
          final filteredMembers = members
              .where((member) => member.No != customer.value.No)
              .toList();
          householdMembers.assignAll(filteredMembers);
        } catch (e) {
          logger.error('Error loading household members: $e');
        }
        isLoadingHousehold.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print(customer.toString());
    return Scaffold(
      appBar: AppBar(
        title: Text(customer.value.Name ?? 'My Account'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help',
            onPressed: () async {
              final Uri url =
                  Uri.parse('https://trimline.co.ke/kanisa-help.html');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade200, Colors.green.shade200],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Responsive design based on screen height
              final isSmallScreen = constraints.maxHeight < 700;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Profile Bio Card
                      Obx(() => Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding:
                                  EdgeInsets.all(isSmallScreen ? 12.0 : 20.0),
                              child: Column(
                                children: [
                                  // Avatar
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue.shade400,
                                          Colors.green.shade400
                                        ],
                                      ),
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.all(
                                          isSmallScreen ? 12 : 16),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        size: isSmallScreen ? 40 : 50,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: isSmallScreen ? 8 : 12),

                                  // Name
                                  Text(
                                    customer.value.Name ?? 'No Name Provided',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 18 : 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade900,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 6),

                                  // Member Number Badge
                                  if (customer.value.No != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: Colors.blue.shade200),
                                      ),
                                      child: Text(
                                        'Member #${customer.value.No}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ),
                                  SizedBox(height: isSmallScreen ? 8 : 12),

                                  // Contact Info in Compact Cards
                                  _buildCompactInfo(
                                    Icons.email_outlined,
                                    customer.value.E_Mail ?? 'No Email',
                                    Colors.orange,
                                  ),
                                  const SizedBox(height: 6),
                                  _buildCompactInfo(
                                    Icons.phone_outlined,
                                    customer.value.Phone_No ?? 'No Phone',
                                    Colors.green,
                                  ),
                                  const SizedBox(height: 6),
                                  _buildCompactInfo(
                                    Icons.location_on_outlined,
                                    customer.value.Global_Dimension_1_Code ??
                                        'No District',
                                    Colors.purple,
                                  ),

                                  // Groups Section (compact)
                                  if (customer.value.MembersGroups != null &&
                                      customer
                                          .value.MembersGroups!.isNotEmpty) ...[
                                    SizedBox(height: isSmallScreen ? 8 : 12),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.green.shade200),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.group,
                                                  size: 16,
                                                  color: Colors.green.shade700),
                                              const SizedBox(width: 6),
                                              Text(
                                                'My Groups',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green.shade900,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 6,
                                            alignment: WrapAlignment.center,
                                            children: customer
                                                .value.MembersGroups!
                                                .map((group) => Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                        border: Border.all(
                                                            color: Colors.green
                                                                .shade300),
                                                      ),
                                                      child: Text(
                                                        group.Global_Dimension_2_Code ??
                                                            '',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: Colors
                                                              .green.shade700,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ))
                                                .toList(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          )),
                      SizedBox(height: isSmallScreen ? 8 : 12),

                      // Household Members Section (Children/Spouse)
                      Obx(() {
                        // Show for primary members and spouses
                        if (!_canManageHousehold) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          children: [
                            // Section Header
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(Icons.family_restroom,
                                            color: Colors.blue.shade600,
                                            size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Text(
                                          'My Household',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (isLoadingHousehold.value)
                                        const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      else
                                        TextButton.icon(
                                          onPressed: () =>
                                              _navigateToAddChild(context),
                                          icon: Icon(Icons.add,
                                              size: 18,
                                              color: Colors.blue.shade600),
                                          label: Text(
                                            'Add Child',
                                            style: TextStyle(
                                              color: Colors.blue.shade600,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Members List
                                  if (householdMembers.isEmpty &&
                                      !isLoadingHousehold.value)
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.info_outline,
                                              color: Colors.grey.shade400),
                                          const SizedBox(width: 8),
                                          Text(
                                            'No family members added yet',
                                            style: TextStyle(
                                                color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    ...householdMembers.map((member) =>
                                        _buildHouseholdMemberCard(
                                            member, context)),
                                ],
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 8 : 12),
                          ],
                        );
                      }),

                      // Quick Actions Grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: isSmallScreen ? 1.4 : 1.5,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        children: [
                          _buildQuickActionCard(
                            icon: Icons.person,
                            title: 'Edit Profile',
                            color: Colors.blue,
                            onTap: () async {
                              Customer? updatedCustomer = await Get.to(() =>
                                  RegistrationScreen(customer: customer.value));
                              logger.info(updatedCustomer.toString());
                              if (updatedCustomer != null) {
                                customer.value = updatedCustomer;
                              }
                            },
                          ),
                          _buildQuickActionCard(
                            icon: Icons.payment,
                            title: 'Make Payment',
                            color: Colors.green,
                            onTap: () => Get.to(
                                () => PaymentScreen(customer: customer.value)),
                          ),
                          _buildQuickActionCard(
                            icon: Icons.history,
                            title: 'Payment History',
                            color: Colors.orange,
                            onTap: () => Get.to(() =>
                                PaymentHistoryScreen(customer: customer.value)),
                          ),
                          // Show "Link to Household" only for primary members not already linked
                          // Hide for: spouses, children, or anyone already linked to a household
                          Obx(() {
                            final isPrimaryOrNew =
                                customer.value.Relationship == null ||
                                    customer.value.Relationship ==
                                        customerRole.primary;
                            final notLinkedToHousehold =
                                customer.value.Household_Primary_No == null ||
                                    customer
                                        .value.Household_Primary_No!.isEmpty;
                            final showLinkButton =
                                isPrimaryOrNew && notLinkedToHousehold;

                            return showLinkButton
                                ? _buildQuickActionCard(
                                    icon: Icons.family_restroom,
                                    title: 'Link to Spouse',
                                    color: Colors.pink,
                                    onTap: () =>
                                        _showLinkToHouseholdDialog(context),
                                  )
                                : _buildQuickActionCard(
                                    icon: Icons.exit_to_app,
                                    title: 'Logout',
                                    color: Colors.red,
                                    onTap: () async {
                                      final SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.remove('phone_number');
                                      Get.offAll(() => Welcome());
                                    },
                                  );
                          }),
                          // Always show logout if link to household is shown
                          Obx(() {
                            final isPrimaryOrNew =
                                customer.value.Relationship == null ||
                                    customer.value.Relationship ==
                                        customerRole.primary;
                            final notLinkedToHousehold =
                                customer.value.Household_Primary_No == null ||
                                    customer
                                        .value.Household_Primary_No!.isEmpty;
                            final showLinkButton =
                                isPrimaryOrNew && notLinkedToHousehold;

                            return showLinkButton
                                ? _buildQuickActionCard(
                                    icon: Icons.exit_to_app,
                                    title: 'Logout',
                                    color: Colors.red,
                                    onTap: () async {
                                      final SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.remove('phone_number');
                                      Get.offAll(() => Welcome());
                                    },
                                  )
                                : const SizedBox.shrink();
                          }),
                        ],
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
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHouseholdMemberCard(Customer member, BuildContext context) {
    // Determine the display role based on member's relationship AND viewer's perspective
    // - If member is a spouse → show as "Spouse"
    // - If member is a child → show as "Child"
    // - If member is primary (being viewed by spouse) → show as "Spouse" (my spouse)
    final bool isSpouse = member.Relationship == customerRole.spouse ||
        member.Relationship == customerRole.primary ||
        member.Relationship == null;
    final bool isChild = member.Relationship == customerRole.child;
    final Color roleColor = isChild ? Colors.blue : Colors.pink;
    final IconData roleIcon = isChild ? Icons.child_care : Icons.favorite;
    final String roleLabel = isChild ? 'Child' : 'Spouse';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: roleColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: roleColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(roleIcon, color: roleColor, size: 24),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        member.Name ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        roleLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: roleColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (member.No != null)
                  Text(
                    'Member #${member.No}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                if (member.Date_of_Birth != null)
                  Text(
                    'DOB: ${member.Date_of_Birth!.day}/${member.Date_of_Birth!.month}/${member.Date_of_Birth!.year}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
          // Edit button - only show for children, not for spouse
          if (isChild)
            IconButton(
              icon: Icon(Icons.edit_outlined,
                  color: Colors.grey.shade600, size: 20),
              onPressed: () async {
                Customer? updatedMember =
                    await Get.to(() => RegistrationScreen(customer: member));
                if (updatedMember != null) {
                  // Refresh the household members list
                  _loadHouseholdMembers();
                }
              },
              tooltip: 'Edit $roleLabel',
            ),
        ],
      ),
    );
  }

  Widget _buildCompactInfo(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddChild(BuildContext context) async {
    // Create a new child customer with relationship set
    // Use the household primary number (works for both primary and spouse)
    final newChild = Customer(
      Relationship: customerRole.child,
      Household_Primary_No: _householdPrimaryNo,
      // Pre-fill common fields from parent
      Global_Dimension_1_Code: customer.value.Global_Dimension_1_Code,
    );

    Customer? result =
        await Get.to(() => RegistrationScreen(customer: newChild));
    if (result != null) {
      // Refresh the household members list
      _loadHouseholdMembers();
      Get.snackbar(
        'Success!',
        '${result.Name} has been added to your household.',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        icon: const Icon(Icons.check_circle, color: Colors.green),
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _showLinkToHouseholdDialog(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();
    final Rx<Customer?> foundMember = Rx<Customer?>(null);
    final RxBool isSearching = false.obs;
    final RxString errorMessage = ''.obs;

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.family_restroom, color: Colors.pink.shade400),
            const SizedBox(width: 8),
            const Text('Link to Spouse'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter your spouse\'s phone number to link your accounts as a family household.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Spouse\'s Phone Number',
                  hintText: 'e.g., 254712345678',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: Obx(() => isSearching.value
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () async {
                            if (phoneController.text.isEmpty) {
                              errorMessage.value =
                                  'Please enter a phone number';
                              return;
                            }
                            isSearching.value = true;
                            errorMessage.value = '';
                            foundMember.value = null;

                            try {
                              final member = await api
                                  .checkCustomerExists(phoneController.text);
                              if (member != null) {
                                // Check if trying to link to self
                                if (member.No == customer.value.No) {
                                  errorMessage.value =
                                      'You cannot link to yourself';
                                } else if (member.Relationship ==
                                        customerRole.spouse ||
                                    member.Relationship == customerRole.child) {
                                  errorMessage.value =
                                      '${member.Name} is already linked to another household';
                                } else {
                                  foundMember.value = member;
                                }
                              } else {
                                errorMessage.value =
                                    'No member found with this phone number';
                              }
                            } catch (e) {
                              errorMessage.value = 'Error searching: $e';
                            }
                            isSearching.value = false;
                          },
                        )),
                ),
              ),
              const SizedBox(height: 12),

              // Error message
              Obx(() => errorMessage.value.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red.shade400, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              errorMessage.value,
                              style: TextStyle(
                                  color: Colors.red.shade700, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink()),

              // Found member card
              Obx(() => foundMember.value != null
                  ? Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: Colors.green.shade600),
                              const SizedBox(width: 8),
                              const Text(
                                'Member Found!',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Name: ${foundMember.value!.Name}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'Member #: ${foundMember.value!.No}',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          Text(
                            'District: ${foundMember.value!.Global_Dimension_1_Code ?? 'N/A'}',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'You will become a spouse in ${foundMember.value!.Name}\'s household.',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          Obx(() => foundMember.value != null
              ? ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    await _linkToHousehold(foundMember.value!);
                  },
                  icon: const Icon(Icons.link, size: 18),
                  label: const Text('Link Accounts'),
                )
              : const SizedBox.shrink()),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _linkToHousehold(Customer spouse) async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      // Update current user's relationship and household link
      final updatedCustomer = Customer(
        Key: customer.value.Key,
        No: customer.value.No,
        Name: customer.value.Name,
        Phone_No: customer.value.Phone_No,
        E_Mail: customer.value.E_Mail,
        Occupation: customer.value.Occupation,
        Confirmed: customer.value.Confirmed,
        Confirmation_Date: customer.value.Confirmation_Date,
        Date_of_Birth: customer.value.Date_of_Birth,
        Gender: customer.value.Gender,
        Global_Dimension_1_Code: customer.value.Global_Dimension_1_Code,
        Baptism_Date: customer.value.Baptism_Date,
        Baptised_by: customer.value.Baptised_by,
        Other_Information: customer.value.Other_Information,
        MembersGroups: customer.value.MembersGroups,
        // Set the household link
        Relationship: customerRole.spouse,
        Household_Primary_No: spouse.No,
      );

      final result = await api.registerCustomer(updatedCustomer);

      Get.back(); // Close loading dialog

      if (result != null) {
        customer.value = result;
        Get.back(); // Close the link dialog

        Get.snackbar(
          'Success!',
          'Your account has been linked to ${spouse.Name}\'s household as a spouse.',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
          icon: const Icon(Icons.check_circle, color: Colors.green),
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to link accounts. Please try again.',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'Failed to link accounts: $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }
}

class AccountOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const AccountOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue.shade700),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
