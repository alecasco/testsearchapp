//
//  DetailViewController.swift
//  testsearchapp
//
//  Created by Alejandro Casco on 4/21/20.
//  Copyright © 2020 meli. All rights reserved.
//

import UIKit
import Alamofire

struct Picture: Codable {
    var id: String
    var secure_url: String
}

struct ItemDetailModel : Codable {
    let id: String
    let title: String
    let price: Double
    var pictures: Array<Picture>
}

class DetailViewController: UIViewController {
    
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    var selectedItem: ItemModel?
    var currency: String = "$"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("RESPONSE: selectedItem", selectedItem?.id, "https://api.mercadolibre.com/items?id="+(selectedItem?.id)!)
        
        AF.request("https://api.mercadolibre.com/items?id="+(selectedItem?.id)!,
                 method: .get).responseDecodable(of: ItemDetailModel.self) { response in
          
                    print("RESPONSE: ", response)
                    self.detailLabel.text = response.value?.title
                    self.priceLabel.text = self.currency+" "+String(Int(response.value!.price))
                    
                    AF.request(response.value!.pictures[0].secure_url).responseImage { imgResponse in
                        if case .success(let img) = imgResponse.result {
                            print("image downloaded: \(img)")
                            self.image.image = img
                        }
                    }
                    
            // response tiene JSON con data de respuesta
//            if let searchResults = response.results {
//                print("RESPONSE: ",searchResults)
//                self.items = searchResults
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                    self.title = response.value?.site
//                }
            }
        }
        
}
    

