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

Notes
----

Some brief details on the system at the moment:

1) sensor values are reported over usb-midi as pitch-bend events (so we can at least get the full 10 bits from the arduino a2d)
2) connecting or disconnecting an auto-id sensor triggers the arduino to send a CC command with the new sensor ID
3) a change in sensor value is only reported if it exceeds a certain threshold (so the midi bus is not flooded), this threshold can be controlled by sending the arduino a CC command
4) if a non-auto-id sensor is connected it will NOT cause the arduino to start sending sensor data, instead a CC command must be sent from the host to the arduino to tell the arduino to enable that sensor


