void loop() {
  Serial.print("ob");
  int p = 0;
  for (int i1 = 0; i1 < 16; i1++){
      Serial.print(p);
      for (int i = 0; i < 256; i++){strip.setPixelColor(i,pgm_read_dword(&arot[i1][i]));};
      p=p+1;
      Serial.print("pr");
      strip.show();
      delay(10);
  };
}
