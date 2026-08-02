///|
/// 从 JSON 值中提取字符串，不存在时使用默认值
fn get_string_opt(obj : Map[String, Json], key : String) -> String? {
  match obj.get(key) {
    Some(Json::String(s)) => Some(s)
    _ => None
  }
}

///|
/// 从 JSON 值中提取必需字符串字段
fn get_string(obj : Map[String, Json], key : String) -> String raise ParseError {
  match obj.get(key) {
    Some(Json::String(s)) => s
    None => raise ParseError::MissingField(field=key)
    _ => raise ParseError::InvalidFieldType(field=key, expected="string")
  }
}

///|
/// 从 JSON 值中提取整数字段
fn get_int(obj : Map[String, Json], key : String) -> Int raise ParseError {
  match obj.get(key) {
    Some(Json::Number(n, ..)) => n.to_int()
    None => raise ParseError::MissingField(field=key)
    _ => raise ParseError::InvalidFieldType(field=key, expected="number")
  }
}

///|
/// 从 JSON 值中提取可选整数字段
fn get_int_opt(obj : Map[String, Json], key : String) -> Int? raise ParseError {
  match obj.get(key) {
    Some(Json::Number(n, ..)) => Some(n.to_int())
    None => None
    _ => raise ParseError::InvalidFieldType(field=key, expected="number")
  }
}

///|
/// 从 JSON 值中提取浮点数字段
fn get_double(
  obj : Map[String, Json],
  key : String,
  default~ : Double,
) -> Double raise ParseError {
  match obj.get(key) {
    Some(Json::Number(n, ..)) => n
    None => default
    _ => raise ParseError::InvalidFieldType(field=key, expected="number")
  }
}

///|
/// 从 JSON 值中提取布尔字段
fn get_bool(
  obj : Map[String, Json],
  key : String,
  default~ : Bool,
) -> Bool raise ParseError {
  match obj.get(key) {
    Some(Json::True) => true
    Some(Json::False) => false
    None => default
    _ => raise ParseError::InvalidFieldType(field=key, expected="boolean")
  }
}

///|
/// 从 JSON 值中提取数值数组
fn get_number_array(
  obj : Map[String, Json],
  key : String,
) -> Array[Double] raise ParseError {
  match obj.get(key) {
    Some(Json::Array(arr)) => {
      let result = []
      for item in arr {
        match item {
          Json::Number(n, ..) => result.push(n)
          _ =>
            raise ParseError::InvalidFieldType(
              field=key,
              expected="array of numbers",
            )
        }
      }
      result
    }
    None => []
    _ => raise ParseError::InvalidFieldType(field=key, expected="array")
  }
}

///|
/// 从 JSON 值中提取对象数组
fn get_obj_array(
  obj : Map[String, Json],
  key : String,
) -> Array[Map[String, Json]] raise ParseError {
  match obj.get(key) {
    Some(Json::Array(arr)) => {
      let result = []
      for item in arr {
        match item {
          Json::Object(o) => result.push(o)
          _ =>
            raise ParseError::InvalidFieldType(
              field=key,
              expected="array of objects",
            )
        }
      }
      result
    }
    None => []
    _ => raise ParseError::InvalidFieldType(field=key, expected="array")
  }
}

///|
/// 从 JSON 值中提取整数数组
fn get_int_array(
  obj : Map[String, Json],
  key : String,
) -> Array[Int] raise ParseError {
  match obj.get(key) {
    Some(Json::Array(arr)) => {
      let result = []
      for item in arr {
        match item {
          Json::Number(n, ..) => result.push(n.to_int())
          _ =>
            raise ParseError::InvalidFieldType(
              field=key,
              expected="array of integers",
            )
        }
      }
      result
    }
    None => []
    _ => raise ParseError::InvalidFieldType(field=key, expected="array")
  }
}

// ===== 枚举解析辅助 =====

///|
fn parse_accessor_type(s : String) -> AccessorType raise ParseError {
  match s {
    "SCALAR" => Scalar
    "VEC2" => Vec2
    "VEC3" => Vec3
    "VEC4" => Vec4
    "MAT2" => Mat2
    "MAT3" => Mat3
    "MAT4" => Mat4
    _ => raise ParseError::UnknownEnum(field="type", value=s)
  }
}

///|
fn parse_component_type(code : Int) -> ComponentType raise ParseError {
  match code {
    5120 => Byte
    5121 => UnsignedByte
    5122 => Short
    5123 => UnsignedShort
    5125 => UnsignedInt
    5126 => Float
    _ => raise ParseError::UnknownEnum(field="componentType", value="\{code}")
  }
}

///|
fn parse_alpha_mode(s : String) -> AlphaMode raise ParseError {
  match s {
    "OPAQUE" => Opaque
    "MASK" => Mask
    "BLEND" => Blend
    _ => raise ParseError::UnknownEnum(field="alphaMode", value=s)
  }
}

///|
fn parse_primitive_mode(code : Int) -> PrimitiveMode raise ParseError {
  match code {
    0 => Points
    1 => Lines
    2 => LineLoop
    3 => LineStrip
    4 => Triangles
    5 => TriangleStrip
    6 => TriangleFan
    _ => raise ParseError::UnknownEnum(field="mode", value="\{code}")
  }
}

///|
fn parse_interpolation(s : String) -> Interpolation raise ParseError {
  match s {
    "LINEAR" => Linear
    "STEP" => Step
    "CUBICSPLINE" => CubicSpline
    _ => raise ParseError::UnknownEnum(field="interpolation", value=s)
  }
}

///|
fn parse_animation_path(s : String) -> AnimationPath raise ParseError {
  match s {
    "translation" => Translation
    "rotation" => Rotation
    "scale" => Scale
    "weights" => Weights
    _ => raise ParseError::UnknownEnum(field="path", value=s)
  }
}

///|
fn parse_filter_mode(code : Int) -> FilterMode raise ParseError {
  match code {
    9728 => Nearest
    9729 => Linear
    9984 => NearestMipmapNearest
    9985 => LinearMipmapNearest
    9986 => NearestMipmapLinear
    9987 => LinearMipmapLinear
    _ => raise ParseError::UnknownEnum(field="filter", value="\{code}")
  }
}

///|
fn parse_wrap_mode(code : Int) -> WrapMode raise ParseError {
  match code {
    33071 => ClampToEdge
    33648 => MirroredRepeat
    10497 => Repeat
    _ => raise ParseError::UnknownEnum(field="wrap", value="\{code}")
  }
}

// ===== 子结构解析 =====

///|
fn parse_vec3(arr : Array[Json]) -> Vec3 raise ParseError {
  if arr.length() < 3 {
    raise ParseError::OutOfRange(msg="Vec3 requires 3 components")
  }
  let x = match arr[0] {
    Json::Number(n, ..) => n
    _ => raise ParseError::InvalidFieldType(field="vec3[0]", expected="number")
  }
  let y = match arr[1] {
    Json::Number(n, ..) => n
    _ => raise ParseError::InvalidFieldType(field="vec3[1]", expected="number")
  }
  let z = match arr[2] {
    Json::Number(n, ..) => n
    _ => raise ParseError::InvalidFieldType(field="vec3[2]", expected="number")
  }
  { x, y, z }
}

///|
fn parse_quat(arr : Array[Json]) -> Quat raise ParseError {
  if arr.length() < 4 {
    raise ParseError::OutOfRange(msg="Quat requires 4 components")
  }
  let x = match arr[0] {
    Json::Number(n, ..) => n
    _ => raise ParseError::InvalidFieldType(field="quat[0]", expected="number")
  }
  let y = match arr[1] {
    Json::Number(n, ..) => n
    _ => raise ParseError::InvalidFieldType(field="quat[1]", expected="number")
  }
  let z = match arr[2] {
    Json::Number(n, ..) => n
    _ => raise ParseError::InvalidFieldType(field="quat[2]", expected="number")
  }
  let w = match arr[3] {
    Json::Number(n, ..) => n
    _ => raise ParseError::InvalidFieldType(field="quat[3]", expected="number")
  }
  { x, y, z, w }
}

///|
fn parse_color4(
  arr : Array[Json],
  default_alpha? : Double = 1.0,
) -> Color4 raise ParseError {
  if arr.length() < 3 {
    raise ParseError::OutOfRange(msg="Color requires at least 3 components")
  }
  let r = match arr[0] {
    Json::Number(n, ..) => n
    _ => raise ParseError::InvalidFieldType(field="color[0]", expected="number")
  }
  let g = match arr[1] {
    Json::Number(n, ..) => n
    _ => raise ParseError::InvalidFieldType(field="color[1]", expected="number")
  }
  let b = match arr[2] {
    Json::Number(n, ..) => n
    _ => raise ParseError::InvalidFieldType(field="color[2]", expected="number")
  }
  let a = if arr.length() >= 4 {
    match arr[3] {
      Json::Number(n, ..) => n
      _ =>
        raise ParseError::InvalidFieldType(field="color[3]", expected="number")
    }
  } else {
    default_alpha
  }
  { r, g, b, a }
}

///|
fn parse_texture_info(obj : Map[String, Json]) -> TextureInfo raise ParseError {
  let index = get_int(obj, "index")
  let tex_coord = match get_int_opt(obj, "texCoord") {
    Some(n) => n
    None => 0
  }
  { index, tex_coord }
}

///|
fn parse_pbr(obj : Map[String, Json]) -> PbrMetallicRoughness raise ParseError {
  let base_color_factor = match obj.get("baseColorFactor") {
    Some(Json::Array(arr)) => parse_color4(arr)
    None => { r: 1.0, g: 1.0, b: 1.0, a: 1.0 }
    _ =>
      raise ParseError::InvalidFieldType(
        field="baseColorFactor",
        expected="array",
      )
  }
  let base_color_texture = match obj.get("baseColorTexture") {
    Some(Json::Object(o)) => Some(parse_texture_info(o))
    _ => None
  }
  let metallic_factor = get_double(obj, "metallicFactor", default=1.0)
  let roughness_factor = get_double(obj, "roughnessFactor", default=1.0)
  let metallic_roughness_texture = match obj.get("metallicRoughnessTexture") {
    Some(Json::Object(o)) => Some(parse_texture_info(o))
    _ => None
  }
  {
    base_color_factor,
    base_color_texture,
    metallic_factor,
    roughness_factor,
    metallic_roughness_texture,
  }
}
