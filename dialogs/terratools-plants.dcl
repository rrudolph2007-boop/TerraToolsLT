terratools_plants : dialog {
  label = "TerraTools | Plants";
  : text { key = "context"; width = 90; fixed_width = true; }
  : row {
    : text { key = "workarea"; width = 65; fixed_width = true; }
    : button { key = "area"; label = "Change Work Area..."; width = 23; }
  }
  : boxed_column {
    label = "Available plant data";
    : text { key = "database"; width = 88; fixed_width = true; }
    : text { key = "samples"; width = 88; fixed_width = true; }
  }
  spacer;
  : row {
    : popup_list { key = "mode"; label = "View"; width = 42; }
    : button { key = "browse"; label = "Search Plant Library"; width = 24; }
    : button { key = "projectview"; label = "Project Plants"; width = 20; }
  }
  : row {
    : edit_box { key = "query"; label = "Search plants"; edit_width = 36; }
    : popup_list { key = "category"; label = "Category"; width = 28; }
    : button { key = "search"; label = "Search"; is_default = true; width = 12; }
  }
  : text { key = "scope"; width = 90; fixed_width = true; }
  : list_box { key = "plants"; width = 90; height = 12; fixed_width = true; }
  : row {
    : button { key = "previous"; label = "Previous"; width = 12; }
    : text { key = "page"; width = 60; fixed_width = true; }
    : button { key = "next"; label = "Next"; width = 12; }
  }
  : boxed_column {
    label = "Selected plant";
    : text { key = "name"; width = 88; fixed_width = true; }
    : text { key = "common"; width = 88; fixed_width = true; }
    : text { key = "summary"; width = 88; fixed_width = true; }
    : text { key = "source"; width = 88; fixed_width = true; }
    : text { key = "description"; width = 88; fixed_width = true; }
  }
  : row {
    : button { key = "place"; label = "Place"; width = 18; }
    : button { key = "add"; label = "Add to Project"; width = 18; }
    : button { key = "variant"; label = "New Variant"; width = 18; }
    : spacer { width = 18; }
    : button { key = "details"; label = "Details..."; width = 18; }
  }
  : row {
    : button { key = "edit"; label = "Edit..."; width = 18; }
    : button { key = "favorite"; label = "Favorite"; width = 18; }
    : button { key = "remove"; label = "Remove..."; width = 18; }
    : button { key = "tools"; label = "Tools..."; width = 18; }
    : button { key = "cancel"; label = "Close"; is_cancel = true; width = 18; }
  }
  : text { key = "status"; width = 90; fixed_width = true; }
}

terratools_plant_edit : dialog {
  label = "TerraTools | Project Plant";
  : text { key = "plant_name"; width = 72; fixed_width = true; }
  : text { label = "Edits belong to this project. The original library plant is unchanged."; }
  : boxed_column {
    label = "Project identity";
    : edit_box { key = "code"; label = "Unique project code"; edit_width = 32; }
    : popup_list { key = "category"; label = "Design category"; width = 48; }
  }
  : boxed_column {
    label = "Design and specification";
    : edit_box { key = "size"; label = "Size"; edit_width = 40; }
    : edit_box { key = "spacing"; label = "Spacing (include units)"; edit_width = 32; }
    : edit_box { key = "cost"; label = "Unit cost (blank if unknown)"; edit_width = 32; }
    : edit_box { key = "symbol"; label = "Symbol block (blank for default)"; edit_width = 32; }
    : edit_box { key = "notes"; label = "Project notes"; edit_width = 48; }
  }
  : text { key = "error"; width = 78; fixed_width = true; }
  : row { spacer; : button { key = "accept"; label = "Save"; is_default = true; width = 14; } : button { key = "cancel"; label = "Cancel"; is_cancel = true; width = 14; } }
}
