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
