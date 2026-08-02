///|
/// glTF/GLB 解析错误类型
pub(all) suberror ParseError {
  /// 非法 JSON 格式
  InvalidJson(msg~ : String)
  /// 缺少必需字段
  MissingField(field~ : String)
  /// 字段类型错误
  InvalidFieldType(field~ : String, expected~ : String)
  /// 枚举值无法识别
  UnknownEnum(field~ : String, value~ : String)
  /// GLB 文件魔数不匹配
  InvalidGlbMagic
  /// GLB 版本不支持
  UnsupportedGlbVersion(version~ : Int)
  /// 数据超出缓冲区范围
  OutOfRange(msg~ : String)
} derive(Debug, Eq)

///|
pub impl Show for ParseError with fn output(self, logger) {
  match self {
    InvalidJson(msg~) =>
      logger.write_string("ParseError: invalid JSON - \{msg}")
    MissingField(field~) =>
      logger.write_string("ParseError: missing required field '\{field}'")
    InvalidFieldType(field~, expected~) =>
      logger.write_string(
        "ParseError: field '\{field}' has wrong type, expected \{expected}",
      )
    UnknownEnum(field~, value~) =>
      logger.write_string(
        "ParseError: unknown enum value '\{value}' for field '\{field}'",
      )
    InvalidGlbMagic =>
      logger.write_string("ParseError: invalid GLB magic bytes")
    UnsupportedGlbVersion(version~) =>
      logger.write_string(
        "ParseError: unsupported GLB version \{version}, expected 2",
      )
    OutOfRange(msg~) => logger.write_string("ParseError: out of range - \{msg}")
  }
}
