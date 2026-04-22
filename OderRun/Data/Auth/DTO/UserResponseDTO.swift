import Foundation

struct UserResponseDTO: Decodable {
  let id: String
  let email: String
  let name: String
  let phone: String
  let createdAt: String
  let lastLoginAt: String
  let alarmEnabled: Bool
}

extension UserResponseDTO {
  func toDomain() -> User {
    User(
      id: id,
      email: email,
      name: name,
      phone: phone,
      createdAt: DateFormatters.parse(createdAt),
      lastLoginAt: DateFormatters.parse(lastLoginAt),
      alarmEnabled: alarmEnabled
    )
  }
}
