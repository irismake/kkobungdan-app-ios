//
//  NotificationRepositoryImpl.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//
//  TODO: API 미정 — 더미 전용. 실제 스펙 확정 시 교체.
//

import Foundation

actor NotificationRepositoryImpl: NotificationRepositoryProtocol {
  private static let simulatedLatency: UInt64 = 500_000_000

  private var notifications: [NotificationDTO] = [
    .init(
      id: "n-1",
      title: "새 지원이 도착했어요",
      body: "홍길동님이 '약국에서 약 수령' 요청에 지원했어요.",
      createdAt: "2026-04-22T09:20:00",
      isRead: false
    ),
    .init(
      id: "n-2",
      title: "매칭 완료",
      body: "'저녁 식사 픽업' 요청의 러너로 지현님이 확정됐어요.",
      createdAt: "2026-04-22T08:05:00",
      isRead: false
    ),
    .init(
      id: "n-3",
      title: "전달 완료",
      body: "'택배 맡기기' 미션이 전달 완료로 업데이트됐어요. 수령 확인 부탁드립니다.",
      createdAt: "2026-04-21T16:45:00",
      isRead: true
    ),
    .init(
      id: "n-4",
      title: "정산 완료",
      body: "지난 주 심부름비 18,000원이 정산됐어요.",
      createdAt: "2026-04-20T20:00:00",
      isRead: true
    ),
    .init(
      id: "n-5",
      title: "프로모션 안내",
      body: "이번 주 심야 시간대 심부름비 10% 추가 적립 이벤트가 진행 중입니다.",
      createdAt: "2026-04-19T11:30:00",
      isRead: true
    )
  ]

  func fetchNotifications() async throws -> [AppNotification] {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return notifications
      .sorted { $0.createdAt > $1.createdAt }
      .map { $0.toDomain() }
  }

  func markAsRead(id: String) async throws {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    guard let index = notifications.firstIndex(where: { $0.id == id }) else {
      throw RepositoryError.notFound
    }
    let existing = notifications[index]
    notifications[index] = NotificationDTO(
      id: existing.id,
      title: existing.title,
      body: existing.body,
      createdAt: existing.createdAt,
      isRead: true
    )
  }
}
