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

    String generateTransferContent(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'VERIFIED_${userId.substring(0, 8)}_$timestamp';
  }

      String generateVietQRUrl({
    required String transferContent,
    double? amount,
  }) {
    final double finalAmount = amount ?? verificationPrice;
    
    final encodedContent = Uri.encodeComponent(transferContent);
    final encodedAccountName = Uri.encodeComponent(accountName);
    
    return 'https://img.vietqr.io/image/$bankId-$accountNo-compact2.png'
        '?amount=${finalAmount.toInt()}'
        '&addInfo=$encodedContent'
        '&accountName=$encodedAccountName';
  }

    String generateVietQRData({
    required String transferContent,
    double? amount,
  }) {
    final double finalAmount = amount ?? verificationPrice;
    
    final url = 'https://img.vietqr.io/image/$bankId-$accountNo-compact2.png'
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

    Future<Map<String, dynamic>?> getPendingTransaction(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('payment_transactions')
          .where('user_id', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .where('type', isEqualTo: 'verification_badge')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        
        final docs = querySnapshot.docs.toList();
        docs.sort((a, b) {
          final aTime = a.data()['created_at'] as Timestamp?;
          final bTime = b.data()['created_at'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime); 
        });
        
        final doc = docs.first;
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi khi kiểm tra giao dịch: $e');
    }
  }

      Future<void> confirmPayment({
    required String transactionId,
    required String userId,
  }) async {
    try {
      
      await _firestore.collection('payment_transactions').doc(transactionId).update({
        'status': 'verified',
        'verified_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      
      await _firestore.collection('users').doc(userId).update({
        'is_verified': true,
        'verified_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
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
        
        if (pendingTrans != null && pendingTrans['transfer_content'] == transferContent) {
          
          await confirmPayment(
            transactionId: pendingTrans['id'] as String,
            userId: userId,
          );
          
          return true; 
        }
      } else {
      }

      return false; 
    } catch (e) {
      throw Exception('Lỗi khi kiểm tra thanh toán: $e');
    }
  }

    Future<void> cancelTransaction(String transactionId) async {
    try {
      await _firestore.collection('payment_transactions').doc(transactionId).update({
        'status': 'cancelled',
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi khi hủy giao dịch: $e');
    }
  }

    Future<bool> isUserVerified(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data()?['is_verified'] as bool? ?? false;
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
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy lịch sử giao dịch: $e');
    }
  }

    static String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}đ';
  }
}

