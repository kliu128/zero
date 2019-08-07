#! /usr/bin/env nix-shell
#! nix-shell -i python3 -p python3 dvdisaster p7zip ddrescue vlc

import os
import sys
import subprocess


def rip_dvd(name):
    iso_filename = f"{name}.iso"
    archive_filename = f"{name}.7z"
    subprocess.run([
        "dvdisaster",
        "--read",
        "--image", iso_filename], check=True)
    subprocess.run(["7z", "a", archive_filename, iso_filename], check=True)
    os.remove(iso_filename)

def rip_floppy(name):
    img_filename = f"{name}.img"
    log_filename = f"{name}.log"
    subprocess.run(["ddrescue", "-d", "-b512", img_filename, log_filename], check=True)

def rip_vcd(name):
    filename = f"{name}.mpeg"
    subprocess.run(["cvlc", "vcd:///dev/sr0", "--sout", f"#std{{access=file,mux=raw,dst={filename}}}", "vlc://quit"], check=True)

actions = {
    "dvd": rip_dvd,
    "floppy": rip_floppy,
    "vcd": rip_vcd
}

def print_help():
    print("Syntax:", sys.argv[0], "<" + "|".join(actions.keys()) + ">", file=sys.stderr)
    sys.exit(1)


if len(sys.argv) < 2:
    print_help()
    sys.exit(1)

action = sys.argv[1]
if not action in actions:
    print("Invalid action.", file=sys.stderr)
    print_help()
    sys.exit(1)

os.nice(20) # Be nice to the system while ripping
print("OMNIRIPPER v0")
while True:
    name = input("Rip name: ")
    actions[action](name)
    print("=== RIP COMPLETED ===")