///|
/// GLB 二进制解析结果
pub(all) struct GlbData {
  /// 解析出的 JSON 字符串
  json_str : String
  /// 二进制数据块
  bin_buffer : Bytes?
} derive(Debug, ToJson)

///|
/// 解析 GLB 二进制流数据
///
/// # Example
/// ```mbt check
/// test "parse glb header mock" {
///   // 一个极简 of GLB 模拟字节流（12字节头部 + JSON chunk 头部 + 数据）
///   // 头部: magic="glTF"(0x46546C67), version=2, length=32
///   // JSON chunk: length=8, type="JSON"(0x4E4F534A), data=`{}` (padded with spaces to 8 bytes)
///   let glb_bytes = Bytes::from_array([
///     0x67, 0x6c, 0x54, 0x46, // magic
///      0x02, 0x00, 0x00, 0x00, // version
///      0x20, 0x00, 0x00, 0x00, // total length (32)
///      0x08, 0x00, 0x00, 0x00, // chunk 0 length (8)
///      0x4a, 0x53, 0x4f, 0x4e, // chunk 0 type (JSON)
///      0x7b, 0x7d, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, // chunk 0 data: "{}" with spaces
///   ])
///   let glb = @gltf.unpack_glb(glb_bytes)
///   inspect(glb.json_str.trim(), content="{}")
/// }
/// ```
pub fn unpack_glb(data : Bytes) -> GlbData raise ParseError {
  let len = data.length()
  if len < 12 {
    raise ParseError::OutOfRange(msg="GLB header too short")
  }
  // 1. 读取魔数 "glTF"
  let magic = read_uint32_le(data, 0)
  if magic != 0x46546C67 {
    raise ParseError::InvalidGlbMagic
  }
  // 2. 读取版本号
  let version = read_uint32_le(data, 4).reinterpret_as_int()
  if version != 2 {
    raise ParseError::UnsupportedGlbVersion(version~)
  }
  // 3. 读取总长度
  let _total_length = read_uint32_le(data, 8).reinterpret_as_int()

  // 4. 解析 Chunks
  let mut offset = 12
  let mut json_str : String? = None
  let mut bin_buffer : Bytes? = None
  while offset < len {
    if offset + 8 > len {
      raise ParseError::OutOfRange(msg="GLB chunk header too short")
    }
    let chunk_len = read_uint32_le(data, offset).reinterpret_as_int()
    let chunk_type = read_uint32_le(data, offset + 4)
    offset += 8
    if offset + chunk_len > len {
      raise ParseError::OutOfRange(msg="GLB chunk data exceeds file boundaries")
    }
    if chunk_type == 0x4E4F534A {
      // JSON chunk
      let json_bytes = Bytes::makei(chunk_len, i => data[offset + i])
      json_str = Some(bytes_to_utf8_string(json_bytes))
    } else if chunk_type == 0x004E4942 {
      // BIN chunk
      let bin_bytes = Bytes::makei(chunk_len, i => data[offset + i])
      bin_buffer = Some(bin_bytes)
    }
    offset += chunk_len
  }
  match json_str {
    Some(js) => { json_str: js, bin_buffer }
    None => raise ParseError::MissingField(field="JSON chunk")
  }
}

///|
fn read_uint32_le(bytes : Bytes, offset : Int) -> UInt {
  let b0 = bytes[offset].to_uint()
  let b1 = bytes[offset + 1].to_uint()
  let b2 = bytes[offset + 2].to_uint()
  let b3 = bytes[offset + 3].to_uint()
  b0 | (b1 << 8) | (b2 << 16) | (b3 << 24)
}

///|
pub fn bytes_to_utf8_string(bytes : Bytes) -> String {
  let sb = StringBuilder()
  let mut i = 0
  let len = bytes.length()
  while i < len {
    let b = bytes[i].to_int()
    if b < 0x80 {
      let char = b.unsafe_to_char()
      sb.write_char(char)
      i += 1
    } else if (b & 0xE0) == 0xC0 {
      if i + 1 < len {
        let b2 = bytes[i + 1].to_int()
        let val = ((b & 0x1F) << 6) | (b2 & 0x3F)
        let char = val.unsafe_to_char()
        sb.write_char(char)
      }
      i += 2
    } else if (b & 0xF0) == 0xE0 {
      if i + 2 < len {
        let b2 = bytes[i + 1].to_int()
        let b3 = bytes[i + 2].to_int()
        let val = ((b & 0x0F) << 12) | ((b2 & 0x3F) << 6) | (b3 & 0x3F)
        let char = val.unsafe_to_char()
        sb.write_char(char)
      }
      i += 3
    } else {
      i += 1
    }
  }
  sb.to_string()
}
