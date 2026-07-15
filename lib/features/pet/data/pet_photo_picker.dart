import 'dart:typed_data';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

/// Fotoğraf kaynağı (UI'ı platform paketinden ayırır).
enum PhotoSource { camera, gallery }

/// Fotoğraf seçme + kırpma soyutlaması (UI'da doğrudan platform kodu olmaz).
/// Seçilip kırpılan görselin JPEG byte'larını döner; kullanıcı vazgeçerse null.
abstract interface class PetPhotoPicker {
  Future<Uint8List?> pickAndCrop(PhotoSource source);
}

/// image_picker + image_cropper ile gerçek uygulama.
///
/// Kırpma kare (1:1) yapılır; uzun kenar en fazla 1200px; JPEG ~%85 kalite →
/// gereksiz büyük dosya yüklenmez.
class ImagePickerCropper implements PetPhotoPicker {
  ImagePickerCropper({ImagePicker? picker, ImageCropper? cropper})
    : _picker = picker ?? ImagePicker(),
      _cropper = cropper ?? ImageCropper();

  final ImagePicker _picker;
  final ImageCropper _cropper;

  static const int _maxEdge = 1200;
  static const int _quality = 85;

  @override
  Future<Uint8List?> pickAndCrop(PhotoSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source == PhotoSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      maxWidth: _maxEdge.toDouble(),
      maxHeight: _maxEdge.toDouble(),
      imageQuality: _quality,
    );
    if (picked == null) return null;

    final CroppedFile? cropped = await _cropper.cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      maxWidth: _maxEdge,
      maxHeight: _maxEdge,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: _quality,
      uiSettings: <PlatformUiSettings>[
        AndroidUiSettings(
          toolbarTitle: 'Fotoğrafı kırp',
          hideBottomControls: false,
          lockAspectRatio: true,
        ),
        IOSUiSettings(title: 'Fotoğrafı kırp', aspectRatioLockEnabled: true),
      ],
    );
    if (cropped == null) return null;
    return cropped.readAsBytes();
  }
}
