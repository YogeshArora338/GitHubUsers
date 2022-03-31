//
//  Array+GitHubUsers.swift
//  GitHubUsers
//
//  Created by Yogesh Arora on 31/03/22.
//

extension Array where Element: Equatable {
    mutating func removeDuplicates() {
        let result = self.removingDuplicates()
        self = result
    }
    
    func removingDuplicates() -> [Element] {
        var result = [Element]()
        for el in self {
            if !result.contains(el) {
                result.append(el)
            }
        }
        return result
    }
    
    /// True if any elements in the given array are contained by this array.
    /// (E.g. [1, 2, 3].contains(anyOf: [3, 4, 5]) is true because both contain 3.
    func contains(anyOf other: [Element]) -> Bool {
        return self.contains { el -> Bool in
            return other.contains(el)
        }
    }
}
