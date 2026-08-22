///|
/// Resource streaming schedules for progressive loading and bounded memory use.
pub(all) enum StreamPriority {
  Critical
  Visible
  Prefetch
  Background
} derive(Debug, ToJson, Eq)

///|
pub(all) enum StreamState {
  Queued
  Loading
  Ready
  Failed
  Evicted
} derive(Debug, ToJson, Eq)

///|
pub(all) struct StreamRequest {
  id : Int
  resource : Int
  offset : Int
  length : Int
  priority : StreamPriority
  dependency_count : Int
  distance : Double
  state : StreamState
  retries : Int
} derive(Debug, ToJson, Eq)

///|
pub(all) struct StreamBudget {
  max_requests : Int
  max_in_flight_bytes : Int
  max_resident_bytes : Int
  max_retries : Int
  allow_eviction : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct StreamSelection {
  request_ids : Array[Int]
  bytes : Int
  critical_bytes : Int
  visible_bytes : Int
  prefetch_bytes : Int
  background_bytes : Int
} derive(Debug, ToJson, Eq)

///|
pub(all) struct StreamPlan {
  requests : Array[StreamRequest]
  selected : StreamSelection
  resident_bytes : Int
  in_flight_bytes : Int
  queued_bytes : Int
  evictable_bytes : Int
} derive(Debug, ToJson, Eq)

///|
pub(all) struct StreamValidation {
  passed : Bool
  violations : Array[String]
  request_count : Int
  total_bytes : Int
} derive(Debug, ToJson, Eq)

///|
pub fn stream_priority_rank(priority : StreamPriority) -> Int {
  match priority {
    Critical => 0
    Visible => 1
    Prefetch => 2
    Background => 3
  }
}

///|
pub fn stream_priority_name(priority : StreamPriority) -> String {
  match priority {
    Critical => "critical"
    Visible => "visible"
    Prefetch => "prefetch"
    Background => "background"
  }
}

///|
pub fn stream_state_name(state : StreamState) -> String {
  match state {
    Queued => "queued"
    Loading => "loading"
    Ready => "ready"
    Failed => "failed"
    Evicted => "evicted"
  }
}

///|
pub fn stream_request(
  id : Int,
  resource : Int,
  offset : Int,
  length : Int,
  priority : StreamPriority,
) -> StreamRequest {
  {
    id,
    resource,
    offset,
    length: if length < 0 {
      0
    } else {
      length
    },
    priority,
    dependency_count: 0,
    distance: 0.0,
    state: Queued,
    retries: 0,
  }
}

///|
pub fn stream_request_with_context(
  request : StreamRequest,
  dependency_count : Int,
  distance : Double,
) -> StreamRequest {
  { ..request, dependency_count, distance }
}

///|
pub fn stream_request_set_state(
  request : StreamRequest,
  state : StreamState,
) -> StreamRequest {
  { ..request, state, }
}

///|
pub fn stream_request_retry(request : StreamRequest) -> StreamRequest {
  { ..request, retries: request.retries + 1, state: Queued }
}

///|
pub fn stream_request_is_active(request : StreamRequest) -> Bool {
  request.state == Queued || request.state == Loading
}

///|
pub fn stream_request_is_resident(request : StreamRequest) -> Bool {
  request.state == Ready
}

///|
pub fn stream_request_is_evictable(request : StreamRequest) -> Bool {
  request.state == Ready && request.priority != Critical
}

///|
pub fn stream_request_end(request : StreamRequest) -> Int {
  request.offset + request.length
}

///|
pub fn stream_requests_overlap(
  left : StreamRequest,
  right : StreamRequest,
) -> Bool {
  left.resource == right.resource &&
  left.offset < stream_request_end(right) &&
  right.offset < stream_request_end(left)
}

///|
pub fn stream_merge_requests(
  left : StreamRequest,
  right : StreamRequest,
) -> StreamRequest? {
  if left.resource != right.resource || !stream_requests_overlap(left, right) {
    None
  } else {
    let start = if left.offset < right.offset {
      left.offset
    } else {
      right.offset
    }
    let end = if stream_request_end(left) > stream_request_end(right) {
      stream_request_end(left)
    } else {
      stream_request_end(right)
    }
    let priority = if stream_priority_rank(left.priority) <
      stream_priority_rank(right.priority) {
      left.priority
    } else {
      right.priority
    }
    Some({
      id: if left.id < right.id {
        left.id
      } else {
        right.id
      },
      resource: left.resource,
      offset: start,
      length: end - start,
      priority,
      dependency_count: left.dependency_count + right.dependency_count,
      distance: if left.distance < right.distance {
        left.distance
      } else {
        right.distance
      },
      state: Queued,
      retries: if left.retries > right.retries {
        left.retries
      } else {
        right.retries
      },
    })
  }
}

///|
pub fn default_stream_budget() -> StreamBudget {
  {
    max_requests: 100000,
    max_in_flight_bytes: 64 * 1024 * 1024,
    max_resident_bytes: 512 * 1024 * 1024,
    max_retries: 3,
    allow_eviction: true,
  }
}

///|
pub fn stream_total_bytes(requests : Array[StreamRequest]) -> Int {
  let mut total = 0
  for request in requests {
    total = total + request.length
  }
  total
}

///|
pub fn stream_bytes_for_priority(
  requests : Array[StreamRequest],
  priority : StreamPriority,
) -> Int {
  let mut total = 0
  for request in requests {
    if request.priority == priority {
      total = total + request.length
    }
  }
  total
}

///|
pub fn stream_bytes_for_state(
  requests : Array[StreamRequest],
  state : StreamState,
) -> Int {
  let mut total = 0
  for request in requests {
    if request.state == state {
      total = total + request.length
    }
  }
  total
}

///|
pub fn stream_request_score(request : StreamRequest) -> Double {
  let priority_score = Double::from_int(
      4 - stream_priority_rank(request.priority),
    ) *
    1000000.0
  let dependency_score = Double::from_int(request.dependency_count) * 1000.0
  let distance_score = if request.distance <= 0.0 {
    1000.0
  } else {
    1.0 / request.distance
  }
  priority_score +
  dependency_score +
  distance_score -
  Double::from_int(request.retries) * 100.0
}

///|
pub fn stream_sort_requests(requests : Array[StreamRequest]) -> Unit {
  let count = requests.length()
  if count < 2 {
    return
  }
  for pass in 0..<count {
    let limit = count - pass - 1
    for index in 0..<limit {
      match (requests.get(index), requests.get(index + 1)) {
        (Some(left), Some(right)) =>
          if stream_request_score(left) < stream_request_score(right) {
            requests[index] = right
            requests[index + 1] = left
          }
        _ => ()
      }
    }
  }
}

///|
pub fn stream_select(
  requests : Array[StreamRequest],
  budget : StreamBudget,
) -> StreamSelection {
  let candidates = requests.filter(fn(request) {
    request.state == Queued &&
    request.length > 0 &&
    request.retries <= budget.max_retries
  })
  stream_sort_requests(candidates)
  let selected : Array[Int] = []
  let mut bytes = 0
  let mut critical_bytes = 0
  let mut visible_bytes = 0
  let mut prefetch_bytes = 0
  let mut background_bytes = 0
  for request in candidates {
    if selected.length() >= budget.max_requests {
      break
    }
    if bytes + request.length > budget.max_in_flight_bytes {
      continue
    }
    selected.push(request.id)
    bytes = bytes + request.length
    match request.priority {
      Critical => critical_bytes = critical_bytes + request.length
      Visible => visible_bytes = visible_bytes + request.length
      Prefetch => prefetch_bytes = prefetch_bytes + request.length
      Background => background_bytes = background_bytes + request.length
    }
  }
  {
    request_ids: selected,
    bytes,
    critical_bytes,
    visible_bytes,
    prefetch_bytes,
    background_bytes,
  }
}

///|
pub fn stream_selection_contains(selection : StreamSelection, id : Int) -> Bool {
  selection.request_ids.contains(id)
}

///|
pub fn stream_selection_priority_bytes(
  selection : StreamSelection,
  priority : StreamPriority,
) -> Int {
  match priority {
    Critical => selection.critical_bytes
    Visible => selection.visible_bytes
    Prefetch => selection.prefetch_bytes
    Background => selection.background_bytes
  }
}

///|
pub fn stream_plan(
  requests : Array[StreamRequest],
  budget : StreamBudget,
) -> StreamPlan {
  let selection = stream_select(requests, budget)
  {
    requests,
    selected: selection,
    resident_bytes: stream_bytes_for_state(requests, Ready),
    in_flight_bytes: stream_bytes_for_state(requests, Loading),
    queued_bytes: stream_bytes_for_state(requests, Queued),
    evictable_bytes: stream_requests(requests).filter(
      stream_request_is_evictable,
    )
    |> stream_total_bytes,
  }
}

///|
fn stream_requests(requests : Array[StreamRequest]) -> Array[StreamRequest] {
  requests
}

///|
pub fn stream_apply_selection(
  requests : Array[StreamRequest],
  selection : StreamSelection,
) -> Array[StreamRequest] {
  requests.map(fn(request) {
    if selection_contains_id(selection.request_ids, request.id) {
      stream_request_set_state(request, Loading)
    } else {
      request
    }
  })
}

///|
fn selection_contains_id(ids : Array[Int], id : Int) -> Bool {
  ids.contains(id)
}

///|
pub fn stream_mark_ready(
  requests : Array[StreamRequest],
  id : Int,
) -> Array[StreamRequest] {
  requests.map(fn(request) {
    if request.id == id {
      stream_request_set_state(request, Ready)
    } else {
      request
    }
  })
}

///|
pub fn stream_mark_failed(
  requests : Array[StreamRequest],
  id : Int,
  retry : Bool,
) -> Array[StreamRequest] {
  requests.map(fn(request) {
    if request.id != id {
      request
    } else if retry {
      stream_request_retry(request)
    } else {
      stream_request_set_state(request, Failed)
    }
  })
}

///|
pub fn stream_evict(
  requests : Array[StreamRequest],
  max_bytes : Int,
) -> Array[StreamRequest] {
  let result = requests.copy()
  let mut resident = stream_bytes_for_state(result, Ready)
  if resident <= max_bytes {
    return result
  }
  let evictable = result.filter(stream_request_is_evictable)
  let ordered = evictable.copy()
  stream_sort_eviction_candidates(ordered)
  for candidate in ordered {
    if resident <= max_bytes {
      break
    }
    for index, request in result {
      if request.id == candidate.id {
        result[index] = stream_request_set_state(request, Evicted)
        resident = resident - request.length
        break
      }
    }
  }
  result
}

///|
fn stream_sort_eviction_candidates(requests : Array[StreamRequest]) -> Unit {
  let count = requests.length()
  if count < 2 {
    return
  }
  for pass in 0..<count {
    let limit = count - pass - 1
    for index in 0..<limit {
      match (requests.get(index), requests.get(index + 1)) {
        (Some(left), Some(right)) => {
          let left_score = Double::from_int(stream_priority_rank(left.priority)) *
            1000.0 +
            left.distance
          let right_score = Double::from_int(
              stream_priority_rank(right.priority),
            ) *
            1000.0 +
            right.distance
          if left_score < right_score {
            requests[index] = right
            requests[index + 1] = left
          }
        }
        _ => ()
      }
    }
  }
}

///|
pub fn stream_validate(
  requests : Array[StreamRequest],
  budget : StreamBudget,
) -> StreamValidation {
  let violations : Array[String] = []
  if requests.length() > budget.max_requests {
    violations.push("request count exceeds budget")
  }
  if stream_bytes_for_state(requests, Loading) > budget.max_in_flight_bytes {
    violations.push("in-flight bytes exceed budget")
  }
  if stream_bytes_for_state(requests, Ready) > budget.max_resident_bytes {
    violations.push("resident bytes exceed budget")
  }
  for request in requests {
    if request.offset < 0 || request.length < 0 {
      violations.push("request has a negative range")
      break
    }
    if request.retries > budget.max_retries {
      violations.push("request retries exceed budget")
      break
    }
  }
  {
    passed: violations.length() == 0,
    violations,
    request_count: requests.length(),
    total_bytes: stream_total_bytes(requests),
  }
}

///|
pub fn stream_coalesce(requests : Array[StreamRequest]) -> Array[StreamRequest] {
  let result : Array[StreamRequest] = []
  for request in requests {
    let mut merged : StreamRequest? = None
    let mut merged_index : Int? = None
    for index, existing in result {
      match stream_merge_requests(existing, request) {
        Some(value) => {
          merged = Some(value)
          merged_index = Some(index)
          break
        }
        None => ()
      }
    }
    match (merged, merged_index) {
      (Some(value), Some(index)) => result[index] = value
      _ => result.push(request)
    }
  }
  result
}

///|
pub fn stream_group_by_resource(
  requests : Array[StreamRequest],
) -> Map[Int, Int] {
  let groups : Map[Int, Int] = Map([])
  for request in requests {
    groups[request.resource] = match groups.get(request.resource) {
      Some(count) => count + 1
      None => 1
    }
  }
  groups
}

///|
pub fn stream_plan_lines(plan : StreamPlan) -> Array[String] {
  [
    "requests=\{plan.requests.length()}",
    "selected=\{plan.selected.request_ids.length()}",
    "selected_bytes=\{plan.selected.bytes}",
    "resident_bytes=\{plan.resident_bytes}",
    "in_flight_bytes=\{plan.in_flight_bytes}",
    "queued_bytes=\{plan.queued_bytes}",
    "evictable_bytes=\{plan.evictable_bytes}",
  ]
}

///|
pub fn stream_selection_lines(selection : StreamSelection) -> Array[String] {
  [
    "bytes=\{selection.bytes}",
    "critical_bytes=\{selection.critical_bytes}",
    "visible_bytes=\{selection.visible_bytes}",
    "prefetch_bytes=\{selection.prefetch_bytes}",
    "background_bytes=\{selection.background_bytes}",
  ]
}
