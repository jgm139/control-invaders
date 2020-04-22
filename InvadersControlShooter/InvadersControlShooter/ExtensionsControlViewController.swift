//
//  ExtensionsControlViewController.swift
//  InvadersControlShooter
//
//  Created by Julia García Martínez on 16/04/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit
import CoreBluetooth

// Implementación de la parte central de iOS
extension ControlViewController: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            case .unknown:
                print("central.state is .unknown")
            case .resetting:
                print("central.state is .resetting")
            case .unsupported:
                print("central.state is .unsupported")
            case .unauthorized:
                print("central.state is .unauthorized")
            case .poweredOff:
                print("central.state is .poweredOff")
            case .poweredOn:
                print("central.state is .poweredOn")
                // Con scanForPeripherals escanemos los periféricos.
                // Especificamos que queremos periféricos con un determinado servicio,
                // en nuestro caso SCREEN_DEVICE_SERVICE_UUID_SHOOT
                self.centralManager?.scanForPeripherals(withServices: [BLE.SCREEN_DEVICE_SERVICE_UUID_SHOOT])
            default:
                break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // Obtenemos el nombre del periférico que coincide con el servicio buscado
        if let advertisementPackageName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            // Si coincide con el servicio:
            // - seleccionamos el periférico
            // - paramos el escaneo de periféricos
            // - asignamos la clase delegada
            // - nos conectamos a él para obtener información
            if advertisementPackageName == BLE.nameScreenDevicePeripherical {
                self.selectedPeripheral = peripheral
                self.centralManager?.stopScan()
                self.selectedPeripheral.delegate = self
                self.centralManager?.connect(selectedPeripheral)
                
                print("Central: paramos de escanear periféricos y conectamos con: " + advertisementPackageName)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Central: hemos conectado con el periférico: " + peripheral.name!)
        
        // Aunque en la petición del periférico hemos especificado el tipo de servicio,
        // es necesario descubrir el servicio para usarlo
        self.selectedPeripheral.discoverServices([BLE.SCREEN_DEVICE_SERVICE_UUID_SHOOT])
    }

}

extension ControlViewController: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            print("Central: hemos encontrado un servicio con UUID: " + service.uuid.uuidString)
            
            if service.uuid == BLE.SCREEN_DEVICE_SERVICE_UUID_SHOOT {
                peripheral.discoverCharacteristics([BLE.SCREEN_DEVICE_CHARACTERISTIC_UUID_SHOOT], for: service)
                
                print("Central: hemos encontrado el servicio y procedemos a descubrir características")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print("Central: hemos encontrado la característica con UUID: " + characteristic.uuid.uuidString + " del periférico " + characteristic.service.peripheral.name!)
            
            if characteristic.uuid == BLE.SCREEN_DEVICE_CHARACTERISTIC_UUID_SHOOT {
                // La característica notificará que hay una actualización de los valores
                if characteristic.properties.contains(.writeWithoutResponse) {
                    print("Central: hemos encontrado la característica SHOOT")
                    self.peripheral = peripheral
                    self.characteristicShoot = characteristic
                }
            }
        }
    }
}

// Implementación de la parte periférica de iOS
// Servicio con características X e Y
extension ControlViewController: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        // Si tenemos activado el bluetooth, añadimos los servicios y
        // características a la parte periférica de la app
        if peripheral.state == .poweredOn {
            if self.peripheralManager.isAdvertising {
                self.peripheralManager.stopAdvertising()
            }
            
            // Creamos el servicio y las características
            //let pX = "\(self.position.x)".data(using: .utf8)
            //let pY = "\(self.position.y)".data(using: .utf8)
            
            self.myService = CBMutableService(type: BLE.CONTROL_SHOOTER_SERVICE_UUID_XY, primary: true)
            self.myCharacteristicX = CBMutableCharacteristic(type: BLE.CONTROL_SHOOTER_CHARACTERISTIC_UUID_X, properties: BLE.CONTROL_SHOOTER_CHARACTERISTIC_PROPERTIES, value: nil, permissions: BLE.CONTROL_SHOOTER_CHARACTERISTIC_PERMISSIONS)
            self.myCharacteristicY = CBMutableCharacteristic(type: BLE.CONTROL_SHOOTER_CHARACTERISTIC_UUID_Y, properties: BLE.CONTROL_SHOOTER_CHARACTERISTIC_PROPERTIES, value: nil, permissions: BLE.CONTROL_SHOOTER_CHARACTERISTIC_PERMISSIONS)
            
            self.myService!.characteristics = [self.myCharacteristicX!, self.myCharacteristicY!]
            
            // Añadimos el servicio al periférico local
            self.peripheralManager.add(self.myService!)
            
            print("Periférico local: inicializamos árbol de servicios y características")
            
            // Iniciamos el advertising
            self.peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [BLE.CONTROL_SHOOTER_SERVICE_UUID_XY], CBAdvertisementDataLocalNameKey: BLE.nameControlShooterDevicePeripherical])
            
            print("Periférico local: empezamos a publicitarnos con el nombre de: " + BLE.nameControlShooterDevicePeripherical)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let e = error {
            print("Periférico local: error al publicar un servicio: " + e.localizedDescription)
        }
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let e = error {
            print("Periférico local: error al publicitar un servicio: " + e.localizedDescription)
        }
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        if !self.checkUpdateX {
            peripheral.updateValue("\(self.position.x)".data(using: .utf8)!, for: myCharacteristicX!, onSubscribedCentrals: nil)
            self.checkUpdateX = true
        }
        
        if !self.checkUpdateY {
            peripheral.updateValue("\(self.position.y)".data(using: .utf8)!, for: myCharacteristicY!, onSubscribedCentrals: nil)
            self.checkUpdateY = true
        }
    }
}
