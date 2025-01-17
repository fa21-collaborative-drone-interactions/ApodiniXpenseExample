//
// This source file is part of the Apodini Xpense Example
//
// SPDX-FileCopyrightText: 2018-2021 Paul Schmiedmayer and project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Apodini
import ApodiniAuthorization
import Foundation
import XpenseModel


struct UpdateTransaction: Handler {
    struct UpdateTransactionMediator: Codable {
        let amount: Transaction.Cent?
        let description: String?
        var date: Date?
        let location: Coordinate?
        let account: UUID?
    }
    
    
    @Environment(\.xpenseModel) var xpenseModel
    
    @Binding var transactionId: UUID
    
    @Parameter(.http(.body)) var transaction: UpdateTransactionMediator
    
    @Throws(.notFound, reason: "The Account could not be found") var accountNotFound: ApodiniError
    @Throws(.notFound, reason: "The Transaction could not be found") var transactionNotFound: ApodiniError
    
    @Authorized(User.self) var user
    
    func handle() async throws -> Transaction {
        let user = try user()
        
        guard var oldTransaction = xpenseModel.transaction(transactionId) else {
            throw transactionNotFound
        }
        
        guard xpenseModel.account(oldTransaction.account)?.userID == user.id,
              xpenseModel.account(transaction.account ?? oldTransaction.account)?.userID == user.id else {
            throw accountNotFound
        }
        
        
        if let amount = transaction.amount {
            oldTransaction.amount = amount
        }
        if let description = transaction.description {
            oldTransaction.description = description
        }
        if let date = transaction.date {
            oldTransaction.date = date
        }
        if let location = transaction.location {
            oldTransaction.location = location
        }
        if let account = transaction.account {
            oldTransaction.account = account
        }
        
        return try await xpenseModel.save(oldTransaction)
    }
    
    var metadata: Metadata {
        Operation(.update)
    }
}
