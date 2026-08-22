///|
/// Safe binary access for glTF buffer data.
///
/// The parser intentionally keeps buffer bytes separate from the JSON
/// document. This module is the production boundary between those two
/// representations: every read checks the byte window before touching the
/// input, and every accessor decode preserves the declared stride and
/// component type.

///|
pub(all) suberror BinaryError {
  NegativeOffset(offset~ : Int)
  InvalidWidth(width~ : Int)
  OutOfBounds(offset~ : Int, width~ : Int, length~ : Int)
  InvalidStride(stride~ : Int, element_size~ : Int)
  MissingBuffer(index~ : Int)
  MissingBufferView(index~ : Int)
  InvalidAccessor(index~ : Int)
  UnsupportedSparseAccessor(index~ : Int)
  InvalidComponentValue(message~ : String)
} derive(Debug, Eq)

///|
pub impl Show for BinaryError with fn output(self, logger) {
  match self {
    NegativeOffset(offset~) =>
      logger.write_string("BinaryError: negative offset \{offset}")
    InvalidWidth(width~) =>
      logger.write_string("BinaryError: invalid read width \{width}")
    OutOfBounds(offset~, width~, length~) =>
      logger.write_string(
        "BinaryError: range \{offset}+\{width} exceeds \{length}",
      )
    InvalidStride(stride~, element_size~) =>
      logger.write_string(
        "BinaryError: stride \{stride} is smaller than element \{element_size}",
      )
    MissingBuffer(index~) =>
      logger.write_string("BinaryError: missing buffer \{index}")
    MissingBufferView(index~) =>
      logger.write_string("BinaryError: missing bufferView \{index}")
    InvalidAccessor(index~) =>
      logger.write_string("BinaryError: invalid accessor \{index}")
    UnsupportedSparseAccessor(index~) =>
      logger.write_string(
        "BinaryError: sparse accessor \{index} is not decoded",
      )
    InvalidComponentValue(message~) =>
      logger.write_string("BinaryError: \{message}")
  }
}

///|
pub(all) struct BinaryRange {
  offset : Int
  length : Int
} derive(Debug, ToJson, Eq)

///|
pub(all) struct Vec4 {
  x : Double
  y : Double
  z : Double
  w : Double
} derive(Debug, ToJson, Eq)

///|
pub(all) struct BinaryBuffer {
  declared_length : Int
  bytes : Bytes
  source : BufferSource
} derive(Debug, ToJson, Eq)

///|
pub(all) enum BufferSource {
  Embedded
  GlbBin
  External
  Missing
} derive(Debug, ToJson, Eq)

///|
pub(all) struct BinaryAsset {
  buffers : Array[BinaryBuffer]
  glb_bin : Bytes?
} derive(Debug, ToJson, Eq)

///|
pub(all) enum AccessorDecodeMode {
  Raw
  Normalized
} derive(Debug, ToJson, Eq)

///|
pub(all) struct DecodedAccessor {
  accessor_index : Int
  count : Int
  component_count : Int
  values : Array[Double]
  valid : Bool
  errors : Array[String]
} derive(Debug, ToJson, Eq)

///|
pub(all) struct DecodedVector {
  values : Array[Vec4]
  component_count : Int
  valid : Bool
  errors : Array[String]
} derive(Debug, ToJson, Eq)

///|
pub fn binary_range(offset : Int, length : Int) -> BinaryRange {
  { offset, length }
}

///|
pub fn binary_buffer(
  bytes : Bytes,
  declared_length~ : Int,
  source~ : BufferSource,
) -> BinaryBuffer {
  { declared_length, bytes, source }
}

///|
pub fn binary_asset(buffers : Array[BinaryBuffer]) -> BinaryAsset {
  { buffers, glb_bin: None }
}

///|
pub fn binary_asset_with_glb(
  buffers : Array[BinaryBuffer],
  glb_bin : Bytes,
) -> BinaryAsset {
  { buffers, glb_bin: Some(glb_bin) }
}

///|
pub fn binary_asset_empty() -> BinaryAsset {
  { buffers: [], glb_bin: None }
}

///|
pub fn binary_buffer_count(asset : BinaryAsset) -> Int {
  asset.buffers.length()
}

///|
pub fn binary_buffer_length(asset : BinaryAsset, index : Int) -> Int {
  match asset.buffers.get(index) {
    Some(buffer) => buffer.bytes.length()
    None => 0
  }
}

///|
pub fn binary_buffer_declared_length(asset : BinaryAsset, index : Int) -> Int {
  match asset.buffers.get(index) {
    Some(buffer) => buffer.declared_length
    None => 0
  }
}

///|
pub fn binary_buffer_source(asset : BinaryAsset, index : Int) -> BufferSource {
  match asset.buffers.get(index) {
    Some(buffer) => buffer.source
    None => Missing
  }
}

///|
pub fn binary_buffer_complete(asset : BinaryAsset, index : Int) -> Bool {
  match asset.buffers.get(index) {
    Some(buffer) =>
      buffer.declared_length >= 0 &&
      buffer.bytes.length() >= buffer.declared_length
    None => false
  }
}

///|
pub fn binary_asset_declared_bytes(asset : BinaryAsset) -> Int {
  asset.buffers.fold(init=0, (sum, buffer) => sum + buffer.declared_length)
}

///|
pub fn binary_asset_loaded_bytes(asset : BinaryAsset) -> Int {
  asset.buffers.fold(init=0, (sum, buffer) => sum + buffer.bytes.length())
}

///|
pub fn binary_asset_missing_count(asset : BinaryAsset) -> Int {
  asset.buffers.fold(init=0, (count, buffer) => {
    match buffer.source {
      Missing => count + 1
      _ => count
    }
  })
}

///|
fn ensure_range(
  data : Bytes,
  offset : Int,
  width : Int,
) -> Unit raise BinaryError {
  if offset < 0 {
    raise BinaryError::NegativeOffset(offset~)
  }
  if width <= 0 {
    raise BinaryError::InvalidWidth(width~)
  }
  if offset > data.length() || width > data.length() - offset {
    raise BinaryError::OutOfBounds(offset~, width~, length=data.length())
  }
}

///|
pub fn binary_range_is_valid(data : Bytes, range : BinaryRange) -> Bool {
  if range.offset < 0 || range.length < 0 {
    false
  } else {
    range.offset <= data.length() &&
    range.length <= data.length() - range.offset
  }
}

///|
pub fn read_u8(data : Bytes, offset : Int) -> Int raise BinaryError {
  ensure_range(data, offset, 1)
  data[offset].to_int()
}

///|
pub fn read_i8(data : Bytes, offset : Int) -> Int raise BinaryError {
  let value = read_u8(data, offset)
  if value >= 128 {
    value - 256
  } else {
    value
  }
}

///|
pub fn read_u16_le(data : Bytes, offset : Int) -> Int raise BinaryError {
  ensure_range(data, offset, 2)
  data[offset].to_int() | (data[offset + 1].to_int() << 8)
}

///|
pub fn read_u16_be(data : Bytes, offset : Int) -> Int raise BinaryError {
  ensure_range(data, offset, 2)
  (data[offset].to_int() << 8) | data[offset + 1].to_int()
}

///|
pub fn read_i16_le(data : Bytes, offset : Int) -> Int raise BinaryError {
  let value = read_u16_le(data, offset)
  if value >= 32768 {
    value - 65536
  } else {
    value
  }
}

///|
pub fn read_i16_be(data : Bytes, offset : Int) -> Int raise BinaryError {
  let value = read_u16_be(data, offset)
  if value >= 32768 {
    value - 65536
  } else {
    value
  }
}

///|
pub fn read_u32_le(data : Bytes, offset : Int) -> UInt raise BinaryError {
  ensure_range(data, offset, 4)
  let b0 = data[offset].to_uint()
  let b1 = data[offset + 1].to_uint()
  let b2 = data[offset + 2].to_uint()
  let b3 = data[offset + 3].to_uint()
  b0 | (b1 << 8) | (b2 << 16) | (b3 << 24)
}

///|
pub fn read_u32_be(data : Bytes, offset : Int) -> UInt raise BinaryError {
  ensure_range(data, offset, 4)
  let b0 = data[offset].to_uint()
  let b1 = data[offset + 1].to_uint()
  let b2 = data[offset + 2].to_uint()
  let b3 = data[offset + 3].to_uint()
  (b0 << 24) | (b1 << 16) | (b2 << 8) | b3
}

///|
pub fn read_i32_le(data : Bytes, offset : Int) -> Int raise BinaryError {
  read_u32_le(data, offset).reinterpret_as_int()
}

///|
pub fn read_i32_be(data : Bytes, offset : Int) -> Int raise BinaryError {
  read_u32_be(data, offset).reinterpret_as_int()
}

///|
pub fn read_f32_le(data : Bytes, offset : Int) -> Double raise BinaryError {
  Float::reinterpret_from_uint(read_u32_le(data, offset)).to_double()
}

///|
pub fn read_f32_be(data : Bytes, offset : Int) -> Double raise BinaryError {
  Float::reinterpret_from_uint(read_u32_be(data, offset)).to_double()
}

///|
pub fn read_bytes(
  data : Bytes,
  offset : Int,
  length : Int,
) -> Bytes raise BinaryError {
  ensure_range(data, offset, if length == 0 { 1 } else { length })
  if length == 0 {
    Bytes::from_array([])
  } else {
    data.view(start=offset, end=offset + length).to_owned()
  }
}

///|
pub fn binary_checksum(data : Bytes) -> UInt {
  let mut hash : UInt = 2166136261
  for byte in data {
    hash = (hash ^ byte.to_uint()) * 16777619
  }
  hash
}

///|
pub fn binary_checksum_range(
  data : Bytes,
  offset : Int,
  length : Int,
) -> UInt raise BinaryError {
  ensure_range(data, offset, if length == 0 { 1 } else { length })
  let mut hash : UInt = 2166136261
  if length > 0 {
    for i in offset..<(offset + length) {
      hash = (hash ^ data[i].to_uint()) * 16777619
    }
  }
  hash
}

///|
pub fn binary_compare_ranges(
  left : Bytes,
  left_offset : Int,
  right : Bytes,
  right_offset : Int,
  length : Int,
) -> Bool {
  if left_offset < 0 || right_offset < 0 || length < 0 {
    false
  } else if left_offset > left.length() ||
    right_offset > right.length() ||
    length > left.length() - left_offset ||
    length > right.length() - right_offset {
    false
  } else {
    let mut equal = true
    for i in 0..<length {
      if left[left_offset + i] != right[right_offset + i] {
        equal = false
      }
    }
    equal
  }
}

///|
pub fn accessor_buffer_index(doc : GltfDocument, accessor_index : Int) -> Int? {
  match doc.accessors.get(accessor_index) {
    Some(accessor) =>
      match accessor.buffer_view {
        Some(view_index) =>
          match doc.buffer_views.get(view_index) {
            Some(view) => Some(view.buffer)
            None => None
          }
        None => None
      }
    None => None
  }
}

///|
pub fn accessor_byte_range(
  doc : GltfDocument,
  accessor_index : Int,
) -> BinaryRange? {
  if accessor_index < 0 || accessor_index >= doc.accessors.length() {
    None
  } else {
    let layout = accessor_layout(doc, accessor_index)
    Some({
      offset: layout.first_byte,
      length: if layout.valid {
        layout.last_byte_exclusive - layout.first_byte
      } else {
        0
      },
    })
  }
}

///|
pub fn binary_asset_for_document(
  doc : GltfDocument,
  buffers : Array[Bytes],
) -> BinaryAsset {
  let loaded : Array[BinaryBuffer] = []
  for index in 0..<doc.buffers.length() {
    let declared = doc.buffers[index].byte_length
    let bytes = match buffers.get(index) {
      Some(value) => value
      None => Bytes::from_array([])
    }
    let source = if bytes.length() == 0 && declared > 0 {
      Missing
    } else if doc.buffers[index].uri is Some(_) {
      External
    } else {
      Embedded
    }
    loaded.push({ declared_length: declared, bytes, source })
  }
  { buffers: loaded, glb_bin: None }
}

///|
pub fn binary_asset_for_glb(
  doc : GltfDocument,
  buffers : Array[Bytes],
  bin : Bytes,
) -> BinaryAsset {
  let asset = binary_asset_for_document(doc, buffers)
  { ..asset, glb_bin: Some(bin) }
}

///|
fn buffer_for_accessor(
  doc : GltfDocument,
  asset : BinaryAsset,
  accessor_index : Int,
) -> (Bytes, Int, Int, Int)? {
  let accessor = doc.accessors.get(accessor_index)
  match accessor {
    None => None
    Some(value) =>
      match value.buffer_view {
        None => None
        Some(view_index) =>
          match doc.buffer_views.get(view_index) {
            None => None
            Some(view) =>
              match asset.buffers.get(view.buffer) {
                None => None
                Some(buffer) => {
                  let stride = match view.byte_stride {
                    Some(value) => value
                    None => accessor_element_size(value)
                  }
                  Some(
                    (
                      buffer.bytes,
                      view.byte_offset + value.byte_offset,
                      stride,
                      view.byte_length,
                    ),
                  )
                }
              }
          }
      }
  }
}

///|
fn normalized_component(component : ComponentType, value : Double) -> Double {
  match component {
    Byte => if value / 127.0 < -1.0 { -1.0 } else { value / 127.0 }
    UnsignedByte => value / 255.0
    Short => if value / 32767.0 < -1.0 { -1.0 } else { value / 32767.0 }
    UnsignedShort => value / 65535.0
    UnsignedInt => value / 4294967295.0
    Float => value
  }
}

///|
fn read_component(
  data : Bytes,
  component : ComponentType,
  offset : Int,
  mode : AccessorDecodeMode,
) -> Double raise BinaryError {
  let value = match component {
    Byte => read_i8(data, offset).to_double()
    UnsignedByte => read_u8(data, offset).to_double()
    Short => read_i16_le(data, offset).to_double()
    UnsignedShort => read_u16_le(data, offset).to_double()
    UnsignedInt => read_u32_le(data, offset).to_double()
    Float => read_f32_le(data, offset)
  }
  match mode {
    Raw => value
    Normalized => normalized_component(component, value)
  }
}

///|
fn read_component_or_none(
  data : Bytes,
  component : ComponentType,
  offset : Int,
  mode : AccessorDecodeMode,
) -> Double? {
  Some(read_component(data, component, offset, mode)) catch {
    _ => None
  }
}

///|
fn read_component_width(component : ComponentType) -> Int {
  component_info(component).size
}

///|
fn decode_error(
  accessor_index : Int,
  count : Int,
  component_count : Int,
  message : String,
) -> DecodedAccessor {
  {
    accessor_index,
    count,
    component_count,
    values: [],
    valid: false,
    errors: [message],
  }
}

///|
pub fn decode_accessor(
  doc : GltfDocument,
  asset : BinaryAsset,
  accessor_index : Int,
) -> DecodedAccessor {
  decode_accessor_with_mode(doc, asset, accessor_index, Raw)
}

///|
pub fn decode_accessor_normalized(
  doc : GltfDocument,
  asset : BinaryAsset,
  accessor_index : Int,
) -> DecodedAccessor {
  decode_accessor_with_mode(doc, asset, accessor_index, Normalized)
}

///|
pub fn decode_accessor_with_mode(
  doc : GltfDocument,
  asset : BinaryAsset,
  accessor_index : Int,
  mode : AccessorDecodeMode,
) -> DecodedAccessor {
  match doc.accessors.get(accessor_index) {
    None => decode_error(accessor_index, 0, 0, "accessor index is invalid")
    Some(accessor) => {
      let component_count = accessor_component_count(accessor.accessor_type)
      if accessor.count < 0 {
        decode_error(
          accessor_index,
          accessor.count,
          component_count,
          "accessor count cannot be negative",
        )
      } else {
        match buffer_for_accessor(doc, asset, accessor_index) {
          None =>
            if accessor.count == 0 {
              {
                accessor_index,
                count: 0,
                component_count,
                values: [],
                valid: true,
                errors: [],
              }
            } else {
              decode_error(
                accessor_index,
                accessor.count,
                component_count,
                "accessor has no loaded bufferView",
              )
            }
          Some((data, start, stride, view_length)) => {
            let width = read_component_width(accessor.component_type)
            let element_size = width * component_count
            if stride < element_size {
              decode_error(
                accessor_index,
                accessor.count,
                component_count,
                "bufferView stride is smaller than the accessor element",
              )
            } else if start < 0 || start > data.length() {
              decode_error(
                accessor_index,
                accessor.count,
                component_count,
                "accessor start is outside the loaded buffer",
              )
            } else {
              let needed = if accessor.count == 0 {
                0
              } else {
                stride * (accessor.count - 1) + element_size
              }
              if needed > view_length || needed > data.length() - start {
                decode_error(
                  accessor_index,
                  accessor.count,
                  component_count,
                  "accessor data exceeds the loaded buffer window",
                )
              } else {
                let values : Array[Double] = []
                let mut failed : String? = None
                for element in 0..<accessor.count {
                  for component_index in 0..<component_count {
                    let offset = start +
                      element * stride +
                      component_index * width
                    match
                      read_component_or_none(
                        data,
                        accessor.component_type,
                        offset,
                        mode,
                      ) {
                      Some(value) => values.push(value)
                      None => failed = Some("component read failed")
                    }
                  }
                }
                match failed {
                  Some(message) =>
                    decode_error(
                      accessor_index,
                      accessor.count,
                      component_count,
                      message,
                    )
                  None =>
                    {
                      accessor_index,
                      count: accessor.count,
                      component_count,
                      values,
                      valid: true,
                      errors: [],
                    }
                }
              }
            }
          }
        }
      }
    }
  }
}

///|
pub fn decoded_accessor_value(
  decoded : DecodedAccessor,
  element : Int,
  component : Int,
) -> Double? {
  if element < 0 ||
    element >= decoded.count ||
    component < 0 ||
    component >= decoded.component_count {
    None
  } else {
    decoded.values.get(element * decoded.component_count + component)
  }
}

///|
pub fn decoded_accessor_element(
  decoded : DecodedAccessor,
  element : Int,
) -> Array[Double] {
  if element < 0 || element >= decoded.count {
    []
  } else {
    let start = element * decoded.component_count
    let values : Array[Double] = []
    for index in 0..<decoded.component_count {
      match decoded.values.get(start + index) {
        Some(value) => values.push(value)
        None => ()
      }
    }
    values
  }
}

///|
pub fn decoded_accessor_min(decoded : DecodedAccessor) -> Double? {
  decoded.values.fold(init=None, (current, value) => {
    match current {
      None => Some(value)
      Some(previous) => Some(if value < previous { value } else { previous })
    }
  })
}

///|
pub fn decoded_accessor_max(decoded : DecodedAccessor) -> Double? {
  decoded.values.fold(init=None, (current, value) => {
    match current {
      None => Some(value)
      Some(previous) => Some(if value > previous { value } else { previous })
    }
  })
}

///|
pub fn decoded_accessor_average(decoded : DecodedAccessor) -> Double? {
  if decoded.values.length() == 0 {
    None
  } else {
    Some(
      decoded.values.fold(init=0.0, (sum, value) => sum + value) /
      decoded.values.length().to_double(),
    )
  }
}

///|
pub fn decode_accessor_vectors(
  doc : GltfDocument,
  asset : BinaryAsset,
  accessor_index : Int,
) -> DecodedVector {
  let decoded = decode_accessor_normalized(doc, asset, accessor_index)
  if !decoded.valid {
    {
      values: [],
      component_count: decoded.component_count,
      valid: false,
      errors: decoded.errors,
    }
  } else {
    let values : Array[Vec4] = []
    for index in 0..<decoded.count {
      let item = decoded_accessor_element(decoded, index)
      let x = match item.get(0) {
        Some(value) => value
        None => 0.0
      }
      let y = match item.get(1) {
        Some(value) => value
        None => 0.0
      }
      let z = match item.get(2) {
        Some(value) => value
        None => 0.0
      }
      let w = match item.get(3) {
        Some(value) => value
        None => 1.0
      }
      values.push({ x, y, z, w })
    }
    {
      values,
      component_count: decoded.component_count,
      valid: true,
      errors: [],
    }
  }
}

///|
pub fn decode_accessor_scalars(
  doc : GltfDocument,
  asset : BinaryAsset,
  accessor_index : Int,
) -> Array[Double] {
  let decoded = decode_accessor(doc, asset, accessor_index)
  if decoded.component_count != 1 || !decoded.valid {
    []
  } else {
    decoded.values
  }
}

///|
pub fn decode_index_values(
  doc : GltfDocument,
  asset : BinaryAsset,
  accessor_index : Int,
) -> Array[Int] {
  match doc.accessors.get(accessor_index) {
    None => []
    Some(accessor) =>
      if !accessor_is_index_compatible(accessor) {
        []
      } else {
        decode_accessor(doc, asset, accessor_index).values.map(value => {
          value.to_int()
        })
      }
  }
}

///|
pub fn decode_position_values(
  doc : GltfDocument,
  asset : BinaryAsset,
  accessor_index : Int,
) -> Array[Vec3] {
  let decoded = decode_accessor_normalized(doc, asset, accessor_index)
  if !decoded.valid || decoded.component_count < 3 {
    []
  } else {
    let values : Array[Vec3] = []
    for index in 0..<decoded.count {
      let item = decoded_accessor_element(decoded, index)
      if item.length() >= 3 {
        values.push({ x: item[0], y: item[1], z: item[2] })
      }
    }
    values
  }
}

///|
pub fn decode_texcoord_values(
  doc : GltfDocument,
  asset : BinaryAsset,
  accessor_index : Int,
) -> Array[Vec2] {
  let decoded = decode_accessor_normalized(doc, asset, accessor_index)
  if !decoded.valid || decoded.component_count < 2 {
    []
  } else {
    let values : Array[Vec2] = []
    for index in 0..<decoded.count {
      let item = decoded_accessor_element(decoded, index)
      if item.length() >= 2 {
        values.push({ x: item[0], y: item[1] })
      }
    }
    values
  }
}

///|
pub fn decode_normal_values(
  doc : GltfDocument,
  asset : BinaryAsset,
  accessor_index : Int,
) -> Array[Vec3] {
  decode_position_values(doc, asset, accessor_index)
}

///|
pub fn decode_quaternion_values(
  doc : GltfDocument,
  asset : BinaryAsset,
  accessor_index : Int,
) -> Array[Quat] {
  let decoded = decode_accessor_normalized(doc, asset, accessor_index)
  if !decoded.valid || decoded.component_count < 4 {
    []
  } else {
    let values : Array[Quat] = []
    for index in 0..<decoded.count {
      let item = decoded_accessor_element(decoded, index)
      if item.length() >= 4 {
        values.push({ x: item[0], y: item[1], z: item[2], w: item[3] })
      }
    }
    values
  }
}

///|
pub fn binary_asset_validate(
  doc : GltfDocument,
  asset : BinaryAsset,
) -> Array[String] {
  let errors : Array[String] = []
  if asset.buffers.length() != doc.buffers.length() {
    errors.push(
      "loaded buffer count \{asset.buffers.length()} does not match document count \{doc.buffers.length()}",
    )
  }
  for index in 0..<doc.buffers.length() {
    match asset.buffers.get(index) {
      None => errors.push("missing loaded buffer \{index}")
      Some(buffer) =>
        if buffer.declared_length < 0 {
          errors.push("buffer \{index} has negative declared length")
        } else if buffer.bytes.length() < buffer.declared_length &&
          buffer.source != Missing {
          errors.push("buffer \{index} is shorter than declared")
        }
    }
  }
  for index in 0..<doc.accessors.length() {
    let layout = accessor_layout(doc, index)
    if !layout.valid {
      for problem in layout.problems {
        errors.push("accessor[\{index}]: \{problem}")
      }
    }
  }
  errors
}

///|
pub fn decode_many_accessors(
  doc : GltfDocument,
  asset : BinaryAsset,
  indices : Array[Int],
) -> Array[DecodedAccessor] {
  indices.map(index => decode_accessor(doc, asset, index))
}

///|
pub fn decode_all_accessors(
  doc : GltfDocument,
  asset : BinaryAsset,
) -> Array[DecodedAccessor] {
  let decoded : Array[DecodedAccessor] = []
  for index in 0..<doc.accessors.length() {
    decoded.push(decode_accessor(doc, asset, index))
  }
  decoded
}

///|
pub fn decoded_accessor_has_non_finite(decoded : DecodedAccessor) -> Bool {
  for value in decoded.values {
    if value != value || value == 1.0 / 0.0 || value == -1.0 / 0.0 {
      return true
    }
  }
  false
}

///|
pub fn decoded_accessor_component_bounds(
  decoded : DecodedAccessor,
  component : Int,
) -> (Double, Double)? {
  if component < 0 || component >= decoded.component_count || decoded.count == 0 {
    None
  } else {
    let first = decoded.values[component]
    let mut low = first
    let mut high = first
    for element in 1..<decoded.count {
      let value = decoded.values[element * decoded.component_count + component]
      if value < low {
        low = value
      }
      if value > high {
        high = value
      }
    }
    Some((low, high))
  }
}

///|
pub fn decoded_accessor_is_monotonic(decoded : DecodedAccessor) -> Bool {
  if decoded.component_count != 1 {
    false
  } else {
    let mut previous : Double? = None
    let mut result = true
    for value in decoded.values {
      match previous {
        Some(old) => if value < old { result = false }
        None => ()
      }
      previous = Some(value)
    }
    result
  }
}

///|
pub fn decoded_accessor_duplicate_count(decoded : DecodedAccessor) -> Int {
  if decoded.component_count == 0 {
    0
  } else {
    let mut duplicates = 0
    for index in 1..<decoded.count {
      let mut same = true
      for component in 0..<decoded.component_count {
        if decoded.values[index * decoded.component_count + component] !=
          decoded.values[(index - 1) * decoded.component_count + component] {
          same = false
        }
      }
      if same {
        duplicates += 1
      }
    }
    duplicates
  }
}
