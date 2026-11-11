# PR: armbian/linux-rockchip — `rk-6.1-rkr7.2`

## Title

```
arm64: dts: rockchip: add LX-R58CH V10 support
```

## Body

> 使用方式：fork `armbian/linux-rockchip`，基于 `rk-6.1-rkr7.2` 建分支，
> `git am` 补丁并改成你自己的作者信息（见 README 第 3 节），push 后开 PR，
> 把下面内容作为 PR 描述。

---

Adds device tree support for the **LX-R58CH V10** board
(`compatible = "rockchip,lz-rk3588-r58ch"`), an RK3588 based terminal board.

### Hardware summary

| Block | Details |
|---|---|
| SoC | Rockchip RK3588 |
| Power | RK806 PMIC (SPI2, single) + RK8602 (big0) + RK8603 (big1) + RK8602 (NPU) |
| Display | eDP0 panel 1920x1080@60 on VOP VP2 + on-board mini-HDMI on HDMI1/VP1 (both enabled) |
| Audio | ES8388 codec on I2S0 (multi-codecs card) |
| Wireless | AMPAK AP6256 — WiFi on SDIO, Bluetooth on UART6 |
| Storage | On-board eMMC (HS400) |
| Peripherals | ILI2511 touch (I2C5), HYM8563 RTC, AK09918 compass + ICM20948 IMU (I2C7), 4G modem (4g-modem-platdata), PWM fan (PWM10), PWM backlight (PWM11), 2x USB2 host + USB3.0 OTG (host mode) |
| Console | UART2 via fiq-debugger, ttyFIQ0 @ 1500000 |

### Notes

- The DTS is ported from the board's production 5.10 BSP DTB (decompiled) and
  adapted to the 6.1 vendor bindings:
  - GPU compatible updated to `arm,mali-valhall`;
  - HDMI-mode PHY wrapper nodes (`hdmiphy@fedx0000`) dropped — HDMI1 now uses
    the unified `hdptxphy1`;
  - RK806 DVS pin sub-nodes dropped (6.1 keeps only `pmic_pins`);
  - `display-subsystem` takes the HDMI PLL clocks (`hdmi0/1_phy_pll`);
  - eDP endpoint graph gets the board-side back-reference.
- All hardware codec blocks are enabled (VDPU/VEPU, RKVDEC x2, RKVENC x2,
  JPEGD + JPEGE x4, IEP, RGA2/RGA3, AV1D, AVSD) plus GPU/NPU.
- Ethernet controllers (GMAC0/1) stay disabled exactly as shipped by the
  board vendor; the full configuration is kept for future enablement.

### Testing

- [x] DTB builds cleanly against `rk-6.1-rkr7.2`
      (CI workflow: `dtb-check.yml` applies this patch with `git am` and
      cross-compiles `rk3588-lz-rk58ch.dtb`)
- [ ] Boots on real hardware — **TODO**: attach serial boot log
- [ ] eDP panel + HDMI output verified
- [ ] eMMC / WiFi / BT / audio / USB verified on target

> AI生成
