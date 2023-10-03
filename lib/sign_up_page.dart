import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iotapp/main.dart';

class SignUpPage extends StatefulWidget {
  final VoidCallback callToSignIn;
  const SignUpPage({
    Key? key,
    required this.callToSignIn,
  }) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _infoController = TextEditingController();
  final TextEditingController _imgController = TextEditingController();
  bool _isPhoneNumberValid = true;
  bool _isPasswordMatch = true;
  String? _emailErrorText;
  bool _isSignUpSuccess = false;

  Future<void> _handleSignUp() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _password2Controller.text.isEmpty ||
        _fullNameController.text.isEmpty ||
        _phoneNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอกข้อมูลให้ครบทุกช่อง'),
        ),
      );
    } else if (_phoneNumberController.text.length != 10) {
      setState(() {
        _isPhoneNumberValid = false;
      });
    } else if (_passwordController.text == _password2Controller.text) {
      setState(() {
        _isPasswordMatch = true;
        _emailErrorText = null;
      });

      try {
        final UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        final User user = userCredential.user!;
        final String uid = user.uid;
        final String fullName = _fullNameController.text;
        final String phoneNumber = _phoneNumberController.text;
        final String email = _emailController.text;
        final String img = _imgController.text;
        final String info = _infoController.text;

        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'ID_users': uid,
          'Full_Name': fullName,
          'Phone_Number': phoneNumber,
          'Email': email,
          'img': img,
          'info': info,
        });

        widget.callToSignIn();
        _isSignUpSuccess = true;
      } on FirebaseAuthException catch (error) {
        if (error.code == 'email-already-in-use') {
          setState(() {
            _emailErrorText = 'อีเมลนี้ถูกใช้งานแล้ว';
          });
        } else {
          print('เกิดข้อผิดพลาดในการสมัครสมาชิก: ${error.message}');
        }
      }
    } else {
      setState(() {
        _isPasswordMatch = false;
      });
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
              decoration: InputDecoration(
                labelText: 'อีเมล',
                labelStyle: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
                errorText: _emailErrorText,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(labelText: 'ชื่อ'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneNumberController,
              onChanged: (value) {
                setState(() {
                  if (value.length == 10) {
                    _isPhoneNumberValid = true;
                  } else {
                    _isPhoneNumberValid = false;
                  }
                });
              },
              decoration: InputDecoration(
                labelText: 'เบอร์โทร',
                errorText: _isPhoneNumberValid
                    ? null
                    : 'กรุณากรอกเบอร์โทรศัพท์ให้ครบ 10 หลัก',
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
              decoration: InputDecoration(
                labelText: 'ยืนยันรหัสผ่าน',
                errorText: _isPasswordMatch ? null : 'รหัสผ่านไม่ตรงกัน',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await _handleSignUp();
                if (_isSignUpSuccess) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const LoginPage(), // หรือชื่อหน้าเข้าสู่ระบบ
                    ),
                  );
                }
              },
              child: const Text('ลงทะเบียน'),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const LoginPage(), // สร้างหน้าใหม่ของ Login
                      ),
                    );
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
