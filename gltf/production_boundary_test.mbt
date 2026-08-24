///|
/// Boundary coverage for the production pipelines added for import and runtime use.
test "binary reader rejects truncated values" {
  let bytes = Bytes::from_array([0x01, 0x02])
  inspect(@gltf.read_u16_le(bytes, 0) catch { _ => -1 }, content="513")
  let value : UInt = @gltf.read_u32_le(bytes, 0) catch { _ => 0 }
  inspect(value.reinterpret_as_int(), content="0")
  inspect(
    @gltf.binary_range_is_valid(bytes, @gltf.binary_range(0, 2)),
    content="true",
  )
  inspect(
    @gltf.binary_range_is_valid(bytes, @gltf.binary_range(1, 2)),
    content="false",
  )
}

///|
test "GLB writer produces aligned container" {
  let glb = @gltf.build_glb(
    "{\"asset\":{\"version\":\"2.0\"}}",
    Bytes::from_array([1, 2, 3]),
  )
  inspect(@gltf.validate_glb_container(glb).length(), content="0")
  inspect(@gltf.glb_chunk_count(glb), content="2")
  inspect(@gltf.glb_has_json_chunk(glb), content="true")
  inspect(@gltf.glb_has_bin_chunk(glb), content="true")
  inspect(glb.length() % 4, content="0")
}

///|
test "topology detects boundaries and degenerate triangles" {
  let triangles = [
    @gltf.topology_triangle(0, 1, 2),
    @gltf.topology_triangle(0, 2, 3),
    @gltf.topology_triangle(4, 4, 5),
  ]
  let report = @gltf.topology_report(triangles, 6)
  inspect(report.triangle_count, content="3")
  inspect(report.degenerate_triangle_count, content="1")
  inspect(report.boundary_edge_count > 0, content="true")
  inspect(
    @gltf.topology_budget_result(report, @gltf.default_topology_policy()).passed,
    content="false",
  )
}

///|
test "spatial ray and sphere queries handle inactive layers" {
  let bounds = @gltf.spatial_aabb(
    @gltf.spatial_vec3(-1.0, -1.0, -1.0),
    @gltf.spatial_vec3(1.0, 1.0, 1.0),
  )
  let active = @gltf.spatial_item(10, bounds, 1)
  let inactive = @gltf.spatial_item_set_active(
    @gltf.spatial_item(20, bounds, 2),
    false,
  )
  let index = @gltf.spatial_index_insert_many(@gltf.spatial_index_empty(), [
    active, inactive,
  ])
  let ray = @gltf.spatial_ray(
    @gltf.spatial_vec3(0.0, 0.0, -5.0),
    @gltf.spatial_vec3(0.0, 0.0, 1.0),
  )
  let result = @gltf.spatial_query_ray(index, ray, 1, 100.0)
  inspect(result.hits.length(), content="1")
  inspect(result.hits[0].id, content="10")
  inspect(
    @gltf.spatial_query_sphere(index, @gltf.spatial_vec3(0.0, 0.0, 0.0), 0.5, 1).hits.length(),
    content="1",
  )
}

///|
test "cache reorder preserves triangle multiset" {
  let indices = [0, 1, 2, 2, 1, 3, 3, 1, 4]
  let policy = @gltf.default_cache_policy()
  let result = @gltf.cache_reorder_greedy(indices, 5, policy)
  inspect(@gltf.cache_validate_reorder(indices, result.indices), content="true")
  inspect(result.indices.length(), content="9")
  inspect(result.after.valid, content="true")
}

///|
test "instance batching groups visible records" {
  let bounds = @gltf.spatial_aabb(
    @gltf.spatial_vec3(0.0, 0.0, 0.0),
    @gltf.spatial_vec3(1.0, 1.0, 1.0),
  )
  let transform = @gltf.instance_transform_identity()
  let first = @gltf.instance_record(1, 3, 4, transform, bounds, 1)
  let second = @gltf.instance_record(2, 3, 4, transform, bounds, 1)
  let hidden = @gltf.instance_set_visible(
    @gltf.instance_record(3, 3, 4, transform, bounds, 1),
    false,
  )
  let plan = @gltf.instance_plan([first, second, hidden], [0, 0, 0])
  inspect(plan.visible_instances, content="2")
  inspect(plan.batch_count, content="1")
  inspect(plan.draw_count, content="1")
}

///|
test "stream scheduler respects byte budget" {
  let requests = [
    @gltf.stream_request(1, 0, 0, 80, @gltf.Critical),
    @gltf.stream_request(2, 0, 80, 80, @gltf.Visible),
    @gltf.stream_request(3, 1, 0, 80, @gltf.Background),
  ]
  let budget = { ..@gltf.default_stream_budget(), max_in_flight_bytes: 100 }
  let selection = @gltf.stream_select(requests, budget)
  inspect(selection.bytes <= 100, content="true")
  inspect(selection.request_ids.length(), content="1")
  let loading = @gltf.stream_apply_selection(requests, selection)
  inspect(@gltf.stream_bytes_for_state(loading, @gltf.Loading), content="80")
}

///|
test "geometry ray hit returns barycentric coordinates" {
  let ray = @gltf.spatial_ray(
    @gltf.spatial_vec3(0.25, 0.25, 1.0),
    @gltf.spatial_vec3(0.0, 0.0, -1.0),
  )
  let hit = @gltf.geometry_ray_triangle(
    ray,
    @gltf.spatial_vec3(0.0, 0.0, 0.0),
    @gltf.spatial_vec3(1.0, 0.0, 0.0),
    @gltf.spatial_vec3(0.0, 1.0, 0.0),
    0,
    false,
  )
  inspect(hit is Some(_), content="true")
  match hit {
    Some(value) =>
      inspect(
        @gltf.geometry_barycentric_valid(value.barycentric, 0.00001),
        content="true",
      )
    None => ()
  }
}

///|
test "quality gate requires structural coverage" {
  let check = @gltf.quality_gate_check(
    @gltf.Geometry,
    "geometry",
    @gltf.Passed,
    95.0,
    [],
  )
  let matrix = @gltf.quality_gate_release_check(
    @gltf.quality_gate_matrix([check]),
    @gltf.default_quality_gate_policy(),
  )
  inspect(matrix.release_ready, content="false")
  inspect(matrix.failed > 0, content="true")
}

///|
test "animation budget checks decoded report timelines" {
  let track = @gltf.AnimationTrack::{
    animation_index: 0,
    channel_index: 0,
    sampler_index: 0,
    node: Some(0),
    path: @gltf.Translation,
    interpolation: @gltf.Linear,
    input_accessor: 0,
    output_accessor: 1,
    times: [0.0, 0.75, 0.5],
    values: [0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0.5, 0.5, 0.5],
    component_count: 3,
    status: @gltf.Valid,
    errors: [],
  }
  let report = @gltf.AnimationClipReport::{
    animation_index: 0,
    name: Some("walk"),
    channel_count: 1,
    sampler_count: 1,
    track_count: 1,
    duration: 0.75,
    start_time: 0.0,
    end_time: 0.75,
    loopable: false,
    invalid_track_count: 1,
    target_node_count: 1,
    animated_path_count: 1,
    tracks: [track],
  }
  let result = @gltf.animation_budget_result_from_reports(
    [report],
    @gltf.default_animation_budget(),
  )
  inspect(result.passed, content="false")
  inspect(result.violations.length(), content="1")
}

///|
test "material report budget preserves policy findings" {
  let slot = @gltf.TextureSlotReport::{
    material: 0,
    semantic: @gltf.BaseColor,
    texture: 0,
    image: Some(2),
    sampler: None,
    tex_coord: 0,
    uri: Some("textures/albedo.png"),
    embedded: false,
    external: true,
    valid: true,
    issues: [],
  }
  let report = @gltf.MaterialReport::{
    material: 0,
    name: Some("transparent-double-sided"),
    alpha_mode: @gltf.Blend,
    texture_slot_count: 1,
    texcoord_set_count: 1,
    has_normal_map: false,
    has_emissive: false,
    has_transparency: true,
    double_sided: true,
    metallic_factor: 0.0,
    roughness_factor: 1.0,
    base_color: @gltf.Color4::{ r: 1.0, g: 1.0, b: 1.0, a: 0.5 },
    texture_slots: [slot],
    issues: [],
    signature: "test",
    valid: true,
  }
  let budget = {
    ..@gltf.default_material_budget(),
    max_unique_images: 0,
    max_external_images: 0,
    max_texcoord_sets: 0,
    allow_double_sided: false,
    allow_blend: false,
  }
  let result = @gltf.material_budget_result_from_reports([report], budget)
  inspect(result.passed, content="false")
  inspect(result.image_overage, content="1")
  inspect(result.external_image_overage, content="1")
  inspect(result.texcoord_overage, content="1")
  inspect(result.violations.length(), content="5")
}
