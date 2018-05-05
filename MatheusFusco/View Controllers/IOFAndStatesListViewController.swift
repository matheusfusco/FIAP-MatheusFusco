//
//  IOFAndStatesListViewController.swift
//  ProductList
//
//  Created by Matheus Pacheco Fusco on 17/04/2018.
//  Copyright © 2018 FIAP. All rights reserved.
//

import UIKit
import CoreData

enum StateType {
    case add
    case edit
}

class IOFAndStatesListViewController: UIViewController {

    //MARK: - Lets and Vars
    var states: [State] = []
    var products: [Product] = []
    
    //MARK: - IBOutlets
    @IBOutlet weak var dolarQuotationTextField: UITextField!
    @IBOutlet weak var iofTextField: UITextField!
    @IBOutlet weak var statesTableView: UITableView!
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        statesTableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTextFields), name: NSNotification.Name.UIApplicationDidBecomeActive, object: UIApplication.shared)
        refreshTextFields()
        loadStates()
        loadProducts()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: - Custom Methods
    @objc func refreshTextFields() {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        var iofValue: Double = 0
        var dolarValue: Double = 0
        
        iofValue = (formatter.number(from: "\(UserDefaults.standard.double(forKey: "iofQuotation"))")?.doubleValue)!
        dolarValue = (formatter.number(from: "\(UserDefaults.standard.double(forKey: "dolarQuotation"))")?.doubleValue)!
        
        UserDefaults.standard.set(dolarValue, forKey: "dolarQuotation")
        UserDefaults.standard.set(iofValue, forKey: "iofQuotation")
        iofTextField.text = "\(iofValue)"
        dolarQuotationTextField.text = "\(dolarValue)"
    }

    func loadStates() {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            states = try context.fetch(fetchRequest)
            self.statesTableView.reloadData()
        }
        catch {
            print(error.localizedDescription)
        }
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
    
    func showAlert(type: StateType, state: State?) {
        let title = type == .add ? "Adicionar" : "Editar"
        let alert = UIAlertController(title: "\(title) Estado", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Nome do estado"
            if let state = state?.name {
                textField.text = state
            }
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Imposto"
            if let tax = state?.tax {
                textField.text = "\(tax)"
            }
        }
        alert.addAction(UIAlertAction(title: title, style: .default, handler: { (action) in
            let state = state ?? State(context: self.context)
            state.name = alert.textFields![0].text
            state.tax = Double(alert.textFields![1].text!)!
            do {
                try self.context.save()
                self.loadStates()
            }
            catch {
                print(error.localizedDescription)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Button Actions
    @IBAction func addStateBtnClicked(_ sender: UIButton) {
        showAlert(type: .add, state: nil)
    }
    
    //MARK: - TextField Actions
    @IBAction func dolarQuotationTextFieldEditingChange(_ sender: UITextField) {
        let valueToSet = (sender.text?.count)! > 0 ? Double(sender.text!) : 0
        UserDefaults.standard.set(valueToSet, forKey: "dolarQuotation")
    }
    
    
    @IBAction func iofQuotationTextFieldEditingChange(_ sender: UITextField) {
        let valueToSet = (sender.text?.count)! > 0 ? Double(sender.text!) : 0
        UserDefaults.standard.set(valueToSet, forKey: "iofQuotation")
    }
    
    //MARK: - Memory Management
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}

//MARK: - UITableView Delegate Methods
extension IOFAndStatesListViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let state = states[indexPath.row]
        showAlert(type: .edit, state: state)
    }
}

//MARK: - UITableView DataSource Methods
extension IOFAndStatesListViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return states.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stateCell", for: indexPath)
        let state = states[indexPath.row]
        cell.textLabel?.text = state.name
        cell.detailTextLabel?.text = "\(state.tax)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let state = states[indexPath.row]
            
            
            for prod in products.filter({$0.state == state}) {
                context.delete(prod)
            }
            
            context.delete(state)
            do {
                try context.save()
                self.states.remove(at: indexPath.row)
                statesTableView.deleteRows(at: [indexPath], with: .fade)
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
}


//MARK: - UITextView Delegate Methods
extension IOFAndStatesListViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        var iofValue: Double = 0
        var dolarValue: Double = 0
        let formatter = NumberFormatter()
        
        iofValue = (formatter.number(from: "\(UserDefaults.standard.double(forKey: "iofQuotation"))")?.doubleValue)!
        dolarValue = (formatter.number(from: "\(UserDefaults.standard.double(forKey: "dolarQuotation"))")?.doubleValue)!
        
        UserDefaults.standard.set(dolarValue, forKey: "dolarQuotation")
        UserDefaults.standard.set(iofValue, forKey: "iofQuotation")
        
        iofTextField.text = "\(iofValue)"
        dolarQuotationTextField.text = "\(dolarValue)"
        
        return true
    }
}
