import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  final VoidCallback callToSignIn;
  const SignUpPage(
      {Key? key,
      required this.callToSignIn,
      required Null Function() callToSingIn})
      : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _password2Controller.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_passwordController.text == _password2Controller.text) {
      try {
        final UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        final User user = userCredential.user!;
        final String uid = user.uid;

        // สร้างเอกสารบน Cloud Firestore ในคอลเลคชัน "users" ด้วย UID ของผู้ใช้ใน Field "IDusers"
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'IDusers': uid,
          // สามารถเพิ่มข้อมูลเพิ่มเติมของผู้ใช้ตามความต้องการได้
        });

        // สมัครสมาชิกสำเร็จ คุณสามารถดำเนินการต่อได้ตามต้องการ
        widget.callToSignIn();
      } catch (error) {
        // จัดการข้อผิดพลาดที่เกิดขึ้นในกรณีที่สมัครสมาชิกไม่สำเร็จ
        print('เกิดข้อผิดพลาดในการสมัครสมาชิก: $error');
      }
    } else {
      // Passwords do not match
      print('รหัสผ่านไม่ตรงกัน');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ลงทะเบียน'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'SignUp',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'อีเมล',
                labelStyle: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'รหัสผ่าน'),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _password2Controller,
              decoration: const InputDecoration(labelText: 'ยืนยันรหัสผ่าน'),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _handleSignUp,
              child: const Text(
                'ลงทะเบียน',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    // กลับไปหน้าล็อกอิน
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'กลับ',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
