# Wrote ~/Code/ShelfSight/src/TODO-SCANNER.md
# Scanner Auto-Detection & Settings Tab - TODO

## Goal
Auto-detect connected barcode scanner type, use appropriate driver, allow manual override in "Scanning" settings tab.

## Scanner Types to Support

| Type | Interface | Detection Method | Driver |
|------|-----------|------------------|--------|
| **1. Keyboard Emulation (HID Keyboard)** | USB HID (Boot Keyboard) | `QHidDevice` usage page 0x01, usage 0x06 | Current `ISBNScannerDialog::keyPressEvent()` |
| **2. USB Serial (CDC/ACM)** | USB CDC-ACM | `QSerialPortInfo` - vendor/product ID matches known scanners | `QSerialPort` + parser |
| **3. USB HID POS (Barcode Scanner)** | USB HID (Usage Page 0x0D) | `QHidDevice` usage page 0x0D | `QHidDevice` + report parsing |
| **4. Bluetooth SPP** | Bluetooth Classic SPP | `QBluetoothDeviceDiscoveryAgent` + service UUID | `QBluetoothSocket` (RFCOMM) |
| **5. Bluetooth BLE/GATT** | Bluetooth LE | `QLowEnergyController` + service/characteristic UUIDs | `QLowEnergyController` + notifications |

---

## Auto-Detection Strategy

### Phase 1: Enumeration (on app start / "Scan for Devices" button)
```cpp
// 1. Enumerate HID devices → check usage page
//    - 0x01/0x06 → Keyboard emulation
//    - 0x0D → HID POS (barcode scanner)

// 2. Enumerate serial ports → match VID/PID against known scanner database
//    - Honeywell: 0x0C2E, 0x0E8F
//    - Zebra: 0x05E0, 0x067B
//    - Datalogic: 0x05F9, 0x0A3A
//    - Generic: 0x1D65, 0x1D66, etc.

// 3. Scan Bluetooth Classic → SPP service (00001101-0000-1000-8000-00805F9B34FB)

// 4. Scan BLE → known barcode service UUIDs
//    - Honeywell: 0000181C-0000-1000-8000-00805F9B34FB
//    - Custom manufacturer services
```

### Phase 2: Capability Test
```cpp
// For each candidate device:
// 1. Open connection
// 2. Send trigger command (if supported) or wait for data
// 3. Verify barcode-like data received (EAN13/UPCA/Code128 pattern)
// 4. Score confidence → select highest
```

### Phase 3: Persistent Selection
- Save selected device (type + VID/PID + serial/port/MAC) to `DatabaseConfigs.ini` → `[Scanner]` section
- On restart, try saved device first, fallback to auto-detect

---

## "Scanning" Settings Tab - UI Design

### Tab Location
`Preferences` → new `Scanning` tab (next to `Worklog`, `Telemetry`)

### Form Fields

| Field | Type | Description |
|-------|------|-------------|
| **Scanner Type** | ComboBox | Auto / Keyboard / USB Serial / USB HID POS / Bluetooth SPP / Bluetooth BLE |
| **Device** | ComboBox | Populated based on selected type (auto-refresh) |
| **VID / PID** | LineEdits (read-only) | Show selected device IDs |
| **Serial Port** | ComboBox | For USB Serial type (auto-populated from `QSerialPortInfo`) |
| **Bluetooth MAC** | LineEdit | For BT types (read-only after pairing) |
| **Baud Rate** | ComboBox | 9600/19200/38400/57600/115200 (default 9600) |
| **Data Bits / Parity / Stop** | ComboBoxes | Serial config |
| **Trigger Mode** | ComboBox | Continuous / Trigger / Presentation / Host |
| **Terminator** | ComboBox | CR / LF / CRLF / Tab / None |
| **Prefix / Suffix** | LineEdits | Optional string prepend/append |
| **Test Scan** | Button + TextArea | Live preview of scanned data |
| **Auto-Connect** | CheckBox | Connect on app start |

### Settings Persistence
```ini
[Scanner]
type=auto                    # auto/keyboard/serial/hidpos/bt_spp/bt_ble
vid=0x0C2E
pid=0x0B01
serial_port=COM3             # or /dev/ttyACM0
baud_rate=9600
data_bits=8
parity=none
stop_bits=1
terminator=cr
prefix=
suffix=
auto_connect=true
bluetooth_mac=00:11:22:33:44:55
```

---

## Implementation Classes

### 1. `ScannerDetector` (singleton/service)
```cpp
class ScannerDetector : public QObject {
    Q_OBJECT
public:
    enum Type { Auto, Keyboard, Serial, HidPos, BtSpp, BtBle };
    
    struct DeviceInfo {
        Type type;
        QString name;
        QString vid, pid;
        QString serialNumber;
        QString port;        // COM3, /dev/ttyACM0
        QString macAddress;  // for Bluetooth
        QString manufacturer;
    };
    
    QVector<DeviceInfo> scanAll();
    DeviceInfo autoSelect();
    bool testDevice(const DeviceInfo&, QString& testOutput);
    
signals:
    void scanCompleted(QVector<DeviceInfo>);
    void deviceConnected(DeviceInfo);
    void deviceDisconnected(DeviceInfo);
};
```

### 2. `ScannerInterface` (abstract base)
```cpp
class ScannerInterface : public QObject {
    Q_OBJECT
public:
    virtual bool open() = 0;
    virtual void close() = 0;
    virtual bool isOpen() const = 0;
    
signals:
    void barcodeScanned(QString isbn);  // clean ISBN-10/13
    void rawDataReceived(QString raw);  // for debugging
    void errorOccurred(QString msg);
};
```

### 3. Concrete implementations
- `KeyboardScanner` - wraps existing `ISBNScannerDialog` logic
- `SerialScanner` - `QSerialPort` + line buffering
- `HidPosScanner` - `QHidDevice` + report parsing
- `BtSppScanner` - `QBluetoothSocket` (RFCOMM)
- `BtBleScanner` - `QLowEnergyController` + notifications

### 4. `ScannerManager` (orchestrator)
```cpp
class ScannerManager : public QObject {
    Q_OBJECT
public:
    void setScannerType(ScannerDetector::Type);
    void setDevice(const ScannerDetector::DeviceInfo&);
    bool start();
    void stop();
    ScannerInterface* currentScanner() const;
    
signals:
    void isbnScanned(QString isbn);
    void statusChanged(QString);
    void error(QString);
};
```

---

## Integration with ISBNScannerDialog

### Modified `showISBNScanner()`:
```cpp
void MainWindow::showISBNScanner(QLineEdit* targetField) {
    if (m_scannerManager->isRunning()) {
        // Use active scanner - show minimal dialog with "Waiting for scan..."
        showActiveScannerDialog(targetField);
    } else {
        // Show full dialog with manual entry + camera + "Start Scanner" button
        ISBNScannerDialog dialog(this);
        // ... existing logic
    }
}
```

### New: Active Scanner Indicator
- Status bar icon: 🟢 Connected / 🟡 Connecting / 🔴 Disconnected
- Tooltip: "Honeywell Xenon 1900 (COM3) - Ready"
- Click → opens Scanning settings tab

---

## Dependencies

| Module | Qt Class | Required Qt Version |
|--------|----------|---------------------|
| HID | `QHidDevice`, `QHidDeviceInfo` | Qt 6.5+ |
| Serial | `QSerialPort`, `QSerialPortInfo` | Qt 5.1+ |
| Bluetooth Classic | `QBluetoothSocket`, `QBluetoothDeviceDiscoveryAgent` | Qt 5.2+ |
| Bluetooth LE | `QLowEnergyController`, `QLowEnergyService` | Qt 5.7+ |

**CMake:** `find_package(Qt6 REQUIRED COMPONENTS SerialPort Bluetooth)`  
**qmake:** `QT += serialport bluetooth`

---

## VID/PID Database (Starter)

```cpp
static const struct { uint16_t vid; uint16_t pid; const char* name; } knownScanners[] = {
    {0x0C2E, 0x0B01, "Honeywell Xenon 1900"},
    {0x0C2E, 0x0B02, "Honeywell Voyager 1400g"},
    {0x05E0, 0x067B, "Zebra DS2208"},
    {0x05E0, 0x1200, "Zebra LI4278"},
    {0x05F9, 0x0A3A, "Datalogic Gryphon"},
    {0x05F9, 0x3333, "Datalogic QuickScan"},
    {0x1D65, 0x1D66, "Generic USB Barcode"},
    {0x04D9, 0x0001, "Holtek USB Scanner"},
    {0x04E6, 0x0001, "SCM Microsystems"},
};
```

---

## Test Plan

1. **Keyboard emulation** - Any USB scanner in keyboard mode
2. **USB Serial** - Honeywell Xenon 1900 in USB-CDC mode
3. **USB HID POS** - Zebra DS2208 in HID POS mode
4. **Bluetooth SPP** - Zebra LI4278 paired via SPP
5. **Bluetooth BLE** - SocketScan S700 / SocketScan S800

---

## Priority Order

1. **Keyboard** (already works) + **USB Serial** (most common in libraries)
2. **USB HID POS** (industrial standard)
3. **Bluetooth SPP** (legacy wireless)
4. **Bluetooth BLE** (modern wireless)
5. **Auto-detection UI** + **Scanning settings tab**

---

## Notes

- Camera scanning (ZXing) remains separate - works alongside any hardware scanner
- Worklog integration: log `scanner_type` + `device_id` with each scan
- On Windows: prefer `SetupDiGetClassDevs` for more reliable device enumeration
- On Linux: `udev` rules may be needed for non-root serial/HID access
