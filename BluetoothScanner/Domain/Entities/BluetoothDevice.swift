import Foundation

struct BluetoothDevice: Identifiable, Equatable {
    let id: UUID
    var name: String?
    var rssi: Int
    var characteristics: [BluetoothCharacteristic] = []
    var isConnected: Bool = false
}
