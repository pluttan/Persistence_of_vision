<div align="center">

# POVgram

**LED-куб 8x8x8 на принципе persistence-of-vision с браузерным редактором 3D-анимаций**

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

## ■ Как это работает

```
1. Датчик оборотов генерирует прерывание по переднему фронту; ESP32-S2 использует математику кривошипно-шатунного механизма с фиксированной точкой для вычисления точных временных смещений для каждого слоя.
2. PID-управление мотором (LEDC PWM) поддерживает стабильную скорость вращения с логикой жёсткого старта.
3. В каждый вычисленный момент прошивка управляет полоской WS2812B 8x8 через SPI DMA, отрисовывая один вертикальный срез текущего кадра анимации — формируя полный объём вокселей 8x8x8 в воздухе.
4. Анимации создаются в браузерном редакторе: кадры рисуются срез за срезом в плоскостях XY/YZ/ZX и просматриваются в реальном времени в 3D-виде на Three.js с поддержкой undo/redo.
5. Готовая анимация экспортируется как JSON и отправляется на устройство по HTTP (Wi-Fi); устройство сохраняет её на SPI Flash (FAT) и воспроизводит по запросу.
6. Тот же раздел Flash также доступен как USB Mass Storage (TinyUSB MSC) для прямого управления файлами.
```

## ■ Скриншоты

<div align="center">

![Screenshot](screenshots/main.png)

*Основной интерфейс редактора анимаций с 3D-предпросмотром куба*

</div>

## ■ Использование

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

## ■ Железо

<div align="center">

| Деталь | Описание |
|--------|----------|
| MCU | ESP32-S2 |
| LEDs | 64x WS2812B strip (data on GPIO 16, SPI2 @ 2.5 MHz) |
| Motor | DC motor + driver (LEDC PWM on GPIO 40, 2 kHz) |
| Sensor | Rotation sensor (GPIO 39, rising-edge interrupt, internal pull-up) |
| Storage | Internal SPI Flash (1 MB FAT partition) |
| Interface | USB (Mass Storage) + Wi-Fi (HTTP API) |

</div>

## ■ Лицензия

MIT © [pluttan](https://github.com/pluttan)
