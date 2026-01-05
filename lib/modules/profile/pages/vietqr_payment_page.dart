import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:overlay_support/overlay_support.dart';
import '../../../services/firebase_payment_service.dart';
import '../../../values/app_theme.dart';

class VietQRPaymentPage extends StatefulWidget {
  final String userId;
  final String userName;

  const VietQRPaymentPage({
    Key? key,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  @override
  State<VietQRPaymentPage> createState() => _VietQRPaymentPageState();
}

class _VietQRPaymentPageState extends State<VietQRPaymentPage> {
  final _paymentService = FirebasePaymentService();
  String? _transferContent;
  String? _qrUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePayment();
  }

  Future<void> _initializePayment() async {
    setState(() => _isLoading = true);

    try {
      
      final existingTransaction =
          await _paymentService.getPendingTransaction(widget.userId);

      if (existingTransaction != null) {
        final transferContent = existingTransaction['transfer_content'] as String;
        setState(() {
          _transferContent = transferContent;
          _qrUrl = _paymentService.generateVietQRUrl(
            transferContent: transferContent,
          );
        });
      } else {
        
        final transferContent = _paymentService.generateTransferContent(widget.userId);
        final qrUrl = _paymentService.generateVietQRUrl(
          transferContent: transferContent,
        );

        
        await _paymentService.createPendingTransaction(
          userId: widget.userId,
          transferContent: transferContent,
          amount: FirebasePaymentService.verificationPrice,
        );

        setState(() {
          _transferContent = transferContent;
          _qrUrl = qrUrl;
        });
      }
    } catch (e) {
      if (mounted) {
        toast('Lỗi: ${e.toString()}');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    toast('Đã sao chép $label');
  }

  Future<void> _confirmPaymentManually() async {
    if (_transferContent == null) {
      toast('Lỗi: Thông tin giao dịch không hợp lệ');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận thanh toán'),
        content: const Text(
          'Bạn xác nhận đã chuyển khoản đúng số tiền và nội dung?\n\n'
          'Hệ thống sẽ kiểm tra giao dịch của bạn trên ngân hàng.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Kiểm tra'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      // Kiểm tra giao dịch trên Google Sheets
      final isPaymentVerified = await _paymentService.checkAndVerifyPayment(
        userId: widget.userId,
        transferContent: _transferContent!,
        amount: FirebasePaymentService.verificationPrice,
      );
      
      if (isPaymentVerified) {
        if (mounted) {
          toast('🎉 Thanh toán thành công! Tài khoản đã được xác minh.');
          Navigator.of(context).pop(true);
        }
      } else {
        // Kiểm tra xem user đã được verify chưa (có thể đã verify trước đó)
        final isVerified = await _paymentService.isUserVerified(widget.userId);
        
        if (isVerified) {
          if (mounted) {
            toast('Tài khoản đã được xác minh thành công!');
            Navigator.of(context).pop(true);
          }
        } else {
          toast('Chưa tìm thấy giao dịch của bạn.\n\nVui lòng kiểm tra:\n- Đã chuyển khoản chưa?\n- Số tiền đúng chưa?\n- Nội dung chuyển khoản đúng chưa?\n\nĐợi vài phút rồi thử lại.');
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Hàm refresh để sử dụng trong tương lai nếu cần
  // ignore: unused_element
  Future<void> _refreshTransaction() async {
    if (_transferContent == null) {
      toast('Lỗi: Thông tin giao dịch không hợp lệ');
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      
      
      if (kIsWeb) {
        final isVerified = await _paymentService.isUserVerified(widget.userId);
        
        if (isVerified) {
          if (mounted) {
            toast('Tài khoản đã được xác minh thành công!');
            Navigator.of(context).pop(true);
          }
        } else {
          if (mounted) {
            
            showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Xác minh thanh toán'),
                content: const Text(
                  'Trên nền tảng Web, tính năng kiểm tra tự động chưa khả dụng.\n\n'
                  'Sau khi chuyển khoản, vui lòng:\n'
                  '1. Chụp ảnh bill chuyển khoản\n'
                  '2. Gửi cho admin qua email/chat\n'
                  '3. Admin sẽ xác nhận trong vòng 24h\n\n'
                  'Hoặc test trên ứng dụng Android/iOS để tự động xác minh.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Đã hiểu'),
                  ),
                ],
              ),
            );
          }
        }
        return;
      }

      
      final isPaymentVerified = await _paymentService.checkAndVerifyPayment(
        userId: widget.userId,
        transferContent: _transferContent!,
        amount: FirebasePaymentService.verificationPrice,
      );
      
      if (isPaymentVerified) {
        if (mounted) {
          toast('🎉 Thanh toán thành công! Tài khoản đã được xác minh.');
          Navigator.of(context).pop(true);
        }
      } else {
        
        final isVerified = await _paymentService.isUserVerified(widget.userId);
        
        if (isVerified) {
          if (mounted) {
            toast('Tài khoản đã được xác minh thành công!');
            Navigator.of(context).pop(true);
          }
        } else {
          toast('🎉 Chưa nhận được thanh toán. Vui lòng đợi vài phút và thử lại.');
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().contains('CORS')
            ? 'Tính năng này chỉ hoạt động trên ứng dụng di động.'
            : 'Lỗi: ${e.toString()}';
        toast(errorMsg);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhận Tích Xanh'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.verified,
                            size: 60,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Nhận Tích Xanh Xác Minh',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Chỉ với ${FirebasePaymentService.formatCurrency(FirebasePaymentService.verificationPrice)}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tài khoản của bạn sẽ được xác minh và nhận dấu tích xanh uy tín',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  
                  const Text(
                    'Hướng dẫn thanh toán:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInstructionStep(
                    '1',
                    'Mở ứng dụng ngân hàng của bạn',
                  ),
                  _buildInstructionStep(
                    '2',
                    'Quét mã QR hoặc chuyển khoản theo thông tin bên dưới',
                  ),
                  _buildInstructionStep(
                    '3',
                    'Đảm bảo nội dung chuyển khoản chính xác',
                  ),
                  _buildInstructionStep(
                    '4',
                    'Sau khi chuyển khoản, nhấn "Kiểm tra thanh toán"',
                  ),

                  const SizedBox(height: 24),

                  
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Quét mã QR để thanh toán',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: _qrUrl == null
                                ? Container(
                                    width: 280,
                                    height: 280,
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : Image.network(
                                    _qrUrl!,
                                    width: 280,
                                    height: 280,
                                    fit: BoxFit.contain,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return SizedBox(
                                        width: 280,
                                        height: 280,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 280,
                                        height: 280,
                                        color: Colors.grey[200],
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.error_outline, size: 40, color: Colors.grey),
                                            const SizedBox(height: 8),
                                            const Text(
                                              'Không thể tải QR code',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Vui lòng kiểm tra kết nối mạng',
                                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Thông tin chuyển khoản',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            'Ngân hàng',
                            FirebasePaymentService.bankId,
                            FirebasePaymentService.bankId,
                          ),
                          _buildInfoRow(
                            'Số tài khoản',
                            FirebasePaymentService.accountNo,
                            FirebasePaymentService.accountNo,
                          ),
                          _buildInfoRow(
                            'Tên tài khoản',
                            FirebasePaymentService.accountName,
                            FirebasePaymentService.accountName,
                          ),
                          _buildInfoRow(
                            'Số tiền',
                            FirebasePaymentService.formatCurrency(
                                FirebasePaymentService.verificationPrice),
                            FirebasePaymentService.verificationPrice.toString(),
                          ),
                          _buildInfoRow(
                            'Nội dung',
                            _transferContent ?? '',
                            _transferContent ?? '',
                            isImportant: true,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.orange[700]),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Lưu ý: Vui lòng nhập CHÍNH XÁC nội dung chuyển khoản. Sau khi chuyển khoản, nhấn "Xác nhận đã thanh toán" bên dưới.',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  
                  ElevatedButton(
                    onPressed: _isLoading ? null : _confirmPaymentManually,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Xác nhận đã thanh toán',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Hủy'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                text,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, String copyValue,
      {bool isImportant = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isImportant ? FontWeight.bold : FontWeight.w500,
                    color: isImportant ? AppTheme.primaryColor : Colors.black,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                onPressed: () => _copyToClipboard(copyValue, label),
                tooltip: 'Sao chép',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          if (isImportant) ...[
            const SizedBox(height: 4),
            Text(
              '⚠️ Vui lòng sao chép chính xác',
              style: TextStyle(
                fontSize: 11,
                color: Colors.orange[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

