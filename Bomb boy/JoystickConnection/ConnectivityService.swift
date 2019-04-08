//
//  ConnectivityService.swift
//  Bomb boy
//
//  Created by João Paulo de Oliveira Sabino on 08/04/19.
//  Copyright © 2019 Gustavo Portela Chaves. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class ConnectivityService {
    
    static let shared = ConnectivityService()
    
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    
    init() {
        self.peerID = MCPeerID(displayName: UIDevice.current.name)
        self.mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
    }
    
    func sendData(data: Data){
        do {
            try mcSession.send(data, toPeers: mcSession.connectedPeers, with: .reliable)
        } catch{
            print(error)
        }
    }
}
