//
//  AddEditProductViewController.swift
//  ProductList
//
//  Created by Matheus Pacheco Fusco on 17/04/2018.
//  Copyright © 2018 FIAP. All rights reserved.
//

import UIKit
import CoreData

enum ProductType: String {
    case add
    case edit
}

class AddEditProductViewController: UIViewController {
    //MARK: - Lets and Vars
    var addEdit: ProductType!
    var product: Product!
    var states: [State] = []
    var prodImage: UIImage!
    var pickerView: UIPickerView!
    
    //MARK: - IBOutlets
    @IBOutlet weak var productNameTextField: UITextField!
    @IBOutlet weak var productImageImageView: UIImageView!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var productValueTextField: UITextField!
    @IBOutlet weak var isCardSwitch: UISwitch!
    @IBOutlet weak var registerUpdateProductBtn: UIButton!
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadStates()
        if product != nil && product?.state == nil {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: - Custom Methods
    func configViews() {
        if product != nil {
            addEdit = .edit
            productNameTextField.text = product.name!
            stateTextField.text = product.state?.name!
            productValueTextField.text = "\(product.value)"
            isCardSwitch.isOn = product.isCard
            if let image = product.image as? UIImage {
                prodImage = image
                productImageImageView.image = prodImage
            }
        }
        else {
            addEdit = .add
        }
        
        self.title = (addEdit == .add ? "Cadastrar" : "Editar") + " Produto"
        registerUpdateProductBtn.setTitle(addEdit == .add ? "CADASTRAR" : "SALVAR ALTERAÇÕES", for: .normal)
        
        configPicker()
    }
    
    func configPicker() {
        pickerView = UIPickerView()
        pickerView.backgroundColor = .white
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        
        let btSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let btDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.items = [btSpace, btDone]
        
        stateTextField.inputView = pickerView
        stateTextField.inputAccessoryView = toolbar
    }
    
    func loadStates() {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            states = try context.fetch(fetchRequest)
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    @objc func done() {
        if states.count > 0 {
            stateTextField.text = states[pickerView.selectedRow(inComponent: 0)].name
        }
        stateTextField.resignFirstResponder()
    }
    
    func validateFields() -> Bool {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        guard let name = productNameTextField.text, let state = stateTextField.text, let value = formatter.number(from: productValueTextField.text!)?.doubleValue else {
            return false
        }
        
        guard name.count > 0, state.count > 0, value > 0, prodImage != nil else {
            return false
        }
        return true
    }
    
    func selectProductPhoto(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: - Button Actions
    @IBAction func addProductPhotoBtnClicked(_ sender: UIButton) {
        let alert = UIAlertController(title: "Selecionar poster", message: "De onde você quer escolher o poster", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Câmera", style: .default) { (action) in
                self.selectProductPhoto(sourceType: .camera)
            }
            alert.addAction(cameraAction)
        }
        
        let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default) { (action) in
            self.selectProductPhoto(sourceType: .photoLibrary)
        }
        alert.addAction(libraryAction)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func registerUpdateProductBtnClicked(_ sender: UIButton) {
        if !validateFields() {
            let alert = UIAlertController(title: nil, message: "Favor preencher todos os campos corretamente!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let prod = product ?? Product(context: self.context)
            prod.name = productNameTextField.text
            prod.isCard = isCardSwitch.isOn
            prod.value = Double(String(format: "%.2f", Double(productValueTextField.text!)!))!
            prod.state = states.filter({$0.name == stateTextField.text}).first
            if prodImage != nil {
                prod.image = prodImage
            }
            do {
                try self.context.save()
                self.navigationController?.popViewController(animated: true)
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
    
    //MARK: - Memory Management
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension AddEditProductViewController : UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == stateTextField {
            let indexOf = states.index(where: {$0.name == textField.text})
            if let index = indexOf {
                pickerView.selectRow(index, inComponent: 0, animated: false)
            }
        }
    }
}

extension AddEditProductViewController : UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //Retornando o texto recuperado do objeto dataSource, baseado na linha selecionada
        return states[row].name
    }
}

extension AddEditProductViewController : UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return states.count
    }
}

extension AddEditProductViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        let newSize = CGSize(width: 343, height: 150)
        
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        prodImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        productImageImageView.image = prodImage
        
        dismiss(animated: true, completion: nil)
        
    }
}
