import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:image_picker/image_picker.dart';

class GalleryView extends StatefulWidget {
  const GalleryView({
    Key? key,
    required this.title,
    this.text,
    required this.onImage,
    required this.onDetectorViewModeChanged,
  }) : super(key: key);

  final String title;
  final String? text;
  final Function(InputImage inputImage) onImage;
  final Function()? onDetectorViewModeChanged;

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  File? _image;
  String? _path;
  ImagePicker? _imagePicker;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _imagePicker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Platform.isIOS ? Icons.camera_alt_outlined : Icons.camera),
            onPressed: widget.onDetectorViewModeChanged,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                if (_image != null)
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        _image!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                else
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.image,
                      size: 100,
                      color: Colors.grey[600],
                    ),
                  ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _getImage(ImageSource.gallery),
                      icon: Icon(Icons.photo_library),
                      label: Text('Gallery'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _getImage(ImageSource.camera),
                      icon: Icon(Icons.camera_alt),
                      label: Text('Camera'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_image != null && widget.text != null)
                  Container(
                    margin: EdgeInsets.all(20),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Analysis Results:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(widget.text!),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future _getImage(ImageSource source) async {
    setState(() {
      _image = null;
      _path = null;
      _isProcessing = true;
    });

    try {
      final pickedFile = await _imagePicker?.pickImage(source: source);
      if (pickedFile != null) {
        await _processPickedFile(pickedFile);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future _processPickedFile(XFile? pickedFile) async {
    final path = pickedFile?.path;
    if (path == null) {
      return;
    }

    setState(() {
      _image = File(path);
    });
    _path = path;

    try {
      final inputImage = InputImage.fromFilePath(path);
      widget.onImage(inputImage);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}