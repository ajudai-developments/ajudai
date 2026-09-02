import '../json_utils.dart';

class RejeitarPrestadorRequestDto {
  final String verificacaoId;
  const RejeitarPrestadorRequestDto({required this.verificacaoId});
  factory RejeitarPrestadorRequestDto.fromJson(Map<String, dynamic> json) {
    return RejeitarPrestadorRequestDto(
      verificacaoId: JsonUtils.requireString(json, 'verificacaoId'),
    );
  }
  Map<String, dynamic> toJson() {
    return {'verificacaoId': verificacaoId};
  }
}
