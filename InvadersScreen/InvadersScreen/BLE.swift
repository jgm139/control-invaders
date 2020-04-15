//
//  Constants.swift
//  InvadersScreen
//
//  Created by Julia García Martínez on 14/04/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import Foundation
import CoreBluetooth

struct BLE {
    
    // Control Shooter constants
    public static let CONTROL_SHOOTER_SERVICE_UUID_XY = CBUUID(string: "0BE27C50-8BD0-40A5-AC61-88DC52CE9C64")
    
    public static let CONTROL_SHOOTER_CHARACTERISTIC_UUID_X = CBUUID(string:"C1B89437-74B3-4DA7-9780-9EDAC73CD146")
    public static let CONTROL_SHOOTER_CHARACTERISTIC_UUID_Y = CBUUID(string:"08D12BDA-CAE0-424B-B9F6-478C13CC400B")
    
    public static let CONTROL_SHOOTER_CHARACTERISTIC_PROPERTIES: CBCharacteristicProperties = .read
    public static let CONTROL_SHOOTER_CHARACTERISTIC_PERMISSIONS: CBAttributePermissions = .readable
    
    // Screen Device constants
    public static let SCREEN_DEVICE_SERVICE_UUID_SHOOT = CBUUID(string: "5DA21B79-CA3E-4398-A470-4565E6D02A61")
    
    public static let SCREEN_DEVICE_CHARACTERISTIC_UUID_SHOOT = CBUUID(string: "8113F397-0840-4BDB-B9C6-DFD6BE7A7172")
    
    public static let SCREEN_DEVICE_CHARACTERISTIC_PROPERTIES_SHOOT: CBCharacteristicProperties = .writeWithoutResponse
    public static let SCREEN_DEVICE_CHARACTERISTIC_PERMISSIONS_SHOOT: CBAttributePermissions = .writeable
    
    public static let nameScreenDevicePeripherical = "Soy ScreenDevice"
    public static let nameControlShooterDevicePeripherical = "Soy ControlShooter"
    
}
