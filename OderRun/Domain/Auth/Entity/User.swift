//
//  User.swift
//  OderRun
//
//  Created by 김가희 on 3/4/26.
//

import Foundation

struct User: Equatable {
  let id: String
  let email: String
  let name: String
  let phone: String
  let createdAt: Date
  let lastLoginAt: Date
}
