//
//  RepositoryError.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

enum RepositoryError: Error {
  case notImplemented
  case notFound
  case conflict
  case unauthorized
  case network
}
