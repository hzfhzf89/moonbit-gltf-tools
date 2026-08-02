///|
/// glTF 2.0 核心数据类型定义
///
/// 遵循 Khronos glTF 2.0 规范：
/// https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html

// ===== 基础向量类型 =====

///|
/// 三维浮点向量
pub(all) struct Vec3 {
  x : Double
  y : Double
  z : Double
} derive(Debug, ToJson, Eq)

///|
/// 四元数（用于旋转）
pub(all) struct Quat {
  x : Double
  y : Double
  z : Double
  w : Double
} derive(Debug, ToJson, Eq)

///|
/// RGBA 颜色（[0.0, 1.0] 范围）
pub(all) struct Color4 {
  r : Double
  g : Double
  b : Double
  a : Double
} derive(Debug, ToJson, Eq)

// ===== 缓冲区与访问器 =====

///|
/// glTF Buffer — 二进制数据块
pub(all) struct GltfBuffer {
  /// 可选名称
  name : String?
  /// 字节长度
  byte_length : Int
  /// URI（外部文件）或空（GLB 内嵌）
  uri : String?
} derive(Debug, ToJson, Eq)

///|
/// glTF BufferView — 指向 Buffer 的窗口
pub(all) struct GltfBufferView {
  name : String?
  /// 对应 Buffer 的索引
  buffer : Int
  byte_offset : Int
  byte_length : Int
  /// 顶点索引=34963，顶点属性=34962
  target : Int?
  byte_stride : Int?
} derive(Debug, ToJson, Eq)

///|
/// Accessor 数据类型
pub(all) enum AccessorType {
  Scalar
  Vec2
  Vec3
  Vec4
  Mat2
  Mat3
  Mat4
} derive(Debug, ToJson, Eq)

///|
/// Accessor 数据分量类型（对应 WebGL 常量）
pub(all) enum ComponentType {
  Byte
  UnsignedByte
  Short
  UnsignedShort
  UnsignedInt
  Float
} derive(Debug, ToJson, Eq)

///|
/// glTF Accessor — 描述 BufferView 中数据的布局方式
pub(all) struct GltfAccessor {
  name : String?
  buffer_view : Int?
  byte_offset : Int
  component_type : ComponentType
  normalized : Bool
  count : Int
  accessor_type : AccessorType
  max_values : Array[Double]
  min_values : Array[Double]
} derive(Debug, ToJson, Eq)

// ===== 图像与纹理 =====

///|
/// glTF Image — 纹理贴图源数据
pub(all) struct GltfImage {
  name : String?
  uri : String?
  mime_type : String?
  buffer_view : Int?
} derive(Debug, ToJson, Eq)

///|
/// 纹理采样过滤模式
pub(all) enum FilterMode {
  Nearest
  Linear
  NearestMipmapNearest
  LinearMipmapNearest
  NearestMipmapLinear
  LinearMipmapLinear
} derive(Debug, ToJson, Eq)

///|
/// 纹理环绕模式
pub(all) enum WrapMode {
  ClampToEdge
  MirroredRepeat
  Repeat
} derive(Debug, ToJson, Eq)

///|
/// glTF Sampler — 纹理采样参数
pub(all) struct GltfSampler {
  name : String?
  mag_filter : FilterMode?
  min_filter : FilterMode?
  wrap_s : WrapMode
  wrap_t : WrapMode
} derive(Debug, ToJson, Eq)

///|
/// glTF Texture — 关联 Image 与 Sampler
pub(all) struct GltfTexture {
  name : String?
  sampler : Int?
  source : Int?
} derive(Debug, ToJson, Eq)

///|
/// 纹理引用（含纹理坐标集）
pub(all) struct TextureInfo {
  index : Int
  tex_coord : Int
} derive(Debug, ToJson, Eq)

// ===== 材质 =====

///|
/// PBR 金属粗糙度工作流参数
pub(all) struct PbrMetallicRoughness {
  base_color_factor : Color4
  base_color_texture : TextureInfo?
  metallic_factor : Double
  roughness_factor : Double
  metallic_roughness_texture : TextureInfo?
} derive(Debug, ToJson, Eq)

///|
/// Alpha 混合模式
pub(all) enum AlphaMode {
  Opaque
  Mask
  Blend
} derive(Debug, ToJson, Eq)

///|
/// glTF Material — 表面外观描述
pub(all) struct GltfMaterial {
  name : String?
  pbr_metallic_roughness : PbrMetallicRoughness
  normal_texture : TextureInfo?
  occlusion_texture : TextureInfo?
  emissive_texture : TextureInfo?
  emissive_factor : Vec3
  alpha_mode : AlphaMode
  alpha_cutoff : Double
  double_sided : Bool
} derive(Debug, ToJson, Eq)

// ===== 几何体 =====

///|
/// 图元拓扑类型
pub(all) enum PrimitiveMode {
  Points
  Lines
  LineLoop
  LineStrip
  Triangles
  TriangleStrip
  TriangleFan
} derive(Debug, ToJson, Eq)

///|
/// glTF Primitive — 几何体中的单个绘制调用
pub(all) struct GltfPrimitive {
  /// 顶点属性名 -> Accessor 索引
  attributes : Map[String, Int]
  indices : Int?
  material : Int?
  mode : PrimitiveMode
} derive(Debug, ToJson, Eq)

///|
/// glTF Mesh — 由若干 Primitive 组成的网格
pub(all) struct GltfMesh {
  name : String?
  primitives : Array[GltfPrimitive]
} derive(Debug, ToJson, Eq)

// ===== 场景节点 =====

///|
/// glTF Node — 场景图中的变换节点
pub(all) struct GltfNode {
  name : String?
  children : Array[Int]
  mesh : Int?
  skin : Int?
  camera : Int?
  translation : Vec3?
  rotation : Quat?
  scale : Vec3?
} derive(Debug, ToJson, Eq)

///|
/// glTF Scene — 渲染时使用的根节点集合
pub(all) struct GltfScene {
  name : String?
  nodes : Array[Int]
} derive(Debug, ToJson, Eq)

// ===== 动画 =====

///|
/// 动画插值方式
pub(all) enum Interpolation {
  Linear
  Step
  CubicSpline
} derive(Debug, ToJson, Eq)

///|
/// 动画目标属性
pub(all) enum AnimationPath {
  Translation
  Rotation
  Scale
  Weights
} derive(Debug, ToJson, Eq)

///|
/// 动画采样器
pub(all) struct AnimationSampler {
  input : Int
  output : Int
  interpolation : Interpolation
} derive(Debug, ToJson, Eq)

///|
/// 动画通道目标
pub(all) struct AnimationTarget {
  node : Int?
  path : AnimationPath
} derive(Debug, ToJson, Eq)

///|
/// 动画通道 — 将采样器输出映射到节点属性
pub(all) struct AnimationChannel {
  sampler : Int
  target : AnimationTarget
} derive(Debug, ToJson, Eq)

///|
/// glTF Animation — 关键帧动画
pub(all) struct GltfAnimation {
  name : String?
  channels : Array[AnimationChannel]
  samplers : Array[AnimationSampler]
} derive(Debug, ToJson, Eq)

// ===== 骨骼蒙皮 =====

///|
/// glTF Skin — 骨骼蒙皮数据
pub(all) struct GltfSkin {
  name : String?
  skeleton : Int?
  joints : Array[Int]
  inverse_bind_matrices : Int?
} derive(Debug, ToJson, Eq)

// ===== 顶层 Document =====

///|
/// 完整的 glTF 文档，包含所有资产数据
pub(all) struct GltfDocument {
  /// 版本字符串，如 "2.0"
  version : String
  /// 生成器标识
  generator : String?
  /// 版权信息
  copyright : String?
  scenes : Array[GltfScene]
  nodes : Array[GltfNode]
  meshes : Array[GltfMesh]
  materials : Array[GltfMaterial]
  textures : Array[GltfTexture]
  images : Array[GltfImage]
  samplers : Array[GltfSampler]
  accessors : Array[GltfAccessor]
  buffer_views : Array[GltfBufferView]
  buffers : Array[GltfBuffer]
  animations : Array[GltfAnimation]
  skins : Array[GltfSkin]
  default_scene : Int?
} derive(Debug, ToJson)
