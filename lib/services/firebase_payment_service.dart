import 'package:cloud_firestore/cloud_firestore.dart';
import 'google_sheets_service.dart';

class FirebasePaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSheetsService _sheetsApi = GoogleSheetsService();

  static const String bankId = 'MB';
  static const String accountNo = '0981115151';
  static const String accountName = 'TRUONG TRUONG PHUC';
  static const String template = 'compact2';
  static const double verificationPrice = 50000;

  /// Tạo mã nội dung chuyển khoản cố định cho user
  /// Mỗi user chỉ có 1 mã duy nhất để tránh trường hợp out app và nội dung bị thay đổi
  String generateTransferContent(String userId) {
    // Sử dụng userId làm mã cố định thay vì timestamp
    // Lấy 12 ký tự đầu của userId để mã ngắn gọn hơn
    final userCode = userId.length > 12
        ? userId.substring(0, 12).toUpperCase()
        : userId.toUpperCase().padRight(12, '0');
    return 'VERIFY_$userCode';
  }

  String generateVietQRUrl({required String transferContent, double? amount}) {
    final double finalAmount = amount ?? verificationPrice;

    final encodedContent = Uri.encodeComponent(transferContent);
    final encodedAccountName = Uri.encodeComponent(accountName);

    return 'https://img.vietqr.io/image/$bankId-$accountNo-compact2.png'
        '?amount=${finalAmount.toInt()}'
        '&addInfo=$encodedContent'
        '&accountName=$encodedAccountName';
  }

  String generateVietQRData({required String transferContent, double? amount}) {
    final double finalAmount = amount ?? verificationPrice;

    final url =
        'https://img.vietqr.io/image/$bankId-$accountNo-compact2.png'
        '?amount=${finalAmount.toInt()}'
        '&addInfo=${Uri.encodeComponent(transferContent)}'
        '&accountName=${Uri.encodeComponent(accountName)}';

    return url;
  }

  Future<void> createPendingTransaction({
    required String userId,
    required String transferContent,
    required double amount,
  }) async {
    try {
      await _firestore.collection('payment_transactions').add({
        'user_id': userId,
        'transfer_content': transferContent,
        'amount': amount,
        'status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'type': 'verification_badge',
      });
    } catch (e) {
      throw Exception('Lỗi khi tạo giao dịch: $e');
    }
  }

  /// Lấy giao dịch đang pending của user
  /// Nếu chưa có thì trả về null, nếu có rồi thì trả về để tái sử dụng
  Future<Map<String, dynamic>?> getPendingTransaction(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('payment_transactions')
          .where('user_id', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .where('type', isEqualTo: 'verification_badge')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Sắp xếp theo thời gian tạo để lấy giao dịch mới nhất
        final docs = querySnapshot.docs.toList();
        docs.sort((a, b) {
          final aTime = a.data()['created_at'] as Timestamp?;
          final bTime = b.data()['created_at'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime);
        });

        final doc = docs.first;
        return {'id': doc.id, ...doc.data()};
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi khi kiểm tra giao dịch: $e');
    }
  }

  /// Lấy hoặc tạo mã nội dung chuyển khoản cố định cho user
  /// Đảm bảo mỗi user luôn có 1 mã duy nhất
  Future<String> getOrCreateTransferContent(String userId) async {
    try {
      // Kiểm tra xem đã có giao dịch pending chưa
      final existingTransaction = await getPendingTransaction(userId);

      if (existingTransaction != null) {
        // Đã có giao dịch pending, trả về mã cũ
        return existingTransaction['transfer_content'] as String;
      }

      // Chưa có, tạo mã mới (nhưng mã này sẽ cố định dựa trên userId)
      return generateTransferContent(userId);
    } catch (e) {
      // Nếu lỗi, vẫn tạo mã cố định từ userId
      return generateTransferContent(userId);
    }
  }

  Future<void> confirmPayment({
    required String transactionId,
    required String userId,
  }) async {
    try {
      await _firestore
          .collection('payment_transactions')
          .doc(transactionId)
          .update({
            'status': 'verified',
            'verified_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          });

      // Try to update user, but don't fail if permission denied
      try {
        await _firestore.collection('users').doc(userId).update({
          'is_verified': true,
          'verified_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
      } catch (userUpdateError) {
        // Không throw error, vì transaction đã được mark verified
        // User verification sẽ được check từ payment_transactions
      }
    } catch (e) {
      if (e.toString().contains('PERMISSION_DENIED') ||
          e.toString().contains('permission')) {
        throw Exception(
          'Lỗi quyền truy cập Firestore. Vui lòng deploy Firestore rules:\n'
          'firebase deploy --only firestore:rules',
        );
      }
      throw Exception('Lỗi khi xác nhận thanh toán: $e');
    }
  }

  Future<bool> checkAndVerifyPayment({
    required String userId,
    required String transferContent,
    required double amount,
  }) async {
    try {
      final payment = await _sheetsApi.findPayment(
        transferContent: transferContent,
        expectedAmount: amount,
      );

      if (payment != null) {
        final pendingTrans = await getPendingTransaction(userId);

        if (pendingTrans != null) {
          final transContent = pendingTrans['transfer_content'] as String?;

          // Normalize cả 2 bên để so sánh
          final normalizedPending =
              transContent
                  ?.toUpperCase()
                  .replaceAll('_', '')
                  .replaceAll('-', '')
                  .replaceAll(' ', '') ??
              '';
          final normalizedExpected = transferContent
              .toUpperCase()
              .replaceAll('_', '')
              .replaceAll('-', '')
              .replaceAll(' ', '');

          if (normalizedPending == normalizedExpected) {
            await confirmPayment(
              transactionId: pendingTrans['id'] as String,
              userId: userId,
            );
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      throw Exception('Lỗi khi kiểm tra thanh toán: $e');
    }
  }

  Future<void> cancelTransaction(String transactionId) async {
    try {
      await _firestore
          .collection('payment_transactions')
          .doc(transactionId)
          .update({
            'status': 'cancelled',
            'updated_at': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Lỗi khi hủy giao dịch: $e');
    }
  }

  Future<bool> isUserVerified(String userId) async {
    try {
      // Kiểm tra trong users collection - đây là source of truth chính thức
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final isVerified = doc.data()?['is_verified'] as bool? ?? false;
        // Nếu users.is_verified = false (admin đã xóa verify) thì return false ngay
        // Không quan tâm payment_transactions có verified hay không
        if (isVerified == false) return false;
        if (isVerified == true) return true;
      }

      // Nếu user document không tồn tại hoặc không có field is_verified
      // Thì check payment_transactions làm fallback
      // (Trường hợp Firestore rules chưa deploy, user document chưa được update)
      final transSnapshot = await _firestore
          .collection('payment_transactions')
          .where('user_id', isEqualTo: userId)
          .where('status', isEqualTo: 'verified')
          .where('type', isEqualTo: 'verification_badge')
          .limit(1)
          .get();

      if (transSnapshot.docs.isNotEmpty) {
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getUserTransactions(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('payment_transactions')
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy lịch sử giao dịch: $e');
    }
  }

  static String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';
  }
}
