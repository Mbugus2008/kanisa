import 'package:get/get.dart';
import 'package:kanisa/Network/Apis.dart';
import 'package:kanisa/models/dimensions.dart';

class DimensionController extends GetxController {
  var isLoading = false.obs;
  var districtDimensions = <Dimension>[].obs;
  var groupDimensions = <Dimension>[].obs;

  // Observable properties for selected dimensions
  var selectedDistrictDimension = Rx<Dimension?>(null);
  var selectedGroupDimension = Rx<Dimension?>(null);
  // For multiple group selections
  var selectedGroupDimensions = <Dimension>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDimensions();
  }

  void fetchDimensions() async {
    isLoading(true);
    try {
      var fetchedDimensions = await ApiClient().fetchDimensions();
      if (fetchedDimensions.isNotEmpty) {
        // Filter out dimensions with the code "LCC"
        var filteredDistricts = fetchedDimensions
            .where((d) => d.Dimension_Code == 'DISTRICT' && d.Code != 'LCC')
            .toList();
        var filteredGroups = fetchedDimensions
            .where((d) => d.Dimension_Code == 'GROUPS' && d.Code != 'LCC')
            .toList();
        districtDimensions.assignAll(filteredDistricts);
        groupDimensions.assignAll(filteredGroups);
      }
    } finally {
      isLoading(false);
    }
  }
}
