terratools_records : dialog {
  key = "title"; label = "TerraTools LT | Project Manager";
  : text { key = "context"; width = 82; }
  : row {
    : edit_box { key = "query"; label = "Search"; edit_width = 50; }
    : button { key = "search"; label = "Search"; is_default = true; }
  }
  : list_box { key = "records"; width = 88; height = 14; fixed_width = true; }
  : text { key = "detail"; width = 88; }
  : row {
    : button { key = "add"; label = "Add"; }
    : button { key = "edit"; label = "Edit"; }
    : button { key = "remove"; label = "Remove"; }
    : button { key = "place"; label = "Place / Assign"; }
    : button { key = "highlight"; label = "Highlight / Count"; }
  }
  : row {
    : button { key = "library"; label = "Library"; }
    : button { key = "more"; label = "More Actions"; }
    : spacer { width = 30; }
    : button { key = "cancel"; label = "Close"; is_cancel = true; }
  }
  : text { key = "status"; width = 88; }
}

terratools_record_edit : dialog {
  key = "title"; label = "TerraTools LT | Edit Record";
  : row { : text { key = "l0"; width = 28; } : edit_box { key = "f0"; edit_width = 45; } }
  : row { : text { key = "l1"; width = 28; } : edit_box { key = "f1"; edit_width = 45; } }
  : row { : text { key = "l2"; width = 28; } : edit_box { key = "f2"; edit_width = 45; } }
  : row { : text { key = "l3"; width = 28; } : edit_box { key = "f3"; edit_width = 45; } }
  : row { : text { key = "l4"; width = 28; } : edit_box { key = "f4"; edit_width = 45; } }
  : row { : text { key = "l5"; width = 28; } : edit_box { key = "f5"; edit_width = 45; } }
  : row { : text { key = "l6"; width = 28; } : edit_box { key = "f6"; edit_width = 45; } }
  : row { : text { key = "l7"; width = 28; } : edit_box { key = "f7"; edit_width = 45; } }
  : text { key = "error"; width = 78; }
  ok_cancel;
}

terratools_record_details : dialog {
  label = "TerraTools LT | Record Details";
  : list_box { key = "details"; width = 100; height = 24; }
  : button { key = "cancel"; label = "Close"; is_default = true; is_cancel = true; }
}
