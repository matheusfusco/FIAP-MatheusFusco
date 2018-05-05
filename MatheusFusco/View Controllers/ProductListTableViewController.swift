//
//  ProductListTableViewController.swift
//  ProductList
//
//  Created by Matheus Pacheco Fusco on 17/04/2018.
//  Copyright © 2018 FIAP. All rights reserved.
//

import UIKit
import CoreData

class ProductListTableViewController: UITableViewController {
    
    // MARK: - Lets and Vars
    var products: [Product] = []
    var selectedProduct: Product!
    var label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 22))
    
    // MARK: - IBOutlets
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        label.text = "Sua lista está vazia!"
        label.textAlignment = .center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.selectedProduct = nil
        loadProducts()
    }
    
    // MARK: - Custom Methods
    func loadProducts() {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            products = try context.fetch(fetchRequest)
            self.tableView.reloadData()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AddEditProductViewController {
            if let prod = self.selectedProduct {
                vc.product = prod
            }
        }
    }
    
    // MARK: - Button Actions
    @IBAction func addProductBtnClicked(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "addEditProductIdentifier", sender: self)
    }
    
    // MARK: - Memory Management
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    // MARK: - TableView DataSource Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        tableView.backgroundView = (products.count == 0) ? label : nil
        return products.count
    }
    
    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedProduct = products[indexPath.row]
        self.performSegue(withIdentifier: "addEditProductIdentifier", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! ProductDetailTableViewCell
        let product = products[indexPath.row]
        if let img = product.image as? UIImage {
            cell.productImage.image = img
        }
        cell.productName.text = product.name
        cell.productPrice.text = "\(product.value)"
        return cell
    }
}
