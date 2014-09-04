# Moodle deployment scripts and notes

## Notes
Open Nebula Ubuntu 14.04 marketplace VMs seem to boot without an IP address for the loop back device.

MySQL will fail to install or start if lo does not have IP 127.0.0.1

Running `ip addr add 127.0.0.1 dev lo` will assign the IP until next boot.

I need a permanent solution.
