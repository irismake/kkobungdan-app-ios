//
//  NotificationDTO.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

/// `GET /v1/notifications` 응답의 `data` 페이로드. (`{success, data, message}` envelope 으로 감싸져 온다)
struct NotificationListResponseDTO: Decodable {
  let total: Int
  let notifications: [NotificationDTO]
  let page: Int
  let pageSize: Int
}

struct NotificationDTO: Decodable {
  let id: Int
  let userID: String
  let notificationType: NotificationType
  let title: String
  let body: String
  let data: String?
  let relatedEntityType: String?
  let relatedEntityID: Int?
  let status: NotificationStatus
  let fcmMessageID: String?
  let errorMessage: String?
  let createdAt: String
  let sentAt: String?
  let deliveredAt: String?
  let readAt: String?

  /// 전역 디코더가 .convertFromSnakeCase 라 키는 camelCase 기준으로 매핑된다.
  /// (user_id → userId) "ID" 접미사 프로퍼티만 변환 결과와 어긋나므로 명시 매핑한다.
  enum CodingKeys: String, CodingKey {
    case id
    case userID = "userId"
    case notificationType
    case title
    case body
    case data
    case relatedEntityType
    case relatedEntityID = "relatedEntityId"
    case status
    case fcmMessageID = "fcmMessageId"
    case errorMessage
    case createdAt
    case sentAt
    case deliveredAt
    case readAt
  }
}

extension NotificationDTO {
  func toDomain() -> AppNotification {
    // TODO: userId, notificationType, data, relatedEntityType, relatedEntityId,
    //       fcmMessageId, errorMessage, sentAt, deliveredAt, readAt — UI 반영 시 엔티티에 추가
    AppNotification(
      id: id,
      title: title,
      body: body,
      createdAt: DateFormatters.parse(createdAt),
      isRead: status == .read
    )
  }
}
