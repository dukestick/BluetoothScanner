import Foundation

struct BluetoothCharacteristic: Identifiable, Equatable {
    let id: UUID
    var name: String
    var value: Data?
}
