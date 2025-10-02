# OptiGemini Installer Resources

This directory contains resources for the WiX installer:

## Files

- **default-config.json**: Default configuration file installed with the application
- **License.rtf**: License agreement displayed during installation
- **OptiGemini.ico**: Application icon (to be created)
- **Banner.bmp**: Installer banner image (493×58 pixels)
- **Dialog.bmp**: Installer dialog background (493×312 pixels)

## Creating Graphics

### Icon (OptiGemini.ico)
- Size: 256×256, 128×128, 64×64, 48×48, 32×32, 16×16
- Format: ICO with multiple resolutions
- Tool: Can be created with tools like GIMP, Paint.NET, or online converters

### Banner (Banner.bmp)
- Size: 493×58 pixels
- Format: 24-bit BMP
- Content: OptiGemini logo and name on blue gradient background

### Dialog (Dialog.bmp)
- Size: 493×312 pixels
- Format: 24-bit BMP
- Content: Product branding image for installer welcome screen

## Placeholder Images

For development purposes, placeholder images can be created using PowerShell:

```powershell
# Create placeholder banner
Add-Type -AssemblyName System.Drawing
$banner = New-Object System.Drawing.Bitmap(493, 58)
$graphics = [System.Drawing.Graphics]::FromImage($banner)
$graphics.Clear([System.Drawing.Color]::Blue)
$banner.Save("Banner.bmp", [System.Drawing.Imaging.ImageFormat]::Bmp)
$graphics.Dispose()

# Create placeholder dialog
$dialog = New-Object System.Drawing.Bitmap(493, 312)
$graphics = [System.Drawing.Graphics]::FromImage($dialog)
$graphics.Clear([System.Drawing.Color]::LightBlue)
$dialog.Save("Dialog.bmp", [System.Drawing.Imaging.ImageFormat]::Bmp)
$graphics.Dispose()
```

## Notes

- Images should follow Windows Installer UI guidelines
- Keep file sizes reasonable (<500KB per image)
- Ensure compliance with branding guidelines
