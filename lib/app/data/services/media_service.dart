import 'package:get/get.dart';

import '../constants/api_endpoints.dart';
import '../providers/api_client.dart';

/// File / media upload — `MediaController` (`POST /api/media/upload`).
class MediaService extends GetxService {
  final ApiClient _api = Get.find<ApiClient>();

  /// Uploads one file (JPEG, PNG or WebP; PDF for documents). [purpose] is
  /// avatar, listing (partners only), review or document.
  /// Returns `{fileId, fileUrl, purpose, …}`.
  Future<dynamic> upload(String filePath, {String purpose = 'avatar'}) =>
      _api.uploadFile(
        MediaEndpoints.upload,
        filePath: filePath,
        fields: {'purpose': purpose},
        usePut: false,
      );
}
