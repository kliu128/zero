#!/usr/bin/env bash
# This script dynamically manages allocated hugepages size depending on running libvirt VMs.
# Based on Thomas Lindroth's shell script which sets up host for VM: http://sprunge.us/JUfS
# put this script to /etc/libvirt/hooks/qemu

TOTAL_CORES='0-7'
TOTAL_CORES_MASK=FF            # 0-11, bitmask 0b111111111111
HOST_CORES='4-7'            # Cores reserved for host
HOST_CORES_MASK=F              # 0-1,6-7, bitmask 0b000011000011
VIRT_CORES='0-3'           # Cores reserved for virtual machine(s)

HUGEPAGES_SIZE=$(grep Hugepagesize /proc/meminfo | awk {'print $2'})
HUGEPAGES_SIZE=$((HUGEPAGES_SIZE * 1024))
HUGEPAGES_ALLOCATED=$(sysctl vm.nr_hugepages | awk {'print $3'})

VM_NAME=$1
VM_ACTION=$2

shield_vm() {
    cset set -c $TOTAL_CORES -s machine.slice
    # Shield two cores cores for host and rest for VM(s)
    cset shield --kthread on --cpu $VIRT_CORES
}

unshield_vm() {
    echo $TOTAL_CORES_MASK > /sys/bus/workqueue/devices/writeback/cpumask
    cset shield --reset
}

# For manual invocation
if [[ $VM_NAME == 'shield' ]];
then
    shield_vm
    exit 0
elif [[ $VM_NAME == 'unshield' ]];
then
    unshield_vm
    exit 0
fi

cd $(dirname "$0")
# VM_HUGEPAGES_NEED=$(( $(./vm-mem-requirements $VM_NAME) / HUGEPAGES_SIZE ))

logger Starting with $@

if [[ $VM_ACTION == 'prepare' ]];
then
    sync
    echo 3 > /proc/sys/vm/drop_caches
    echo 1 > /proc/sys/vm/compact_memory

    # VM_HUGEPAGES_TOTAL=$(($HUGEPAGES_ALLOCATED + $VM_HUGEPAGES_NEED))
    # sysctl vm.nr_hugepages=$VM_HUGEPAGES_TOTAL

    # if [[ $HUGEPAGES_ALLOCATED == '0' ]];
    # then
        shield_vm
        # Reduce VM jitter: https://www.kernel.org/doc/Documentation/kernel-per-CPU-kthreads.txt
        sysctl vm.stat_interval=120

        sysctl -w kernel.watchdog=0
        # the kernel's dirty page writeback mechanism uses kthread workers. They introduce
        # massive arbitrary latencies when doing disk writes on the host and aren't
        # migrated by cset. Restrict the workqueue to use only cpu 0.
        echo $HOST_CORES_MASK > /sys/bus/workqueue/devices/writeback/cpumask
        # THP can allegedly result in jitter. Better keep it off.
        echo never > /sys/kernel/mm/transparent_hugepage/enabled
        # Force P-states to P0
        echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
        echo 0 > /sys/bus/workqueue/devices/writeback/numa
        >&2 echo "VMs Shielded"
    # fi
fi

if [[ $VM_ACTION == 'release' ]];
then
    # VM_HUGEPAGES_TOTAL=$(($HUGEPAGES_ALLOCATED - $VM_HUGEPAGES_NEED))
    # VM_HUGEPAGES_TOTAL=$(($VM_HUGEPAGES_TOTAL<0?0:$VM_HUGEPAGES_TOTAL))
    # sysctl vm.nr_hugepages=$VM_HUGEPAGES_TOTAL

    # if [[ $VM_HUGEPAGES_TOTAL == '0' ]];
    # then
        # All VMs offline
        sysctl vm.stat_interval=1
        sysctl -w kernel.watchdog=1
        unshield_vm
        echo always > /sys/kernel/mm/transparent_hugepage/enabled
        echo powersave | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
        echo 1 > /sys/bus/workqueue/devices/writeback/numa
        >&2 echo "VMs UnShielded"
    # fi
fi