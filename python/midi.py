#!/usr/bin/env python

import logging
import time

import pypm

class HiduinoSensor(object):
    def __init__(self, input_device, output_device):
        self.input_device = input_device
        self.output_device = output_device
        self.I = pypm.Input(self.input_device)
        self.O = pypm.Output(self.output_device)
        self.reading = -1

    def _parse_ID(self, packet):
        if packet[0][1] != 83:
            logging.warning("Unknown packet: %s" % packet)
            return
        self.sensor_id = packet[0][2]

    def _parse_sensor(self, packet):
        self.time = packet[1]
        lsb = packet[0][1]
        msb = packet[0][2]
        self.reading = lsb + (msb << 7)
    
    def _parse_input(self, packet):
        # if CC -> parse ID
        # if PitchBend -> store value
        if packet[0][0] == 189:
            self._parse_ID(packet)
        elif packet[0][0] == 237:
            self._parse_sensor(packet)
        else:
            logging.warning("Unknown packet: %s" % packet)

    def set_threshold(self, threshold):
        # send CC 
        #  channel = sensor_index (1...)
        #  number = threshold
        #  value = 0:disable,1:enable,2:nada
        #self.O.Write([[[189, sensor_index, threshold, 2],0]])#pypm.Time()]])
        self.O.Write([[[176, threshold, 2],pypm.Time()]]) # for sensor 1

    def enable(self, threshold):
        self.O.Write([[[176, threshold, 1],pypm.Time()]])

    def disable(self, threshold):
        self.O.Write([[[176, threshold, 0],pypm.Time()]])

    def read_sensor(self):
        while self.I.Poll():
            self._parse_input(self.I.Read(1)[0])
        return self.reading

    def blocking_read_sensor(self, poll_time = 0.001):
        while not self.I.Poll():
            time.sleep(poll_time)
        return self.read_sensor()


def find_hiduino():
    input_index = -1
    output_index = -1
    for d in xrange(pypm.CountDevices()):
        device_info = pypm.GetDeviceInfo(d)
        if 'HIDUINO' in device_info[1]:
            if device_info[2]:
                input_index = d
            if device_info[3]:
                output_index = d
    if (input_index == -1) or (output_index == -1):
        raise IOError('Hiduino not found: input=%i output=%i' % (input_index, output_index))
    return input_index, output_index

if __name__ == '__main__':
    pypm.Initialize()
    m = HiduinoSensor(*find_hiduino())

    for i in xrange(3):
        print m.blocking_read_sensor()

    print "Setting threshold to 1"
    m.set_threshold(1)
    for i in xrange(3):
        print m.blocking_read_sensor()

    print "Setting threshold to 10"
    m.set_threshold(10)
    for i in xrange(3):
        print m.blocking_read_sensor()

    m.disable(10)
    for i in xrange(3):
        print m.read_sensor()
        time.sleep(0.5)
    m.enable(10)

    for i in xrange(3):
        print m.read_sensor()
        time.sleep(0.5)
