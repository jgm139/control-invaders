//
//  ViewController.swift
//  InvadersControlShooter
//
//  Created by Julia García Martínez on 15/04/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit
import CoreBluetooth

class ControlViewController: UIViewController {
    
    // MARK: - Control properties
    var position = CGPoint()
    var checkUpdateX = false
    var checkUpdateY = false
    
    // MARK: - Core Bluetooth properties
    var selectedPeripheral: CBPeripheral!
    var centralManager: CBCentralManager?
    var peripheralManager = CBPeripheralManager()
    var peripheral: CBPeripheral?
    
    var myService: CBMutableService?
    var myCharacteristicX: CBMutableCharacteristic?
    var myCharacteristicY: CBMutableCharacteristic?
    
    var characteristicShoot: CBCharacteristic?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func calculatePosition(_ x: CGFloat, _ y: CGFloat) {
        position.x = 2 * ((x - self.view.frame.minX) / (self.view.frame.maxX - self.view.frame.minX)) - 1
        position.y = 2 * ((y - self.view.frame.minY) / (self.view.frame.maxY - self.view.frame.minY)) - 1
        position.y = -position.y
        
        self.checkUpdateX = self.peripheralManager.updateValue("\(self.position.x)".data(using: .utf8)!, for: myCharacteristicX!, onSubscribedCentrals: nil)
        self.checkUpdateY = self.peripheralManager.updateValue("\(self.position.y)".data(using: .utf8)!, for: myCharacteristicY!, onSubscribedCentrals: nil)
        
        print("Calculated position - x: \(position.x), y: \(position.y)")
    }
    
    @IBAction func handlePan(_ gesture: UIPanGestureRecognizer) {
        // Recuperamos los gestos que ha hecho el usuario
        let translation = gesture.translation(in: view)
        
        // Obtenemos una referencia de la view de la mirilla
        guard let gestureView = gesture.view else {
            return
        }
        print("View - x: \(self.view.frame.maxX), y: \(self.view.frame.maxY)")
        
        // Movemos el centro de la view (mirilla) según el movimiento obtenido
        gestureView.center = CGPoint(x: gestureView.center.x + translation.x, y: gestureView.center.y + translation.y)
        print("Aim view position - x: \(gestureView.center.x), y: \(gestureView.center.y)")
        calculatePosition(gestureView.center.x, gestureView.center.y)
        
        // Para evitar errores, ponemos a cero la traslación
        gesture.setTranslation(.zero, in: view)
    }
    
    @IBAction func handleTap(_ gesture: UITapGestureRecognizer) {
        // controlar el disparo
        print("Central: Solicitamos la escritura de su valor")
        let data = "0x5".data(using: .utf8)!
        self.peripheral!.writeValue(data, for: characteristicShoot!, type: .withoutResponse)
        print("pum, pum")
    }


}

