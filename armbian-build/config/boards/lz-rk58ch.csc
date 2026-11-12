# Rockchip RK3588 octa core 4/8GB RAM SoC eMMC USB3 mini-HDMI eDP touch LTE-modem
BOARD_NAME="LX-R58CH V10"
BOARDFAMILY="rockchip-rk3588"
BOARD_MAINTAINER="" # TODO: set your GitHub handle before submitting
INTRODUCED="2026"
BOOTCONFIG="lz-rk58ch-rk3588_defconfig" # dedicated board U-Boot config (fork: LSP0123/u-boot, branch next-dev-v2024.10-lz-rk58ch)
KERNEL_TARGET="vendor"
KERNEL_TEST_TARGET="vendor"
FULL_DESKTOP="yes"
BOOT_LOGO="desktop"
BOOT_FDT_FILE="rockchip/rk3588-lz-rk58ch.dtb"
BOOT_SCENARIO="spl-blobs"
IMAGE_PARTITION_TABLE="gpt"
# Keep the classic two-partition layout: separate ext4 /boot partition
# (easy to mount/edit boot.scr, armbianEnv.txt, DTBs from any host)
# plus the rootfs partition.
BOOTFS_TYPE="ext4"

# Serial console: UART2 on the M2 pins (GPIO3_B1/B2), fiq-debugger
# (ttyFIQ0 @ 1500000). The rockchip-rk3588 family already defaults SERIALCON
# to ttyFIQ0 on the vendor branch, so no override is needed here.

# Trim the shared vendor kernel config for this board (appended entries
# win in Kconfig): the GPU runs on the mainline Panthor DRM KMD (see the
# board DTS &gpu_panthor), so the whole vendor Mali kbase DDK family is
# unused and only bloats vmlinuz. The append happens before the kernel
# build reads the config file.
function post_family_config__lz_rk58ch_kernel_config_trim() {
	display_alert "$BOARD" "Kernel config trim: vendor Mali kbase off (Panther GPU stack)" "info"
	cat >> "${SRC}/config/kernel/linux-rk35xx-vendor.config" << 'EOF'
# --- lx-rk58ch board trim (appended; later entries win in Kconfig) ---
# GPU runs on the mainline Panthor DRM KMD (&gpu_panthor in the board DTS);
# the vendor Mali kbase DDK (MIDGARD + VALHALL, incl. EXPERT/DEBUG paths)
# is unused dead weight in vmlinuz.
# CONFIG_MALI_MIDGARD is not set
# CONFIG_MALI_VALHALL is not set
EOF
}

# /boot only ever loads rockchip/rk3588-lz-rk58ch.dtb (BOOT_FDT_FILE), but
# the dtb package ships the whole rockchip family (~116 MB), which fills the
# 230 MB ext4 /boot partition to 97%. Keep only this board's dtb so future
# kernel updates still fit. Runs after the kernel deb is installed and
# before update-initramfs.
function pre_update_initramfs__lz_rk58ch_trim_boot_dtb() {
	local root_dir="${MOUNT:-${SDCARD}}"
	local dtb_dir
	display_alert "$BOARD" "Trimming /boot: keep only rk3588-lz-rk58ch.dtb" "info"
	for dtb_dir in "${root_dir}"/boot/dtb-*; do
		[[ -d "${dtb_dir}" ]] || continue
		find "${dtb_dir}" -type f -name '*.dtb' -not -name 'rk3588-lz-rk58ch.dtb' -delete
	done
	return 0
}

function post_family_tweaks__lz_rk58ch_naming_audios() {
	display_alert "$BOARD" "Renaming lz-rk58ch audios" "info"

	mkdir -p $SDCARD/etc/udev/rules.d/
	echo 'SUBSYSTEM=="sound", ENV{ID_PATH}=="platform-es8388-sound", ENV{SOUND_DESCRIPTION}="ES8388 Audio"' > $SDCARD/etc/udev/rules.d/90-naming-audios.rules

	return 0
}

# Belt-and-braces for the vendor U-Boot cmdline fixup: the vendor booti
# merges the kernel-DTB /chosen bootargs into the environment and
# replaces the FIRST root= token (the Android PARTUUID fixup). The board
# kernel DTS already deletes /chosen/bootargs (the primary fix), but if a
# boot path ever merges a DTB that still carries one, this keeps a
# working root: the kernel uses the LAST root= token it sees.
function post_family_tweaks__lz_rk58ch_bootcmd_root_guard() {
	display_alert "$BOARD" "Applying boot.cmd root= guard" "info"

	sed -i 's|setenv bootargs "root=|setenv bootargs "root=/dev/null root=|' $SDCARD/boot/boot.cmd
	mkimage -C none -A arm -T script -d $SDCARD/boot/boot.cmd $SDCARD/boot/boot.scr

	return 0
}

# Touch-to-wake shim. Touch events reach mutter, but a blank (locked)
# panel ignores touch-type input and only unblanks on key-type events.
# lz-wake-helper watches the ILI2511 touchscreen evdev node and, while
# the panel is blank, injects a KEY_ENTER press through uinput on the
# first touch-down so the lock screen lights up. Validated on hardware.
function post_family_tweaks__lz_rk58ch_touch_wake_helper() {
	display_alert "$BOARD" "Installing touch-to-wake helper deb" "info"

	install_deb_chroot "${SRC}/packages/lz-wake-helper_1.0-1_all.deb"

	return 0
}
