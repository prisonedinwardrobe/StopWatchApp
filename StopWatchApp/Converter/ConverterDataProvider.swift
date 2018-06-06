//
//  ConverterDataProvider.swift
//  StopWatchApp
//
//  Created by leonid on 30.05.2018.
//  Copyright © 2018 CSU. All rights reserved.
//

import UIKit
import CryptoCurrencyKit

class ConverterDataProvider: NSObject {
    
   static let shared = { ConverterDataProvider() }()
    
    func fetchTickers(completion: @escaping (_ tickers:[tickerTuple], _ error: Error?) -> Void) {
        CryptoCurrencyKit.fetchTickers(convert: .usd, limit: 10) { result in
            switch result {
            case .success(let tickers):
                completion(tickers.compactMap({ ($0.name, $0.priceUSD ?? 0) }), nil)
                
            case .failure(let error):
                completion([tickerTuple](), error)
            }
        }
    }
}
