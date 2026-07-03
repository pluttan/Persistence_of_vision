<div align="center">

# POVgram

**Persistence-of-vision LED cube 8x8x8 with a browser-based 3D animation editor**

</div>

A mechanical platform with a 64-LED WS2812B strip spins on a motor while an ESP32-S2 synchronizes color output with rotation, producing a volumetric 3D image of 512 virtual voxels in mid-air. Animations are created in a browser-based editor and uploaded to the device over Wi-Fi.

## ■ Features

- ❖ **512-voxel 3D display** — 8x8x8 POV cube rendered by a spinning 8x8 LED strip synchronized with a rotation sensor
- ❖ **Browser-based 3D editor** — React app with a Three.js live preview, per-slice pixel painting across XY/YZ/ZX planes, and undo/redo history
- ❖ **Multi-frame animation** — sequences of 8x8x8 frames with configurable rotation speed, looping, per-frame duplication, and drag-and-drop reordering
- ❖ **Custom color palettes** — 16-color palettes (default Catppuccin), saved across sessions via cookies, edited with a native color picker
- ❖ **Wi-Fi upload** — push animations to the device over HTTP as JSON, stored on SPI Flash (FAT), played back on demand
- ❖ **USB Mass Storage** — device appears as a USB drive (TinyUSB MSC) for direct file access to stored animations
- ❖ **PID motor control** — closed-loop speed regulation with hard-kickstart logic and fixed-point slider-crank layer-timing math

## ■ Stack

<div align="center">

| Component | Technology |
|-----------|-----------|
| MCU | ESP32-S2 |
| Firmware | ESP-IDF + FreeRTOS (C++) |
| LEDs | 64x WS2812B via SPI DMA |
| Layer timing | GPTimer (us reset) + fixed-point slider-crank math |
| Motor control | PID controller + LEDC PWM |
| Storage | SPI Flash (FAT via TinyUSB MSC) |
| HTTP server | esp_http_server (Wi-Fi STA) |
| Frontend | React 19 + Vite 7 |
| 3D visualization | Three.js (OrbitControls) |
| Default palette | Catppuccin |

</div>

## ■ How It Works

```
1. The rotation sensor fires a rising-edge interrupt; the ESP32-S2 uses fixed-point slider-crank math to compute precise per-layer timing offsets.
2. PID motor control (LEDC PWM) maintains stable rotation speed with hard-kickstart logic.
3. At each computed offset the firmware drives the 8x8 WS2812B strip via SPI DMA, painting one vertical slice of the current animation frame — building the full 8x8x8 voxel volume in mid-air.
4. Animations are authored in the browser editor: frames are painted slice-by-slice on XY/YZ/ZX planes and previewed live in a Three.js 3D view with undo/redo support.
5. The finished animation is exported as JSON and pushed to the device over HTTP (Wi-Fi); the device stores it on SPI Flash (FAT) and plays it back on demand.
6. The same Flash partition is also accessible as a USB Mass Storage drive (TinyUSB MSC) for direct file management.
```

## ■ Screenshots

<div align="center">

![Screenshot](screenshots/main.png)

*Main animation editor interface with 3D cube preview*

</div>

## ■ Usage

### Frontend (animation editor)

```bash
cd povgram-frontend
npm install
npm run dev
```

### Firmware

```bash
cd usb-example/tusb_msc
idf.py set-target esp32s2
idf.py menuconfig    # set WIFI_SSID and WIFI_PASSWORD
idf.py build flash
```

### Upload Animation

1. Open the web editor in a browser
2. Draw frames slice by slice in the 8x8 grid, preview the cube in 3D
3. Enter the device IP in the badge, then open the Export menu and flash the animation to the device
4. Trigger playback from the same menu to display it on the cube

## ■ Repository Structure

```
POVgram/
├── povgram-frontend/             # React web editor (Vite)
│   └── src/
│       ├── components/
│       │   ├── MagicCube.jsx     # Main orchestrator / layout
│       │   ├── Cube3D/           # Three.js 3D preview
│       │   ├── panels.jsx        # LayerEditor, Palette, FrameTimeline, ExportMenu, ...
│       │   ├── ui.jsx            # Logo, ToolDock, ZNav, DeviceBadge, ...
│       │   ├── VoxelThumb.jsx    # Frame thumbnail renderer
│       │   ├── Onboarding.jsx    # First-run overlay
│       │   └── Toast.jsx         # Toast notifications
│       ├── hooks/
│       │   ├── useFrameAnimation.js  # Frame management + playback + undo/redo
│       │   └── usePaletteSystem.js   # Palette state + persistence
│       └── utils/                # device protocol, palette, voxel, persist
│
├── usb-example/tusb_msc/         # ESP32-S2 firmware (ESP-IDF)
│   └── main/components/
│       ├── init                  # task setup, sensor ISR, drawLayer
│       ├── wifi                  # Wi-Fi STA + HTTP API (esp_http_server)
│       ├── leds                  # WS2812B SPI driver + GPTimer
│       ├── pidController         # Motor speed regulation (PID + LEDC)
│       ├── PointsCalc            # Fixed-point slider-crank layer timing
│       └── usbMscStorage         # USB MSC + FAT filesystem
│
├── esp32c3-render-node/          # Experimental ESP32-C3 24x24x24 render node (SPI slave)
├── esp32c3-test-master/          # Experimental ESP32-C3 SPI-master test bench
└── demos/                        # Sample animations (JSON) + Node.js generators
```

## ■ Hardware

<div align="center">

| Part | Description |
|------|-------------|
| MCU | ESP32-S2 |
| LEDs | 64x WS2812B strip (data on GPIO 16, SPI2 @ 2.5 MHz) |
| Motor | DC motor + driver (LEDC PWM on GPIO 40, 2 kHz) |
| Sensor | Rotation sensor (GPIO 39, rising-edge interrupt, internal pull-up) |
| Storage | Internal SPI Flash (1 MB FAT partition) |
| Interface | USB (Mass Storage) + Wi-Fi (HTTP API) |

</div>

## ■ License

MIT © [pluttan](https://github.com/pluttan)
