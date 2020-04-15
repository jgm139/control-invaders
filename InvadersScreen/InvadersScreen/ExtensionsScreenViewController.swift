//
//  ExtensionsScreenViewController.swift
//  InvadersScreen
//
//  Created by Julia García Martínez on 14/04/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import Cocoa
import CoreBluetooth

// Implementación de la parte central de macOS
extension ScreenViewController: CBCentralManagerDelegate {
    
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
                // en nuestro caso CONTROL_SHOOTER_SERVICE_UUID_XY
                self.centralManager?.scanForPeripherals(withServices: [BLE.CONTROL_SHOOTER_SERVICE_UUID_XY])
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
            if advertisementPackageName == BLE.nameControlShooterDevicePeripherical {
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
        self.selectedPeripheral.discoverServices([BLE.CONTROL_SHOOTER_SERVICE_UUID_XY])
    }
}

extension ScreenViewController: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            print("Central: hemos encontrado un servicio con UUID: " + service.uuid.uuidString)
            
            if service.uuid == BLE.CONTROL_SHOOTER_SERVICE_UUID_XY {
                peripheral.discoverCharacteristics([BLE.CONTROL_SHOOTER_CHARACTERISTIC_UUID_X, BLE.CONTROL_SHOOTER_CHARACTERISTIC_UUID_Y], for: service)
                
                print("Central: hemos encontrado el servicio y procedemos a descubrir características")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print("Central: hemos encontrado la característica con UUID: " + characteristic.uuid.uuidString + " del periférico " + characteristic.service.peripheral.name!)
            
            if characteristic.uuid == BLE.CONTROL_SHOOTER_CHARACTERISTIC_UUID_X || characteristic.uuid == BLE.CONTROL_SHOOTER_CHARACTERISTIC_UUID_Y {
                // La característica notificará que hay una actualización de los valores
                if characteristic.properties.contains(.notify) {
                    print("Central: hemos encontrado la característica X o Y")
                    print("Central: Solicitamos lectura de su valor")
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == BLE.CONTROL_SHOOTER_CHARACTERISTIC_UUID_X {
            if let valueX = characteristic.value {
                let stringValue = String(data: valueX, encoding: String.Encoding.utf8) ?? "0.0"
                let intValue = ((Double(stringValue) ?? 0) * Double(self.view.bounds.midY) * (-1.0))+Double(self.view.bounds.midY)
                self.aimImageView.frame.origin = CGPoint(x:Double(self.aimImageView.frame.origin.x) , y: intValue)
            }
        }
        
        if characteristic.uuid == BLE.CONTROL_SHOOTER_CHARACTERISTIC_UUID_Y {
            if let valueY = characteristic.value {
                let stringValue = String(data: valueY, encoding: String.Encoding.utf8) ?? "0.0"
                let intValue = ((Double(stringValue) ?? 0) * Double(self.view.bounds.midX) * (-1.0))+Double(self.view.bounds.midX)
                self.aimImageView.frame.origin = CGPoint(x:intValue , y: Double(self.aimImageView.frame.origin.y))
            }
        }
    }
    
}

// Implementación de la parte periférica del macOS
// Servicio con característica SHOOT
extension ScreenViewController: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        // Si tenemos activado el bluetooth, añadimos los servicios y
        // características a la parte periférica de la app
        if peripheral.state == .poweredOn {
            if self.peripheralManager.isAdvertising {
                self.peripheralManager.stopAdvertising()
            }
            
            // Creamos el servicio y la característica
            let myService = CBMutableService(type: BLE.SCREEN_DEVICE_SERVICE_UUID_SHOOT, primary: true)
            let myCharacteristic = CBMutableCharacteristic(type: BLE.SCREEN_DEVICE_CHARACTERISTIC_UUID_SHOOT, properties: BLE.SCREEN_DEVICE_CHARACTERISTIC_PROPERTIES_SHOOT, value: nil, permissions: BLE.SCREEN_DEVICE_CHARACTERISTIC_PERMISSIONS_SHOOT)
            
            myService.characteristics = [myCharacteristic]
            
            // Añadimos el servicio al periférico local
            self.peripheralManager.add(myService)
            
            print("Periférico local: inicializamos árbol de servicios y características")
            
            // Iniciamos el advertising
            self.peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [BLE.SCREEN_DEVICE_SERVICE_UUID_SHOOT], CBAdvertisementDataLocalNameKey: BLE.nameScreenDevicePeripherical])
            
            print("Periférico local: empezamos a publicitarnos con el nombre de: " + BLE.nameScreenDevicePeripherical)
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
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        print("Periférico local: recibimos disparo")
        
        shoot()
    }
}
