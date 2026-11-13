//
//  NetworkMonitor.swift
//  Lab5_RPMS_Kiritseva
//
//  Created by Ann Kiritseva on 13.11.2026.
//

import Foundation
import Network

final class NetworkMonitor: ObservableObject {

    @Published private(set) var isConnected = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(
        label: "NetworkMonitor"
    )

    init() {
        monitor.pathUpdateHandler = { [weak self] path in

            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }

        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
