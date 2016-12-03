//
//  CSwiftV.swift
//  CSwiftV
//
//  Created by Daniel Haight on 30/08/2014.
//  Copyright (c) 2014 ManyThings. All rights reserved.
//

import class Foundation.NSCharacterSet

extension String {
    
    var isEmptyOrWhitespace: Bool {
        return isEmpty ? true : stringByTrimmingCharactersInSet(.whitespaceCharacterSet()) == ""
    }
    
    var isNotEmptyOrWhitespace: Bool {
        return !isEmptyOrWhitespace
    }
    
}

// MARK: Parser
public class CSwiftV {
    
    private let columnCount: Int
    public let headers: [String]
    public let keyedRows: [[String: String]]?
    public let rows: [[String]]
    
    /// Creates an instance containing the data extracted from the `with` String
    /// - Parameter with: The String obtained from reading the csv file.
    /// - Parameter separator: The separator used in the csv file, defaults to ","
    /// - Parameter headers: The array of headers from the file. If not included, it will be populated with the ones from the first line
    
    public init(with string: String, separator: String = ",", headers: [String]? = nil) {
        var parsedLines = CSwiftV.records(from: string.stringByReplacingOccurrencesOfString("\r\n", withString: "\n")).map { CSwiftV.cells(forRow: $0, separator: separator) }
        self.headers = headers ?? parsedLines.removeFirst()
        rows = parsedLines
        columnCount = self.headers.count
        
        let tempHeaders = self.headers
        keyedRows = rows.map { field -> [String: String] in
            var row = [String: String]()
            //only store value which are not empty
            for (index, value) in field.enumerate() where value.isNotEmptyOrWhitespace {
                if index < tempHeaders.count {
                    row[tempHeaders[index]] = value
                }
            }
            return row
        }
    }
    
    public convenience init(string: String, headers: [String]?) {
        self.init(with: string, headers:headers, separator:",")
    }
    
    /// Analizes a row and tries to obtain the different cells contained as an Array of String
    /// - Parameter forRow: The string corresponding to a row of the data matrix
    /// - Parameter separator: The string that delimites the cells or fields inside the row. Defaults to ","
    internal static func cells(forRow string: String, separator: String = ",") -> [String] {
        
        return CSwiftV.split(separator, string: string).map { element in
            let first = element.characters.first
            let last = element.characters.last
            if first == "\"" && last == "\"" {
                let range = element.startIndex.successor() ..< element.endIndex.predecessor()
                return element[range]
            }
            return element
        }
    }
    
    /// Analizes the CSV data as an String, and separates the different rows as an individual String each.
    /// - Parameter forRow: The string corresponding the whole data
    /// - Attention: Assumes "\n" as row delimiter, needs to filter string for "\r\n" first
    internal static func records(from string: String) -> [String] {
        return CSwiftV.split("\n", string: string).filter { $0.isNotEmptyOrWhitespace }
    }
    
    /// Tries to preserve the parity between open and close characters for different formats. Analizes the escape character count to do so
    private static func split(_ separator: String, string: String) -> [String] {
        func oddNumberOfQuotes(_ string: String) -> Bool {
            return string.componentsSeparatedByString("\"").count % 2 == 0
        }
        
        let initial = string.componentsSeparatedByString(separator)
        var merged = [String]()
        for newString in initial {
            guard let record = merged.last where oddNumberOfQuotes(record) == true else {
                merged.append(newString)
                continue
            }
            merged.removeLast()
            let lastElem = record + separator + newString
            merged.append(lastElem)
        }
        return merged
    }
    
}
