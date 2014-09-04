# Moodle deployment

This work aims to capture and document all of the software requirements for the Moodle server hosted by the Saint Mary's Mathematics and Computing Science department.

## Notes
OpenNebula Ubuntu 14.04 marketplace VMs seem to boot without an IP address for the loop back device.

MySQL will fail to install or start if lo does not have IP 127.0.0.1

Running `ip addr add 127.0.0.1 dev lo` will assign the IP until next boot.

I need a permanent solution.
