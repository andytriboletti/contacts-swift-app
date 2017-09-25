//
//  IndexTableViewController.swift
//  Code Test Andy Triboletti
//
//  Created by Andy Triboletti on 9/22/17.
//  Copyright © 2017 GreenRobot LLC. All rights reserved.
//

import UIKit

class IndexTableViewController: UITableViewController {
    var contacts: [Contact] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let searchController = UISearchController(searchResultsController: nil)

    var filteredContacts:[Contact] = []

    override func viewDidAppear(_ animated: Bool) {
        self.getData()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar

        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
//        self.tableView.delegate=self;
//        self.tableView.dataSource=self;
        //self.getData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getData() {
        do {
            contacts = try context.fetch(Contact.fetchRequest())
        }
        catch {
            print("Fetching Failed")
        }
        self.tableView.reloadData()
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return contacts.count
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredContacts.count
        }
        else {
            return contacts.count
        }
    }
    


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mycell", for: indexPath)
        var contact:Contact
        
        if isFiltering() {
            contact = filteredContacts[indexPath.row]
        } else {
            contact = contacts[indexPath.row]
        }
        
        cell.textLabel?.text=contact.firstName! + " " + contact.lastName!
         //Configure the cell...

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
     /Users/andytriboletti/servicefusion/Code Test Andy Triboletti/Pods   return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        var theController = segue.destination as! AddContactViewController
        let indexPath = self.tableView.indexPathForSelectedRow
        let selectedRow = indexPath?.row

        //let thisTask = fetchedResultsController.objectAtIndexPath(indexPath!) as! Contact
        
       // theController.theContact=thisTask
        
        if let indexPath = tableView.indexPathForSelectedRow{
            let selectedRow = indexPath.row
            let detailVC = segue.destination as! AddContactViewController
            detailVC.theContact = self.contacts[selectedRow]
        }
        
    }
 
    
    // MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredContacts = contacts.filter({( contact : Contact) -> Bool in
            return (((contact.firstName?.lowercased())! + " " + (contact.lastName?.lowercased())!).contains(searchText.lowercased()))
        })
        
        tableView.reloadData()
    }



    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
}


extension IndexTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {

        filterContentForSearchText(searchController.searchBar.text!)
    }
}
