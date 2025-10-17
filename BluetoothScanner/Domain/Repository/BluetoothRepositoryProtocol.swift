import Foundation

protocol BluetoothRepositoryProtocol: AnyObject {
    var onDevicesUpdated: (([BluetoothDevice]) -> Void)? { get set }
    var onCharacteristicRead: ((UUID, UUID, Data?) -> Void)? { get set } 
    
    func startScanning()
    func stopScanning()
    func readCharacteristic(_ characteristic: BluetoothCharacteristic)
    
    func connect(to device: BluetoothDevice)
    func disconnect(from device: BluetoothDevice)
}
