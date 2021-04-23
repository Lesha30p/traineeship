//
//  ConverterController.swift
//  CurrencyCourses
//
//  Created by Леша Панин on 13.04.21.
//

import UIKit

class ConverterController: UIViewController {

    
    @IBOutlet weak var buttonFrom: UIButton!
    @IBOutlet weak var buttonTo: UIButton!
    
    @IBOutlet weak var textTo: UITextField!
    @IBOutlet weak var textFrom: UITextField!
    
    @IBAction func pushFromAction(_ sender: Any) {
         let nc = storyboard?.instantiateViewController(withIdentifier: "selectedCurrencyNSID") as! UINavigationController
        (nc.viewControllers[0] as! SelectCurrencyController).flagCurrency = .from
        nc.modalPresentationStyle = .fullScreen
        present(nc, animated: true, completion: nil )
    }
    
    @IBAction func pushToAction(_ sender: Any) {
        let nc = storyboard?.instantiateViewController(withIdentifier: "selectedCurrencyNSID") as! UINavigationController
       (nc.viewControllers[0] as! SelectCurrencyController).flagCurrency = .to
        nc.modalPresentationStyle = .fullScreen
       present(nc, animated: true, completion: nil )
    }
     
    override func viewDidLoad() {
        super.viewDidLoad()
        textFrom.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshButtons()
        textFromEditingChanged(self)
    }
    
    @IBOutlet weak var buttonDone: UIBarButtonItem!
    
    @IBAction func pushDoneAction(_ sender: Any) {
        textFrom.resignFirstResponder()
        navigationItem.rightBarButtonItem = nil
    }
    
    
    @IBAction func textFromEditingChanged(_ sender: Any) {
        let amount = Double(textFrom.text!)
     
        textTo.text = Model.shared.convert(amount: amount)
        
    }
    
    
    
    func refreshButtons() {
        buttonFrom.setTitle(Model.shared.fromCurrency.charCode, for: UIControl.State.normal)
        buttonTo.setTitle(Model.shared.toCurrency.charCode, for: UIControl.State.normal)
    }
    

}

extension ConverterController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
        navigationItem.rightBarButtonItem = buttonDone
        return true
        
    }
}
