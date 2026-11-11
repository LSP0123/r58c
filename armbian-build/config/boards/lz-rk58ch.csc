# Rockchip RK3588 octa core 4/8GB RAM SoC eMMC USB3 mini-HDMI eDP touch LTE-modem
BOARD_NAME="LX-R58CH V10"
BOARDFAMILY="rockchip-rk3588"
BOARD_MAINTAINER="" # TODO: set your GitHub handle before submitting
INTRODUCED="2026"
BOOTCONFIG="rock-5b-rk3588_defconfig" # interim: no dedicated U-Boot config for this ODM board yet
KERNEL_TARGET="vendor"
KERNEL_TEST_TARGET="vendor"
FULL_DESKTOP="yes"
BOOT_LOGO="desktop"
BOOT_FDT_FILE="rockchip/rk3588-lz-rk58ch.dtb"
BOOT_SCENARIO="spl-blobs"
IMAGE_PARTITION_TABLE="gpt"

# Serial console: UART2 based debug port handled by the fiq-debugger
# (ttyFIQ0 @ 1500000). The rockchip-rk3588 family already defaults SERIALCON
# to ttyFIQ0 on the vendor branch, so no override is needed here.

function post_family_tweaks__lz_rk58ch_naming_audios() {
	display_alert "$BOARD" "Renaming lz-rk58ch audios" "info"

	mkdir -p $SDCARD/etc/udev/rules.d/
	echo 'SUBSYSTEM=="sound", ENV{ID_PATH}=="platform-es8388-sound", ENV{SOUND_DESCRIPTION}="ES8388 Audio"' > $SDCARD/etc/udev/rules.d/90-naming-audios.rules

	return 0
}
