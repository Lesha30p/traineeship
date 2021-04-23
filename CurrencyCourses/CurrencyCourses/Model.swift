//
//  Model.swift
//  CurrencyCourses
//
//  Created by Леша Панин on 25.02.21.
//

import UIKit
//Currency Market"><Valute ID="R01010"><NumCode>036</NumCode><CharCode>AUD</CharCode><Nominal>1</Nominal><Name>¿‚ÒÚ‡ÎËÈÒÍËÈ ‰ÓÎÎ‡</Name><Value>16,0102</Value></Valute><Valute
class Currensy{
    var numCode: String?
    var charCode: String?
    var nominal: String?
    var nominalDouble: Double?
    var name: String?
    var value: String?
    var valueDouble: Double?
    
    class func rouble() -> Currensy{
        let r = Currensy()
        r.charCode = "RUB"
        r.name = "Российский рубль"
        r.nominal = "1"
        r.nominalDouble = 1
        r.value =  "1"
        r.valueDouble = 1
        
        return r
    }
}

class Model: NSObject, XMLParserDelegate {
    static let shared = Model()
    
    var currensyes: [Currensy] = []
    var currentDate: String = ""
    
    var fromCurrency: Currensy = Currensy.rouble()
    var toCurrency: Currensy = Currensy.rouble()
    
    func convert (amount: Double?) -> String{
        if amount == nil{
           return ""
        }
        
        let d = ((fromCurrency.nominalDouble! * fromCurrency.valueDouble!)/(toCurrency.nominalDouble! * toCurrency.valueDouble! )) * amount!
        
        return String(d)
    }
    
    var pathForHML: String{
    let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/data.xml"
        
        if FileManager.default.fileExists(atPath: path){
            return path
        }
        return Bundle.main.path(forResource: "data", ofType: "xml")!
    }
    
    var urlForXML: URL{
        return URL(fileURLWithPath: pathForHML)
    }
    
    func loadXMLFile(date: Date?){
        var strURL = "http://www.cbr.ru/scripts/XML_daily.asp?date_req="
        
        if date != nil{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/mm/yyyy "
            strURL = strURL+dateFormatter.string(from: date!)
             
        }
        
        let url = URL(string: strURL)
        
        let task = URLSession.shared.dataTask(with: url! ) { (data , responce, error ) in
            
            var errorGlobal: String?
            
            if error == nil{
                let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/data.xml"
                let urlForSave = URL(fileURLWithPath: path)
                do{
                    try data?.write(to: urlForSave)
                    print("Файл загружен")
                    self.parseXML()
                }catch{
                    print("Error when save data:\(error.localizedDescription)")
                    errorGlobal = error.localizedDescription
                }
                
            }else{
                print("Error when loadXMLFile"+error!.localizedDescription)
                errorGlobal = error?.localizedDescription
            }
            
            if let errorGlobal = errorGlobal{
                NotificationCenter.default.post(name: NSNotification.Name("errorWhenXMLloading"), object: self, userInfo: ["errorName":errorGlobal])
            }
    
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "startLoadingXML") , object: self)
        task.resume()
        
    }
    //парсим файл в массив и отправляем уведомление приложению о обновленных данных
    func parseXML(){
        
        currensyes = [Currensy.rouble()]
        
        let parser = XMLParser(contentsOf: urlForXML)
        parser?.delegate = self
        parser?.parse()
        print("Данные обновлены")
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dataRefreshed") , object: self)
    }
    var currentCurrency: Currensy?
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]){
        
        if elementName == "ValCurs"{
            if let currentDateString = attributeDict["Date"]{
               currentDate = currentDateString
            }
        }
         
        if elementName == "Valute"{
            currentCurrency = Currensy()
        }
    }
    
    var currentCharacters: String = ""
    func parser(_ parser: XMLParser, foundCharacters string: String){
        currentCharacters = string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?){
        if elementName == "Valute"{
            currensyes.append(currentCurrency!)
        }
        if elementName == "NumCode"{
            currentCurrency?.numCode = currentCharacters
            }
        if elementName == "CharCode"{
            currentCurrency?.charCode = currentCharacters
        }
        if elementName == "Nominal"{
            currentCurrency?.nominal = currentCharacters
            currentCurrency?.nominalDouble = Double(currentCharacters)
        }
        if elementName == "Name"{
            currentCurrency?.name = currentCharacters
        }
        if elementName == "Value"{
            currentCurrency?.value = currentCharacters
            currentCurrency?.valueDouble = Double(currentCharacters)
        }
        
    }
   
}
