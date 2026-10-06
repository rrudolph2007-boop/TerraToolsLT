terratools_main : dialog {
  label = "TerraTools LT";
  : boxed_column {
    label = "Project";
    : row {
      : button { key = "project"; label = "Project..."; width = 16; }
      : button { key = "settings"; label = "Settings..."; width = 16; }
      : button { key = "workareas"; label = "Work Areas..."; width = 16; }
    }
  }
  : boxed_column {
    label = "Design Tools";
    : row {
      : button { key = "planting"; label = "Planting..."; width = 16; }
      : button { key = "site"; label = "Site..."; width = 16; }
      : button { key = "details"; label = "Details..."; width = 16; }
    }
    : row {
      : button { key = "lighting"; label = "Lighting..."; width = 16; }
      : button { key = "irrigation"; label = "Irrigation..."; width = 16; }
      : button { key = "schedules"; label = "Schedules..."; width = 16; }
    }
  }
  : boxed_column {
    label = "Standards and Data";
    : row {
      : button { key = "standards"; label = "Standards..."; width = 16; }
      : button { key = "data"; label = "Plant Data..."; width = 16; }
      : button { key = "help"; label = "Help..."; width = 16; }
    }
  }
  : boxed_column {
    label = "Support";
    : row {
      : button { key = "diagnostics"; label = "Diagnostics..."; width = 16; }
      : button { key = "about"; label = "About"; width = 16; }
      : button { key = "close"; label = "Close"; is_cancel = true; width = 16; }
    }
  }
}
