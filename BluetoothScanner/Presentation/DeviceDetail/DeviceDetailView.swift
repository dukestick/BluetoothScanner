import SwiftUI

struct DeviceDetailView: View {
    @State var viewModel: DeviceDetailViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text(viewModel.device.name ?? "Device Details")
                    .font(.title2)
                    .bold()
                Spacer()
                Text(viewModel.device.isConnected ? "Connected" : "Not connected")
                    .font(.caption)
                    .foregroundColor(viewModel.device.isConnected ? .green : .red)
            }
            .padding(.horizontal)
            
            List(viewModel.characteristics) { characteristic in
                HStack {
                    Text(characteristic.name)
                    Spacer()
                    Text(characteristic.value?.hexString ?? "N/A")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .onTapGesture {
                    viewModel.readCharacteristic(characteristic)
                }
            }
        }
        .navigationTitle(viewModel.device.name ?? "Device Details")
        .onAppear {
            viewModel.connect()
        }
    }
}

extension Data {
    var hexString: String {
        map { String(format: "%02x", $0) }.joined()
    }
}
