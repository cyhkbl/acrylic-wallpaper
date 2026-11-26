# 生成商店/发布用的 ZIP

构建产物放在 `dist/` 下，只包含扩展运行需要的文件。

```powershell
pwsh -File scripts/build-zip.ps1
# -> dist/acrylic-wallpaper-<version>.zip
```

版本号取自 `manifest.json`。
