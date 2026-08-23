//
//  NotificationDecodingTests.swift
//  KkobungdanTests
//

@testable import Kkobungdan
import XCTest

/// 스펙 밖 `notification_type`·`status` 값 하나 때문에 알림 목록 **전체**가 안 뜨던 회귀를 고정한다.
final class NotificationDecodingTests: XCTestCase {
  private func makeDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }

  private func listJSON(type: String, status: String) -> Data {
    Data("""
    {
      "total": 1,
      "page": 1,
      "page_size": 20,
      "notifications": [
        {
          "id": 1,
          "user_id": "u-1",
          "notification_type": "\(type)",
          "title": "입금 안내",
          "body": "24시간 내에 입금해주세요.",
          "data": null,
          "related_entity_type": null,
          "related_entity_id": null,
          "status": "\(status)",
          "fcm_message_id": null,
          "error_message": null,
          "created_at": "2026-08-23T10:00:00",
          "sent_at": null,
          "delivered_at": null,
          "read_at": null
        }
      ]
    }
    """.utf8)
  }

  func test_알_수_없는_notification_type_이_와도_목록이_디코딩된다() throws {
    let page = try makeDecoder().decode(
      NotificationListResponseDTO.self,
      from: listJSON(type: "deposit_deadline", status: "sent")
    )

    XCTAssertEqual(page.notifications.count, 1)
    XCTAssertEqual(page.notifications[0].notificationType, .unknown)
    XCTAssertEqual(page.toDomain().notifications[0].title, "입금 안내")
  }

  func test_알_수_없는_status_가_와도_목록이_디코딩되고_안읽음으로_취급된다() throws {
    let page = try makeDecoder().decode(
      NotificationListResponseDTO.self,
      from: listJSON(type: "payment_reminder", status: "queued")
    )

    XCTAssertEqual(page.notifications[0].status, .unknown)
    XCTAssertFalse(page.toDomain().notifications[0].isRead)
  }

  func test_알려진_값은_그대로_디코딩된다() throws {
    let page = try makeDecoder().decode(
      NotificationListResponseDTO.self,
      from: listJSON(type: "payment_reminder", status: "read")
    )

    XCTAssertEqual(page.notifications[0].notificationType, .paymentReminder)
    XCTAssertTrue(page.toDomain().notifications[0].isRead)
  }
}
