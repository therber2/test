local function cut_off_bottom(picture, bottom)
  picture.scale = picture.scale or 1
  local top = -picture.height / 2
  if top < bottom then
    picture.height = bottom - top
    local shift = util.by_pixel(0, (top + picture.height/2) * picture.scale)
    if not picture.shift then
      picture.shift = shift
    else
      picture.shift[1] = picture.shift[1] + shift[1]
      picture.shift[2] = picture.shift[2] + shift[2]
    end
  else
    picture.filename = "__core__/graphics/empty.png"
    picture.width = 1
    picture.height = 1
  end
end

local function copy_and_shift(source, shift)
  local picture = table.deepcopy(source)
  if not picture.shift then picture.shift = {0, 0} end
  if not picture.hr_version.shift then picture.hr_version.shift = {0, 0} end
  picture.shift[1] = picture.shift[1] + shift[1]
  picture.shift[2] = picture.shift[2] + shift[2]
  picture.hr_version.shift[1] = picture.hr_version.shift[1] + shift[1]
  picture.hr_version.shift[2] = picture.hr_version.shift[2] + shift[2]
  return picture
end

local function load_vertical_picture(picture, layer, num)
    picture[layer] = {
      filename = "__rail-bridge__/graphics/vertical_"..layer..".png",
      x = (num - 1) * 128,
      width = 128,
      height = 64,
      variation_count = 1,
      priority = "extra-high",
      flags = {"low-object"},
      hr_version = {
        filename = "__rail-bridge__/graphics/hr_vertical_"..layer..".png",
        x = (num - 1) * 256,
        width = 256,
        height = 128,
        variation_count = 1,
        priority = "extra-high",
        flags = {"low-object"},
        scale = 0.5
      }
    }
end

local function trim_4_to_2_tile_width(picture)
  picture.width = 64
  picture.x = picture.x + 32
  picture.hr_version.width = 128
  picture.hr_version.x = picture.hr_version.x + 64
  return picture
end

-- Horizontal rail for straight bridge
local rail_east = table.deepcopy(data.raw["straight-rail"]["straight-rail"])
rail_east.name = "rail-bridge-east"
rail_east.collision_box = {{-0.4, -0.99}, {0.4, 0.1}}
rail_east.collision_mask = {}
rail_east.minable = nil
rail_east.flags = {"building-direction-8-way", "not-deconstructable", "not-upgradable"}
rail_east.selectable_in_game = false
data:extend{rail_east}

-- Vertical rail for straight bridge
local rail_north = table.deepcopy(rail_east)
rail_north.name = "rail-bridge-north"
rail_north.collision_box = {{-0.4, -0.1}, {0.4, 0.99}}
for _, layer in pairs{"stone_path_background", "stone_path", "ties", "backplates", "metals"} do
  cut_off_bottom(rail_north.pictures.straight_rail_vertical[layer], -14)
  cut_off_bottom(rail_north.pictures.straight_rail_vertical[layer].hr_version, -28)
end
data:extend{rail_north}

-- Rail for diagonal left bridge
local rail_1 = table.deepcopy(rail_east);
rail_1.name = "rail-bridge-rail-1"
rail_1.localised_name = {"entity-name.rail-bridge-diagonal-left"}
rail_1.collision_box = {{-0.1, -0.99}, {0.1, 0.1}}
for _, layer in pairs{"stone_path_background", "stone_path", "ties", "backplates", "metals"} do
  cut_off_bottom(rail_1.pictures.straight_rail_diagonal_right_bottom[layer], 2)
  cut_off_bottom(rail_1.pictures.straight_rail_diagonal_right_bottom[layer].hr_version, 4)
  load_vertical_picture(rail_1.pictures.straight_rail_vertical, layer, 1)
end
data:extend{rail_1}

-- Rail for diagonal left bridge
local rail_2 = table.deepcopy(rail_east);
rail_2.name = "rail-bridge-rail-2"
rail_2.localised_name = {"entity-name.rail-bridge-diagonal-left"}
rail_2.collision_box = {{-0.1, -0.1}, {0.1, 0.99}}
for _, layer in pairs{"stone_path_background", "stone_path", "ties", "backplates", "metals"} do
  cut_off_bottom(rail_2.pictures.straight_rail_diagonal_left_top[layer], -30)
  cut_off_bottom(rail_2.pictures.straight_rail_diagonal_left_top[layer].hr_version, -60)
  load_vertical_picture(rail_2.pictures.straight_rail_vertical, layer, 2)
end
data:extend{rail_2}

-- Rail for diagonal right bridge
local rail_3 = table.deepcopy(rail_east)
rail_3.name = "rail-bridge-rail-3"
rail_3.localised_name = {"entity-name.rail-bridge-diagonal-right"}
rail_3.collision_box = {{-0.1, -0.99}, {0.1, 0.1}}
for _, layer in pairs{"stone_path_background", "stone_path", "ties", "backplates", "metals"} do
  cut_off_bottom(rail_3.pictures.straight_rail_diagonal_left_bottom[layer], 2)
  cut_off_bottom(rail_3.pictures.straight_rail_diagonal_left_bottom[layer].hr_version, 4)
  load_vertical_picture(rail_3.pictures.straight_rail_vertical, layer, 3)
end
data:extend{rail_3}

-- Rail for diagonal right bridge
local rail_4 = table.deepcopy(rail_east)
rail_4.name = "rail-bridge-rail-4"
rail_4.localised_name = {"entity-name.rail-bridge-diagonal-right"}
rail_4.collision_box = {{-0.1, -0.1}, {0.1, 0.99}}
for _, layer in pairs{"stone_path_background", "stone_path", "ties", "backplates", "metals"} do
  cut_off_bottom(rail_4.pictures.straight_rail_diagonal_right_top[layer], -30)
  cut_off_bottom(rail_4.pictures.straight_rail_diagonal_right_top[layer].hr_version, -60)
  load_vertical_picture(rail_4.pictures.straight_rail_vertical, layer, 4)
end
data:extend{rail_4}

-- Straight bridge entity
local bridge = {
  type = "simple-entity-with-force",
  name = "rail-bridge",
  icon = "__rail-bridge__/graphics/icon.png",
  icon_size = 32,
  flags = {"player-creation"},
  collision_mask = {"item-layer", "object-layer", "water-tile"},
  collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
  selection_box = {{-1, -1}, {1, 1}},
  minable = {mining_time = 0.5, result = "rail-bridge"},
  max_health = 300,
  resistances = table.deepcopy(rail_east.resistances),
  corpse = "straight-rail-remnants",
  map_color = table.deepcopy(data.raw["utility-constants"]["default"].chart.rail_color),
  render_layer = "building-smoke",  -- 1 layer below rails
  picture = {layers = {}}
}
-- Add crossing rail graphics
for _, layer in pairs{"stone_path_background", "stone_path", "ties", "backplates", "metals"} do
  table.insert(bridge.picture.layers, table.deepcopy(rail_north.pictures.straight_rail_vertical[layer]))
  table.insert(bridge.picture.layers, table.deepcopy(rail_east.pictures.straight_rail_horizontal[layer]))
end
-- Add bridge graphics
table.insert(bridge.picture.layers, table.deepcopy(data.raw.sprite["rail-bridge"]))
data:extend{bridge}

-- Fake crafting category so we can use assembling-machine as a base entity
data:extend{
  {
    type = "recipe-category",
    name = "rail-bridge-category",
  }
}

-- Diagonal left bridge entity
local diag_left = {
  type = "assembling-machine",
  name = "rail-bridge-diagonal-left",
  icon = "__rail-bridge__/graphics/icon-left.png",
  icon_size = 32,
  subgroup = "transport",
  order = "a[train-system]-a[rail]-b[bridge]",
  flags = {"placeable-neutral", "player-creation", "hide-alt-info"},
  collision_mask = {"item-layer", "object-layer", "water-tile"},
  collision_box = {{-0.55, -1.55}, {0.55, 1.55}},
  selection_box = {{-1, -2}, {1, 2}},
  minable = {mining_time = 0.5, result = "rail-bridge-diagonal-left"},
  max_health = 300,
  resistances = table.deepcopy(rail_east.resistances),
  corpse = "straight-rail-remnants",
  map_color = table.deepcopy(data.raw["utility-constants"]["default"].chart.rail_color),
  crafting_categories = {"rail-bridge-category"},
  crafting_speed = 1,
  energy_usage = "0.0000001W",
  energy_source = {type = "void"},
  off_when_no_fluid_recipe = false,
  fluid_boxes = {{
    base_area = 10,
    base_level = -1,
    production_type = "output",
    pipe_connections = {{type = "output", position = {0, -2}}},
    pipe_picture = {},
    render_layer = "building-smoke",  -- 1 layer below rails
  }},
}
local pipe_picture = diag_left.fluid_boxes[1].pipe_picture
for _, direction in pairs{"north", "east", "south", "west"} do
  pipe_picture[direction] = {layers = {}}
end
-- Add crossing rail graphics
for _, layer in pairs{"stone_path_background", "stone_path", "ties", "backplates", "metals"} do
  for _, direction in pairs{"north", "south"} do
    local offset = -2
    if direction == "north" then offset = 2 end
    table.insert(pipe_picture[direction].layers, trim_4_to_2_tile_width(copy_and_shift(rail_1.pictures.straight_rail_vertical[layer], {0, -1 + offset})))
    table.insert(pipe_picture[direction].layers, trim_4_to_2_tile_width(copy_and_shift(rail_2.pictures.straight_rail_vertical[layer], {0, 1 + offset})))
    table.insert(pipe_picture[direction].layers, copy_and_shift(rail_1.pictures.straight_rail_diagonal_left_bottom[layer], {0, -1 + offset}))
    table.insert(pipe_picture[direction].layers, copy_and_shift(rail_2.pictures.straight_rail_diagonal_right_top[layer], {0, 1 + offset}))
  end
  for _, direction in pairs{"east", "west"} do
    local offset = 2
    if direction == "east" then offset = -2 end
    table.insert(pipe_picture[direction].layers, copy_and_shift(rail_1.pictures.straight_rail_diagonal_right_bottom[layer], {-1 + offset, 0}))
    table.insert(pipe_picture[direction].layers, copy_and_shift(rail_2.pictures.straight_rail_diagonal_left_top[layer], {1 + offset, 0}))
    table.insert(pipe_picture[direction].layers, copy_and_shift(rail_1.pictures.straight_rail_horizontal[layer], {-1 + offset, 0}))
    table.insert(pipe_picture[direction].layers, copy_and_shift(rail_2.pictures.straight_rail_horizontal[layer], {1 + offset, 0}))
  end
end
-- Add bridge graphics
table.insert(pipe_picture["north"].layers, copy_and_shift(data.raw.sprite["rail-bridge-ne"], {0, 2}))
table.insert(pipe_picture["south"].layers, copy_and_shift(data.raw.sprite["rail-bridge-ne"], {0, -2}))
table.insert(pipe_picture["east"].layers, copy_and_shift(data.raw.sprite["rail-bridge-sw"], {-2, 0}))
table.insert(pipe_picture["west"].layers, copy_and_shift(data.raw.sprite["rail-bridge-sw"], {2, 0}))
data:extend{diag_left}

-- Diagonal right bridge entity
local diag_right = table.deepcopy(diag_left)
diag_right.name = "rail-bridge-diagonal-right"
diag_right.icon = "__rail-bridge__/graphics/icon-right.png"
diag_right.minable.result = "rail-bridge-diagonal-right"
pipe_picture = diag_right.fluid_boxes[1].pipe_picture
for _, direction in pairs{"north", "east", "south", "west"} do
  pipe_picture[direction] = {layers = {}}
end
-- Add crossing rail graphics
for _, layer in pairs{"stone_path_background", "stone_path", "ties", "backplates", "metals"} do
  for _, direction in pairs{"north", "south"} do
    local offset = -2
    if direction == "north" then offset = 2 end
    table.insert(pipe_picture[direction].layers, trim_4_to_2_tile_width(copy_and_shift(rail_3.pictures.straight_rail_vertical[layer], {0, -1 + offset})))
    table.insert(pipe_picture[direction].layers, trim_4_to_2_tile_width(copy_and_shift(rail_4.pictures.straight_rail_vertical[layer], {0, 1 + offset})))
    table.insert(pipe_picture[direction].layers, copy_and_shift(rail_3.pictures.straight_rail_diagonal_right_bottom[layer], {0, -1 + offset}))
    table.insert(pipe_picture[direction].layers, copy_and_shift(rail_4.pictures.straight_rail_diagonal_left_top[layer], {0, 1 + offset}))
  end
  for _, direction in pairs{"east", "west"} do
    local offset = 2
    if direction == "east" then offset = -2 end
    table.insert(pipe_picture[direction].layers, copy_and_shift(rail_4.pictures.straight_rail_diagonal_right_top[layer], {-1 + offset, 0}))
    table.insert(pipe_picture[direction].layers, copy_and_shift(rail_3.pictures.straight_rail_diagonal_left_bottom[layer], {1 + offset, 0}))
    table.insert(pipe_picture[direction].layers, copy_and_shift(rail_3.pictures.straight_rail_horizontal[layer], {-1 + offset, 0}))
    table.insert(pipe_picture[direction].layers, copy_and_shift(rail_4.pictures.straight_rail_horizontal[layer], {1 + offset, 0}))
  end
end
-- Add bridge graphics
table.insert(pipe_picture["north"].layers, copy_and_shift(data.raw.sprite["rail-bridge-nw"], {0, 2}))
table.insert(pipe_picture["south"].layers, copy_and_shift(data.raw.sprite["rail-bridge-nw"], {0, -2}))
table.insert(pipe_picture["east"].layers, copy_and_shift(data.raw.sprite["rail-bridge-se"], {-2, 0}))
table.insert(pipe_picture["west"].layers, copy_and_shift(data.raw.sprite["rail-bridge-se"], {2, 0}))
data:extend{diag_right};
