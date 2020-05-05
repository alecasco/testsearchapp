//
//  ViewController.swift
//  testsearchapp
//
//  Created by Alejandro Casco on 4/7/20.
//  Copyright © 2020 meli. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

struct SearchResultModel: Codable {
    var site: String
    var query: String
    var results: [ItemModel]?
    
    private enum CodingKeys: String, CodingKey {
        case site = "site_id"
        case query
        case results
    }
}

struct ItemModel: Codable {
    let id: String
    let title: String
    let price: Double
    let thumbnail: String
    let currency_id: String
}

enum ListMode {
    case search
    case history
}

class ListViewController: UIViewController, UITableViewDataSource {
    
    static let HISTORY_KEY = "history-key"
    
    @IBOutlet weak var tableView: UITableView!
    var items: [ItemModel] = []
    var history: [String] = []
    var selectedRow: Int?
    var currency: String = "$"
    var queryInput: String = ""
    var site: String = ""
    public var mode: ListMode = .search
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("queryInput: ", queryInput)
        
        if (self.mode == .search) {
            searchItems()
            self.tableView.rowHeight = 100
        } else if (self.mode == .history) {
            fetchHistory()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func searchItems() {
        saveSearchToHistort();
        AF.request("https://api.mercadolibre.com/sites/\(site)/search?q=\(queryInput)",
                 method: .get).responseDecodable(of: SearchResultModel.self) { response in
          
            // response tiene JSON con data de respuesta
            if let searchResults = response.value?.results {
                self.items = searchResults
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.title = response.value?.query
                }
            }
        }
    }
    
    func saveSearchToHistort() {
        guard self.mode == .search else {
            return
        }
        guard self.queryInput.count > 0 else {
            return
        }
        
        var history = UserDefaults.standard.stringArray(forKey: ListViewController.HISTORY_KEY) ?? []
        history.insert(self.queryInput, at: 0)
        UserDefaults.standard.set(history, forKey: ListViewController.HISTORY_KEY)
    }
    
    func fetchHistory() {
        history = UserDefaults.standard.stringArray(forKey: ListViewController.HISTORY_KEY) ?? []
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let selected = selectedRow, let detailVC = segue.destination as? DetailViewController else {
            return
        }
        detailVC.selectedItem = items[selected]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.mode == .search) {
            return items.count
        } else {
            return history.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.mode == .search) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! CustomCellView
            cell.titleLabel.text = items[indexPath.row].title
            cell.priceLabel.text = items[indexPath.row].currency_id+" "+String(Int(items[indexPath.row].price))
            AF.request(items[indexPath.row].thumbnail).responseImage { response in
                if case .success(let image) = response.result {
                    print("image downloaded: \(image)")
                    cell.thumbnail.image = image
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell") as! HistoryCellView
            cell.label.text = history[indexPath.row]
            return cell
        }
        
    }
    
    

}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (self.mode == .search) {
            self.selectedRow = indexPath.row
            self.performSegue(withIdentifier: "detalle", sender: nil)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let listVc = storyboard.instantiateViewController(withIdentifier: "listViewController") as! ListViewController
            listVc.queryInput = history[indexPath.row]
            self.navigationController?.pushViewController(listVc, animated: true)
        }
    }
}
