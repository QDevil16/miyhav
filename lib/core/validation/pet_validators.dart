/// Pet formu için saf (ağsız) doğrulamalar. Geçerliyse `null` döner.
abstract final class PetValidators {
  static const int nameMax = 40;
  static const int breedMax = 40;
  static const int colorMax = 30;
  static const int descriptionMax = 200;
  static const int microchipMax = 30;
  static const double weightMax = 200;

  static String? name(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return 'Pet adını gir.';
    if (v.length > nameMax) return 'Ad en fazla $nameMax karakter olabilir.';
    return null;
  }

  static String? breed(String? value) {
    if ((value ?? '').trim().length > breedMax) {
      return 'Cins en fazla $breedMax karakter olabilir.';
    }
    return null;
  }

  static String? color(String? value) {
    if ((value ?? '').trim().length > colorMax) {
      return 'Renk en fazla $colorMax karakter olabilir.';
    }
    return null;
  }

  static String? description(String? value) {
    if ((value ?? '').trim().length > descriptionMax) {
      return 'Açıklama en fazla $descriptionMax karakter olabilir.';
    }
    return null;
  }

  static String? microchip(String? value) {
    if ((value ?? '').trim().length > microchipMax) {
      return 'Mikroçip no en fazla $microchipMax karakter olabilir.';
    }
    return null;
  }

  /// Ağırlık opsiyoneldir; doluysa geçerli, pozitif ve makul olmalı (kg).
  static String? weight(String? value) {
    final String v = (value ?? '').trim().replaceAll(',', '.');
    if (v.isEmpty) return null;
    final double? parsed = double.tryParse(v);
    if (parsed == null) return 'Geçerli bir ağırlık gir (ör. 4.5).';
    if (parsed <= 0 || parsed > weightMax) {
      return 'Ağırlık 0 ile $weightMax kg arasında olmalı.';
    }
    return null;
  }

  /// Geçerli ağırlık metnini double'a çevirir (boşsa null).
  static double? parseWeight(String? value) {
    final String v = (value ?? '').trim().replaceAll(',', '.');
    if (v.isEmpty) return null;
    return double.tryParse(v);
  }
}
