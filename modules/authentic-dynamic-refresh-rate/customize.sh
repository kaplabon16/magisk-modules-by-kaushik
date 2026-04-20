SKIPMOUNT=false
PROPFILE=true
POSTFSDATA=true
LATESTARTSERVICE=true

print_modname() {
  ui_print "*******************************"
  ui_print "  Refresh Rate Module "
  ui_print "   Authentic Profile v2.0      "
  ui_print "*******************************"
}

on_install() {
  ui_print "- Installing module files"
  mkdir -p "$MODPATH/system/bin"
  chmod -R 0755 "$MODPATH"
}

set_permissions() {
  set_perm_recursive $MODPATH 0 0 0755 0644
  set_perm $MODPATH/service.sh 0 0 0755
  set_perm $MODPATH/post-fs-data.sh 0 0 0755
}
