import 'package:flutter/material.dart';
import 'package:flutter_store_mobile/common/widgets/text/section_heading.dart';
import 'package:flutter_store_mobile/data/repositories/address/address_repository.dart';
import 'package:flutter_store_mobile/features/personalize/screen/address/add_new_address.dart';
import 'package:flutter_store_mobile/features/personalize/screen/address/widgets/single_address.dart';
import 'package:flutter_store_mobile/features/shop/models/address_model.dart';
import 'package:flutter_store_mobile/utils/constants/images_string.dart';
import 'package:flutter_store_mobile/utils/constants/sizes.dart';
import 'package:flutter_store_mobile/utils/helpers/could_helper_function.dart';
import 'package:flutter_store_mobile/utils/helpers/loader.dart';
import 'package:flutter_store_mobile/utils/helpers/network_manager.dart';
import 'package:flutter_store_mobile/utils/popups/full_screen_loader.dart';
import 'package:flutter_store_mobile/utils/popups/loader.dart';
import 'package:get/get.dart';

class AddressController extends GetxController {
  static AddressController get instance => Get.find();

  final name = TextEditingController();
  final phoneNumber = TextEditingController();
  final sreet = TextEditingController();
  final postalCode = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();
  final country = TextEditingController();
  GlobalKey<FormState> addressFormKey = GlobalKey<FormState>();

  RxBool refreshData = true.obs;
  final Rx<AddressModel> selectedAddress = AddressModel.empty().obs;
  final addressRepository = Get.put(AddressRepository());

  Future<List<AddressModel>> allUserAddress() async {
    try {
      final addressed = await addressRepository.fetchUserAddress();
      selectedAddress.value = addressed.firstWhere(
          (element) => element.selectedAddress,
          orElse: () => AddressModel.empty());
      return addressed;
    } catch (e) {
      TLoaders.errorSnackbar(
          title: 'Không tìm thấy địa chỉ', message: e.toString());
      return [];
    }
  }

  Future selectAdress(AddressModel newselectAdress) async {
    try {
      Get.defaultDialog(
        title: '',
        onWillPop: () async {
          return false;
        },
        barrierDismissible: false,
        backgroundColor: Colors.transparent,
        content: const TCircularLoader(),
      );

      if (selectedAddress.value.id.isNotEmpty) {
        await addressRepository.updateSelectedField(
            selectedAddress.value.id, false);
      }

      newselectAdress.selectedAddress = true;
      selectedAddress.value = newselectAdress;

      await addressRepository.updateSelectedField(
          selectedAddress.value.id, true);
    } catch (e) {
      TLoaders.errorSnackbar(
          title: 'Lỗi trong lúc chọn địa chỉ', message: e.toString());
    }
  }

  Future addNewAddresses() async {
    try {
      // Start Loading
      TFullScreenLoader.openLoadingDialog('Đăng lưu địa chỉ', TImages.imagefix);

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoadingDialog();
        return;
      }

      // Form Validation
      if (!addressFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoadingDialog();
        return;
      }

      // Save Address Data
      final address = AddressModel(
        id: '',
        name: name.text.trim(),
        phoneNumber: phoneNumber.text.trim(),
        street: sreet.text.trim(),
        city: city.text.trim(),
        state: state.text.trim(),
        postalCode: postalCode.text.trim(),
        country: country.text.trim(),
        selectedAddress: true,
      );

      final id = await addressRepository.addAddress(address);

      address.id = id;
      selectedAddress(address);

      TFullScreenLoader.stopLoadingDialog();

      TLoaders.successSnackbar(
          title: 'Chúc mừng', message: 'bạn đã thêm địa chỉ thành công');

      refreshData.toggle();

      resetFormFields();

      Navigator.of(Get.context!).pop();
    } catch (e) {
      TFullScreenLoader.stopLoadingDialog();
      TLoaders.errorSnackbar(
          title: 'Không tìm thấy địa chỉ', message: e.toString());
    }
  }

  void resetFormFields() {
    name.clear();
    phoneNumber.clear();
    sreet.clear();
    postalCode.clear();
    city.clear();
    state.clear();
    country.clear();
    addressFormKey.currentState?.reset();
  }

  Future<void> selectNewAddressPopup(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(TSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TSectionWidget(title: 'Chọn Địa chỉ'),
            FutureBuilder(
              future: allUserAddress(),
              builder: (_, snapshot) {
                final response = TCloudHelperFunctions.checkMultiRecordState(
                    snapshot: snapshot);
                if (response != null) return response;

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (_, index) => TSingleAddress(
                    address: snapshot.data![index],
                    onTap: () async {
                      await selectAdress(snapshot.data![index]);
                      Get.back();
                    },
                  ),
                );
              },
            ),
            const SizedBox(
              height: TSizes.defaultSpace,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AddNewAddressScreen())),
                child: const Text('Thêm địa chỉ mới'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
