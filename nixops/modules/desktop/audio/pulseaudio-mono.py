import sys
import dbus
import os
import subprocess
import re
import time
from functools import partial

if sys.version_info >= (3,):
    from gi.repository import GLib

from dbus.mainloop.glib import DBusGMainLoop


class AudioLogic(object):
    _conn = None
    
    def __init__(self):
        DBusGMainLoop(set_as_default=True)
        
        self.pacore = None
        self.nulldevice = None
        self.nulldevice = open(os.devnull, 'w')        
        
        AudioLogic._conn = AudioLogic.connect()
        self.conn = AudioLogic._conn
        
        self.pacore = self.conn.get_object(object_path = "/org/pulseaudio/core1", introspect=False)
        self.pacore.ListenForSignal("", dbus.Array(signature='o'))
        
    def add_signal_receiver(self,*args,**kargs):
        self.conn.add_signal_receiver(*args,**kargs)
    
    @staticmethod    
    def connect():
        if 'PULSE_DBUS_SERVER' in os.environ:
            address = os.environ['PULSE_DBUS_SERVER']
        else:
            bus = dbus.SessionBus()
            server_lookup = bus.get_object("org.PulseAudio1", "/org/pulseaudio/server_lookup1")
            address = server_lookup.Get("org.PulseAudio.ServerLookup1", "Address")
    
        return dbus.connection.Connection(address)
    
    
    def get_playback_streams_index(self):
        """
            get all curent playback_streams
        """
        streams = self.pacore.Get("org.PulseAudio.Core1","PlaybackStreams")
        index = []
        for i in streams:
            tmp = self.conn.get_object("org.PulseAudio.Core1.Stream", i, introspect=False)            
            index.append(tmp.Get("org.PulseAudio.Core1.Stream", "Index"))
        return index


def on_new_card(obj, card):
    card_tmp = obj.conn.get_object("org.PulseAudio.Core1.Card", card, introspect=False)
    cardname = card_tmp.Get("org.PulseAudio.Core1.Card","Name")
    print("New card detected with name", cardname)

    if cardname == "bluez_card.BC_F2_92_57_3D_09":
        subprocess.call(["pacmd", "set-card-profile", cardname, "a2dp_sink"])
        subprocess.call(["pacmd", "set-card-profile", cardname, "headset_head_unit"])
        subprocess.call(["pacmd", "set-card-profile", cardname, "a2dp_sink"])


def on_new_sink(obj, sink):
    """
    On a new sink, if it's the bluetooth one, load module-remap-sink
    """
    sourceindex = obj.get_playback_streams_index()
    sink_tmp = obj.conn.get_object("org.PulseAudio.Core1.Device", sink, introspect=False)
    sinkname = sink_tmp.Get("org.PulseAudio.Core1.Device","Name")

    print("New sink detected with name", sinkname)


    if "remapped" in sinkname:
        return
    
    if sinkname != "bluez_sink.BC_F2_92_57_3D_09.a2dp_sink":
        return
    
    obj.headphones_sink = sink

    if "remapped" not in sinkname:
        print("Remapping to mono")
        subprocess.call(["pacmd", "load-module", "module-remap-sink",
        "master=" + sinkname, "channels=2", "channel_map=mono,mono"])
    for i in sourceindex:
        subprocess.call(["pacmd", "move-sink-input", str(i), sinkname + ".remapped"])
        
def on_removed_sink(obj, sink):
    print("Removed sink", sink)
    if sink == obj.headphones_sink:
        print("Removing module-remap-sink")
        subprocess.call(["pacmd", "unload-module", "module-remap-sink"])


if __name__ == "__main__":
    
    loop = GLib.MainLoop()
    
    al = AudioLogic()
    al.add_signal_receiver(partial(on_new_sink,al), signal_name="NewSink")
    al.add_signal_receiver(partial(on_new_card,al), signal_name="NewCard")
    al.add_signal_receiver(partial(on_removed_sink,al), signal_name="SinkRemoved")
    loop.run()