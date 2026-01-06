import 'package:dio/dio.dart';

class GoogleSheetsService {
  final Dio _dio = Dio();

  static const String sheetId = '1HfeCdmCyrjB_KLLK41vidavkAL6d6Zn7ogq_gu5nfHE';
  static const String sheetName = 'Sheet1';

  Future<List<Map<String, dynamic>>> getPayments() async {
    try {
      final url =
          'https://docs.google.com/spreadsheets/d/$sheetId/gviz/tq?tqx=out:csv&sheet=$sheetName';

      final response = await _dio.get<dynamic>(url);

      if (response.statusCode == 200) {
        final csvData = response.data.toString();
        final payments = _parseCsv(csvData);

        return payments;
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403 || e.response?.statusCode == 404) {
        throw Exception();
      }

      throw Exception('lỗi kết nối: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  Future<Map<String, dynamic>?> getLatestPayment() async {
    try {
      final url =
          'https://docs.google.com/spreadsheets/d/$sheetId/gviz/tq?tqx=out:csv&sheet=$sheetName';

      final response = await _dio.get<dynamic>(url);

      if (response.statusCode == 200) {
        final csvData = response.data.toString();
        final lines = csvData.split('\n');

        if (lines.length < 2) {
          return null;
        }

        final headers = _parseCsvLine(lines[0]);

        final firstLine = lines[1].trim();
        if (firstLine.isEmpty) return null;

        final values = _parseCsvLine(firstLine);
        if (values.length != headers.length) return null;

        final Map<String, dynamic> payment = {};
        for (var j = 0; j < headers.length; j++) {
          payment[headers[j]] = values[j];
        }

        return payment;
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      return null;
    }
  }

  List<Map<String, dynamic>> _parseCsv(String csvData) {
    final lines = csvData.split('\n');
    if (lines.isEmpty) return [];

    final headers = _parseCsvLine(lines[0]);

    final List<Map<String, dynamic>> result = [];
    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final values = _parseCsvLine(line);

      if (values.length != headers.length) {
        continue;
      }

      final Map<String, dynamic> row = {};
      for (var j = 0; j < headers.length; j++) {
        row[headers[j]] = values[j];
      }
      result.add(row);
    }

    return result;
  }

  List<String> _parseCsvLine(String line) {
    final List<String> result = [];
    final buffer = StringBuffer();
    bool inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        result.add(buffer.toString().trim());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }

    result.add(buffer.toString().trim());
    return result;
  }

  Future<Map<String, dynamic>?> findPayment({
    required String transferContent,
    required double expectedAmount,
    Duration timeWindow = const Duration(
      hours: 24,
    ), // Tăng lên 24h để user có thời gian test
  }) async {
    try {
      final latestPayment = await getLatestPayment();

      if (latestPayment != null) {
        final description =
            latestPayment['Mô tả']?.toString().toUpperCase() ?? '';
        final amountStr =
            latestPayment['Giá trị']
                ?.toString()
                .replaceAll(',', '')
                .replaceAll('.', '') ??
            '0';
        final amount = double.tryParse(amountStr) ?? 0;
        final dateStr = latestPayment['Ngày diễn ra']?.toString() ?? '';

        final normalizedTransferContent = _normalizeText(transferContent);
        final normalizedDescription = _normalizeText(description);

        final isContentMatch = normalizedDescription.contains(
          normalizedTransferContent,
        );
        final isAmountMatch =
            amount >= expectedAmount * 0.99 && amount <= expectedAmount * 1.01;

        if (isContentMatch && isAmountMatch) {
          if (_isWithinTimeWindow(dateStr, timeWindow)) {
            return latestPayment;
          } else {}
        } else {}
      }

      final allPayments = await getPayments();

      for (var payment in allPayments) {
        final description = payment['Mô tả']?.toString().toUpperCase() ?? '';
        final amountStr =
            payment['Giá trị']
                ?.toString()
                .replaceAll(',', '')
                .replaceAll('.', '') ??
            '0';
        final amount = double.tryParse(amountStr) ?? 0;
        final dateStr = payment['Ngày diễn ra']?.toString() ?? '';

        if (!_isWithinTimeWindow(dateStr, timeWindow)) {
          continue;
        }

        final normalizedTransferContent = _normalizeText(transferContent);
        final normalizedDescription = _normalizeText(description);

        final isContentMatch = normalizedDescription.contains(
          normalizedTransferContent,
        );
        final isAmountMatch =
            amount >= expectedAmount * 0.99 && amount <= expectedAmount * 1.01;

        if (isContentMatch && isAmountMatch) {
          return payment;
        }
      }

      return null;
    } catch (e) {
      throw Exception('Lỗi tìm payment: $e');
    }
  }

  String _normalizeText(String text) {
    // XÓA dấu gạch dưới _ vì app banking thường tự động xóa ký tự này
    // VD: User nhập "VERIFY_ABC123" nhưng sheet nhận "VERIFYABC123"
    return text
        .toUpperCase()
        .replaceAll('_', '') // Xóa dấu gạch dưới để match với banking app
        .replaceAll('-', '') // Xóa dấu gạch ngang
        .replaceAll(' ', '') // Xóa khoảng trắng
        .replaceAll('.', '') // Xóa dấu chấm
        .replaceAll(',', ''); // Xóa dấu phẩy
  }

  bool _isWithinTimeWindow(String dateStr, Duration timeWindow) {
    try {
      if (dateStr.isEmpty) return true;

      DateTime? transactionDate;

      if (dateStr.contains('/')) {
        final parts = dateStr.split(' ');
        if (parts.length >= 2) {
          final dateParts = parts[0].split('/');
          final timeParts = parts[1].split(':');

          if (dateParts.length == 3 && timeParts.length >= 2) {
            final day = int.tryParse(dateParts[0]);
            final month = int.tryParse(dateParts[1]);
            final year = int.tryParse(dateParts[2]);
            final hour = int.tryParse(timeParts[0]);
            final minute = int.tryParse(timeParts[1]);

            if (day != null &&
                month != null &&
                year != null &&
                hour != null &&
                minute != null) {
              transactionDate = DateTime(year, month, day, hour, minute);
            }
          }
        }
      } else if (dateStr.contains('-')) {
        transactionDate = DateTime.tryParse(dateStr);
      }

      if (transactionDate == null) {
        return true;
      }

      final now = DateTime.now();
      final difference = now.difference(transactionDate);

      return difference <= timeWindow;
    } catch (e) {
      return true;
    }
  }

  @Deprecated('Use findPayment() instead')
  Future<Map<String, dynamic>?> findPaymentOld({
    required String transferContent,
    required double expectedAmount,
  }) async {
    try {
      final payments = await getPayments();

      for (var payment in payments) {
        final description = payment['Mô tả']?.toString().toUpperCase() ?? '';
        final amountStr =
            payment['Giá trị']
                ?.toString()
                .replaceAll(',', '')
                .replaceAll('.', '') ??
            '0';
        final amount = double.tryParse(amountStr) ?? 0;

        if (description.contains(transferContent.toUpperCase()) &&
            amount >= expectedAmount) {
          return payment;
        }
      }

      return null;
    } catch (e) {
      throw Exception('Lỗi tìm payment: $e');
    }
  }

  Future<bool> testConnection() async {
    try {
      final payments = await getPayments();

      if (payments.isNotEmpty) {}

      return true;
    } catch (e) {
      return false;
    }
  }
}
