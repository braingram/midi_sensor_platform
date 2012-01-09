Arduino sketch to read in sensor values from Vernier probes and relay data to a host computer or device (iOS) using usb-midi

Currently tested with arduino-0023, UNO board, usbtiny programmer and iPad.

Instructions
------------

- clone repository
- download HIDUINO firmware [http://code.google.com/p/hiduino/downloads/list]
- from HIDUINO copy Compiled Firmwares/HIDUINO_MIDI.hex to 8u2_firmware/
- from Arduino IDE copy hardware/arduino/firmwares/UNO-dfu_and_usbserial_combined.hex to 8u2_firmware/
- open vernier_midi.pde in Arduino IDE
- compile and upload vernier_midi.pde to Arduino UNO
- disconnect UNO
- connect usbtiny programmer to 8u2 ICSP headers
- run 8u2_firmware/flash_midi.sh
- disconnect usbtiny
- attach Arduino UNO to computer with usb cable (or iPad with usb cable and camera connector)
- watch for midi events!

To reprogram the Arduino UNO after following the previous instructions you will need to reflash the 8u2 serial firmware by running 8u2_firmware/flash_serial.sh.
