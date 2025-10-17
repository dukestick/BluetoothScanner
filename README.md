# BLE Scanner App

Simple iOS app to scan, connect, and read characteristics from BLE devices using Core Bluetooth and SwiftUI.

## Requirements
- Xcode 15+
- iOS 16+ device with BLE support
- Developer Mode enabled on the iPhone

## Setup
1. Clone or download the repository.
2. Open `BluetoothScanner.xcodeproj` in Xcode.
3. Ensure **Info.plist** includes:
   - `NSBluetoothAlwaysUsageDescription`
   - `NSBluetoothPeripheralUsageDescription`
4. Build and run on your iPhone.
5. Grant Bluetooth permissions when prompted.

## Usage
- Tap **Scan** to discover devices.
- Tap a device to view its characteristics.
- Tap a characteristic to read its value.
- Connection status is shown in green/red.
