//
//  TotalBuyingsViewController.swift
//  ProductList
//
//  Created by Matheus Pacheco Fusco on 17/04/2018.
//  Copyright © 2018 FIAP. All rights reserved.
//

import UIKit
import CoreData

class TotalBuyingsViewController: UIViewController {

    //MARK: - Lets and Vars
    var dolarQuotation: Double = 0
    var iofQuotation: Double = 0
    var products: [Product] = []
    var totalRS: Double = 0
    var totalDolar: Double = 0
    
    //MARK: - IBOutlets
    @IBOutlet weak var totalUSLabel: UILabel!
    @IBOutlet weak var totalRSLabel: UILabel!
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshLabels), name: NSNotification.Name.UIApplicationDidBecomeActive, object: UIApplication.shared)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        iofQuotation = UserDefaults.standard.double(forKey: "iofQuotation")
        dolarQuotation = UserDefaults.standard.double(forKey: "dolarQuotation")
        loadProducts()
        refreshLabels()
    }

    //MARK: - Custom Methods
    @objc func refreshLabels() {
        var stateValue: Double = 0
        var creditCardValue: Double = 0
        var valueAfterAllTaxes: Double = 0
        totalRS = 0
        totalDolar = 0
        
        for prod in products {
            stateValue = prod.value/100 * (prod.state?.tax)!
            creditCardValue = prod.isCard == true ? (prod.value/100) * iofQuotation : 0
            valueAfterAllTaxes += stateValue + creditCardValue + prod.value
            totalDolar += prod.value
        }
        totalRS = valueAfterAllTaxes * dolarQuotation
        totalUSLabel.text = "\(totalDolar)"//String(format: "U$ %.2f", totalDolar).replacingOccurrences(of: ".", with: ",")
        totalRSLabel.text = "\(totalRS)"//String(format: "R$ %.2f", totalRS).replacingOccurrences(of: ".", with: ",")
    }
    
    func loadProducts() {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            products = try context.fetch(fetchRequest)
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    //MARK: - Memory Management
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
