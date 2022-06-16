//
//  ViewController.swift
//  socket-demo
//
//  Created by クワシマ・ユウキ on 2022/06/16.
//

import UIKit
import CoreGraphics

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet var textField: UITextField!
    @IBOutlet var tableView: UITableView!
    
    var urlSession: URLSession?
    var webSocketTask: URLSessionWebSocketTask?
    
    var items: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        urlSession = URLSession(configuration: .default)
        webSocketTask = urlSession?.webSocketTask(with: URL(string: "ws://localhost:4567/websocket")!)
        webSocketTask?.resume()
        receiveMessage()
    }
    
    func receiveMessage() {
        webSocketTask?.receive { [self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received! text: \(text)")
                    DispatchQueue.main.async {
                        items.insert(text, at: 0)
                        tableView.reloadData()
                    }
                case .data(let data):
                    print("Received! binary: \(data)")
                @unknown default:
                    fatalError()
                }
                receiveMessage()
            case .failure(let error):
            print("Failed! error: \(error)")
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    @IBAction func send(_ sender: UIButton) {
        webSocketTask?.send(.string(textField.text!), completionHandler: {_ in
            DispatchQueue.main.async {
                self.textField.text = ""
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("counts")
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        cell.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        return cell
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }

}

