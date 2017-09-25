//
//  ViewController.swift
//  Code Test Andy Triboletti
//
//  Created by Andy Triboletti on 9/21/17.
//  Copyright © 2017 GreenRobot LLC. All rights reserved.
//

import UIKit
import SwiftForms
import CoreData

class AddContactViewController: FormViewController {
    var section1:FormSectionDescriptor=FormSectionDescriptor(headerTitle: "Basics", footerTitle: "");
    var section2:FormSectionDescriptor=FormSectionDescriptor(headerTitle: "Addresses", footerTitle: "");
    var section3:FormSectionDescriptor=FormSectionDescriptor(headerTitle: "Phone", footerTitle: "");
    var section4:FormSectionDescriptor=FormSectionDescriptor(headerTitle: "Email", footerTitle: "");
    var section5:FormSectionDescriptor=FormSectionDescriptor(headerTitle: "Submit", footerTitle: "");
    var section6:FormSectionDescriptor=FormSectionDescriptor(headerTitle: "Delete", footerTitle: "");
    var theContact:Contact?;
    var theObjectIDs: [NSManagedObjectID]?
    var addressCount:Int = 0;
    var phoneCount:Int = 0;
    var emailCount:Int = 0;
    var contact:Contact?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Create form instace
        var form = FormDescriptor()
        form.title = "Example form"
        
        // Define first section
        if(theContact?.firstName != nil) {
            section1 = FormSectionDescriptor(headerTitle: theContact!.firstName, footerTitle: "")

        }
        else {
            section1 = FormSectionDescriptor(headerTitle: "My Contacts", footerTitle: "")
        }
        var row = FormRowDescriptor(tag: "name", type: .text, title: "First Name")
        if(theContact?.firstName != nil) {
            row.value=theContact!.firstName! as AnyObject
        }
        section1.rows.append(row)
        
        row = FormRowDescriptor(tag: "lastName", type: .text, title: "Last Name")
        if(theContact?.lastName != nil) {
            row.value=theContact!.lastName! as AnyObject
        }
        section1.rows.append(row)
        
        row = FormRowDescriptor(tag: "birthday", type: .date, title: "Date of Birth")
        if(theContact?.dateOfBirth != nil) {
            row.value=theContact!.dateOfBirth! as AnyObject
        }
        section1.rows.append(row)
        
        section2 = FormSectionDescriptor(headerTitle: "Addresses", footerTitle: "")

         if(theContact?.myAddress != nil) {
            for myItem in (theContact?.myAddress )!{
                
                addressCount = addressCount + 1
                
            }
        }
        self.calculatePhoneCount()
        if(theContact?.myEmail != nil) {
            for myItem in (theContact?.myEmail )!{
                
                emailCount = emailCount + 1
                
            }
        }
        
        //ADDRESS
        if(addressCount == 0) {
            row = FormRowDescriptor(tag: "button", type: .button, title: "Add Address")
            row.configuration.cell.required=false;
            self.section2.rows.append(row)
            row.configuration.button.didSelectClosure = { _ in
                self.addAddress()
                
            }
        }
        else {
            
            row = FormRowDescriptor(tag: "button", type: .button, title: "Add Another Address")
            row.configuration.cell.required=false

            self.section2.rows.append(row)
            row.configuration.button.didSelectClosure = { _ in
                self.addAddress()
            }
            var row = FormRowDescriptor(tag: "button", type: .button, title: "Remove Last Address")
            row.configuration.cell.required=false
            row.configuration.button.didSelectClosure = { _ in
                self.removeAddress();
                
            }
            self.section2.rows.append(row)
            
            
            
        }
        
        
        addressCount = 0;
        if(theContact?.myAddress != nil) {
            for myItem in (theContact?.myAddress )!{
                print((myItem as! Address).myText)
                var myText = (myItem as! Address).myText;
                //(myItem as! Address).objectID
                if(myText != nil) {
                    row = FormRowDescriptor(tag: "address", type: .text, title: "Address")
                    row.value=myText! as AnyObject
                    section2.rows.append(row)
                    addressCount = addressCount + 1
                }
                
            }
        }


        //PHONE
        
        section3 = FormSectionDescriptor(headerTitle: "Phone", footerTitle: "")
        
        row = FormRowDescriptor(tag: "button", type: .button, title: "Add Another Phone")
        row.configuration.cell.required=false;
        row.configuration.button.didSelectClosure = { _ in

            self.savePhoneToCore()

            if(self.validateMyPhone()) {

                self.addPhone()
            }
            else {
                
                let alertController = UIAlertController(title: "Required field missing.", message: "Field required: Phone", preferredStyle: UIAlertControllerStyle.alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                    print("OK")
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
            }
        }
        
        
        self.section3.rows.append(row)
        
        if(phoneCount > 1) {

        row = FormRowDescriptor(tag: "button", type: .button, title: "Remove Last Phone")
        row.configuration.cell.required=false;

        row.configuration.button.didSelectClosure = { _ in
            self.removePhone();
            
        }
        
        self.section3.rows.append(row)

        }
        else if(phoneCount < 1 && theContact != nil) {
            self.addPhone();
        }
        
        

        phoneCount = 0;
        if(theContact?.myPhone != nil) {
            for myItem in (theContact?.myPhone )!{
                print((myItem as! Phone).myText)
                var myText = (myItem as! Phone).myText;
                
                row = FormRowDescriptor(tag: "phone", type: .phone, title: "Phone")
                row.value = myText as AnyObject
                section3.rows.append(row)
                phoneCount = phoneCount + 1
                
            }
        }
        else {
            self.addPhone()
        }
        //END PHONE
        
        
        
        
        
        
        
        
        
        //NEW EMAIL
        
        section4 = FormSectionDescriptor(headerTitle: "Email", footerTitle: "")
        
        row = FormRowDescriptor(tag: "button", type: .button, title: "Add Another Email")
        row.configuration.cell.required=false;
        row.configuration.button.didSelectClosure = { _ in
            
            self.saveEmailToCore()
            
            if(self.validateMyEmail()) {
                
                self.addEmail()
            }
            else {
                
                let alertController = UIAlertController(title: "Required field missing.", message: "Field required: Email", preferredStyle: UIAlertControllerStyle.alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                    print("OK")
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
            }
        }
        
        
        self.section4.rows.append(row)
        
        if(emailCount > 1) {
            
            row = FormRowDescriptor(tag: "button", type: .button, title: "Remove Last Email")
            row.configuration.cell.required=false;
            
            row.configuration.button.didSelectClosure = { _ in
                self.removePhone();
                
            }
            
            self.section4.rows.append(row)
            
        }
        else if(emailCount < 1 && theContact != nil) {
            self.addEmail();
        }
        
        
        
        emailCount = 0;
        if(theContact?.myEmail != nil) {
            for myItem in (theContact?.myEmail )!{
                print((myItem as! Email).myText)
                var myText = (myItem as! Email).myText;
                
                row = FormRowDescriptor(tag: "email", type: .phone, title: "Email")
                row.value = myText as AnyObject
                section4.rows.append(row)
                emailCount = emailCount + 1
                
            }
        }
        else {
            self.addEmail()
        }
        //END NEW EMAIL
        
        
        
        
        
        
        
        
        
        //SUBMIT
        
        section5 = FormSectionDescriptor(headerTitle: "Submit", footerTitle: "")
        
        
        row = FormRowDescriptor(tag: "button", type: .button, title: "Submit")
        row.configuration.cell.required=false

        self.section5.rows.append(row)
        
        
        row.configuration.button.didSelectClosure = { _ in
            
            self.validateMyForm()
            
            
        }
        
        section6 = FormSectionDescriptor(headerTitle: "Delete", footerTitle: "")
        
        
        row = FormRowDescriptor(tag: "button", type: .button, title: "Delete")
        row.configuration.cell.required=false
        self.section6.rows.append(row)
        
        
        row.configuration.button.didSelectClosure = { _ in
            
            self.delete()
            
        }
        
        self.setupForm()

    }
    
    
    func validateMyPhone() -> Bool {
        self.calculatePhoneCount();
        if(self.phoneCount > 0 || self.form.sections[2].rows[1].value != nil) {
            return true;
        }
        else {
            return false;
        }
    }
    
    func validateMyEmail() -> Bool {
        self.calculateEmailCount();
        if(self.emailCount > 0 || self.form.sections[3].rows[1].value != nil) {
            return true;
        }
        else {
            return false;
        }
    }
    
    func validateMyForm()  -> Bool {
        let error = self.form.validateForm()
        print("ok")
        
        if(error != nil) {
            let name = error?.title!
            //let truncated = name?.substring(to: (name?.index(before: (name?.endIndex)!))!)
            
            let alertController = UIAlertController(title: "Required field missing.", message: "Field required: " + name!, preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                print("OK")
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return false;
        }
        else {
            self.submit()
            return true;
        }
        
        
    }
    func delete() {
        print("delete")
   
        
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        //let note = contacts[indexPath.row]
        
            managedContext.delete(theContact!)
            
            do {
                try managedContext.save()
                self.navigationController?.popViewController(animated: true);
            } catch let error as NSError {
                print("Error While Deleting contact: \(error.userInfo)")
            }
            
        
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        //let noteEntity = "Note" //Entity Name
        
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        //let note = contacts[indexPath.row]
        
        if editingStyle == .delete {
            managedContext.delete(theContact!)
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Error While Deleting Note: \(error.userInfo)")
            }
            
        }
//
//        //Code to Fetch New Data From The DB and Reload Table.
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: noteEntity)
//
//        do {
//            self.contacts = try managedContext.fetch(fetchRequest) as! [Contact]
//        } catch let error as NSError {
//            print("Error While Fetching Data From DB: \(error.userInfo)")
//        }
//        self.tableView.reloadData()
    }
    

    func setupForm() {
        if(theContact != nil) {
            form.sections = [self.section1, self.section2, section3, section4, section5, section6]
        }
        else {
            form.sections = [self.section1, self.section2, section3, section4, section5]

        }
        self.form = form
        
    }

    func calculatePhoneCount() {
        phoneCount = 0
        if(theContact?.myPhone != nil) {
            for myItem in (theContact?.myPhone )!{
                
                phoneCount = phoneCount + 1
                
            }
        }
        
    }
    
    func calculateEmailCount() {
        emailCount = 0
        if(theContact?.myEmail != nil) {
            for myItem in (theContact?.myEmail )!{
                
                emailCount = emailCount + 1
                
            }
        }
        
    }
    func submit() {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
       // var contact:Contact
        if(theContact != nil) {
            contact = theContact!
        }
        else {
            contact = Contact(context: context) // Link Task & Context

        }
        contact?.firstName = self.section1.rows[0].value as! String
        contact?.lastName = self.section1.rows[1].value as! String
        contact?.dateOfBirth = self.section1.rows[2].value as! Date
        
        var address:Address
        var myAddress:Address
        theContact = contact
        
        //var addresses = NSSet(array: [address])
        var rowIndex:Int = 0
        for myItem in (self.section2.rows) {
            //print(myItem.value);
            //var thisItem = myItem as Address
            if(myItem.value != nil) {
                if(theContact?.myAddress?.allObjects == nil || theContact?.myAddress?.allObjects.count == 0) {
                    myAddress = Address(context: context)
                }
                else {
                    myAddress=theContact?.myAddress?.allObjects[rowIndex] as! Address;
                }
                myAddress.setValue(myItem.value, forKey: "myText")
                myAddress.myContact=contact;
            }
            rowIndex = rowIndex + 1

        }
        
        
        
        
        self.savePhoneToCore()
        self.saveEmailToCore()

        self.navigationController?.popViewController(animated: true)
        print("submit");
    }
    
    
    func savePhoneToCore() {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        //phone
        var rowIndexPhone:Int = 0
        for myItem in (self.section3.rows) {
            //print(myItem.value);
            //var thisItem = myItem as Address
            if(myItem.value != nil) {
                var myPhone:Phone = Phone(context: context)
                
                if(theContact?.myPhone?.allObjects == nil || theContact?.myPhone?.allObjects.count == 0 || (theContact?.myPhone?.allObjects.count)! < rowIndexPhone) {
                    myPhone = Phone(context: context)
                }
                else {
                    var myObjects = theContact?.myPhone?.allObjects;
                    if((myObjects?.count)! <= rowIndexPhone) {
                        myPhone = Phone(context: context)
                        
                    }
                    else {
                        myPhone=myObjects![rowIndexPhone] as! Phone;
                    }
                }
                
                myPhone.setValue(myItem.value, forKey: "myText");
                myPhone.myContact=contact;
                rowIndexPhone = rowIndexPhone + 1
                
            }
            
            
        }
        
        // Save the data to coredata
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
    }
    
    func saveEmailToCore() {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        //phone
        var rowIndexEmail:Int = 0
        for myItem in (self.section4.rows) {
            //print(myItem.value);
            //var thisItem = myItem as Address
            if(myItem.value != nil) {
                var myEmail:Email = Email(context: context)
                
                if(theContact?.myEmail?.allObjects == nil || theContact?.myEmail?.allObjects.count == 0 || (theContact?.myEmail?.allObjects.count)! < rowIndexEmail) {
                    myEmail = Email(context: context)
                }
                else {
                    var myObjects = theContact?.myEmail?.allObjects;
                    if((myObjects?.count)! <= rowIndexEmail) {
                        myEmail = Email(context: context)
                        
                    }
                    else {
                        myEmail = myObjects![rowIndexEmail] as! Email;
                    }
                }
                
                myEmail.setValue(myItem.value, forKey: "myText");
                myEmail.myContact=contact;
                rowIndexEmail = rowIndexEmail + 1
                
            }
            
            
        }
        
        // Save the data to coredata
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
    }
    
    
    
    
    
    
    func removePhone() {
        self.calculatePhoneCount()
        var phoneToRemove:FormRowDescriptor

        if(self.section3.rows.count == 4 && theContact == nil) {
       // if(self.phoneCount == 2) {
            self.section3.rows.popLast();
            phoneToRemove=self.section3.rows.popLast()!;
            self.tableView.reloadData()
       // }
        }
        else if(theContact != nil && self.section3.rows.count == 3) {
            self.section3.rows.remove(at: self.section3.rows.count - 2)
        }
        else if(self.section3.rows.count != 2) {
            phoneToRemove=self.section3.rows.popLast()!;
           
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<Phone> = Phone.fetchRequest()
        
        if(theContact?.myPhone != nil) {
            var phones:Array = (theContact?.myPhone)!.allObjects
        
        if(phones.count > 0) {
        
        let lastPhone:Phone = phones[phones.count - 1] as! Phone
        var myThing:NSManagedObjectID = lastPhone.objectID as! NSManagedObjectID
        
        fetchRequest.predicate = NSPredicate.init(format: "self == %@", myThing)
        let object = try! managedContext.fetch(fetchRequest)
        
        if let result = try? managedContext.fetch(fetchRequest) {
            for object in result {
                managedContext.delete(object)
            }
        }
        
        do {
            try managedContext.save()
            //self.navigationController?.popViewController(animated: true);
            // self.tableView.reloadData();
            
        } catch let error as NSError {
            print("Error While Deleting contact: \(error.userInfo)")
        }
        
        
        }
        
        }
        }
    
        self.tableView.reloadData();

    }
    
    func addEmail() {
        
        
        
        if(self.section4.rows.count == 2) {
            var row = FormRowDescriptor(tag: "button", type: .button, title: "Remove Last Email")
            row.configuration.cell.required=false;

            row.configuration.button.didSelectClosure = { _ in
                self.removeEmail();
                
            }
            
            
            self.section4.rows.append(row)
        }
        
        var row = FormRowDescriptor(tag: "email", type: .email, title: "Email")
        section4.rows.append(row)
        
        self.setupForm()
        self.tableView.reloadData();
        
        
        print("add phone")
        
    }
    
    
    
    func addPhone() {
        if(self.section3.rows.count == 2) {
            var row = FormRowDescriptor(tag: "button", type: .button, title: "Remove Last Phone")
            row.configuration.cell.required=false
            row.configuration.button.didSelectClosure = { _ in
                self.removePhone();

            }


            self.section3.rows.append(row)
        }
        
        var row = FormRowDescriptor(tag: "phone", type: .phone, title: "Phone")
        section3.rows.append(row)
        
        self.setupForm()
        self.tableView.reloadData();
        
        
        print("add phone")
        
    }
    
    
    

    
    func removeEmail() {
        if(self.section4.rows.count == 4) {
            self.section4.rows.popLast();
            self.section4.rows.popLast();
        }
        else {
            self.section4.rows.popLast();
            
        }
        //self.addAddress()
        self.tableView.reloadData();
        
    }
  
    func removeAddress() {
        var addressToRemove:FormRowDescriptor
        if(self.section2.rows.count == 3) {
            self.section2.rows.popLast();
            self.section2.rows.popLast();
            addressToRemove=self.section2.rows.popLast()!;
            var row = FormRowDescriptor(tag: "button", type: .button, title: "Add Another Address")
            row.configuration.cell.required=false
            self.section2.rows.append(row)
            row.configuration.button.didSelectClosure = { _ in
                self.addAddress()
            }
            
            
        }
        else {
            addressToRemove=self.section2.rows.popLast()!;
            
        }
        //self.addAddress()
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let fetchRequest: NSFetchRequest<Address> = Address.fetchRequest()
        var addresses:Array = (theContact?.myAddress)!.allObjects
        
        let lastAddress:Address = addresses[addresses.count - 1] as! Address
        var myThing:NSManagedObjectID = lastAddress.objectID as! NSManagedObjectID
        
        fetchRequest.predicate = NSPredicate.init(format: "self == %@", myThing)
        let object = try! managedContext.fetch(fetchRequest)
        
        if let result = try? managedContext.fetch(fetchRequest) {
            for object in result {
                managedContext.delete(object)
            }
        }
        
        
        
        //let note = contacts[indexPath.row]
        //theContact?.myAddress.
        
        //managedContext.delete(addressToRemove.value as! NSManagedObject)
        
        do {
            try managedContext.save()
            //self.navigationController?.popViewController(animated: true);
           // self.tableView.reloadData();
            
        } catch let error as NSError {
            print("Error While Deleting contact: \(error.userInfo)")
        }
        
        
        
        self.tableView.reloadData();
        
    }
    func addAddress() {
        if(self.section2.rows.count == 1) {
            var row = FormRowDescriptor(tag: "button", type: .button, title: "Remove Last Address")
            row.configuration.cell.required=false
            row.configuration.button.didSelectClosure = { _ in
                self.removeAddress();
                
            }
            
            
            self.section2.rows.append(row)
        }
        
        var row = FormRowDescriptor(tag: "address", type: .text, title: "Address")
        section2.rows.append(row)
        
        self.setupForm()
        self.tableView.reloadData();
        
        print(" add address");
    }
    



    
}

