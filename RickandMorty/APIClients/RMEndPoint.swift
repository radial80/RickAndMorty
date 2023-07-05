//
//  RMEndPoint.swift
//  RickandMorty
//
//  Created by Kasım Sağır on 15.06.2023.
//

import Foundation



/// Represent Unique API Endpoint
@frozen enum RMEndPoint: String {
    /// Endpoint to get character info
    case character
    /// Endpoint to get location info
    case location
    /// Endpoint to get episode info
    case episode
}

