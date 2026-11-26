# 商店上架信息（Edge 加载项 / Chrome 应用商店）

## 基本信息

| 字段 | 值 |
| --- | --- |
| 名称 | Acrylic Wallpaper |
| 版本 | 1.0.0（取自 `manifest.json`） |
| 类别 | 工具 / Productivity（Chrome 选 Productivity；Edge 选 Productivity） |
| 语言 | 简体中文、English |
| 官方网站 | https://github.com/cyhkbl/acrylic-wallpaper |
| 隐私政策 | https://github.com/cyhkbl/acrylic-wallpaper/blob/main/PRIVACY.md |
| 支持邮箱 | cyhkbl@hotmail.com |

## 简短描述（≤132 字符）

中文：新标签页是原图壁纸，所有网站背景是同一张壁纸的磨砂版，跟随页面明暗自动切换。

English: A clean wallpaper new tab, and the same wallpaper blurred behind every website. Auto light/dark.

## 详细描述

```
Acrylic Wallpaper 把一张壁纸变成整个浏览器的背景。

· 新标签页：壁纸铺满，没有搜索框、没有快捷网站、没有文字。
· 所有网站：同一张壁纸重度模糊后垫在页面下方，网页自己的底色被清空，每篇文章、每个列表都浮在同一块毛玻璃上。
· 明暗自适应：默认按页面正文颜色选择蒙版——白底站点走浅色，深色站点走深色，白底站点在夜间也不会变成黑底黑字。也可以在弹窗里改成跟随系统。
· 可控：总开关、三档强度（轻/标准/强）、按站点禁用。

隐私：不联网、不收集任何数据。壁纸与代码全部打包在扩展内，设置只存在浏览器自带的同步存储里。

想用自己的照片：运行仓库里的 scripts/set-wallpaper.ps1，或直接替换 wallpaper.jpg 与 wallpaper-blur.jpg。

开源：MIT，源码与问题反馈见 https://github.com/cyhkbl/acrylic-wallpaper
```

English version for the store description field:

```
Acrylic Wallpaper turns one picture into the background of your whole browser.

- New tab: the wallpaper, edge to edge. No search box, no shortcuts, no text.
- Every website: a heavily blurred copy of the same wallpaper sits under the page while the page's own background is cleared, so articles and feeds float on frosted glass.
- Light/dark aware: the veil follows the page's own text colour, so light sites stay light even at night. Switch to "follow the system" in the popup if you prefer.
- In control: master switch, three strength levels, per-site opt-out.

Privacy: no network requests, no data collection. The artwork and code ship inside the extension; settings live in the browser's own sync storage.

Bring your own picture with scripts/set-wallpaper.ps1, or replace wallpaper.jpg and wallpaper-blur.jpg.

MIT licensed. Source: https://github.com/cyhkbl/acrylic-wallpaper
```

## 权限说明（Chrome 必填 / Edge 选填但建议）

| 权限 | 用途 |
| --- | --- |
| `storage` | 保存总开关、强度、明暗模式与站点禁用名单 |
| `tabs` | 弹窗读取当前标签页的域名，用于「禁用本站」 |
| `host_permissions: <all_urls>` | 内容脚本需要在任意网站注入背景样式与背景元素 |
| `chrome_url_overrides.newtab` | 用壁纸页面替换新标签页 |

单用途说明（Chrome single purpose）：

> The extension's single purpose is to display a wallpaper as the browser's new tab and as a blurred backdrop behind web pages.

## 远程代码

不使用远程代码。所有脚本、样式、图片随扩展打包。

## 截图

| 文件 | 内容 |
| --- | --- |
| `screenshots/screenshot-1-newtab-1280x800.png` | 新标签页（纯壁纸） |
| `screenshots/screenshot-2-site-1280x800.png` | 普通白底文章 + 模糊壁纸背景 |
| `screenshots/screenshot-3-popup-1280x800.png` | 工具栏弹窗与设置 |
| `screenshots/promo-440x280.png` | Chrome 小宣传图 |
| `screenshots/screenshot-1-newtab-640x480.png` | Edge 备用尺寸 |

## 提交步骤

### Edge 加载项商店

1. 打开 <https://partner.microsoft.com/dashboard/microsoftedge/>，用 Microsoft 账号注册开发者（个人免费）。
2. 「新建扩展」→ 上传 `dist/acrylic-wallpaper-1.0.0.zip`。
3. 填写上表信息、上传截图、粘贴隐私政策链接。
4. 提交审核（通常 1–7 个工作日）。

### Chrome 应用商店

1. 打开 <https://chrome.google.com/webstore/devconsole>，用 Google 账号注册开发者（一次性 5 美元）。
2. 「新增项目」→ 上传同一个 ZIP。
3. 填写商店信息、单用途说明、权限理由、截图、隐私政策链接。
4. 提交审核（通常 1–3 个工作日）。

## 审核常见退回原因与应对

- 缺少隐私政策链接 → 用仓库里的 PRIVACY.md 原始链接。
- 权限理由写得笼统 → 用上面「权限说明」表格的原文。
- 描述里出现「最好用」「第一」等绝对化用语 → 已避免。
- 截图与实际功能不符 → 截图均来自真实渲染。

