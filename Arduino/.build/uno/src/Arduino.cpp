#include <Arduino.h>
#include <Adafruit_NeoPixel.h>
void setup();
#line 1 "src/Arduino.ino"
//#include <Adafruit_NeoPixel.h>
#define PIN 5        // пин DI
#define NUM_LEDS 256   // число диодов
Adafruit_NeoPixel strip = Adafruit_NeoPixel(NUM_LEDS, PIN, NEO_GRB + NEO_KHZ800);
void setup() {
  Serial.begin(9600);
  strip.begin();
  strip.setBrightness(50);    // яркость, от 0 до 255
  strip.clear();                          // очистить
  strip.show();                           // отправить на ленту
}
