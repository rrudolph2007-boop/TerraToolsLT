terratools_plants : dialog {
  label = "TerraTools LT | Plants";
  : text { key = "context"; width = 82; }
  : row {
    : popup_list { key = "mode"; label = "Browse"; width = 24; }
    : edit_box { key = "query"; label = "Search"; edit_width = 30; }
    : button { key = "search"; label = "Search"; is_default = true; width = 10; }
  }
  : row {
    : popup_list { key = "category"; label = "Category"; width = 24; }
    : text { label = "Search by name, code, family or synonym."; }
  }
  : list_box { key = "plants"; width = 90; height = 15; fixed_width = true; }
  : row {
    : button { key = "previous"; label = "Previous"; width = 12; }
    : text { key = "page"; width = 54; }
    : button { key = "next"; label = "Next"; width = 12; }
  }
  : boxed_column {
    label = "Selected plant";
    : text { key = "name"; width = 88; }
    : text { key = "source"; width = 88; }
    : text { key = "description"; width = 88; }
  }
  : row {
    : button { key = "add"; label = "Add to Project"; }
    : button { key = "variant"; label = "New Variant"; }
    : button { key = "edit"; label = "Edit Project"; }
    : button { key = "remove"; label = "Remove"; }
    : button { key = "favorite"; label = "Favorite"; }
  }
  : row {
    : button { key = "place"; label = "Place"; }
    : button { key = "details"; label = "Full Details"; }
    : button { key = "user"; label = "User Library"; }
    : spacer { width = 24; }
    : button { key = "cancel"; label = "Close"; is_cancel = true; }
  }
  : text { key = "status"; width = 88; }
}

terratools_plant_edit : dialog {
  label = "TerraTools LT | Project Plant";
  : text { key = "plant_name"; width = 65; }
  : edit_box { key = "code"; label = "Project code"; edit_width = 30; }
  : popup_list { key = "category"; label = "Design category"; }
  : edit_box { key = "size"; label = "Size"; edit_width = 40; }
  : edit_box { key = "spacing"; label = "Spacing (include units when needed)"; edit_width = 24; }
  : edit_box { key = "cost"; label = "Unit cost (blank means unknown)"; edit_width = 24; }
  : edit_box { key = "symbol"; label = "Symbol block (blank uses default)"; edit_width = 30; }
  : edit_box { key = "notes"; label = "Project notes"; edit_width = 48; }
  : text { key = "error"; width = 65; }
  ok_cancel;
}
