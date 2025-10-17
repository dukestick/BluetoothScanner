import SwiftUI

struct BluetoothScannerView: View {
    @State private var viewModel = BluetoothViewModel(repository: BluetoothRepository())
    
    var body: some View {
        NavigationStack {
            List(viewModel.devices) { device in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(device.name ?? "Unknown Device")
                            .font(.headline)
                        Spacer()
                        Text(device.isConnected ? "Connected" : "Not connected")
                            .font(.caption)
                            .foregroundColor(device.isConnected ? .green : .red)
                    }
                    Text("RSSI: \(device.rssi)")
                        .font(.subheadline)
                }
                .padding(.vertical, 4)
                .background(
                    NavigationLink(
                        destination: DeviceDetailView(
                            viewModel: DeviceDetailViewModel(
                                device: device,
                                repository: viewModel.repository
                            )
                        ),
                        label: { EmptyView() }
                    )
                    .hidden()
                )
            }
            .navigationTitle("BLE Devices")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Scan") {
                        viewModel.startScanning()
                    }
                }
            }
        }
    }
}
