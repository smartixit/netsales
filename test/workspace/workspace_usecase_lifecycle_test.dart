import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/features/commercial/data/datasources/commercial_remote_data_source.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/commercial/presentation/bindings/commercial_binding.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  test('network use case can be recreated after GetX disposes its instance', () async {
    CommercialBinding().dependencies();

    final firstInstance = Get.find<GetMyNetworksUseCase>();
    expect(firstInstance, isA<GetMyNetworksUseCase>());

    await Get.delete<GetMyNetworksUseCase>();
    await Get.delete<CommercialRepository>();
    await Get.delete<CommercialRemoteDataSource>();

    expect(Get.isPrepared<GetMyNetworksUseCase>(), isTrue);
    expect(Get.isPrepared<CommercialRepository>(), isTrue);
    expect(Get.isPrepared<CommercialRemoteDataSource>(), isTrue);

    final recreatedInstance = Get.find<GetMyNetworksUseCase>();
    expect(recreatedInstance, isA<GetMyNetworksUseCase>());
    expect(identical(firstInstance, recreatedInstance), isFalse);
  });
}
