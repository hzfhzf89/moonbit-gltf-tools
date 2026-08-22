///|
pub(all) enum SceneTaskKind {
  Transform
  Visibility
  Animation
  Skinning
  Geometry
  Upload
} derive(Debug, ToJson, Eq)

///|
pub(all) enum SceneTaskState {
  Pending
  Ready
  Running
  Complete
  Blocked
  Failed
} derive(Debug, ToJson, Eq)

///|
pub(all) struct SceneTask {
  id : Int
  node : Int
  kind : SceneTaskKind
  state : SceneTaskState
  dependencies : Array[Int]
  dependents : Array[Int]
  cost : Int
  priority : Int
  frame : Int
} derive(Debug, ToJson, Eq)

///|
pub(all) struct SceneSchedule {
  tasks : Array[SceneTask]
  ready : Array[Int]
  blocked : Array[Int]
  completed : Array[Int]
  frame : Int
  estimated_cost : Int
} derive(Debug, ToJson, Eq)

///|
pub(all) struct SceneSchedulerPolicy {
  max_tasks : Int
  max_cost_per_frame : Int
  max_dependencies : Int
  allow_failed_dependencies : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct SceneSchedulerResult {
  passed : Bool
  violations : Array[String]
  schedule : SceneSchedule
} derive(Debug, ToJson, Eq)

///|
pub fn scene_task_kind_rank(kind : SceneTaskKind) -> Int {
  match kind {
    Transform => 0
    Visibility => 1
    Animation => 2
    Skinning => 3
    Geometry => 4
    Upload => 5
  }
}

///|
pub fn scene_task_kind_name(kind : SceneTaskKind) -> String {
  match kind {
    Transform => "transform"
    Visibility => "visibility"
    Animation => "animation"
    Skinning => "skinning"
    Geometry => "geometry"
    Upload => "upload"
  }
}

///|
pub fn scene_task_state_name(state : SceneTaskState) -> String {
  match state {
    Pending => "pending"
    Ready => "ready"
    Running => "running"
    Complete => "complete"
    Blocked => "blocked"
    Failed => "failed"
  }
}

///|
pub fn scene_task(
  id : Int,
  node : Int,
  kind : SceneTaskKind,
  cost : Int,
  priority : Int,
) -> SceneTask {
  {
    id,
    node,
    kind,
    state: Pending,
    dependencies: [],
    dependents: [],
    cost: if cost < 0 {
      0
    } else {
      cost
    },
    priority,
    frame: 0,
  }
}

///|
pub fn scene_task_add_dependency(
  task : SceneTask,
  dependency : Int,
) -> SceneTask {
  if task.dependencies.contains(dependency) {
    task
  } else {
    { ..task, dependencies: task.dependencies + [dependency] }
  }
}

///|
pub fn scene_task_add_dependent(task : SceneTask, dependent : Int) -> SceneTask {
  if task.dependents.contains(dependent) {
    task
  } else {
    { ..task, dependents: task.dependents + [dependent] }
  }
}

///|
pub fn scene_task_is_terminal(task : SceneTask) -> Bool {
  task.state == Complete || task.state == Failed
}

///|
pub fn scene_task_is_ready(task : SceneTask, tasks : Array[SceneTask]) -> Bool {
  if task.state != Pending && task.state != Blocked {
    return false
  }
  for dependency in task.dependencies {
    match tasks.get(dependency) {
      Some(value) => if value.state != Complete { return false }
      None => return false
    }
  }
  true
}

///|
pub fn scene_task_dependency_cost(
  task : SceneTask,
  tasks : Array[SceneTask],
) -> Int {
  let mut result = 0
  for dependency in task.dependencies {
    match tasks.get(dependency) {
      Some(value) => result = result + value.cost
      None => ()
    }
  }
  result
}

///|
pub fn scene_task_score(task : SceneTask, tasks : Array[SceneTask]) -> Double {
  let priority = Double::from_int(task.priority) * 1000.0
  let kind = Double::from_int(6 - scene_task_kind_rank(task.kind)) * 100.0
  let dependency = Double::from_int(scene_task_dependency_cost(task, tasks))
  priority + kind - dependency - Double::from_int(task.cost)
}

///|
pub fn scene_sort_ready(ids : Array[Int], tasks : Array[SceneTask]) -> Unit {
  let count = ids.length()
  for pass in 0..<count {
    let limit = count - pass - 1
    for index in 0..<limit {
      match (ids.get(index), ids.get(index + 1)) {
        (Some(left_id), Some(right_id)) =>
          match (tasks.get(left_id), tasks.get(right_id)) {
            (Some(left), Some(right)) =>
              if scene_task_score(left, tasks) < scene_task_score(right, tasks) {
                ids[index] = right_id
                ids[index + 1] = left_id
              }
            _ => ()
          }
        _ => ()
      }
    }
  }
}

///|
pub fn scene_schedule(tasks : Array[SceneTask]) -> SceneSchedule {
  let ready : Array[Int] = []
  let blocked : Array[Int] = []
  for index, task in tasks {
    if task.dependencies.length() == 0 {
      ready.push(index)
    } else {
      blocked.push(index)
    }
  }
  scene_sort_ready(ready, tasks)
  { tasks, ready, blocked, completed: [], frame: 0, estimated_cost: 0 }
}

///|
pub fn scene_schedule_add_task(
  schedule : SceneSchedule,
  task : SceneTask,
) -> SceneSchedule {
  let tasks = schedule.tasks.copy()
  tasks.push(task)
  let index = tasks.length() - 1
  let ready = schedule.ready.copy()
  let blocked = schedule.blocked.copy()
  if task.dependencies.length() == 0 {
    ready.push(index)
  } else {
    blocked.push(index)
  }
  { ..schedule, tasks, ready, blocked }
}

///|
pub fn scene_schedule_link(
  schedule : SceneSchedule,
  task_id : Int,
  dependency_id : Int,
) -> SceneSchedule {
  let tasks = schedule.tasks.copy()
  match (tasks.get(task_id), tasks.get(dependency_id)) {
    (Some(task), Some(dependency)) => {
      tasks[task_id] = scene_task_add_dependency(task, dependency_id)
      tasks[dependency_id] = scene_task_add_dependent(dependency, task_id)
      { ..schedule, tasks, }
    }
    _ => schedule
  }
}

///|
pub fn scene_schedule_refresh(schedule : SceneSchedule) -> SceneSchedule {
  let ready : Array[Int] = []
  let blocked : Array[Int] = []
  for index, task in schedule.tasks {
    if scene_task_is_ready(task, schedule.tasks) {
      ready.push(index)
    } else if !scene_task_is_terminal(task) {
      blocked.push(index)
    }
  }
  scene_sort_ready(ready, schedule.tasks)
  { ..schedule, ready, blocked }
}

///|
pub fn scene_schedule_take(
  schedule : SceneSchedule,
  budget : Int,
) -> (SceneSchedule, Array[Int]) {
  let refreshed = scene_schedule_refresh(schedule)
  let tasks = refreshed.tasks.copy()
  let ready = refreshed.ready.copy()
  let selected : Array[Int] = []
  let mut used = 0
  while ready.length() > 0 {
    let id = ready.remove(0)
    match tasks.get(id) {
      Some(task) =>
        if used + task.cost <= budget {
          tasks[id] = { ..task, state: Running, frame: refreshed.frame }
          selected.push(id)
          used = used + task.cost
        } else {
          ready.insert(0, id)
          break
        }
      None => ()
    }
  }
  ({ ..refreshed, tasks, ready, estimated_cost: used }, selected)
}

///|
pub fn scene_schedule_complete(
  schedule : SceneSchedule,
  task_id : Int,
) -> SceneSchedule {
  let tasks = schedule.tasks.copy()
  let completed = schedule.completed.copy()
  match tasks.get(task_id) {
    Some(task) =>
      if !scene_task_is_terminal(task) {
        tasks[task_id] = { ..task, state: Complete }
        completed.push(task_id)
      }
    None => ()
  }
  scene_schedule_refresh({ ..schedule, tasks, completed })
}

///|
pub fn scene_schedule_fail(
  schedule : SceneSchedule,
  task_id : Int,
) -> SceneSchedule {
  let tasks = schedule.tasks.copy()
  match tasks.get(task_id) {
    Some(task) => tasks[task_id] = { ..task, state: Failed }
    None => ()
  }
  scene_schedule_refresh({ ..schedule, tasks, })
}

///|
pub fn scene_schedule_advance(
  schedule : SceneSchedule,
  frame : Int,
) -> SceneSchedule {
  {
    ..schedule,
    frame: if frame < schedule.frame {
      schedule.frame
    } else {
      frame
    },
  }
}

///|
pub fn scene_schedule_completed_cost(schedule : SceneSchedule) -> Int {
  let mut cost = 0
  for task in schedule.tasks {
    if task.state == Complete {
      cost = cost + task.cost
    }
  }
  cost
}

///|
pub fn scene_schedule_pending_cost(schedule : SceneSchedule) -> Int {
  let mut cost = 0
  for task in schedule.tasks {
    if !scene_task_is_terminal(task) {
      cost = cost + task.cost
    }
  }
  cost
}

///|
pub fn scene_schedule_cycle_nodes(schedule : SceneSchedule) -> Array[Int] {
  let result : Array[Int] = []
  for task in schedule.tasks {
    if task.state == Blocked && task.dependencies.length() > 0 {
      let mut all_blocked = true
      for dependency in task.dependencies {
        match schedule.tasks.get(dependency) {
          Some(value) => if value.state == Complete { all_blocked = false }
          None => ()
        }
      }
      if all_blocked {
        result.push(task.id)
      }
    }
  }
  result
}

///|
pub fn default_scene_scheduler_policy() -> SceneSchedulerPolicy {
  {
    max_tasks: 100000,
    max_cost_per_frame: 1000000,
    max_dependencies: 64,
    allow_failed_dependencies: false,
  }
}

///|
pub fn scene_scheduler_result(
  schedule : SceneSchedule,
  policy : SceneSchedulerPolicy,
) -> SceneSchedulerResult {
  let violations : Array[String] = []
  if schedule.tasks.length() > policy.max_tasks {
    violations.push("task count exceeds policy")
  }
  if schedule.estimated_cost > policy.max_cost_per_frame {
    violations.push("frame cost exceeds policy")
  }
  for task in schedule.tasks {
    if task.dependencies.length() > policy.max_dependencies {
      violations.push("task dependency count exceeds policy")
      break
    }
    if !policy.allow_failed_dependencies {
      for dependency in task.dependencies {
        match schedule.tasks.get(dependency) {
          Some(value) =>
            if value.state == Failed {
              violations.push("failed dependency blocks schedule")
              break
            }
          None => violations.push("task references missing dependency")
        }
      }
    }
  }
  { passed: violations.length() == 0, violations, schedule }
}

///|
pub fn scene_schedule_lines(schedule : SceneSchedule) -> Array[String] {
  [
    "tasks=\{schedule.tasks.length()}",
    "ready=\{schedule.ready.length()}",
    "blocked=\{schedule.blocked.length()}",
    "completed=\{schedule.completed.length()}",
    "frame=\{schedule.frame}",
    "estimated_cost=\{schedule.estimated_cost}",
    "completed_cost=\{scene_schedule_completed_cost(schedule)}",
    "pending_cost=\{scene_schedule_pending_cost(schedule)}",
  ]
}
