import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socail/services/firebase_profile_service.dart';
import 'package:socail/models/user.dart' as app_user;

class EditProfilePage extends StatefulWidget {
  final app_user.User user;

  const EditProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _profileService = FirebaseProfileService();
  final _imagePicker = ImagePicker();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;

  bool _isLoading = false;
  XFile? _selectedImage;
  String? _uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.user.firstName ?? '');
    _lastNameController =
        TextEditingController(text: widget.user.lastName ?? '');
    _usernameController =
        TextEditingController(text: widget.user.username ?? '');
    _bioController = TextEditingController(text: widget.user.bio ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<ImageProvider?> _getImageProvider() async {
    if (_selectedImage != null) {
      if (kIsWeb) {
        
        final bytes = await _selectedImage!.readAsBytes();
        return MemoryImage(bytes);
      } else {
        
        return FileImage(File(_selectedImage!.path));
      }
    } else if (widget.user.imgUrl.isNotEmpty) {
      return NetworkImage(widget.user.imgUrl);
    }
    return null;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể chọn ảnh: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User không được xác thực');
      }


      
      if (_selectedImage != null) {
        _uploadedImageUrl = await _profileService.uploadAvatar(_selectedImage!);
        if (_uploadedImageUrl != null) {
        } else {
          throw Exception('Không thể tải lên ảnh đại diện');
        }
      }

      final success = await _profileService.updateUserProfile(
        userId: currentUser.uid,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        username: _usernameController.text.trim(),
        bio: _bioController.text.trim(),
      );


      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã cập nhật hồ sơ thành công'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); 
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể cập nhật hồ sơ'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Chỉnh Sửa Hồ Sơ',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: Text(
              'Lưu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _isLoading ? Colors.grey : Color(0xFFE91E63),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Center(
                      child: Stack(
                        children: [
                          FutureBuilder<ImageProvider?>(
                            future: _getImageProvider(),
                            builder: (context, snapshot) {
                              return CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: snapshot.data,
                                child: snapshot.data == null
                                    ? Icon(Icons.person,
                                        size: 50, color: Colors.grey[600])
                                    : null,
                              );
                            },
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFE91E63),
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt, size: 20),
                                color: Colors.white,
                                onPressed: _pickImage,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    
                    TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        labelText: 'Tên',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên của bạn';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    
                    TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        labelText: 'Họ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập họ của bạn';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Tên người dùng',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.alternate_email),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên người dùng';
                        }
                        if (value.contains(' ')) {
                          return 'Tên người dùng không được chứa khoảng trắng';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    
                    TextFormField(
                      controller: _bioController,
                      decoration: InputDecoration(
                        labelText: 'Tiểu sử',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.description_outlined),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                      maxLength: 150,
                    ),
                    const SizedBox(height: 24),

                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Lưu Thay Đổi',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

