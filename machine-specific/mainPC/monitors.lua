local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))

-- Main monitor: LG UltraGear, horizontal
hl.monitor({
  output = "DP-1",
  mode = "2560x1440@164.96",
  position = "0x240",
  scale = 1
})

-- Secondary monitor: AOC 24G4, vertical on the left
hl.monitor({
  output = "DP-2",
  mode = "1920x1080@60",
  position = "-1080x0",
  scale = 1,
  transform = 3
})
