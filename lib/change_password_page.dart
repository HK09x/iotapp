import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เปลี่ยนรหัสผ่าน'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'รหัสผ่านเดิม'),
              ),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'รหัสผ่านใหม่'),
              ),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'ยืนยันรหัสผ่านใหม่'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;

                  if (user != null) {
                    String newPassword = _newPasswordController.text;
                    String confirmPassword = _confirmPasswordController.text;

                    if (newPassword == confirmPassword) {
                      try {
                        // เปลี่ยนรหัสผ่าน
                        await user.updatePassword(newPassword);

                        // แจ้งเตือนหรือทำอย่างอื่นตามที่คุณต้องการ
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('เปลี่ยนรหัสผ่านสำเร็จ'),
                          ),
                        );

                        // หลังจากเปลี่ยนรหัสผ่านเรียบร้อยแล้ว นำผู้ใช้กลับไปยังหน้า "ProfilePage"
                        Navigator.of(context).pop();
                      } catch (error) {
                        // กรณีเกิดข้อผิดพลาดในการเปลี่ยนรหัสผ่าน
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('เกิดข้อผิดพลาดในการเปลี่ยนรหัสผ่าน: $error'),
                          ),
                        );
                      }
                    } else {
                      // กรณีรหัสผ่านใหม่และการยืนยันรหัสผ่านใหม่ไม่ตรงกัน
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('รหัสผ่านใหม่และการยืนยันรหัสผ่านใหม่ไม่ตรงกัน'),
                        ),
                      );
                    }
                  }
                },
                child: const Text('บันทึกรหัสผ่านใหม่'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // ต้องคำนึงถึงการลบ Controller เมื่อไม่ได้ใช้งานอีกต่อไป
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
