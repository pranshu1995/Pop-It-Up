//
//  File.swift
//  1-Navigation Controller
//
//  Created by Pranshu Midha on 28/04/21.
//

import Foundation

struct Highscore: Codable{
    // Struct for maintaining high scores
    // Codable to store in User Defaults
    var name: String;
    var score: Float;
}

