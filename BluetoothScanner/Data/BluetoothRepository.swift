import Foundation
import CoreBluetooth

final class BluetoothRepository: NSObject, BluetoothRepositoryProtocol {
    
    var onDevicesUpdated: (([BluetoothDevice]) -> Void)?
    var onCharacteristicRead: ((UUID, UUID, Data?) -> Void)?
    
    private var centralManager: CBCentralManager!
    private var peripheralMap: [UUID: CBPeripheral] = [:]
    
    private var characteristicReadRequests: [CBPeripheral: CBCharacteristic] = [:]
    
    private var rssiMap: [UUID: Int] = [:]
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        guard centralManager.state == .poweredOn else { return }
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func stopScanning() {
        centralManager.stopScan()
    }
    
    func connect(to device: BluetoothDevice) {
        guard let peripheral = peripheralMap[device.id] else { return }
        peripheral.delegate = self
        centralManager.connect(peripheral)
    }
    
    func disconnect(from device: BluetoothDevice) {
        guard let peripheral = peripheralMap[device.id] else { return }
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    func readCharacteristic(_ characteristic: BluetoothCharacteristic) {
        guard let peripheral = peripheralMap[characteristic.id] else { return }
        peripheral.delegate = self
        
        if let cbChar = peripheral.services?.flatMap({ $0.characteristics ?? [] })
            .first(where: { $0.uuid == CBUUID(nsuuid: characteristic.id) }) {
            characteristicReadRequests[peripheral] = cbChar
            peripheral.readValue(for: cbChar)
        }
    }
}

extension BluetoothRepository: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        } else {
            print("Bluetooth is not powered on.")
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        
        peripheralMap[peripheral.identifier] = peripheral
        rssiMap[peripheral.identifier] = RSSI.intValue
        
        updateDevicesList()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "Unknown")")
        updateConnectionStatus(peripheral, isConnected: true)
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral.name ?? "Unknown"):", error ?? "unknown error")
        updateConnectionStatus(peripheral, isConnected: false)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from \(peripheral.name ?? "Unknown")")
        updateConnectionStatus(peripheral, isConnected: false)
    }
}

extension BluetoothRepository: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Failed to discover services:", error)
            return
        }
        
        peripheral.services?.forEach { service in
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        if let error = error {
            print("Failed to discover characteristics:", error)
            return
        }
        
        var allCharacteristics: [BluetoothCharacteristic] = []
        peripheral.services?.forEach { svc in
            if let chars = svc.characteristics {
                allCharacteristics += chars.map {
                    BluetoothCharacteristic(
                        id: $0.uuid.asUUID,
                        name: $0.uuid.uuidString,
                        value: $0.value
                    )
                }
            }
        }
        
        updateDevicesList()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Failed to read characteristic:", error)
            onCharacteristicRead?(peripheral.identifier, characteristic.uuid.asUUID, nil)
        } else {
            onCharacteristicRead?(peripheral.identifier, characteristic.uuid.asUUID, characteristic.value)
        }
        characteristicReadRequests.removeValue(forKey: peripheral)
    }
}

private extension BluetoothRepository {
    
    func updateDevicesList() {
        let devices = peripheralMap.values.map { p in
            BluetoothDevice(
                id: p.identifier,
                name: p.name,
                rssi: rssiMap[p.identifier] ?? 0,
                characteristics: p.services?.flatMap { $0.characteristics?.map {
                    BluetoothCharacteristic(
                        id: $0.uuid.asUUID,
                        name: $0.uuid.uuidString,
                        value: $0.value
                    )
                } ?? [] } ?? [], isConnected: p.state == .connected
            )
        }
        onDevicesUpdated?(devices)
    }
    
    func updateConnectionStatus(_ peripheral: CBPeripheral, isConnected: Bool) {
        updateDevicesList()
    }
}

private extension CBUUID {
    var asUUID: UUID {
        UUID(uuidString: self.uuidString) ?? UUID()
    }
}
