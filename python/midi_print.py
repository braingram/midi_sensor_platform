#!/usr/bin/env python

from mididings import *

def midi_print(ev):
    print ev, ev.channel, ev.type

run(Process(midi_print))
