// Format thời gian thành chuỗi dễ đọc 
class TimeUtils {
      static String timeAgo(dynamic dateTime) {
    try {
      DateTime? date;
      
      if (dateTime is String) {
        date = DateTime.parse(dateTime);
      } else if (dateTime is DateTime) {
        date = dateTime;
      } else {
        return 'Vừa xong';
      }

      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) {
        final years = (difference.inDays / 365).floor();
        return '$years năm trước';
      } else if (difference.inDays > 30) {
        final months = (difference.inDays / 30).floor();
        return '$months tháng trước';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} ngày trước';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} giờ trước';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} phút trước';
      } else if (difference.inSeconds > 5) {
        return '${difference.inSeconds} giây trước';
      } else {
        return 'Vừa xong';
      }
    } catch (e) {
      return 'Vừa xong';
    }
  }

      static String formatDate(dynamic dateTime) {
    try {
      DateTime? date;
      
      if (dateTime is String) {
        date = DateTime.parse(dateTime);
      } else if (dateTime is DateTime) {
        date = dateTime;
      } else {
        return '';
      }

      final months = ['Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6', 
                     'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'];
      
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return '';
    }
  }
}

