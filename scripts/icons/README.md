# Nimbus Icon Assets

Nimbus keeps icon source in SVG and generated Windows/web raster assets in the
repo so installer, tray, and web UI branding stay aligned.

Regenerate the Nimbus PNG/ICO assets from the vector design with:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\icons\generate_nimbus_icon.ps1
```

The generator writes:

- `nimbus.png` and `nimbus.ico`
- `src_assets/common/assets/web/public/images/logo-nimbus-*.png`
- `src_assets/common/assets/web/public/images/nimbus*.ico`
- status tray PNG/ICO variants for playing, pausing, and locked states
