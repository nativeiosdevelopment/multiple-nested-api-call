//
//  ViewController.swift
//  GloryiOSApp
//
//  Created by John Kricorian on 30/07/2021.
//

import UIKit
import GloryFramework

class ViewController: UIViewController {
    
    var sessionId: String?
    var glory: Glory?
    var currentTransaction: Transaction?
        
    @IBAction func firstButtonPressed(_ sender: UIButton) {

    }
    
    @IBAction func secondButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func thirdButtonPressed(_ sender: UIButton) {
        glory?.changeCancel(completionHandler: { result in
            switch result {
            case .success(let occupyStatus):
                print(occupyStatus.rawValue )
            case .failure(let error):
                print(error)
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        glory = Glory()
        glory?.connect(gloryOutputDelegate: self, logger: self, serverIp: "192.168.1.25", user: "John")
    }
}

extension ViewController: GloryOutputDelegate {
    func didUpdate(emptyMoneyItems: [MoneyItem]) {}
    func didUpdateConnexion(isConnected: Bool) {}
    func didUpdateEventError(url: String, errorCode: Int) {}
    func didUpdateStacker(isFlagged: Bool) {}
    func didUpdate(statusCode: StatusCode) {}
    func didUpdate(billDevStatus: DeviceStatus) {}
    func didUpdate(coinDevStatus: DeviceStatus) {}
    func didStart(transaction: Transaction?) {}
    func didUpdate(transaction: Transaction?) {}
    func didSucceed(transaction: Transaction?) {}
    func didFail(transaction: Transaction?, error: Error) {}
    func eventError(url: String, errorCode: Int) {}
    func connectionDidFail(error: Error) {}
    func serverDidFail() {}
}

extension ViewController: GloryLoggerDelegate {
    func debug(message: String, meta: [String : Any]?) {}
    func info(message: String, meta: [String : Any]?) {}
    func error(message: String, meta: [String : Any]?) {}
}
