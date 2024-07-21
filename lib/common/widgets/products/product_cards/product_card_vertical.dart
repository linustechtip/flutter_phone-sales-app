import 'package:flutter/material.dart';
import 'package:flutter_store_mobile/common/widgets/custom_shape/containers/rounded_container.dart';
import 'package:flutter_store_mobile/common/widgets/images/rounded_image.dart';
import 'package:flutter_store_mobile/common/widgets/text/product_price_text.dart';
import 'package:flutter_store_mobile/common/widgets/text/product_title_text.dart';
import 'package:flutter_store_mobile/features/shop/controller/product_controller.dart';
import 'package:flutter_store_mobile/features/shop/models/product_model.dart';
import 'package:flutter_store_mobile/features/shop/screens/product_details/product_detail.dart';
import 'package:flutter_store_mobile/utils/constants/colors.dart';
import 'package:flutter_store_mobile/utils/constants/enums.dart';
import 'package:flutter_store_mobile/utils/constants/sizes.dart';
import 'package:flutter_store_mobile/utils/helpers/helper_function.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart'; // Import the intl package
import '../../../style/shadows.dart';
import '../../icons/t_circular_icon.dart';
import '../../text/brand_title_text_verfied_icon.dart';

class TProductCardVertical extends StatelessWidget {
  const TProductCardVertical({super.key, required this.productModel});

  final ProductModel productModel;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final controller = ProductController.instance;
    final salePercentage = controller.calculateSalePercentage(
        productModel.price, productModel.salePrice);

    final NumberFormat currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    //Container san pham
    return GestureDetector(
      onTap: () => Get.to(() => ProductDetail(
            productModel: productModel,
          )),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          boxShadow: [TShadowStyle.verticalProductShadow],
          borderRadius: BorderRadius.circular(TSizes.productImageRadius),
          color: dark ? TColors.darkGrey : TColors.white,
        ),
        child: Column(
          children: [
            // mã giảm giá, nút yêu thích,hình
            TRoundedContainer(
              height: 180,
              width: 180,
              padding: const EdgeInsets.all(TSizes.sm),
              backgroundColor: dark ? TColors.dark : TColors.light,
              child: Stack(
                children: [
                  ///thumbnail
                  Center(
                    child: TRoundedImage(
                      imageUrl: productModel.thumbnail,
                      applyImageRadius: true,
                      isNetworkImage: true,
                    ),
                  ),

                  /// mã giảm giá
                  if(salePercentage != null )
                  Positioned(
                    top: 12,
                    child: TRoundedContainer(
                      radius: TSizes.sm,
                      backgroundColor: TColors.secondary.withOpacity(0.8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: TSizes.sm, vertical: TSizes.xs),
                      child: Text('$salePercentage%',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .apply(color: TColors.black)),
                    ),
                  ),

                  ///Button Yêu thích
                  const Positioned(
                    top: 0,
                    right: 0,
                    child: TCircularIcon(
                      icon: Iconsax.heart5,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems / 2),
            // thông tin chi tiết
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: TSizes.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TProductTitleText(
                        title: productModel.title, smallSize: true),
                    const SizedBox(height: TSizes.spaceBtwItems / 2),
                    TBrandTitleWithVerifiedIcon(
                        title: productModel.brand!.name),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //Giá
                Flexible(
                  child: Column(
                    children: [
                      if (productModel.productType ==
                              ProductType.single.toString() &&
                          productModel.salePrice > 0)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: TSizes.sm),
                            child: Text(
                              currencyFormatter.format(productModel.price),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .apply(
                                      decoration: TextDecoration.lineThrough),
                            ),
                          ),
                        ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: TSizes.sm),
                          child: TProductPriceText(
                              price: controller.getProductPrice(productModel)),
                        ),
                      ),
                    ],
                  ),
                ),

                // Button add vào giỏ hàng
                Container(
                  decoration: const BoxDecoration(
                    color: TColors.dark,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(TSizes.cardRadiusMd),
                      bottomRight: Radius.circular(TSizes.productImageRadius),
                    ),
                  ),
                  child: const SizedBox(
                    width: TSizes.iconLg * 1.2,
                    height: TSizes.iconLg * 1.2,
                    child:
                        Center(child: Icon(Iconsax.add, color: TColors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
