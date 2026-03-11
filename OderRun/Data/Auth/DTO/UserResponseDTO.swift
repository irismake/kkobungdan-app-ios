import Foundation

struct UserResponseDTO: Decodable {
  let id: String
  let email: String
  let name: String
  let phone: String
  let createdAt: String
  let lastLoginAt: String
}

extension UserResponseDTO {
  func toDomain(dateFormatter: ISO8601DateFormatter = ISO8601DateFormatter()) -> User {
    User(
      id: id,
      email: email,
      name: name,
      phone: phone,
      createdAt: dateFormatter.date(from: createdAt) ?? Date(),
      lastLoginAt: dateFormatter.date(from: lastLoginAt) ?? Date()
    )
  }
}
