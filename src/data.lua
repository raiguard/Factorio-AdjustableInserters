-- local data_util = require("__flib__.data-util")

data:extend({
  { type = "custom-input", name = "ains-adjust", key_sequence = "ALT + I" },
  {
    type = "custom-input",
    name = "ains-linked-smart-pipette",
    key_sequence = "",
    linked_game_control = "smart-pipette",
  },
  {
    type = "custom-input",
    name = "ains-linked-build",
    key_sequence = "",
    linked_game_control = "build",
  },
  {
    type = "custom-input",
    name = "ains-linked-mine",
    key_sequence = "",
    linked_game_control = "mine",
  },
  -- {
  --   type = "selection-tool",
  --   name = "tl-tool",
  --   localised_name = { "item-name.tl-tool" },
  --   icons = { { icon = data_util.black_image, icon_size = 1, scale = 64 } },
  --   subgroup = "tool",
  --   order = "c[automated-construction]-x",
  --   selection_mode = { "nothing" },
  --   alt_selection_mode = { "nothing" },
  --   selection_color = { a = 0 },
  --   alt_selection_color = { a = 0 },
  --   selection_cursor_box_type = "not-allowed",
  --   alt_selection_cursor_box_type = "not-allowed",
  --   stack_size = 1,
  --   flags = { "not-stackable", "hidden", "only-in-cursor", "spawnable" },
  --   -- draw_label_for_cursor_render = true,
  --   -- mouse_cursor = "tl-tool-cursor",
  -- },
})

for _, inserter in pairs(data.raw["inserter"]) do
  inserter.allow_custom_vectors = true
end

-- TODO: Remove long inserters
