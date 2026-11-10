# Armbian 支持提交包 — LX-R58CH V10（RK3588）

本目录是为 **LX-R58CH V10** 板卡准备的一整套 Armbian 上游支持提交材料。
依据对 `armbian/build`（main 分支）与 `armbian/linux-rockchip`（rk-6.1-rkr7.2 分支）
2026-11 当前结构的实际调研，按官方现行工作流组织。

## 一、目录结构

```
armbian/
├── README.md                                  ← 本说明
├── PR-linux-rockchip.md                       ← 内核仓库 PR 描述（英文）
├── PR-armbian-build.md                        ← build 仓库 PR 描述（英文）
├── .github/workflows/
│   ├── dtb-check.yml                          ← CI：补丁 git am + 交叉编译 DTB（push 自动跑）
│   └── armbian-image.yml                      ← CI：手动触发构建完整 Armbian 镜像（可选）
├── armbian-build/
│   └── config/boards/lz-rk58ch.csc           ← 提交物①：板卡配置（armbian/build）
└── linux-rockchip/
    └── 0001-arm64-dts-rockchip-add-LX-R58CH-V10-support.patch
                                               ← 提交物②：内核 DTS 补丁（armbian/linux-rockchip）
```

> **Armbian 现行规则**（见 `patch/kernel/rk35xx-vendor-6.1/README.md` 原文
> "Do not put patches here. Send them directly to armbian/linux-rockchip"）：
> 新板支持 = **两处提交**——内核 DTS 提交到 `armbian/linux-rockchip` 仓库，
> 板卡配置提交到 `armbian/build` 仓库。本包把两件都准备好了。

## 二、提交物说明

### ① 内核补丁（linux-rockchip，目标分支 `rk-6.1-rkr7.2`）

- 内容：新增 `arch/arm64/boot/dts/rockchip/rk3588-lz-rk58ch.dts`（1750 行，
  英文注释）+ Makefile 增加 dtb 条目（插入 Armbian 增量段的 `hinlink-h88k` 与
  `mixtile-blade3` 之间，按字母序）。
- 与主交付的 `rk3588-lz-rk58ch.dts` 内容一致，仅注释翻译为英文以满足上游惯例。
- 已本地验证：`git am` 干净应用（Makefile +1 / DTS 1750 行，作者与主题解析正确）。

### ② 板卡配置（armbian/build，目标分支 `main`）

按 main 分支现有 RK3588 板卡（turing-rk1.csc / orangepi5b.csc / cyber-aib-rk3588.csc）
的现行格式编写：

- `BOARDFAMILY="rockchip-rk3588"`（main 分支 RK3588 现行家族，vendor 分支
  内核即 `armbian/linux-rockchip@rk-6.1-rkr7.2`，与补丁目标一致）
- `KERNEL_TARGET="vendor"`（仅 vendor 6.1；edge/current 走主线内核、本板无线
  主线 DTS，故不列）
- `BOOT_FDT_FILE="rockchip/rk3588-lz-rk58ch.dtb"`
- 串口控制台：家族 vendor 分支默认 `SERIALCON=ttyFIQ0`，与本板 UART2 +
  fiq-debugger 控制台完全一致，无需覆盖
- `BOOTCONFIG="rock-5b-rk3588_defconfig"`：过渡方案（该 ODM 板无专属 U-Boot
  defconfig，选用已验证存在于 radxa/u-boot next-dev-v2024.10 的 Rock 5B 配置）
- 含 ES8388 声卡 udev 命名规则（沿用社区板卡惯例）
- **提交前必须**把 `BOARD_MAINTAINER=""` 填上你的 GitHub 账号

## 三、提交步骤（建议顺序）

```bash
# ============ 1. 内核 DTS PR（先做，build PR 要引用它）============
# fork https://github.com/armbian/linux-rockchip → your-fork
git clone -b rk-6.1-rkr7.2 --depth=50 https://github.com/<you>/linux-rockchip.git
cd linux-rockchip
git am ../armbian/linux-rockchip/0001-*.patch
# 改成你自己的作者身份并加上 Signed-off-by（Armbian 要求 sign-off）：
git commit --amend --reset-author -s   # 需要 git config user.name/user.email 已配置
git push origin rk-6.1-rkr7.2           # 或推到新分支 rk-6.1-rkr7.2-lz-rk58ch
# 在 GitHub 上对 armbian/linux-rockchip 的 rk-6.1-rkr7.2 分支开 PR
# PR 描述用 PR-linux-rockchip.md 的 Body 部分

# ============ 2. 板卡配置 PR ============
# fork https://github.com/armbian/build → your-fork
git clone https://github.com/<you>/build.git && cd build
git checkout -b add-lz-rk58ch origin/main
# 1) 填 BOARD_MAINTAINER；2) 拷入板卡文件：
cp <本包>/armbian/armbian-build/config/boards/lz-rk58ch.csc config/boards/
git add config/boards/lz-rk58ch.csc
git commit -s -m "Add new board support: LX-R58CH V10 (lz-rk58ch)"
git push origin add-lz-rk58ch
# 在 GitHub 上对 armbian/build 的 main 分支开 PR
# PR 描述用 PR-armbian-build.md 的 Body 部分（记得贴上第 1 步的 PR 链接）
```

## 四、GitHub Actions 用法

> **重要**：把本目录（`armbian/`）**里面的内容**放到仓库**根目录**——
> `.github` 必须位于仓库根，GitHub 才会识别工作流。若整包上传成
> `仓库/armbian/.github/...` 子目录，Action 不会触发。

**上传后立即可跑**：`dtb-check.yml`（push 自动触发）——它自带全部依赖，
验证补丁在真实 rk-6.1-rkr7.2 内核树上可应用、DTB 可编译。绿勾 = 补丁本身合格。

**镜像构建（`armbian-image.yml`）有一个前提**：构建用的内核默认来自官方
`armbian/linux-rockchip@rk-6.1-rkr7.2`，而我们的 DTS 提交尚在其中。因此
先按第三节把补丁推到你 fork 的 linux-rockchip 分支，然后手动触发本工作流并填：

- `kernel_repo`：`https://github.com/<你>/linux-rockchip.git`
- `kernel_branch`：如 `rk-6.1-rkr7.2-lz-rk58ch`

工作流会自动把 KERNELSOURCE/KERNELBRANCH 覆盖注入板卡文件再构建；
参数留空时工作流会在预检阶段直接报错退出（避免白白构建 30 分钟）。
等 linux-rockchip PR 合并后，两个输入都不再需要。

产物：artifact `armbian-lz-rk58ch-image`（`*.img` + `*.img.sha`）。
注意：完整镜像构建耗时约 40–90 分钟，占用磁盘大（工作流内含清理步骤）。

## 五、提交前自查清单

- [ ] `git am` 在干净 `rk-6.1-rkr7.2` 上应用成功（Actions `dtb-check.yml` 绿勾）
- [ ] `BOARD_MAINTAINER` 已填你的 GitHub 账号
- [ ] 实机串口日志（1500000 波特率，ttyFIQ0）已留存，附在 PR 里
- [ ] eDP/mini-HDMI 双显示、eMMC、USB、WiFi/BT、音频、触摸实机验证
- [ ] 两个 PR 互相链接（build PR 引用 linux-rockchip PR 编号）

## 六、已知限制与说明

1. **私有驱动**：原厂 5.10 固件包含 ODM 私有驱动（`usb,control`、`usb,detect`、
   音频 `lanxus,not-use-dapm` 补丁）。上游/Armbian 内核无对应驱动，DTS 节点
   已保留（无驱动时无副作用），但充电检测/CC 切换功能不生效，需向板厂索取
   6.1 私有驱动后另行 mainline 化。
2. **网口**：原厂固件双 GMAC 即为关闭状态（走 UIO 方案的配置也一并保留），
   本提交维持关闭；需启用时把 `&gmac0/&gmac1` 的 status 改 okay 即可。
3. **U-Boot**：无板厂 defconfig，过渡复用 Rock 5B 配置；板载 SPI 里的原厂
   U-Boot 同样可引导 Armbian。后续可为板子贡献专属 defconfig。
4. **补丁作者信息**：补丁的 From/作者为占位符，务必按第三节步骤
   `--reset-author -s` 改成你自己的身份再推送。
5. 本包基于 2026-11 的 main 分支格式调研；若提交时 Armbian 结构有变动
   （如家族/变量名调整），以当时的 `config/boards/` 同族板卡为准对齐。

> AI生成
