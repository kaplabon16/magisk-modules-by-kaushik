# Authentic Dynamic Refresh Rate

## Description
This module dynamically adjusts refresh rate based on device usage.

## Behavior
- Idle → Lower refresh rate (30)
- Scrolling → Higher refresh rate (120)
- Video apps → Stable refresh behavior (60-90)
- Foreground apps → Adaptive switching

## What you should notice
- Screen drops refresh when idle
- Smooth increase when scrolling
- More consistent refresh behavior across apps
- Slight battery improvement during inactive use

## How to verify

Check logs:

Go to developers option and select 'Show/View Refresh Rate'
