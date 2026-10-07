terratools_main : dialog {
  label = "TerraTools | Home";
  : text { key = "context"; width = 76; fixed_width = true; }
  : text { key = "units"; width = 76; fixed_width = true; }
  : text { key = "workarea"; width = 76; fixed_width = true; }
  : text { key = "database"; width = 76; fixed_width = true; }
  spacer;
  : boxed_column {
    label = "Project and planting";
    : row {
      : button { key = "project"; label = "Project..."; width = 24; is_default = true; }
      : button { key = "planting"; label = "Plants..."; width = 24; }
      : button { key = "workareas"; label = "Work Areas..."; width = 24; }
    }
  }
  : boxed_column {
    label = "Design";
    : row {
      : button { key = "site"; label = "Site / Reference..."; width = 24; }
      : button { key = "details"; label = "Details..."; width = 24; }
      : button { key = "lighting"; label = "Lighting..."; width = 24; }
    }
    : row {
      : button { key = "irrigation"; label = "Irrigation..."; width = 24; }
      : button { key = "schedules"; label = "Schedules / Reports..."; width = 24; }
      : button { key = "standards"; label = "Office Standards..."; width = 24; }
    }
  }
  : boxed_column {
    label = "Review and tools";
    : row {
      : button { key = "diagnostics"; label = "Verify / Diagnostics..."; width = 24; }
      : button { key = "recovery"; label = "Recovery..."; width = 24; }
      : button { key = "settings"; label = "Preferences..."; width = 24; }
    }
    : row {
      : button { key = "data"; label = "Plant Libraries..."; width = 24; }
      : button { key = "package"; label = "Project Package..."; width = 24; }
      : button { key = "help"; label = "Help..."; width = 24; }
    }
  }
  : text { key = "status"; width = 76; fixed_width = true; }
  : row { : button { key = "about"; label = "About"; width = 16; } spacer; : button { key = "close"; label = "Close"; is_cancel = true; width = 16; } }
}

terratools_tools : dialog {
  key = "title"; label = "TerraTools | Tools";
  : text { key = "context"; width = 78; fixed_width = true; }
  : text { key = "guide"; width = 78; fixed_width = true; }
  : boxed_column {
    label = "Choose a task";
    : list_box { key = "tasks"; width = 78; height = 14; fixed_width = true; }
  }
  : text { key = "description"; width = 78; fixed_width = true; }
  : text { key = "status"; width = 78; fixed_width = true; }
  : row { spacer; : button { key = "accept"; label = "Continue"; is_default = true; width = 16; } : button { key = "cancel"; label = "Back"; is_cancel = true; width = 16; } }
}
