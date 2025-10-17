import Foundation
import SwiftUI

@Observable
final class BluetoothViewModel {
    var devices: [BluetoothDevice] = []
    var selectedDevice: BluetoothDevice?
    var selectedDeviceCharacteristics: [BluetoothCharacteristic] = []
    
    let repository: BluetoothRepositoryProtocol
    
    init(repository: BluetoothRepositoryProtocol) {
        self.repository = repository
        
        repository.onDevicesUpdated = { [weak self] devices in
            DispatchQueue.main.async {
                self?.devices = devices
            }
        }
        
        repository.onCharacteristicRead = { [weak self] deviceId, characteristicId, value in
            DispatchQueue.main.async {
                if let device = self?.devices.first(where: { $0.id == deviceId }) {
                    let characteristic = BluetoothCharacteristic(id: characteristicId, name: characteristicId.uuidString, value: value)
                    self?.selectedDeviceCharacteristics = [characteristic]
                }
            }
        }
    }
    
    func startScanning() {
        repository.startScanning()
    }
    
    func stopScanning() {
        repository.stopScanning()
    }
    
    func connectToDevice(_ device: BluetoothDevice) {
        selectedDevice = device
    }
    
    func readCharacteristic(_ characteristic: BluetoothCharacteristic) {
        repository.readCharacteristic(characteristic)
    }
}
