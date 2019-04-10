//
//  SelectNumberPlayerViewController.swift
//  Bomb boy
//
//  Created by João batista Romão on 09/04/19.
//  Copyright © 2019 Gustavo Portela Chaves. All rights reserved.
//

import UIKit

class SelectNumberPlayerViewController: UIViewController {
    var numberPlayer = 3
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func selectOne(_ sender: Any) {
    }
    
    @IBAction func selectTwo(_ sender: Any) {
        
    }
    @IBAction func selectThree(_ sender: Any) {
        
    }
    @IBAction func selectFour(_ sender: Any) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationView: GameViewController = segue.destination as! GameViewController
        
        switch segue.identifier {
        case "onePlayer":
            destinationView.numberOfPlayer = 1
            break
        case "twoPlayer":
            destinationView.numberOfPlayer = 2
            break
        case "threePlayer":
            destinationView.numberOfPlayer = 3
            break
        case "fourPlayer":
            destinationView.numberOfPlayer = 4
            break
        default:
            destinationView.numberOfPlayer = 1
        }
        if segue.identifier == "onePlayer"{
           
        }
        
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
