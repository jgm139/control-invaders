//
//  ViewController.swift
//  InvadersScreen
//
//  Created by Julia García Martínez on 14/04/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import Cocoa
import AVFoundation
import CoreBluetooth

class ScreenViewController: NSViewController {
    
    // MARK: - Outlets
    @IBOutlet var window: NSView!
    
    // MARK: - Game properties
    let aimImageView = NSImageView(image: NSImage(named: "aim")!)
    let fireImageView = NSImageView(image: NSImage(named: "fire")!)
    
    var targets = [NSImageView]()
    var currentTarget = 0
    
    let numberOfSmoothUpdates = 25
    var eyeGazeHistory = ArraySlice<CGPoint>()
    
    let targetNames = ["alien-blue", "alien-red", "alien-green", "alien-orange"]
    
    var laserShot: AVAudioPlayer?
    
    var startTime = CACurrentMediaTime()
    
    // MARK: - Core Bluetooth properties
    var selectedPeripheral: CBPeripheral!
    var centralManager: CBCentralManager?
    var peripheralManager = CBPeripheralManager()
    
    // MARK: - View Controller's functions
    override func viewDidLoad() {
        super.viewDidLoad()

        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        
        //self.centralManager = CBCentralManager(delegate: self, queue: nil)
        //self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        self.aimImageView.frame = CGRect(x:self.view.bounds.midX, y:self.view.bounds.midY, width:64, height:64)
        self.fireImageView.frame = CGRect(x:self.view.bounds.midX, y:self.view.bounds.midY, width:64, height:64)
        
        initTargets()
        
        perform(#selector(createTarget), with: nil, afterDelay: 3.0)
    }

    // MARK: - Methods
    func initTargets(){
        // Crea una NSStackView de marcianos por código
        let rowStackView = NSStackView()
        rowStackView.translatesAutoresizingMaskIntoConstraints = false
        
        rowStackView.distribution = .fillEqually
        rowStackView.orientation = .vertical
        rowStackView.spacing = 20
        
        for _ in 1...8 {
            let colStackView = NSStackView()
            //colStackView.translatesAutoresizingMaskIntoConstraints = false
            
            colStackView.distribution = .fillEqually
            //colStackView.axis = .horizontal
            colStackView.spacing = 20
            
            rowStackView.addArrangedSubview(colStackView)
            
            for imageName in targetNames {
                let imageView = NSImageView(image: NSImage(named:imageName)!)
                imageView.layerContentsPlacement = .scaleProportionallyToFill
                imageView.alphaValue = 0
                targets.append(imageView)
                
                colStackView.addArrangedSubview(imageView)
            }
        }
        
        self.view.addSubview(rowStackView)
        
        NSLayoutConstraint.activate([
            rowStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rowStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rowStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            rowStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
            
            ])
        
        self.view.addSubview(aimImageView)
        fireImageView.alphaValue=0.0
        self.view.addSubview(fireImageView)
        targets.shuffle()
    }
    
    @objc func createTarget(){
        
        guard currentTarget < self.targets.count else {
            endGame()
            return
        }
        // Objetivo actual que queremos mostrar por pantalla
        let target = self.targets[currentTarget]
        
        NSAnimationContext.runAnimationGroup({context in
          context.duration = 0.5
          context.allowsImplicitAnimation = true
            target.alphaValue = 1.0
            self.fireImageView.alphaValue = 0.0
            self.view.layoutSubtreeIfNeeded()

        }, completionHandler:nil)
        currentTarget += 1
        self.fireImageView.alphaValue = 0.0
    }
    
    func shoot(){
        if let url = Bundle.main.url(forResource: "laser-sound", withExtension: "wav") {
            laserShot = try? AVAudioPlayer(contentsOf: url)
            laserShot?.play()
        }
        let aimFrame = aimImageView.superview!.convert(aimImageView.frame, to: nil)
        
        print ("disparo recibido")
        let hitTargets = self.targets.filter { iv -> Bool in
            if iv.alphaValue == 0 { return false }
            let targetFrame = iv.superview!.convert(iv.frame, to: nil)
            print ("acierto: \(targetFrame.intersects(aimFrame))")
            return targetFrame.intersects(aimFrame)
        }
        
        guard let selectedTarget = hitTargets.first else {
            return
        }
        
        self.fireImageView.frame.origin = CGPoint(x:Double(self.aimImageView.frame.origin.x) , y: Double(self.aimImageView.frame.origin.y))
        //self.fireImageView.frame.origin=self.aimImageView.frame.origin
        fireImageView.alphaValue = 1.0
        
        
        /*
        NSAnimationContext.runAnimationGroup({context in
            context.duration = 1.5
            fireImageView.alphaValue = 0.0
            //self.fireImageView.animator().isHidden = true
            self.view.layoutSubtreeIfNeeded()

        }, completionHandler: {
            print ("animacion completada")
            //self.fireImageView.alphaValue = 0.0
        })
        
        */

        
        selectedTarget.alphaValue = 0
        
        if let url = Bundle.main.url(forResource: "explosion", withExtension: "wav") {
            laserShot = try? AVAudioPlayer(contentsOf: url)
            laserShot?.play()
        }
        
        perform(#selector(createTarget), with: nil, afterDelay: 1.5)
    }

    
    
    func endGame(){
        let gameTime = Int(CACurrentMediaTime() - startTime)
        
        let alert = NSAlert()
        alert.messageText = "Fin de la partida"
        alert.informativeText = "Has tardado \(gameTime) segundos."
        alert.runModal()
        perform(#selector(backToMainMenu), with: nil, afterDelay: 4.0)
    }
    
    @objc func backToMainMenu(){
        /*dismiss(animated: true) {
            self.navigationController?.popToRootViewController(animated: true)
        }*/
        print ("end game")
    }

}

