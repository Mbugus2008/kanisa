# Kanisa Play Store Graphics

This folder contains HTML templates for generating Play Store graphics.

## Files

| File | Purpose | Size |
|------|---------|------|
| `feature_graphic.html` | Main banner for Play Store listing | 1024 x 500 px |
| `screenshot_mockup.html` | Phone mockups with app screens | 440 x 900 px each |
| `app_icon_512.html` | High-res app icon | 512 x 512 px |

## How to Use

### Step 1: Open in Browser
Double-click any HTML file to open in your browser (Chrome recommended).

### Step 2: Capture Screenshots

**Option A: Windows Snipping Tool**
1. Press `Win + Shift + S`
2. Select "Rectangular Snip"
3. Draw around the graphic
4. Save as PNG

**Option B: Browser DevTools**
1. Press `F12` to open DevTools
2. Click the element selector (arrow icon)
3. Click on the graphic element
4. Right-click the element in DevTools
5. Select "Capture node screenshot"

### Step 3: Upload to Play Console

1. Go to [Play Console](https://play.google.com/console)
2. Navigate to **Main store listing** → **Graphics**
3. Upload:
   - Feature graphic (1024x500)
   - App icon (512x512)
   - Screenshots (2-8 required)

## Customization

Edit the HTML files to:
- Change colors (look for `#1e3c72` and `#2a5298`)
- Update text content
- Replace placeholder content with actual app screenshots

## Using Real Screenshots

1. Run your app on an emulator or device
2. Take screenshots of key screens
3. Edit `screenshot_mockup.html` and replace the phone screen content with:
   ```html
   <img src="path/to/your/screenshot.png" style="width:100%; height:100%; object-fit:cover;">
   ```

## Required Graphics Checklist

- [ ] Feature Graphic (1024 x 500) - Required
- [ ] App Icon (512 x 512) - Required  
- [ ] Screenshot 1 - Home screen
- [ ] Screenshot 2 - Events
- [ ] Screenshot 3 - Bible/Sermons
- [ ] Screenshot 4 - Profile
- [ ] Screenshot 5 (optional)
- [ ] Screenshot 6 (optional)
