terratools_records : dialog {
  key = "title"; label = "TerraTools | Project Records";
  : text { key = "context"; width = 88; fixed_width = true; }
  : row {
    : text { key = "workarea"; width = 62; fixed_width = true; }
    : button { key = "area"; label = "Change Work Area..."; width = 24; }
  }
  : text { key = "guidance"; width = 88; fixed_width = true; }
  spacer;
  : row {
    : edit_box { key = "query"; label = "Search project records"; edit_width = 48; }
    : button { key = "search"; label = "Search"; is_default = true; width = 14; }
    : button { key = "clear"; label = "Clear"; width = 14; }
  }
  : text { key = "scope"; width = 88; fixed_width = true; }
  : list_box { key = "records"; width = 88; height = 14; fixed_width = true; }
  : boxed_column {
    label = "Selected record";
    : text { key = "detail"; width = 86; fixed_width = true; }
    : text { key = "recordhint"; width = 86; fixed_width = true; }
  }
  : row {
    : button { key = "add"; label = "Add..."; width = 17; }
    : button { key = "place"; label = "Place"; width = 17; }
    : button { key = "edit"; label = "Edit..."; width = 17; }
    : button { key = "highlight"; label = "Highlight"; width = 17; }
    : button { key = "details"; label = "Details..."; width = 17; }
  }
  : row {
    : button { key = "library"; label = "Library..."; width = 17; }
    : button { key = "more"; label = "Tools..."; width = 17; }
    : button { key = "remove"; label = "Remove..."; width = 17; }
    : spacer { width = 17; }
    : button { key = "cancel"; label = "Close"; is_cancel = true; width = 17; }
  }
  : text { key = "status"; width = 88; fixed_width = true; }
}

terratools_record_edit : dialog {
  key = "title"; label = "TerraTools | Edit Record";
  : row { : text { key = "l0"; width = 28; } : edit_box { key = "f0"; edit_width = 45; } }
  : row { : text { key = "l1"; width = 28; } : edit_box { key = "f1"; edit_width = 45; } }
  : row { : text { key = "l2"; width = 28; } : edit_box { key = "f2"; edit_width = 45; } }
  : row { : text { key = "l3"; width = 28; } : edit_box { key = "f3"; edit_width = 45; } }
  : row { : text { key = "l4"; width = 28; } : edit_box { key = "f4"; edit_width = 45; } }
  : row { : text { key = "l5"; width = 28; } : edit_box { key = "f5"; edit_width = 45; } }
  : row { : text { key = "l6"; width = 28; } : edit_box { key = "f6"; edit_width = 45; } }
  : row { : text { key = "l7"; width = 28; } : edit_box { key = "f7"; edit_width = 45; } }
  : text { key = "error"; width = 78; fixed_width = true; }
  : row { spacer; : button { key = "accept"; label = "Save"; is_default = true; width = 14; } : button { key = "cancel"; label = "Cancel"; is_cancel = true; width = 14; } }
}

terratools_record_details : dialog {
  label = "TerraTools | Technical Details";
  : text { label = "Advanced record information. Close returns without changes."; }
  : list_box { key = "details"; width = 100; height = 24; }
  : button { key = "cancel"; label = "Close"; is_default = true; is_cancel = true; }
}
