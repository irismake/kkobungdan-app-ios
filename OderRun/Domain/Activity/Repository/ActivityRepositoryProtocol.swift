//
//  ActivityRepositoryProtocol.swift
//  OderRun
//
//  Created by 김가희 on 5/13/26.
//

import Foundation

protocol ActivityRepositoryProtocol: Sendable {
  func fetchMyActivities(
    role: MissionRole?,
    status: MissionStatus?,
    page: Int,
    size: Int
  ) async throws -> [Mission]
}
