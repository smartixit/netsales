import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/core/themes/app_themes.dart';
import 'package:netsales/features/partners/domain/entities/network_entity.dart';
import 'package:netsales/features/partners/domain/entities/network_pos_entity.dart';
import 'package:netsales/features/partners/domain/entities/pos_entity.dart';
import 'package:netsales/features/partners/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/partners/domain/repositories/partners_repository.dart';
import 'package:netsales/features/partners/domain/usecases/approve_partner_use_case.dart';
import 'package:netsales/features/partners/domain/usecases/create_network_pos_use_case.dart';
import 'package:netsales/features/partners/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/features/partners/domain/usecases/get_networks_use_case.dart';
import 'package:netsales/features/partners/domain/usecases/get_pos_list_use_case.dart';
import 'package:netsales/features/partners/domain/usecases/get_pos_wallet_logs_use_case.dart';
import 'package:netsales/features/partners/domain/usecases/get_pos_wallet_use_case.dart';
import 'package:netsales/features/partners/domain/usecases/reject_partner_use_case.dart';
import 'package:netsales/features/partners/domain/usecases/toggle_network_pos_status_use_case.dart';
import 'package:netsales/features/partners/domain/usecases/transfer_pos_wallet_balance_use_case.dart';
import 'package:netsales/features/partners/presentation/controllers/partners_controller.dart';
import 'package:netsales/features/partners/presentation/controllers/pos_wallet_sheet_controller.dart';
import 'package:netsales/features/partners/presentation/screens/partners_screen.dart';
import 'package:netsales/features/partners/presentation/widgets/network_item_card.dart';
import 'package:netsales/features/partners/presentation/widgets/network_pos_item_card.dart';
import 'package:netsales/features/partners/presentation/widgets/pos_item_card.dart';
import 'package:netsales/features/partners/presentation/widgets/sheets/link_partner_sheet.dart';
import 'package:netsales/features/partners/presentation/widgets/sheets/partner_details_sheet.dart';

class FakePartnersRepository implements PartnersRepository {
  final List<NetworkEntity> fakeNetworks = [
    const NetworkEntity(
      networkId: 1,
      networkUuid: 'net-uuid-1',
      networkName: 'شبكة يمن نت التجريبية',
      networkPhoneNumber: '777000111',
      networkEmail: 'contact@yemen.net',
      networkAddress: 'شارع حدة العام',
      governorateId: 1,
      directorateId: 1,
      governorateName: 'أمانة العاصمة',
      directorateName: 'السبعين',
      ownerId: 10,
      ownerName: 'أحمد التاجر',
      ownerPhone: '777000111',
      status: 'ACTIVE',
      posCount: 15,
      packagesCount: 8,
    ),
  ];

  final List<PosEntity> fakePosList = [
    const PosEntity(
      posId: 101,
      posUuid: 'pos-uuid-101',
      posName: 'مركز المدينة للاتصالات',
      posPhoneNumber: '771222333',
      posEmail: 'city@pos.com',
      posAddress: 'جولة ريماس',
      governorateId: 1,
      directorateId: 1,
      governorateName: 'أمانة العاصمة',
      directorateName: 'السبعين',
      ownerId: 20,
      agentName: 'محمد الوكيل',
      agentPhone: '771222333',
      status: 'ACTIVE',
      networksCount: 3,
    ),
  ];

  final List<NetworkPosEntity> fakeContracts = [
    const NetworkPosEntity(
      networkPosId: 501,
      networkId: 1,
      posId: 101,
      networkName: 'شبكة يمن نت التجريبية',
      posName: 'مركز المدينة للاتصالات',
      governorateName: 'أمانة العاصمة',
      directorateName: 'السبعين',
      status: true,
    ),
  ];

  @override
  Future<List<NetworkEntity>> getNetworks({
    int page = 1,
    int perPage = 20,
    String? search,
    String? status,
    int? governorateId,
    int? directorateId,
  }) async =>
      fakeNetworks;

  @override
  Future<List<PosEntity>> getPosList({
    int page = 1,
    int perPage = 20,
    String? search,
    String? status,
    int? governorateId,
    int? directorateId,
  }) async =>
      fakePosList;

  @override
  Future<List<NetworkPosEntity>> getNetworkPosList({
    int page = 1,
    int perPage = 20,
    int? networkId,
    int? posId,
    bool? status,
    String? search,
  }) async =>
      fakeContracts;

  @override
  Future<NetworkPosEntity?> createNetworkPos({
    required int networkId,
    required String posUuid,
    bool status = true,
  }) async =>
      fakeContracts.first;

  @override
  Future<bool> toggleNetworkPosStatus(int networkPosId) async => true;

  @override
  Future<bool> approveNetwork(int networkId) async => true;

  @override
  Future<bool> rejectNetwork(int networkId, String reason) async => true;

  @override
  Future<bool> approvePos(int posId) async => true;

  @override
  Future<bool> rejectPos(int posId, String reason) async => true;

  @override
  Future<PosWalletEntity?> getPosWallet({
    required int networkId,
    required int posId,
  }) async =>
      PosWalletEntity(
        walletId: 1,
        networkId: networkId,
        posId: posId,
        walletUuid: 'wallet-uuid-1',
        walletBalance: 250000.0,
        status: true,
        accountingStatus: 'CREDIT',
        accountingStatusLabel: 'دائن للشبكة',
        isOverdrawn: false,
        debitAmount: 0.0,
        creditAmount: 250000.0,
        networkName: 'شبكة يمن نت التجريبية',
        posName: 'مركز المدينة للاتصالات',
      );

  @override
  Future<bool> transferNetworkToPos({
    required int networkId,
    required int posId,
    required double amount,
    String? statement,
  }) async =>
      true;

  @override
  Future<bool> transferPosToNetwork({
    required int networkId,
    required int posId,
    required double amount,
    String? statement,
  }) async =>
      true;

  @override
  Future<List<PosWalletLogEntity>> getPosWalletLogs({
    required int networkId,
    required int posId,
    int page = 1,
    int perPage = 20,
  }) async =>
      [];
}

Widget buildTestWidget({
  required Widget child,
  required Size size,
}) {
  return MediaQuery(
    data: MediaQueryData(size: size),
    child: ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, _) => GetMaterialApp(
        theme: AppThemes.light,
        home: Scaffold(
          body: SizedBox(
            width: size.width,
            height: size.height,
            child: child,
          ),
        ),
      ),
    ),
  );
}

void main() {
  late FakePartnersRepository fakeRepo;
  late PartnersController controller;

  setUp(() {
    Get.reset();
    fakeRepo = FakePartnersRepository();

    final getNetworksUseCase = GetNetworksUseCase(fakeRepo);
    final getPosListUseCase = GetPosListUseCase(fakeRepo);
    final getNetworkPosListUseCase = GetNetworkPosListUseCase(fakeRepo);
    final toggleNetworkPosStatusUseCase = ToggleNetworkPosStatusUseCase(fakeRepo);
    final createNetworkPosUseCase = CreateNetworkPosUseCase(fakeRepo);
    final approvePartnerUseCase = ApprovePartnerUseCase(fakeRepo);
    final rejectPartnerUseCase = RejectPartnerUseCase(fakeRepo);
    final getPosWalletUseCase = GetPosWalletUseCase(fakeRepo);
    final transferPosWalletBalanceUseCase = TransferPosWalletBalanceUseCase(fakeRepo);
    final getPosWalletLogsUseCase = GetPosWalletLogsUseCase(fakeRepo);

    controller = Get.put(
      PartnersController(
        getNetworksUseCase: getNetworksUseCase,
        getPosListUseCase: getPosListUseCase,
        getNetworkPosListUseCase: getNetworkPosListUseCase,
        toggleNetworkPosStatusUseCase: toggleNetworkPosStatusUseCase,
        createNetworkPosUseCase: createNetworkPosUseCase,
        approvePartnerUseCase: approvePartnerUseCase,
        rejectPartnerUseCase: rejectPartnerUseCase,
      ),
    );

    Get.put(
      PosWalletSheetController(
        getPosWalletUseCase: getPosWalletUseCase,
        transferPosWalletBalanceUseCase: transferPosWalletBalanceUseCase,
        getPosWalletLogsUseCase: getPosWalletLogsUseCase,
      ),
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('PartnersScreen Responsive & Architectural Tests', () {
    testWidgets(
      'renders without overflow on compact mobile (320x640)',
      (tester) async {
        const size = Size(320, 640);
        tester.view.physicalSize = Size(size.width * 2, size.height * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          buildTestWidget(
            child: const Scaffold(body: PartnersScreen()),
            size: size,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(PartnersScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'renders without overflow on standard phone (390x844)',
      (tester) async {
        const size = Size(390, 844);
        tester.view.physicalSize = Size(size.width * 2, size.height * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          buildTestWidget(
            child: const Scaffold(body: PartnersScreen()),
            size: size,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(PartnersScreen), findsOneWidget);
        expect(find.text('شبكة يمن نت التجريبية'), findsWidgets);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'renders without overflow on tablet (768x1024)',
      (tester) async {
        const size = Size(768, 1024);
        tester.view.physicalSize = Size(size.width * 2, size.height * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          buildTestWidget(
            child: const Scaffold(body: PartnersScreen()),
            size: size,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(PartnersScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'switching segments switches between Networks, POS, and Contracts',
      (tester) async {
        const size = Size(390, 844);
        tester.view.physicalSize = Size(size.width * 2, size.height * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          buildTestWidget(
            child: const Scaffold(body: PartnersScreen()),
            size: size,
          ),
        );
        await tester.pumpAndSettle();

        // Initially on Networks (tab 0)
        expect(find.byType(NetworkItemCard), findsOneWidget);

        // Switch to POS (tab 1)
        controller.changeSegment(1);
        await tester.pumpAndSettle();
        expect(find.byType(PosItemCard), findsOneWidget);

        // Switch to Contracts (tab 2)
        controller.changeSegment(2);
        await tester.pumpAndSettle();
        expect(find.byType(NetworkPosItemCard), findsOneWidget);

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'PartnerDetailsSheet opens and displays Network details properly',
      (tester) async {
        const size = Size(390, 844);
        tester.view.physicalSize = Size(size.width * 2, size.height * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          buildTestWidget(
            child: Scaffold(
              body: PartnerDetailsSheet(
                network: fakeRepo.fakeNetworks.first,
                controller: controller,
              ),
            ),
            size: size,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('شبكة يمن نت التجريبية'), findsOneWidget);
        expect(find.text('شارع حدة العام'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'LinkPartnerSheet opens and displays selectors properly',
      (tester) async {
        const size = Size(390, 844);
        tester.view.physicalSize = Size(size.width * 2, size.height * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          buildTestWidget(
            child: Scaffold(
              body: LinkPartnerSheet(
                controller: controller,
              ),
            ),
            size: size,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('اختر مزود الشبكة...'), findsOneWidget);
        expect(find.text('اختر نقطة البيع...'), findsOneWidget);
        expect(find.text('تفعيل العقد مباشرة'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
