//
//  AuthViewModel.swift
//  minimemo
//
//  Created by 鶴田臨 on 2025/04/06.
//

import Foundation
import Combine
import SwiftUI

protocol AuthPersistenceProtocol {
    func saveGoogleAuthToken(_ token: String?)
    func loadGoogleAuthToken() -> String?
}

class AuthViewModel: ObservableObject {
    @Published var isAuthenticatedWithGoogle: Bool = false
    
    private let persistenceService: PersistenceService
    
    init(persistenceService: PersistenceService = PersistenceService()) {
        self.persistenceService = persistenceService
        self.isAuthenticatedWithGoogle = persistenceService.loadGoogleAuthToken() != nil
    }
    
    func disconnectGoogleAccount() {
        print("Googleアカウント連携を解除します。")
        persistenceService.saveGoogleAuthToken(nil)
        isAuthenticatedWithGoogle = false
        print("Googleアカウント連携を解除しました。")
    }
}
