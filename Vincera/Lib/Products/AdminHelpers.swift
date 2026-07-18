//
//  AdminHelpers.swift
//  Vincera
//
//  Created by Matt Linder on 4/18/26.
//

import Foundation

private let ADMIN_KEY = "com.mattlinder.vincera.admin.status"

func grantAdminStatus() {
    UserDefaults.standard.set(true, forKey: ADMIN_KEY)
}

func revokeAdminStatus() {
    UserDefaults.standard.set(false, forKey: ADMIN_KEY)
}

func hasAdminStatus() -> Bool {
    UserDefaults.standard.bool(forKey: ADMIN_KEY)
}

private struct AdminResponse: Decodable {
    let success: Bool
}

func tryGrantAdminStatus(with token: String) async {
    let client = HttpClient(
        baseUrl: "https://vinceratraining.com/api",
        headers: ["Content-Type": "application/json"]
    )
    
    if let result = try? await client.request(
        "/admin",
        method: .post,
        body: ["token": token]
    ), let decoded = try? JSONDecoder().decode(AdminResponse.self, from: result.0),
    decoded.success {
        grantAdminStatus()
    }
}
