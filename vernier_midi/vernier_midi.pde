/************************************
 * Vernier sensor test script
 * by Brett Graham
 * Jan 06, 2012
 * rev 0.0
 ************************************/

#include <MIDI.h>

// lookup vernier resistor ID
// TODO: workout what voltages this would be and what value from 0-1024 (normally 1024, also 16k pullup
// maybe 10k between ID and 5V, sensor connects ID and GND
/*************************************
from labpro_tech_manual.pdf
===========================

R     Name                                 Range          ID Value (R+-5%) (R+-10%)    Ranges
------------------------------------------------------------------------------------------------
1k    Ex hear rate sensor (BPM)            N/A            93   88 to 97    84 to 101    68 - 113
1.5k  EKG                                  N/A            133  127 to 139  121 to 145  113 - 158
2.2k  thermocouple C                       -20 to 1400 C  184  177 to 192  169 to 199  158 - 219
3.3k  Resistance Sensor                    1k to 100k     254  244 to 263  234 to 272  219 - 290
4.7k  TI light sensor                      0 to 1         327  316 to 338  304 to 348  290 - 370
6.8k  Current Sensor                       -10 to 10 A    414  401 to 426  388 to 438  370 - 463
10k   stainless steel or TI temp sensor C  -25 to 125 C   512  498 to 524  385 to 536  463 - 563
15k   Stainless steel or TI temp sensor F  -13 to 257 F   614  601 to 626  588 to 637  563 - 659
22k   Long temperature sensor C            -50 to 150 C   704  692 to 714  680 to 724  659 - 744
33k   TI Voltage sensor                    10 to 10 V     785  776 to 794  766 to 802  744 - 814
47k   Voltage sensor                       0 to 5 V       844  836 to 851  828 to 858  814 - 868
68k   CO2 gas sensor                       0 to 5000 ppm  892  886 to 898  880 to 903  868 - 911
100k  Oxygen gas sensor                    0 to 27%       930  926 to 934  921 to 938  911 - 945 
150k  C V voltage sensor (V)               -6 to 6 V      960  956 to 962  953 to 965  945 - 969
220k  C V current sensor (A)               -0.6 to 0.6 A  979  977 to 981  974 to 983  969 - 993

***************************************/

#define ID_HEARTRATE       1
#define ID_EKG             2
#define ID_THERMOCOUPLE_C  3
#define ID_RESISTANCE      4
#define ID_TI_LIGHT        5
#define ID_CURRENT         6
#define ID_TI_TEMP_C       7
#define ID_TI_TEMP_F       8
#define ID_LONG_TEMP       9
#define ID_TI_VOLTAGE     10
#define ID_VOLTAGE        11
#define ID_CO2            12
#define ID_OXYGEN         13
#define ID_CV_VOLTAGE     14
#define ID_CV_CURRENT     15

byte lookupID(int IDValue) {
  if (IDValue < 113) {
    return ID_HEARTRATE;
  } else if (IDValue < 158) {
    return ID_EKG;
  } else if (IDValue < 219) {
    return ID_THERMOCOUPLE_C;
  } else if (IDValue < 290) {
    return ID_RESISTANCE;
  } else if (IDValue < 370) {
    return ID_TI_LIGHT;
  } else if (IDValue < 463) {
    return ID_CURRENT;
  } else if (IDValue < 563) {
    return ID_TI_TEMP_C;
  } else if (IDValue < 659) {
    return ID_TI_TEMP_F;
  } else if (IDValue < 744) {
    return ID_LONG_TEMP;
  } else if (IDValue < 814) {
    return ID_TI_VOLTAGE;
  } else if (IDValue < 868) {
    return ID_VOLTAGE;
  } else if (IDValue < 911) {
    return ID_CO2;
  } else if (IDValue < 945) {
    return ID_OXYGEN;
  } else if (IDValue < 969) {
    return ID_CV_VOLTAGE;
  } else if (IDValue < 993) {
    return ID_CV_CURRENT;
  } else {
    return 0; // unknown
  }
}

#define ID_THRESHOLD 4 // TODO: make this 4?
#define ID_CC        83
#define SETTLING_TIME 10

class VernierSensor {
  public:
    VernierSensor(byte sensorPin, byte IDPin);
    //~VernierSensor();
    void checkSensor();
    void setThreshold(int threshold);
    
    void enable();
    void disable();
  
  private:
    boolean _enabled;
    
    byte _ID;
    byte _IDPin;
    int _IDValue;
    
    byte _sensorPin;
    int _previousValue;
    int _threshold;
    
    void checkID();
    void sendValue(int sensorValue);
    void sendID();
};

VernierSensor::VernierSensor(byte sensorPin, byte IDPin) {
  _sensorPin = sensorPin;
  _IDPin = IDPin;
  
  // defaults
  _ID = 0;
  _IDValue = 1024;
  _enabled = false;
  _threshold = 4;
  _previousValue = -(_threshold + 1); 
}

void VernierSensor::setThreshold(int threshold) {
  _threshold = threshold;
}

void VernierSensor::enable(){
  _enabled = true;
  for (int i = 0; i < SETTLING_TIME; i++) {
    analogRead(_sensorPin);
  }
  // TODO: settling time
  _previousValue = -(_threshold + 1);// make sure next reading is sent
}

void VernierSensor::disable(){
  _enabled = false;
}

void VernierSensor::checkID() {
  int IDValue = analogRead(_IDPin);
  if (abs(IDValue - _IDValue) > ID_THRESHOLD) {
    _ID = lookupID(IDValue);
    sendID();
    _IDValue = IDValue;
    if (_ID != 0) {
      enable();
    } else {
      disable();
    }
  }
}

void VernierSensor::checkSensor() {
  checkID();
  if (_enabled){
    int sensorValue = analogRead(_sensorPin);
    if (abs(sensorValue - _previousValue) > _threshold) {
      sendValue(sensorValue);
      _previousValue = sensorValue;
    }
  }
}

void VernierSensor::sendValue(int sensorValue) {
  /*
  Serial.print(_sensorPin, DEC);
  Serial.print(":");
  Serial.println(sensorValue, DEC);
  */
  MIDI.sendPitchBend(sensorValue,_sensorPin);
}

void VernierSensor::sendID() {
  /* Sends ID code, 0 for no sensor, or disconnect */
  if (_ID != 0) {
    /*
    Serial.print(_ID, DEC);
    Serial.println("attached");
    */
    MIDI.sendControlChange(ID_CC, _ID, _sensorPin);
  } else {
    /*
    Serial.print(_ID, DEC);
    Serial.println("no, or unknown sensor");
    */
    MIDI.sendControlChange(ID_CC, _ID, _sensorPin);
  }
}

/***********
 * Testing *
 ***********/

VernierSensor v1(A0,A1);
//VernierSensor v2(A2,A3);
//VernierSensor v3(A4,A5);

void HandleCC(byte channel, byte number, byte value) {
  /*
    number -> threshold
    value -> 0: disable; 1: enable; >1: nothing;
  */
  // set threshold (number) and enable (value) here?
  if (channel == 1) {
    v1.setThreshold(number);
    if (value == 1) {
      v1.enable();
    } else if (value == 0) {
      v1.disable();
    }
    /*
  } else if (channel == 2) {
    v2.setThreshold(number);
    if (value != 0) {
      v2.enable();
    } else {
      v2.disable();
    }
  } else if (channel == 3) {
    v3.setThreshold(number);
    if (value != 0) {
      v3.enable();
    } else {
      v3.disable();
    }
    */
  }
}

void setup() {
  MIDI.begin(MIDI_CHANNEL_OMNI);
  MIDI.setHandleControlChange(HandleCC);
}

void loop() {
  v1.checkSensor();
  //v2.checkSensor();
  //v3.checkSensor();
  MIDI.read();
}
