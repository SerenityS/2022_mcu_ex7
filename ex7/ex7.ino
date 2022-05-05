#include <Adafruit_Sensor.h>
#include "DHT.h"
#define DHT11_PIN 10
#define DHTTYPE DHT11
DHT dht(DHT11_PIN, DHTTYPE);

void setup() {
  for (int i = 2; i < 10; i++) {
    pinMode(i, OUTPUT);
    digitalWrite(i, HIGH);
  }

  dht.begin();
  dht.readHumidity();
  dht.readTemperature();

  Serial.begin(9600);
  Serial.print("Ready");
}

void loop() {
  if (Serial.available()) {
    int i = Serial.parseInt();

    if (2 <= i && i <= 9) {
      if (Serial.read() == ',') {
        int cmd = Serial.parseInt();
        int brightness = Serial.parseInt();
        
        if (cmd) {
          analogWrite(i, brightness);
          Serial.print("ON");
        }
        else {
          analogWrite(i, 0);
          Serial.print("OFF");
        }
      }
    }

    if (i == 10) {
      float humidity = dht.readHumidity(); // 상대 습도 읽기
      float temperature = dht.readTemperature(); // 온도 읽기
      Serial.print(temperature);
      Serial.print(",");
      Serial.print(humidity);
    }
    Serial.read();
  }
}
