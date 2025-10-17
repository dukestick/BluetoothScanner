import Foundation
import SwiftUI

@Observable
final class DeviceDetailViewModel {
    var device: BluetoothDevice
    
    private var characteristicsDict: [UUID: BluetoothCharacteristic] = [:]
    
    var characteristics: [BluetoothCharacteristic] {
        Array(characteristicsDict.values)
    }
    
    private let repository: BluetoothRepositoryProtocol
    
    init(device: BluetoothDevice, repository: BluetoothRepositoryProtocol) {
        self.device = device
        self.repository = repository
        
        repository.onDevicesUpdated = { [weak self] devices in
            guard let self = self else { return }
            if let updatedDevice = devices.first(where: { $0.id == self.device.id }) {
                DispatchQueue.main.async {
                    updatedDevice.characteristics.forEach { char in
                        self.characteristicsDict[char.id] = char
                    }
                }
            }
        }
        
        repository.onCharacteristicRead = { [weak self] deviceId, characteristicId, value in
            guard let self = self, deviceId == self.device.id else { return }
            DispatchQueue.main.async {
                if var existingChar = self.characteristicsDict[characteristicId] {
                    existingChar.value = value
                    self.characteristicsDict[characteristicId] = existingChar
                } else {
                    let newChar = BluetoothCharacteristic(id: characteristicId, name: characteristicId.uuidString, value: value)
                    self.characteristicsDict[characteristicId] = newChar
                }
            }
        }
    }
    
    func connect() {
        repository.connect(to: device)
    }
    
    func readCharacteristic(_ characteristic: BluetoothCharacteristic) {
        repository.readCharacteristic(characteristic)
    }
}
