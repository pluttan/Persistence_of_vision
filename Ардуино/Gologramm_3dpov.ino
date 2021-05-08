#include <Adafruit_NeoPixel.h>
#define PIN 6
#define NUM_LEDS 256
Adafruit_NeoPixel strip=Adafruit_NeoPixel(NUM_LEDS,PIN,NEO_GRB+NEO_KHZ800);

void setup() {
	Serial.begin(9600);
	strip.begin();
	strip.setBrightness(50);
	strip.clear();
	strip.show();
}
