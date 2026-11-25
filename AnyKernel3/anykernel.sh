### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=Flow X v1.0.0 (Experimental) by bagaasadit
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=miatoll
device.name2=curtana
device.name3=joyeuse
device.name4=excalibur
device.name5=gram
supported.versions=11-17
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties


# boot shell variables
BLOCK=/dev/block/sde51
IS_SLOT_DEVICE=0
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh;

ui_print " ";
ui_print "  Branch     : Flow X (Experimental)";
ui_print "  Version    : v1.0.0";
ui_print "  Device     : miatoll (A11 - A17)";
ui_print "  Kernel     : Linux 4.14.357 (5.15.207)";
ui_print "  Root       : BakaSU + SUSFS v2.4";
ui_print "  Maintainer : bagaasadit";
ui_print "  ─────────────────────────────────";
ui_print " ";

if mountpoint -q /data; then
	dd if=/dev/block/by-name/boot of=/sdcard/backup_boot_pre_flowx.img >/dev/null 2>&1;
	dd if=/dev/block/by-name/dtbo of=/sdcard/backup_dtbo_pre_flowx.img >/dev/null 2>&1;
	if [ $? != 0 ]; then
		ui_print "  [!] Pre-FlowX backup failed; proceeding...";
	else
		ui_print "  • Backing up pre-FlowX boot/dtbo OK";
	fi
fi

## AnyKernel install

split_boot || abort "split_boot failed";
ui_print "  • Unpacking boot image ......... OK";

flash_boot || abort "flash_boot failed";
ui_print "  • Flashing kernel & dtb ........ OK";

flash_generic dtbo || abort "flash_dtbo failed";
ui_print "  • Flashing dtbo ................ OK";

ui_print " ";
ui_print "  ─────────────────────────────────";
ui_print "  Done. Backup saved in /sdcard.";
ui_print " ";

## end install

