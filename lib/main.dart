import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
// import 'package:flimer/flimer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_whatsapp/share_whatsapp.dart';

const _kTextMessage = 'Share text from share_whatsapp flutter package '
    'https://pub.dev/packages/whatsapp_share';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ScreenshotController screenshotController = ScreenshotController();


  final _mapInstalled = WhatsApp.values.asMap().map<WhatsApp, String?>((key, value) {
    return MapEntry(value, null);
  });

  @override
  void initState() {
    super.initState();
    _checkInstalledWhatsApp();

  }

  Future<void> _checkInstalledWhatsApp() async {
    String whatsAppInstalled = await _check(WhatsApp.standard),
        whatsAppBusinessInstalled = await _check(WhatsApp.business);

    if (!mounted) return;

    setState(() {
      _mapInstalled[WhatsApp.standard] = whatsAppInstalled;
      _mapInstalled[WhatsApp.business] = whatsAppBusinessInstalled;
    });
  }

  Future<String> _check(WhatsApp type) async {
    try {
      return await shareWhatsapp.installed(type: type)
          ? 'INSTALLED'
          : 'NOT INSTALLED';
    } on PlatformException catch (e) {
      return e.message ?? 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Share WhatsApp'),
        ),
        body: Screenshot(
          controller: screenshotController,
          child: ListView(
            children: ListTile.divideTiles(
              context: context,
              tiles: [
                const ListTile(title: Text('STATUS INSTALLATION')),
                ...WhatsApp.values.map((type) {
                  final status = _mapInstalled[type];

                  return ListTile(
                    title: Text(type.toString()),
                    trailing: status != null
                        ? Text(status)
                        : const CircularProgressIndicator.adaptive(),
                  );
                }),
                // const ListTile(title: Text('SHARE CONTENT')),
                // ListTile(
                //   title: const Text('Share Text'),
                //   trailing: const Icon(Icons.share),
                //   onTap: () => shareWhatsapp.shareText(_kTextMessage),
                // ),
                ListTile(
                  title: const Text('Share Image'),
                  trailing: const Icon(Icons.share),
                  onTap: () async {
                    screenshotController
                        .capture(delay: Duration(milliseconds: 10))
                        .then((capturedImage) async {
                      final directory = Directory.systemTemp;
                      final file = File('${directory.path}/image.png');

                      // Write the Uint8List data to the file
                      await file.writeAsBytes(capturedImage!);
                      shareWhatsapp.shareFile(XFile(file.path));

                    }).catchError((onError) {
                      print(onError);
                    });

                    // FilePickerResult? result = await FilePicker.platform.pickFiles(
                    //   allowMultiple: true,
                    //   type: FileType.custom,
                    //   allowedExtensions: ['jpg', 'pdf', 'doc'],
                    // );
                    // XFile? xFile = result?.files.first.xFile;
                    // if (xFile != null) {
                    //   shareWhatsapp.shareFile(xFile);
                    // }
                  },
                ),
                ListTile(
                  title: const Text('Share Text & Image'),
                  trailing: const Icon(Icons.share),
                  onTap: () async {
                    screenshotController
                        .capture(delay: Duration(milliseconds: 10))
                        .then((capturedImage) async {
                      final directory = Directory.systemTemp;
                      final file = File('${directory.path}/image.png');

                      // Write the Uint8List data to the file
                      await file.writeAsBytes(capturedImage!);
                      shareWhatsapp.share(text: _kTextMessage,file:XFile(file.path));

                    }).catchError((onError) {
                      print(onError);
                    });


                    //
                    // FilePickerResult? result = await FilePicker.platform.pickFiles(
                    //   allowMultiple: true,
                    //   type: FileType.custom,
                    //   allowedExtensions: ['jpg', 'pdf', 'doc'],
                    // );
                    // XFile? xFile = result?.files.first.xFile;
                    // if (xFile != null) {
                    //   shareWhatsapp.share(text: _kTextMessage, file: xFile);
                    }
                ),
                // ListTile(
                //   title: const Text('Share Text on Specific Phone Number'),
                //   trailing: const Icon(Icons.share),
                //   onTap: () => shareWhatsapp.share(
                //     text: _kTextMessage,
                //     phone: '+0 000-0000-00000',
                //   ),
                // ),
              ],
            ).toList(),
          ),
        ),
      ),
    );
  }


}