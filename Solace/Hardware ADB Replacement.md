# Assured Delivery Blade (Hardware) Replacement

Refer to https://docs.solace.com/Appliance/Hardware-Maintenance-Tasks/Replacing-ADBs.htm for more details.

This page summarizes the key items to do for ADB replacement. Please refer to the above page for complete information.

# Steps

1. Upgrade software if required
2. Backup current configuration `copy current-config ...`
3. ensure RAID disk are in redundant state `show disk`
    - stop ADB replacement if not in redundant state
4. Check if broker is active
    - `show message-spool`
	- `show routing`
5. Shutdown routing `enable` > `configure` > `routing` > `shutdown`
6. Shutdown messaging services `enable` > `configure` > `service msg-backbone` > `shutdown`
    - Wait until all transacted sessions timeout and the count drops to 0 (max 3 minutes) `show message-spool detail`
7. Shutdown messasge spool `enable` > `configure` > `hardware message-spool` > `shutdown`
    - Check `show message-spool`
8. Backup ADB configuration and spooled messages `enable` > `admin` > `system` > `message-spool` > backup-adb-to-disk` > `y`
    - Ensure no messages spooled on ADB `show message-spool`
9. Power down `power-down`
10. Hardware Replacement - refer to https://docs.solace.com/Appliance/Hardware-Maintenance-Tasks/Physically-Replacing-Bla-1.htm
    - Unplug all cables
	- Remove cover (2 screws + 2 latches)
	- Unscrew ADB bracket screw at the back (2 screws)
	- Slide lever to release ADB box
	- Open ADB box cover (1 screw)
	- Use ADB removal tool (should be seated beside ADB box in appliance)
	- Replace ADB card - ensure alignment and firmly seated within slot
	- Close ADB box cover - ensure alignment (1 screw)
	- Replace ADB box - ensure lever is full extended
	- Tighten 2 screws at the back
	- Replace cover (2 screws + 2 latches)
	- Power up appliance
11. Wait for **15 mintues** for ADB to be fully charged
    - `show hardware detail`
12. Start message spool `enable` > `configure` > `hardware message-spool` > `no shutdown primary`
13. Start messaging services `enable` > `configure` > `service msg-back` > `no shutdown`
14. Start routing ``enable` > `configure` > `routing` > `no shutdown`
15. Check appliance health (redundancy, message spool, messsaging backbone, services, etc)
	