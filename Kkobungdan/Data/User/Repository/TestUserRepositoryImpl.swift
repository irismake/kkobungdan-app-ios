//
//  TestUserRepositoryImpl.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

actor TestUserRepositoryImpl: UserRepositoryProtocol {
  private static let simulatedLatency: UInt64 = 600_000_000

  private var currentUser: User = .dummy

  func fetchUserDetail() async throws -> User {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return currentUser
  }

  func updateName(_ name: String) async throws -> User {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    currentUser = User(
      id: currentUser.id,
      name: name,
      level: currentUser.level,
      alarmEnabled: currentUser.alarmEnabled
    )
    return currentUser
  }

  func updateAlarm(enabled: Bool) async throws -> User {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    currentUser = User(
      id: currentUser.id,
      name: currentUser.name,
      level: currentUser.level,
      alarmEnabled: enabled
    )
    return currentUser
  }

  func updateFcmToken(_: String) async throws {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
  }

  func fetchWithdrawalReasons() async throws -> [WithdrawalReason] {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    let texts = [
      "원하는 임무가 많지 않았어요.",
      "원하는 꼬붕(또는 행님)을 만나기 어려웠어요.",
      "이용 방법이 어려웠어요.",
      "앱이 자주 오류가 났어요.",
      "다른 회원과 문제가 있었어요.",
      "다른 서비스를 이용하려고 해요.",
      "기타"
    ]
    return texts.enumerated().map { index, text in
      WithdrawalReason(
        id: Int64(index + 1),
        questionText: text,
        displayOrder: index + 1,
        requiresDetail: text == "기타"
      )
    }
  }

  func withdraw(reasonQuestionID _: Int64, detailReason _: String?) async throws {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
  }
}
