This module adjusts window animations and transition times dynamically based on the current refresh rate:
- 120 Hz: Faster animations (0.65x to 0.764x speed).
- 60 Hz: Medium animations (0.80x to 0.85x speed).
- 30 Hz: Slower animations (1.0x speed).

It ensures that window transitions and animations feel fluid and match the refresh rate of the device.
This module does not modify the refresh rate itself.

Adjustments and logs can be found in:
- Log: /data/adb/dynamic_animations/module.log

This module works dynamically based on refresh rate changes.