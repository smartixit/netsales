import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/features/expenses/data/models/expense_attachment_model.dart';
import 'package:netsales/features/expenses/data/models/expense_item_model.dart';
import 'package:netsales/features/expenses/data/models/expense_model.dart';
import 'package:netsales/features/expenses/data/models/expense_summary_model.dart';
import 'package:netsales/features/expenses/data/models/new_expense_item_input_model.dart';
import 'package:netsales/features/expenses/domain/entities/expense_attachment_entity.dart';
import 'package:netsales/features/expenses/domain/entities/new_expense_item_input_entity.dart';

void main() {
  group('ExpenseModel and ExpenseEntity Unit Tests', () {
    test(
      'ExpenseModel.fromJson should parse correctly with items and attachments',
      () {
        final json = {
          'expense_id': 101,
          'expense_uuid': 'EXP-2026-001',
          'network_id': 5,
          'expense_total_amount': 7500.50,
          'expense_date': '2026-03-15T10:30:00.000Z',
          'created_by': 12,
          'created_at': '2026-03-15T10:30:00.000Z',
          'updated_at': '2026-03-15T10:30:00.000Z',
          'network': {
            'name': 'شبكة الرواد للاتصالات',
            'logo_url': 'https://example.com/logo.png',
            'phone': '777123456',
          },
          'created_by_user': {'full_name': 'أحمد المحاسب'},
          'items': [
            {
              'item_id': 1,
              'expense_id': 101,
              'item_statement': 'إيجار برج الإرسال',
              'item_amount': 5000.0,
              'created_at': '2026-03-15T10:30:00.000Z',
            },
            {
              'item_id': 2,
              'expense_id': 101,
              'item_statement': 'صيانة بطاريات الطاقة الشمسية',
              'item_amount': 2500.50,
              'created_at': '2026-03-15T10:30:00.000Z',
            },
          ],
          'attachments': [
            {
              'attachment_id': 10,
              'expense_id': 101,
              'attachment_name': 'receipt_01.pdf',
              'attachment_path': 'expenses/101/receipt_01.pdf',
              'attachment_size': 204800,
              'attachment_mime': 'application/pdf',
              'file_url': 'https://example.com/receipt_01.pdf',
              'created_at': '2026-03-15T10:30:00.000Z',
            },
          ],
        };

        final model = ExpenseModel.fromJson(json);

        expect(model.expenseId, 101);
        expect(model.expenseUuid, 'EXP-2026-001');
        expect(model.networkId, 5);
        expect(model.expenseTotalAmount, 7500.50);
        expect(model.networkName, 'شبكة الرواد للاتصالات');
        expect(model.createdByName, 'أحمد المحاسب');
        expect(model.items.length, 2);
        expect(model.items.first.itemStatement, 'إيجار برج الإرسال');
        expect(model.items.first.itemAmount, 5000.0);
        expect(model.attachments.length, 1);
        expect(model.attachments.first.isPdf, isTrue);
        expect(model.attachments.first.isImage, isFalse);
        expect(model.displayReference, 'EXP-2026-001');
        expect(model.hasAttachments, isTrue);
      },
    );

    test('ExpenseModel.toJson should serialize correctly', () {
      final model = ExpenseModel(
        expenseId: 202,
        expenseUuid: 'EXP-202',
        networkId: 3,
        expenseTotalAmount: 1200.0,
        expenseDate: DateTime(2026, 4, 1),
      );

      final json = model.toJson();

      expect(json['expense_id'], 202);
      expect(json['expense_uuid'], 'EXP-202');
      expect(json['network_id'], 3);
      expect(json['expense_total_amount'], 1200.0);
    });

    test('ExpenseItemModel.fromJson and toJson should preserve attributes', () {
      final json = {
        'item_id': 55,
        'expense_id': 101,
        'item_statement': 'كروت كهرباء تجارية',
        'item_amount': 300.0,
      };

      final item = ExpenseItemModel.fromJson(json);
      expect(item.itemId, 55);
      expect(item.itemStatement, 'كروت كهرباء تجارية');
      expect(item.itemAmount, 300.0);

      final serialized = item.toJson();
      expect(serialized['item_id'], 55);
      expect(serialized['item_statement'], 'كروت كهرباء تجارية');
    });

    test('ExpenseAttachmentModel getters detect file types accurately', () {
      const pdfAttachment = ExpenseAttachmentModel(
        attachmentId: 1,
        expenseId: 10,
        attachmentName: 'contract.pdf',
        attachmentPath: 'path/to/contract.pdf',
        attachmentSize: 1048576,
        attachmentMime: 'application/pdf',
      );

      expect(pdfAttachment.isPdf, isTrue);
      expect(pdfAttachment.isImage, isFalse);
      expect(pdfAttachment.formattedSize, '1.00 MB');

      const imageAttachment = ExpenseAttachmentEntity(
        attachmentId: 2,
        expenseId: 10,
        attachmentName: 'invoice_photo.jpg',
        attachmentPath: 'path/to/photo.jpg',
        attachmentSize: 51200,
        attachmentMime: 'image/jpeg',
      );

      expect(imageAttachment.isImage, isTrue);
      expect(imageAttachment.isPdf, isFalse);
      expect(imageAttachment.formattedSize, '50.0 KB');
    });

    test('ExpenseSummaryModel.fromJson parses statistics accurately', () {
      final json = {
        'total_count': 45,
        'total_amount': 250000.0,
        'this_month_amount': 45000.0,
        'today_amount': 3500.0,
      };

      final summary = ExpenseSummaryModel.fromJson(json);

      expect(summary.totalCount, 45);
      expect(summary.totalAmount, 250000.0);
      expect(summary.thisMonthAmount, 45000.0);
      expect(summary.todayAmount, 3500.0);
    });

    test('NewExpenseItemInputModel converts to json correctly', () {
      const input = NewExpenseItemInputEntity(
        itemStatement: 'صيانة راوتر',
        itemAmount: 1500.0,
      );

      final model = NewExpenseItemInputModel.fromEntity(input);
      final json = model.toJson();
      expect(json['item_statement'], 'صيانة راوتر');
      expect(json['item_amount'], 1500.0);
    });
  });
}
