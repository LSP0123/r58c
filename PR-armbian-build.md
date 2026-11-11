# PR: armbian/build — main

## Title

```
Add new board support: LX-R58CH V10 (`lz-rk58ch`)
```

## Body

> 使用方式：fork `armbian/build`，把 `armbian-build/config/boards/lz-rk58ch.csc`
> 加入你的分支（填好 `BOARD_MAINTAINER`），push 后开 PR，把下面内容作为 PR 描述。

---

### Description

Adds support for the **LX-R58CH V10**, an RK3588 based terminal board:

| Item | Value |
|---|---|
| Board name | `lz-rk58ch` |
| SoC | Rockchip RK3588 |
| RAM | 4/8 GB |
| Storage | On-board eMMC |
| Display | eDP0 panel 1920x1080 + mini-HDMI (both outputs enabled) |
| Audio | ES8388 codec |
| Wireless | AP6256 WiFi + Bluetooth, 4G modem |
| USB | 2x USB2 host, 1x USB3.0 OTG (host mode) |
| Console | UART2, fiq-debugger, 1500000 baud (family default `ttyFIQ0`) |
| Kernel | vendor (6.1, `rockchip-rk3588` family) |

### Implementation notes

- **Kernel DTS**: submitted separately to `armbian/linux-rockchip`
  (branch `rk-6.1-rkr7.2`) — PR: *<在此粘贴 linux-rockchip PR 链接>*.
  Until it is merged, the board builds require that DTS commit.
- **U-Boot**: no dedicated vendor defconfig exists for this ODM board yet;
  `rock-5b-rk3588_defconfig` (Radxa U-Boot) is used as an interim. The board
  also boots fine with the vendor U-Boot already shipped in its SPI flash.
- DDR init uses the default RK3588 blob from rkbin (`BOOT_SCENARIO="spl-blobs"`).

### Testing checklist (Armbian board support template)

- [x] Board file follows current `.csc` conventions (`BOARDFAMILY="rockchip-rk3588"`)
- [x] `BOOT_FDT_FILE="rockchip/rk3588-lz-rk58ch.dtb"` matches the kernel DTS
- [ ] Image builds: `./compile.sh create BOARD=lz-rk58ch BRANCH=vendor ...`
      (CI workflow: `armbian-image.yml`)
- [ ] Boots from eMMC; serial log attached
- [ ] Display (eDP + HDMI), USB, WiFi/BT, audio, eMMC R/W verified on hardware
- [ ] `BOARD_MAINTAINER` filled (GitHub handle) — **maintainer signup**

### Files

- `config/boards/lz-rk58ch.csc`

### Related

- Kernel DTS PR: armbian/linux-rockchip#*<编号>*

> AI生成
