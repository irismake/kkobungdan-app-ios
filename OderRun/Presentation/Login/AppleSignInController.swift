//
//  AppleSignInController.swift
//  OderRun
//
//  Created by 김가희 on 5/11/26.
//

import AuthenticationServices
import UIKit

enum AppleSignInError: Error {
  case canceled
  case tokenMissing
  case networkError
  case unknown
}

struct AppleSignInCredential {
  let authorizationCode: String
  let userName: String?
}

@MainActor
final class AppleSignInController: NSObject {
  private var continuation: CheckedContinuation<AppleSignInCredential, Error>?
  private var anchor: ASPresentationAnchor?

  override nonisolated init() {
    super.init()
  }

  func requestSignIn() async throws -> AppleSignInCredential {
    try await withCheckedThrowingContinuation { continuation in
      self.continuation = continuation

      let request = ASAuthorizationAppleIDProvider().createRequest()
      request.requestedScopes = [.fullName, .email]

      let controller = ASAuthorizationController(authorizationRequests: [request])
      controller.delegate = self
      controller.presentationContextProvider = self
      controller.performRequests()
    }
  }

  private func resume(_ result: Result<AppleSignInCredential, Error>) {
    continuation?.resume(with: result)
    continuation = nil
  }
}

extension AppleSignInController: ASAuthorizationControllerDelegate {
  func authorizationController(
    controller _: ASAuthorizationController,
    didCompleteWithAuthorization authorization: ASAuthorization
  ) {
    guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
          let codeData = credential.authorizationCode,
          let authorizationCode = String(data: codeData, encoding: .utf8)
    else {
      resume(.failure(AppleSignInError.tokenMissing))
      return
    }

    let userName: String? = {
      guard let name = credential.fullName else {
        return nil
      }
      let formatter = PersonNameComponentsFormatter()
      formatter.style = .default
      let formatted = formatter.string(from: name).trimmingCharacters(in: .whitespaces)
      return formatted.isEmpty ? nil : formatted
    }()

    resume(.success(AppleSignInCredential(authorizationCode: authorizationCode, userName: userName)))
  }

  func authorizationController(
    controller _: ASAuthorizationController,
    didCompleteWithError error: Error
  ) {
    let nsError = error as NSError
    if let authError = error as? ASAuthorizationError {
      switch authError.code {
      case .canceled:
        resume(.failure(AppleSignInError.canceled))
        return
      default:
        break
      }
    }
    if nsError.domain == NSURLErrorDomain {
      resume(.failure(AppleSignInError.networkError))
      return
    }
    resume(.failure(AppleSignInError.unknown))
  }
}

extension AppleSignInController: ASAuthorizationControllerPresentationContextProviding {
  func presentationAnchor(for _: ASAuthorizationController) -> ASPresentationAnchor {
    if let anchor {
      return anchor
    }
    let resolved = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap(\.windows)
      .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    anchor = resolved
    return resolved
  }
}
