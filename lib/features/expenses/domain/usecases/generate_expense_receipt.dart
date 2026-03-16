import 'dart:typed_data';
import '../../../../core/utils/pdf_generator.dart';
import '../entities/expense.dart';

/// Use case for generating expense receipt PDF
class GenerateExpenseReceipt {
  Future<Uint8List> call(Expense expense) async {
    return await PdfGenerator.generateExpenseReceipt(expense);
  }

  Future<String> saveToDevice(Expense expense) async {
    final pdfBytes = await call(expense);
    final fileName = 'expense_receipt_${expense.id}.pdf';
    return await PdfGenerator.savePdfToDevice(pdfBytes, fileName);
  }
}