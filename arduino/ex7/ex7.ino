#include <Adafruit_Sensor.h>
#include "DHT.h"
#define DHT11_PIN 10
#define DHTTYPE DHT11
DHT dht(DHT11_PIN, DHTTYPE);

void setup() {
  // 2 ~ 9 LED ON
  // 2 ~ 9(Pin No) == 1 ~ 8(LED No)
  for (int i = 2; i < 10; i++) {
    pinMode(i, OUTPUT);
    analogWrite(i, 255);
  }

  // DHT11 초기화
  dht.begin();
  dht.readHumidity();
  dht.readTemperature();

  // 시리얼 통신 시작
  Serial.begin(9600);
  // 정상적으로 시리얼 통신이 연결된 경우 Ready 출력
  Serial.print("Ready");
}

void loop() {
  // 시리얼 통신을 통해 명령어를 전달 받은 경우
  if (Serial.available()) {
    int i = Serial.parseInt();

    // 전달 받은 명령어가 2 ~ 9인 경우
    // ex) 2, 1, 255(LEDNo, ON/OFF, Brightness)
    if (2 <= i && i <= 9) {
      if (Serial.read() == ',') {
        int cmd = Serial.parseInt();
        int brightness = Serial.parseInt();

        // ON
        if (cmd) {
          analogWrite(i, brightness);
          Serial.print("ON");
        }
        // OFF
        else {
          analogWrite(i, 0);
          Serial.print("OFF");
        }
      }
    }

    // 전달 받은 명령어가 10인 경우
    // DHT11 데이터 반환
    if (i == 10) {
      float humidity = dht.readHumidity(); // 상대 습도 읽기
      float temperature = dht.readTemperature(); // 온도 읽기
      // 온습도 시리얼 출력
      Serial.print(temperature);
      Serial.print(",");
      Serial.print(humidity);
    }

    // 전달 받은 명령어가 11인 경우
    // Byte ON/OFF
    if (i == 11) {
      Serial.read(); // 콤마 제거
      String byteArray = Serial.readString(); // 8bit Led Status 일음
      Serial.print(byteArray); // 전체 LED 상태 시리얼 출력
      for (int i = 0; i < 8; i++) {
        int ledStatus = byteArray[i] - 48; // char to int(0, 1)
        digitalWrite(i + 2, ledStatus); // LED On/Off
      }
    }

    // 전달 받은 명령어가 12인 경우
    // 초기화
    if (i == 12) {
      // 전체 LED On
      for (int i = 2; i < 10; i++) {
        digitalWrite(i, 1);
      }
      Serial.print("Clear");
    }
  }
}
