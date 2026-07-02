![Header](header.png)

<div align="center">

# POVgram

**LED-куб 8x8x8 на принципе persistence-of-vision с браузерным редактором 3D-анимаций**

[![License](https://img.shields.io/badge/license-MIT-2C2C2C?style=for-the-badge&labelColor=1E1E1E)](LICENSE)
[![ESP-IDF](https://img.shields.io/badge/ESP--IDF-E7352C?style=for-the-badge&logo=espressif&labelColor=1E1E1E)](https://docs.espressif.com/projects/esp-idf/)
[![React](https://img.shields.io/badge/React_19-61DAFB?style=for-the-badge&logo=react&labelColor=1E1E1E)](https://react.dev)
[![Three.js](https://img.shields.io/badge/Three.js-000000?style=for-the-badge&logo=threedotjs&labelColor=1E1E1E)](https://threejs.org)

</div>

Механическая платформа с полоской из 64 светодиодов WS2812B вращается от мотора, пока ESP32-S2 синхронизирует цветовой вывод с оборотами, формируя в воздухе объёмное 3D-изображение из 512 виртуальных вокселей. Анимации создаются в браузерном редакторе и загружаются на устройство по Wi-Fi.

## ■ Возможности

- ❖ **3D-дисплей из 512 вокселей** — POV-куб 8x8x8, формируемый вращающейся полоской 8x8 светодиодов, синхронизированной с датчиком оборотов
- ❖ **Браузерный 3D-редактор** — React-приложение с живым предпросмотром на Three.js, попиксельной отрисовкой по слоям в плоскостях XY/YZ/ZX и историей undo/redo
- ❖ **Многокадровая анимация** — последовательности кадров 8x8x8 с настраиваемой скоростью вращения, циклическим воспроизведением, дублированием кадров и перестановкой перетаскиванием
- ❖ **Настраиваемые цветовые палитры** — 16-цветные палитры (по умолчанию Catppuccin), сохраняемые между сессиями через cookies и редактируемые нативным color picker
- ❖ **Загрузка по Wi-Fi** — отправка анимаций на устройство по HTTP в формате JSON, хранение на SPI Flash (FAT), воспроизведение по запросу
- ❖ **USB Mass Storage** — устройство определяется как USB-накопитель (TinyUSB MSC) для прямого доступа к сохранённым анимациям
- ❖ **PID-управление мотором** — регулирование скорости в замкнутом контуре с логикой жёсткого старта и математикой кривошипно-шатунного механизма с фиксированной точкой для расчёта тайминга слоёв

## ■ Стек

<div align="center">

| Компонент | Технология |
|-----------|-----------|
| MCU | ESP32-S2 |
| Прошивка | ESP-IDF + FreeRTOS (C++) |
| Светодиоды | 64x WS2812B via SPI DMA |
| Тайминг слоёв | GPTimer (us reset) + fixed-point slider-crank math |
| Управление мотором | PID controller + LEDC PWM |
| Хранилище | SPI Flash (FAT via TinyUSB MSC) |
| HTTP-сервер | esp_http_server (Wi-Fi STA) |
| Фронтенд | React 19 + Vite 7 |
| 3D-визуализация | Three.js (OrbitControls) |
| Палитра по умолчанию | Catppuccin |

</div>

## ■ Структура репозитория

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

## ■ Запуск

### Фронтенд (редактор анимаций)

```bash
cd povgram-frontend
npm install
npm run dev
```

### Прошивка

```bash
cd usb-example/tusb_msc
idf.py set-target esp32s2
idf.py menuconfig    # задать WIFI_SSID и WIFI_PASSWORD
idf.py build flash
```

### Загрузка анимации

1. Открыть веб-редактор в браузере
2. Нарисовать кадры по слоям в сетке 8x8, просмотреть куб в 3D
3. Ввести IP устройства в бейдже, затем открыть меню Export и загрузить анимацию на устройство
4. Запустить воспроизведение из того же меню для отображения на кубе

## ■ Железо

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

## ■ Скриншоты

<div align="center">

![Screenshot](screenshots/main.png)

*Основной интерфейс редактора анимаций с 3D-предпросмотром куба*

</div>

## ■ Лицензия

MIT © [pluttan](https://github.com/pluttan)
