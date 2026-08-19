///|
test "uri safety boundary 0" {
  let value = "textures/brick_0.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 1" {
  let value = "../escape_1.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 2" {
  let value = "data:application/octet-stream;base64,AAAA2"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 3" {
  let value = "#node-3"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 4" {
  let value = "textures/brick_4.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 5" {
  let value = "../escape_5.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 6" {
  let value = "data:application/octet-stream;base64,AAAA6"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 7" {
  let value = "#node-7"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 8" {
  let value = "textures/brick_8.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 9" {
  let value = "../escape_9.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 10" {
  let value = "data:application/octet-stream;base64,AAAA10"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 11" {
  let value = "#node-11"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 12" {
  let value = "textures/brick_12.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 13" {
  let value = "../escape_13.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 14" {
  let value = "data:application/octet-stream;base64,AAAA14"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 15" {
  let value = "#node-15"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 16" {
  let value = "textures/brick_16.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 17" {
  let value = "../escape_17.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 18" {
  let value = "data:application/octet-stream;base64,AAAA18"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 19" {
  let value = "#node-19"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 20" {
  let value = "textures/brick_20.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 21" {
  let value = "../escape_21.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 22" {
  let value = "data:application/octet-stream;base64,AAAA22"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 23" {
  let value = "#node-23"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 24" {
  let value = "textures/brick_24.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 25" {
  let value = "../escape_25.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 26" {
  let value = "data:application/octet-stream;base64,AAAA26"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 27" {
  let value = "#node-27"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 28" {
  let value = "textures/brick_28.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 29" {
  let value = "../escape_29.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 30" {
  let value = "data:application/octet-stream;base64,AAAA30"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 31" {
  let value = "#node-31"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 32" {
  let value = "textures/brick_32.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 33" {
  let value = "../escape_33.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 34" {
  let value = "data:application/octet-stream;base64,AAAA34"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 35" {
  let value = "#node-35"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 36" {
  let value = "textures/brick_36.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 37" {
  let value = "../escape_37.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 38" {
  let value = "data:application/octet-stream;base64,AAAA38"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 39" {
  let value = "#node-39"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 40" {
  let value = "textures/brick_40.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 41" {
  let value = "../escape_41.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 42" {
  let value = "data:application/octet-stream;base64,AAAA42"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 43" {
  let value = "#node-43"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 44" {
  let value = "textures/brick_44.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 45" {
  let value = "../escape_45.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 46" {
  let value = "data:application/octet-stream;base64,AAAA46"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 47" {
  let value = "#node-47"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 48" {
  let value = "textures/brick_48.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 49" {
  let value = "../escape_49.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 50" {
  let value = "data:application/octet-stream;base64,AAAA50"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 51" {
  let value = "#node-51"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 52" {
  let value = "textures/brick_52.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 53" {
  let value = "../escape_53.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 54" {
  let value = "data:application/octet-stream;base64,AAAA54"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 55" {
  let value = "#node-55"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 56" {
  let value = "textures/brick_56.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 57" {
  let value = "../escape_57.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 58" {
  let value = "data:application/octet-stream;base64,AAAA58"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 59" {
  let value = "#node-59"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 60" {
  let value = "textures/brick_60.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 61" {
  let value = "../escape_61.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 62" {
  let value = "data:application/octet-stream;base64,AAAA62"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 63" {
  let value = "#node-63"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 64" {
  let value = "textures/brick_64.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 65" {
  let value = "../escape_65.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 66" {
  let value = "data:application/octet-stream;base64,AAAA66"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 67" {
  let value = "#node-67"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 68" {
  let value = "textures/brick_68.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 69" {
  let value = "../escape_69.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 70" {
  let value = "data:application/octet-stream;base64,AAAA70"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 71" {
  let value = "#node-71"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 72" {
  let value = "textures/brick_72.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 73" {
  let value = "../escape_73.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 74" {
  let value = "data:application/octet-stream;base64,AAAA74"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 75" {
  let value = "#node-75"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 76" {
  let value = "textures/brick_76.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 77" {
  let value = "../escape_77.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 78" {
  let value = "data:application/octet-stream;base64,AAAA78"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 79" {
  let value = "#node-79"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 80" {
  let value = "textures/brick_80.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 81" {
  let value = "../escape_81.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 82" {
  let value = "data:application/octet-stream;base64,AAAA82"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 83" {
  let value = "#node-83"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 84" {
  let value = "textures/brick_84.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 85" {
  let value = "../escape_85.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 86" {
  let value = "data:application/octet-stream;base64,AAAA86"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 87" {
  let value = "#node-87"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 88" {
  let value = "textures/brick_88.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 89" {
  let value = "../escape_89.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 90" {
  let value = "data:application/octet-stream;base64,AAAA90"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 91" {
  let value = "#node-91"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 92" {
  let value = "textures/brick_92.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 93" {
  let value = "../escape_93.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 94" {
  let value = "data:application/octet-stream;base64,AAAA94"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 95" {
  let value = "#node-95"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 96" {
  let value = "textures/brick_96.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 97" {
  let value = "../escape_97.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 98" {
  let value = "data:application/octet-stream;base64,AAAA98"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 99" {
  let value = "#node-99"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 100" {
  let value = "textures/brick_100.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 101" {
  let value = "../escape_101.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 102" {
  let value = "data:application/octet-stream;base64,AAAA102"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 103" {
  let value = "#node-103"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 104" {
  let value = "textures/brick_104.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 105" {
  let value = "../escape_105.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 106" {
  let value = "data:application/octet-stream;base64,AAAA106"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 107" {
  let value = "#node-107"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 108" {
  let value = "textures/brick_108.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 109" {
  let value = "../escape_109.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 110" {
  let value = "data:application/octet-stream;base64,AAAA110"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 111" {
  let value = "#node-111"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 112" {
  let value = "textures/brick_112.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 113" {
  let value = "../escape_113.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 114" {
  let value = "data:application/octet-stream;base64,AAAA114"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 115" {
  let value = "#node-115"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 116" {
  let value = "textures/brick_116.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 117" {
  let value = "../escape_117.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 118" {
  let value = "data:application/octet-stream;base64,AAAA118"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 119" {
  let value = "#node-119"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 120" {
  let value = "textures/brick_120.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 121" {
  let value = "../escape_121.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 122" {
  let value = "data:application/octet-stream;base64,AAAA122"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 123" {
  let value = "#node-123"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 124" {
  let value = "textures/brick_124.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 125" {
  let value = "../escape_125.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 126" {
  let value = "data:application/octet-stream;base64,AAAA126"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 127" {
  let value = "#node-127"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 128" {
  let value = "textures/brick_128.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 129" {
  let value = "../escape_129.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 130" {
  let value = "data:application/octet-stream;base64,AAAA130"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 131" {
  let value = "#node-131"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 132" {
  let value = "textures/brick_132.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 133" {
  let value = "../escape_133.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 134" {
  let value = "data:application/octet-stream;base64,AAAA134"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 135" {
  let value = "#node-135"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 136" {
  let value = "textures/brick_136.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 137" {
  let value = "../escape_137.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 138" {
  let value = "data:application/octet-stream;base64,AAAA138"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 139" {
  let value = "#node-139"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 140" {
  let value = "textures/brick_140.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 141" {
  let value = "../escape_141.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 142" {
  let value = "data:application/octet-stream;base64,AAAA142"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 143" {
  let value = "#node-143"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 144" {
  let value = "textures/brick_144.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 145" {
  let value = "../escape_145.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 146" {
  let value = "data:application/octet-stream;base64,AAAA146"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 147" {
  let value = "#node-147"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 148" {
  let value = "textures/brick_148.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 149" {
  let value = "../escape_149.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 150" {
  let value = "data:application/octet-stream;base64,AAAA150"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 151" {
  let value = "#node-151"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 152" {
  let value = "textures/brick_152.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 153" {
  let value = "../escape_153.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 154" {
  let value = "data:application/octet-stream;base64,AAAA154"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 155" {
  let value = "#node-155"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 156" {
  let value = "textures/brick_156.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 157" {
  let value = "../escape_157.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 158" {
  let value = "data:application/octet-stream;base64,AAAA158"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 159" {
  let value = "#node-159"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 160" {
  let value = "textures/brick_160.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 161" {
  let value = "../escape_161.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 162" {
  let value = "data:application/octet-stream;base64,AAAA162"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 163" {
  let value = "#node-163"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 164" {
  let value = "textures/brick_164.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 165" {
  let value = "../escape_165.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 166" {
  let value = "data:application/octet-stream;base64,AAAA166"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 167" {
  let value = "#node-167"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 168" {
  let value = "textures/brick_168.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 169" {
  let value = "../escape_169.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 170" {
  let value = "data:application/octet-stream;base64,AAAA170"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 171" {
  let value = "#node-171"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 172" {
  let value = "textures/brick_172.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 173" {
  let value = "../escape_173.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 174" {
  let value = "data:application/octet-stream;base64,AAAA174"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 175" {
  let value = "#node-175"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 176" {
  let value = "textures/brick_176.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 177" {
  let value = "../escape_177.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 178" {
  let value = "data:application/octet-stream;base64,AAAA178"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 179" {
  let value = "#node-179"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 180" {
  let value = "textures/brick_180.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 181" {
  let value = "../escape_181.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 182" {
  let value = "data:application/octet-stream;base64,AAAA182"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 183" {
  let value = "#node-183"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 184" {
  let value = "textures/brick_184.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 185" {
  let value = "../escape_185.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 186" {
  let value = "data:application/octet-stream;base64,AAAA186"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 187" {
  let value = "#node-187"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 188" {
  let value = "textures/brick_188.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 189" {
  let value = "../escape_189.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 190" {
  let value = "data:application/octet-stream;base64,AAAA190"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 191" {
  let value = "#node-191"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 192" {
  let value = "textures/brick_192.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 193" {
  let value = "../escape_193.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 194" {
  let value = "data:application/octet-stream;base64,AAAA194"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 195" {
  let value = "#node-195"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 196" {
  let value = "textures/brick_196.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 197" {
  let value = "../escape_197.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 198" {
  let value = "data:application/octet-stream;base64,AAAA198"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 199" {
  let value = "#node-199"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 200" {
  let value = "textures/brick_200.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 201" {
  let value = "../escape_201.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 202" {
  let value = "data:application/octet-stream;base64,AAAA202"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 203" {
  let value = "#node-203"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 204" {
  let value = "textures/brick_204.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 205" {
  let value = "../escape_205.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 206" {
  let value = "data:application/octet-stream;base64,AAAA206"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 207" {
  let value = "#node-207"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 208" {
  let value = "textures/brick_208.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 209" {
  let value = "../escape_209.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 210" {
  let value = "data:application/octet-stream;base64,AAAA210"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 211" {
  let value = "#node-211"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 212" {
  let value = "textures/brick_212.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 213" {
  let value = "../escape_213.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 214" {
  let value = "data:application/octet-stream;base64,AAAA214"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 215" {
  let value = "#node-215"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 216" {
  let value = "textures/brick_216.png"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 217" {
  let value = "../escape_217.bin"
  inspect(uri_is_safe_external(value), content="false")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 218" {
  let value = "data:application/octet-stream;base64,AAAA218"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "uri safety boundary 219" {
  let value = "#node-219"
  inspect(uri_is_safe_external(value), content="true")
  inspect(
    classify_uri(value) is Relative ||
    classify_uri(value) is Data ||
    classify_uri(value) is Fragment,
    content="true",
  )
}

///|
test "math bounds boundary 0" {
  let value = vec3(-5.0, -3.0, -2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 1" {
  let value = vec3(-4.0, -2.0, -1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 2" {
  let value = vec3(-3.0, -1.0, 0.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 3" {
  let value = vec3(-2.0, 0.0, 1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 4" {
  let value = vec3(-1.0, 1.0, 2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 5" {
  let value = vec3(0.0, 2.0, -2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 6" {
  let value = vec3(1.0, 3.0, -1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 7" {
  let value = vec3(2.0, -3.0, 0.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 8" {
  let value = vec3(3.0, -2.0, 1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 9" {
  let value = vec3(4.0, -1.0, 2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 10" {
  let value = vec3(5.0, 0.0, -2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 11" {
  let value = vec3(-5.0, 1.0, -1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 12" {
  let value = vec3(-4.0, 2.0, 0.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 13" {
  let value = vec3(-3.0, 3.0, 1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 14" {
  let value = vec3(-2.0, -3.0, 2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 15" {
  let value = vec3(-1.0, -2.0, -2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 16" {
  let value = vec3(0.0, -1.0, -1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 17" {
  let value = vec3(1.0, 0.0, 0.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 18" {
  let value = vec3(2.0, 1.0, 1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 19" {
  let value = vec3(3.0, 2.0, 2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 20" {
  let value = vec3(4.0, 3.0, -2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 21" {
  let value = vec3(5.0, -3.0, -1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 22" {
  let value = vec3(-5.0, -2.0, 0.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 23" {
  let value = vec3(-4.0, -1.0, 1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 24" {
  let value = vec3(-3.0, 0.0, 2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 25" {
  let value = vec3(-2.0, 1.0, -2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 26" {
  let value = vec3(-1.0, 2.0, -1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 27" {
  let value = vec3(0.0, 3.0, 0.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 28" {
  let value = vec3(1.0, -3.0, 1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 29" {
  let value = vec3(2.0, -2.0, 2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 30" {
  let value = vec3(3.0, -1.0, -2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 31" {
  let value = vec3(4.0, 0.0, -1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 32" {
  let value = vec3(5.0, 1.0, 0.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 33" {
  let value = vec3(-5.0, 2.0, 1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 34" {
  let value = vec3(-4.0, 3.0, 2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 35" {
  let value = vec3(-3.0, -3.0, -2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 36" {
  let value = vec3(-2.0, -2.0, -1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 37" {
  let value = vec3(-1.0, -1.0, 0.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 38" {
  let value = vec3(0.0, 0.0, 1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 39" {
  let value = vec3(1.0, 1.0, 2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 40" {
  let value = vec3(2.0, 2.0, -2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 41" {
  let value = vec3(3.0, 3.0, -1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 42" {
  let value = vec3(4.0, -3.0, 0.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 43" {
  let value = vec3(5.0, -2.0, 1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 44" {
  let value = vec3(-5.0, -1.0, 2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 45" {
  let value = vec3(-4.0, 0.0, -2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 46" {
  let value = vec3(-3.0, 1.0, -1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 47" {
  let value = vec3(-2.0, 2.0, 0.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 48" {
  let value = vec3(-1.0, 3.0, 1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 49" {
  let value = vec3(0.0, -3.0, 2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 50" {
  let value = vec3(1.0, -2.0, -2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 51" {
  let value = vec3(2.0, -1.0, -1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 52" {
  let value = vec3(3.0, 0.0, 0.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 53" {
  let value = vec3(4.0, 1.0, 1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 54" {
  let value = vec3(5.0, 2.0, 2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 55" {
  let value = vec3(-5.0, 3.0, -2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 56" {
  let value = vec3(-4.0, -3.0, -1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 57" {
  let value = vec3(-3.0, -2.0, 0.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 58" {
  let value = vec3(-2.0, -1.0, 1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 59" {
  let value = vec3(-1.0, 0.0, 2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 60" {
  let value = vec3(0.0, 1.0, -2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 61" {
  let value = vec3(1.0, 2.0, -1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 62" {
  let value = vec3(2.0, 3.0, 0.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 63" {
  let value = vec3(3.0, -3.0, 1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 64" {
  let value = vec3(4.0, -2.0, 2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 65" {
  let value = vec3(5.0, -1.0, -2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 66" {
  let value = vec3(-5.0, 0.0, -1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 67" {
  let value = vec3(-4.0, 1.0, 0.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 68" {
  let value = vec3(-3.0, 2.0, 1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 69" {
  let value = vec3(-2.0, 3.0, 2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 70" {
  let value = vec3(-1.0, -3.0, -2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 71" {
  let value = vec3(0.0, -2.0, -1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 72" {
  let value = vec3(1.0, -1.0, 0.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 73" {
  let value = vec3(2.0, 0.0, 1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 74" {
  let value = vec3(3.0, 1.0, 2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 75" {
  let value = vec3(4.0, 2.0, -2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 76" {
  let value = vec3(5.0, 3.0, -1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 77" {
  let value = vec3(-5.0, -3.0, 0.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 78" {
  let value = vec3(-4.0, -2.0, 1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 79" {
  let value = vec3(-3.0, -1.0, 2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 80" {
  let value = vec3(-2.0, 0.0, -2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 81" {
  let value = vec3(-1.0, 1.0, -1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 82" {
  let value = vec3(0.0, 2.0, 0.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 83" {
  let value = vec3(1.0, 3.0, 1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 84" {
  let value = vec3(2.0, -3.0, 2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 85" {
  let value = vec3(3.0, -2.0, -2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 86" {
  let value = vec3(4.0, -1.0, -1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 87" {
  let value = vec3(5.0, 0.0, 0.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 88" {
  let value = vec3(-5.0, 1.0, 1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 89" {
  let value = vec3(-4.0, 2.0, 2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 90" {
  let value = vec3(-3.0, 3.0, -2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 91" {
  let value = vec3(-2.0, -3.0, -1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 92" {
  let value = vec3(-1.0, -2.0, 0.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 93" {
  let value = vec3(0.0, -1.0, 1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 94" {
  let value = vec3(1.0, 0.0, 2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 95" {
  let value = vec3(2.0, 1.0, -2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 96" {
  let value = vec3(3.0, 2.0, -1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 97" {
  let value = vec3(4.0, 3.0, 0.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 98" {
  let value = vec3(5.0, -3.0, 1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 99" {
  let value = vec3(-5.0, -2.0, 2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 100" {
  let value = vec3(-4.0, -1.0, -2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 101" {
  let value = vec3(-3.0, 0.0, -1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 102" {
  let value = vec3(-2.0, 1.0, 0.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 103" {
  let value = vec3(-1.0, 2.0, 1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 104" {
  let value = vec3(0.0, 3.0, 2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 105" {
  let value = vec3(1.0, -3.0, -2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 106" {
  let value = vec3(2.0, -2.0, -1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 107" {
  let value = vec3(3.0, -1.0, 0.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 108" {
  let value = vec3(4.0, 0.0, 1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 109" {
  let value = vec3(5.0, 1.0, 2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 110" {
  let value = vec3(-5.0, 2.0, -2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 111" {
  let value = vec3(-4.0, 3.0, -1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 112" {
  let value = vec3(-3.0, -3.0, 0.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 113" {
  let value = vec3(-2.0, -2.0, 1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 114" {
  let value = vec3(-1.0, -1.0, 2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 115" {
  let value = vec3(0.0, 0.0, -2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 116" {
  let value = vec3(1.0, 1.0, -1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 117" {
  let value = vec3(2.0, 2.0, 0.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 118" {
  let value = vec3(3.0, 3.0, 1.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "math bounds boundary 119" {
  let value = vec3(4.0, -3.0, 2.0)
  let bounds = bounds_include(bounds_empty(), value)
  inspect(bounds.valid, content="true")
  inspect(bounds_center(bounds) == value, content="true")
}

///|
test "vector operation regression 0" {
  let first = vec3(0.0, -4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 1" {
  let first = vec3(1.0, -3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 2" {
  let first = vec3(2.0, -2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 3" {
  let first = vec3(3.0, -1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 4" {
  let first = vec3(4.0, 0.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 5" {
  let first = vec3(5.0, 1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 6" {
  let first = vec3(6.0, 2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 7" {
  let first = vec3(7.0, 3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 8" {
  let first = vec3(8.0, 4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 9" {
  let first = vec3(9.0, -4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 10" {
  let first = vec3(10.0, -3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 11" {
  let first = vec3(11.0, -2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 12" {
  let first = vec3(12.0, -1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 13" {
  let first = vec3(0.0, 0.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 14" {
  let first = vec3(1.0, 1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 15" {
  let first = vec3(2.0, 2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 16" {
  let first = vec3(3.0, 3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 17" {
  let first = vec3(4.0, 4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 18" {
  let first = vec3(5.0, -4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 19" {
  let first = vec3(6.0, -3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 20" {
  let first = vec3(7.0, -2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 21" {
  let first = vec3(8.0, -1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 22" {
  let first = vec3(9.0, 0.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 23" {
  let first = vec3(10.0, 1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 24" {
  let first = vec3(11.0, 2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 25" {
  let first = vec3(12.0, 3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 26" {
  let first = vec3(0.0, 4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 27" {
  let first = vec3(1.0, -4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 28" {
  let first = vec3(2.0, -3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 29" {
  let first = vec3(3.0, -2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 30" {
  let first = vec3(4.0, -1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 31" {
  let first = vec3(5.0, 0.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 32" {
  let first = vec3(6.0, 1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 33" {
  let first = vec3(7.0, 2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 34" {
  let first = vec3(8.0, 3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 35" {
  let first = vec3(9.0, 4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 36" {
  let first = vec3(10.0, -4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 37" {
  let first = vec3(11.0, -3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 38" {
  let first = vec3(12.0, -2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 39" {
  let first = vec3(0.0, -1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 40" {
  let first = vec3(1.0, 0.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 41" {
  let first = vec3(2.0, 1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 42" {
  let first = vec3(3.0, 2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 43" {
  let first = vec3(4.0, 3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 44" {
  let first = vec3(5.0, 4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 45" {
  let first = vec3(6.0, -4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 46" {
  let first = vec3(7.0, -3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 47" {
  let first = vec3(8.0, -2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 48" {
  let first = vec3(9.0, -1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 49" {
  let first = vec3(10.0, 0.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 50" {
  let first = vec3(11.0, 1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 51" {
  let first = vec3(12.0, 2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 52" {
  let first = vec3(0.0, 3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 53" {
  let first = vec3(1.0, 4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 54" {
  let first = vec3(2.0, -4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 55" {
  let first = vec3(3.0, -3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 56" {
  let first = vec3(4.0, -2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 57" {
  let first = vec3(5.0, -1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 58" {
  let first = vec3(6.0, 0.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 59" {
  let first = vec3(7.0, 1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 60" {
  let first = vec3(8.0, 2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 61" {
  let first = vec3(9.0, 3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 62" {
  let first = vec3(10.0, 4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 63" {
  let first = vec3(11.0, -4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 64" {
  let first = vec3(12.0, -3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 65" {
  let first = vec3(0.0, -2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 66" {
  let first = vec3(1.0, -1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 67" {
  let first = vec3(2.0, 0.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 68" {
  let first = vec3(3.0, 1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 69" {
  let first = vec3(4.0, 2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 70" {
  let first = vec3(5.0, 3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 71" {
  let first = vec3(6.0, 4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 72" {
  let first = vec3(7.0, -4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 73" {
  let first = vec3(8.0, -3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 74" {
  let first = vec3(9.0, -2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 75" {
  let first = vec3(10.0, -1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 76" {
  let first = vec3(11.0, 0.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 77" {
  let first = vec3(12.0, 1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 78" {
  let first = vec3(0.0, 2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 79" {
  let first = vec3(1.0, 3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 80" {
  let first = vec3(2.0, 4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 81" {
  let first = vec3(3.0, -4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 82" {
  let first = vec3(4.0, -3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 83" {
  let first = vec3(5.0, -2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 84" {
  let first = vec3(6.0, -1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 85" {
  let first = vec3(7.0, 0.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 86" {
  let first = vec3(8.0, 1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 87" {
  let first = vec3(9.0, 2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 88" {
  let first = vec3(10.0, 3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 89" {
  let first = vec3(11.0, 4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 90" {
  let first = vec3(12.0, -4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 91" {
  let first = vec3(0.0, -3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 92" {
  let first = vec3(1.0, -2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 93" {
  let first = vec3(2.0, -1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 94" {
  let first = vec3(3.0, 0.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 95" {
  let first = vec3(4.0, 1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 96" {
  let first = vec3(5.0, 2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 97" {
  let first = vec3(6.0, 3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 98" {
  let first = vec3(7.0, 4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 99" {
  let first = vec3(8.0, -4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 100" {
  let first = vec3(9.0, -3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 101" {
  let first = vec3(10.0, -2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 102" {
  let first = vec3(11.0, -1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 103" {
  let first = vec3(12.0, 0.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 104" {
  let first = vec3(0.0, 1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 105" {
  let first = vec3(1.0, 2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 106" {
  let first = vec3(2.0, 3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 107" {
  let first = vec3(3.0, 4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 108" {
  let first = vec3(4.0, -4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 109" {
  let first = vec3(5.0, -3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 110" {
  let first = vec3(6.0, -2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 111" {
  let first = vec3(7.0, -1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 112" {
  let first = vec3(8.0, 0.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 113" {
  let first = vec3(9.0, 1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 114" {
  let first = vec3(10.0, 2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 115" {
  let first = vec3(11.0, 3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 116" {
  let first = vec3(12.0, 4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 117" {
  let first = vec3(0.0, -4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 118" {
  let first = vec3(1.0, -3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 119" {
  let first = vec3(2.0, -2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 120" {
  let first = vec3(3.0, -1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 121" {
  let first = vec3(4.0, 0.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 122" {
  let first = vec3(5.0, 1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 123" {
  let first = vec3(6.0, 2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 124" {
  let first = vec3(7.0, 3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 125" {
  let first = vec3(8.0, 4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 126" {
  let first = vec3(9.0, -4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 127" {
  let first = vec3(10.0, -3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 128" {
  let first = vec3(11.0, -2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 129" {
  let first = vec3(12.0, -1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 130" {
  let first = vec3(0.0, 0.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 131" {
  let first = vec3(1.0, 1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 132" {
  let first = vec3(2.0, 2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 133" {
  let first = vec3(3.0, 3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 134" {
  let first = vec3(4.0, 4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 135" {
  let first = vec3(5.0, -4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 136" {
  let first = vec3(6.0, -3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 137" {
  let first = vec3(7.0, -2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 138" {
  let first = vec3(8.0, -1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 139" {
  let first = vec3(9.0, 0.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 140" {
  let first = vec3(10.0, 1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 141" {
  let first = vec3(11.0, 2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 142" {
  let first = vec3(12.0, 3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 143" {
  let first = vec3(0.0, 4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 144" {
  let first = vec3(1.0, -4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 145" {
  let first = vec3(2.0, -3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 146" {
  let first = vec3(3.0, -2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 147" {
  let first = vec3(4.0, -1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 148" {
  let first = vec3(5.0, 0.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 149" {
  let first = vec3(6.0, 1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 150" {
  let first = vec3(7.0, 2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 151" {
  let first = vec3(8.0, 3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 152" {
  let first = vec3(9.0, 4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 153" {
  let first = vec3(10.0, -4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 154" {
  let first = vec3(11.0, -3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 155" {
  let first = vec3(12.0, -2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 156" {
  let first = vec3(0.0, -1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 157" {
  let first = vec3(1.0, 0.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 158" {
  let first = vec3(2.0, 1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 159" {
  let first = vec3(3.0, 2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 160" {
  let first = vec3(4.0, 3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 161" {
  let first = vec3(5.0, 4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 162" {
  let first = vec3(6.0, -4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 163" {
  let first = vec3(7.0, -3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 164" {
  let first = vec3(8.0, -2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 165" {
  let first = vec3(9.0, -1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 166" {
  let first = vec3(10.0, 0.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 167" {
  let first = vec3(11.0, 1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 168" {
  let first = vec3(12.0, 2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 169" {
  let first = vec3(0.0, 3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 170" {
  let first = vec3(1.0, 4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 171" {
  let first = vec3(2.0, -4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 172" {
  let first = vec3(3.0, -3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 173" {
  let first = vec3(4.0, -2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 174" {
  let first = vec3(5.0, -1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 175" {
  let first = vec3(6.0, 0.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 176" {
  let first = vec3(7.0, 1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 177" {
  let first = vec3(8.0, 2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 178" {
  let first = vec3(9.0, 3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 179" {
  let first = vec3(10.0, 4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 180" {
  let first = vec3(11.0, -4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 181" {
  let first = vec3(12.0, -3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 182" {
  let first = vec3(0.0, -2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 183" {
  let first = vec3(1.0, -1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 184" {
  let first = vec3(2.0, 0.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 185" {
  let first = vec3(3.0, 1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 186" {
  let first = vec3(4.0, 2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 187" {
  let first = vec3(5.0, 3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 188" {
  let first = vec3(6.0, 4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 189" {
  let first = vec3(7.0, -4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 190" {
  let first = vec3(8.0, -3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 191" {
  let first = vec3(9.0, -2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 192" {
  let first = vec3(10.0, -1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 193" {
  let first = vec3(11.0, 0.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 194" {
  let first = vec3(12.0, 1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 195" {
  let first = vec3(0.0, 2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 196" {
  let first = vec3(1.0, 3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 197" {
  let first = vec3(2.0, 4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 198" {
  let first = vec3(3.0, -4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 199" {
  let first = vec3(4.0, -3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 200" {
  let first = vec3(5.0, -2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 201" {
  let first = vec3(6.0, -1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 202" {
  let first = vec3(7.0, 0.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 203" {
  let first = vec3(8.0, 1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 204" {
  let first = vec3(9.0, 2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 205" {
  let first = vec3(10.0, 3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 206" {
  let first = vec3(11.0, 4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 207" {
  let first = vec3(12.0, -4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 208" {
  let first = vec3(0.0, -3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 209" {
  let first = vec3(1.0, -2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 210" {
  let first = vec3(2.0, -1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 211" {
  let first = vec3(3.0, 0.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 212" {
  let first = vec3(4.0, 1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 213" {
  let first = vec3(5.0, 2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 214" {
  let first = vec3(6.0, 3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 215" {
  let first = vec3(7.0, 4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 216" {
  let first = vec3(8.0, -4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 217" {
  let first = vec3(9.0, -3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 218" {
  let first = vec3(10.0, -2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 219" {
  let first = vec3(11.0, -1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 220" {
  let first = vec3(12.0, 0.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 221" {
  let first = vec3(0.0, 1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 222" {
  let first = vec3(1.0, 2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 223" {
  let first = vec3(2.0, 3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 224" {
  let first = vec3(3.0, 4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 225" {
  let first = vec3(4.0, -4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 226" {
  let first = vec3(5.0, -3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 227" {
  let first = vec3(6.0, -2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 228" {
  let first = vec3(7.0, -1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 229" {
  let first = vec3(8.0, 0.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 230" {
  let first = vec3(9.0, 1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 231" {
  let first = vec3(10.0, 2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 232" {
  let first = vec3(11.0, 3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 233" {
  let first = vec3(12.0, 4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 234" {
  let first = vec3(0.0, -4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 235" {
  let first = vec3(1.0, -3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 236" {
  let first = vec3(2.0, -2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 237" {
  let first = vec3(3.0, -1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 238" {
  let first = vec3(4.0, 0.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 239" {
  let first = vec3(5.0, 1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 240" {
  let first = vec3(6.0, 2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 241" {
  let first = vec3(7.0, 3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 242" {
  let first = vec3(8.0, 4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 243" {
  let first = vec3(9.0, -4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 244" {
  let first = vec3(10.0, -3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 245" {
  let first = vec3(11.0, -2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 246" {
  let first = vec3(12.0, -1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 247" {
  let first = vec3(0.0, 0.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 248" {
  let first = vec3(1.0, 1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 249" {
  let first = vec3(2.0, 2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 250" {
  let first = vec3(3.0, 3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 251" {
  let first = vec3(4.0, 4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 252" {
  let first = vec3(5.0, -4.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 253" {
  let first = vec3(6.0, -3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 254" {
  let first = vec3(7.0, -2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 255" {
  let first = vec3(8.0, -1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 256" {
  let first = vec3(9.0, 0.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 257" {
  let first = vec3(10.0, 1.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 258" {
  let first = vec3(11.0, 2.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}

///|
test "vector operation regression 259" {
  let first = vec3(12.0, 3.0, 1.0)
  let second = vec3(1.0, 2.0, 3.0)
  let sum = vec3_add(first, second)
  let delta = vec3_sub(sum, second)
  inspect(delta == first, content="true")
  inspect(
    vec3_dot(first, second) == first.x * 1.0 + first.y * 2.0 + 3.0,
    content="true",
  )
}
