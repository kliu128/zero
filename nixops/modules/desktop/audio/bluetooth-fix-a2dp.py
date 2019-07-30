#!/usr/bin/env python3

# Workaround for A2DP with Sony MDR-XB950BT. Without this, only HFP/HSP is
# connected. Probably fixed by
# https://git.kernel.org/pub/scm/bluetooth/bluez.git/commit/?id=477ecca127c529611adbc53f08039cefaf86305d

import dbus
from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib


def device_properties_changed(interface, changed, invalidated, path):
    if 'Connected' in changed:
        if changed['Connected']:
            device_connected(path)
        else:
            device_disconnected(path)


def device_connected(path):
    print("Connected " + path, flush=True)
    device_connect(path)


def device_disconnected(path):
    print("Disconnected " + path, flush=True)


def device_connect(path):
    dev = bus.get_object('org.bluez', path)
    dev.Connect(dbus_interface='org.bluez.Device1')
    # with bad timing, we may need this as well:
    # pacmd set-card-profile bluez_card.10_4F_A8_72_7D_67 a2dp_sink


def main():
    global bus
    DBusGMainLoop(set_as_default=True)
    bus = dbus.SystemBus()

    bus.add_signal_receiver(
        device_properties_changed,
        dbus_interface='org.freedesktop.DBus.Properties',
        signal_name='PropertiesChanged',
        bus_name='org.bluez',
        path='/org/bluez/hci0/dev_10_4F_A8_72_7D_67',
        arg0='org.bluez.Device1',
        path_keyword='path',
    )

    loop = GLib.MainLoop()
    loop.run()


if __name__ == "__main__":
    main()