import '../json_utils.dart';

class AprovarPrestadorRequestDto {
  final String verificacaoId;

  const AprovarPrestadorRequestDto({required this.verificacaoId});

  factory AprovarPrestadorRequestDto.fromJson(Map<String, dynamic> json) {
    return AprovarPrestadorRequestDto(
      verificacaoId: JsonUtils.requireString(json, 'verificacaoId'),
    );
  }

  Map<String, dynamic> toJson() {
    return {'verificacaoId': verificacaoId};
  }
}
