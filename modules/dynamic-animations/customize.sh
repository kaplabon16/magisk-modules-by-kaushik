SKIPMOUNT=false
PROPFILE=true
POSTFSDATA=false
LATESTARTSERVICE=true
REPLACE=""

print_modname() {
  ui_print "*******************************"
  ui_print "  Dynamic Animations (Only) "
  ui_print "*******************************"
}

on_install() {
  ui_print "- Installing module files"
  unzip -o "$ZIPFILE" 'module.prop' 'service.sh' 'system.prop' 'uninstall.sh' 'README.txt' -d $MODPATH >&2
}

set_permissions() {
  set_perm_recursive $MODPATH 0 0 0755 0644
  set_perm $MODPATH/service.sh 0 0 0755
  set_perm $MODPATH/uninstall.sh 0 0 0755
}