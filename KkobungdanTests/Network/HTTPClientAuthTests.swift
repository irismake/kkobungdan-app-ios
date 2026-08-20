//
//  HTTPClientAuthTests.swift
//  KkobungdanTests
//
//  401 응답에서 토큰 갱신·강제 로그아웃이 "상태코드"가 아니라 "에러 코드"로 갈리는지 검증한다.
//  잘못 건드리면 전 사용자가 로그인 화면으로 튕기는 경로라 규칙을 테스트로 고정한다.
//
//   - 갱신 시도: 401 `INVALID_TOKEN` 이고, 실패한 요청이 `/v1/auth/refresh` 가 아닐 때만
//   - 강제 로그아웃: `/v1/auth/refresh` 응답이 `INVALID_TOKEN`·`USER_NOT_FOUND` 일 때만
//   - 그 외 401(`INVALID_CREDENTIALS` 등): 세션은 그대로 두고 서버 message 를 노출
//

@testable import Kkobungdan
import XCTest

private let expiredToken = "expired-access-token"
private let refreshedToken = "refreshed-access-token"

final class HTTPClientAuthTests: XCTestCase {
    private var spy: SpyAuthRepository!

    override func setUp() {
        super.setUp()
        StubURLProtocol.reset()
        spy = SpyAuthRepository()
        TokenStorage.shared.accessToken = expiredToken
        TokenStorage.shared.refreshToken = "refresh-token"
    }

    override func tearDown() {
        StubURLProtocol.reset()
        TokenStorage.shared.clear()
        spy = nil
        super.tearDown()
    }

    // MARK: - 갱신 시도

    func test_401_INVALID_TOKEN_이면_갱신하고_원요청을_재시도한다() async throws {
        StubURLProtocol.enqueue(401, Self.errorBody("INVALID_TOKEN", "유효하지 않은 토큰입니다."))
        StubURLProtocol.enqueue(200, #"{"success": true, "data": null, "message": null}"#)

        try await makeClient().postVoid("/v1/proposal")

        XCTAssertEqual(spy.refreshCallCount, 1, "갱신은 요청당 한 번만 수행돼야 합니다.")
        XCTAssertEqual(StubURLProtocol.requests.count, 2, "갱신 후 원요청을 재시도해야 합니다.")
        XCTAssertEqual(
            StubURLProtocol.requests.last?.value(forHTTPHeaderField: "Authorization"),
            "Bearer \(refreshedToken)",
            "재시도는 갱신된 액세스 토큰으로 나가야 합니다."
        )
    }

    func test_401_INVALID_CREDENTIALS_는_갱신도_로그아웃도_하지_않는다() async {
        StubURLProtocol.enqueue(401, Self.errorBody("INVALID_CREDENTIALS", "로그인 정보가 올바르지 않습니다."))

        await assertThrowsServerError(.invalidCredentials, message: "로그인 정보가 올바르지 않습니다.") {
            try await self.makeClient().postVoid("/v1/auth/login/send")
        }

        XCTAssertEqual(spy.refreshCallCount, 0, "세션과 무관한 401 은 갱신을 건드리면 안 됩니다.")
        XCTAssertEqual(StubURLProtocol.requests.count, 1, "재시도하면 안 됩니다.")
        XCTAssertEqual(TokenStorage.shared.accessToken, expiredToken, "세션이 유지돼야 합니다.")
    }

    func test_봉투_없는_401_은_갱신하지_않는다() async {
        // 프록시·게이트웨이가 서버 봉투 없이 내려주는 401. 에러 코드를 알 수 없으므로 갱신 대상이 아니다.
        StubURLProtocol.enqueue(401, "Unauthorized")

        await assertThrows(RepositoryError.unauthorized) {
            try await self.makeClient().postVoid("/v1/proposal")
        }

        XCTAssertEqual(spy.refreshCallCount, 0)
        XCTAssertEqual(StubURLProtocol.requests.count, 1)
        XCTAssertEqual(TokenStorage.shared.accessToken, expiredToken, "세션이 유지돼야 합니다.")
    }

    // MARK: - 강제 로그아웃

    func test_갱신_후에도_INVALID_TOKEN_이면_세션을_유지한다() async {
        // 강제 로그아웃 조건은 `/v1/auth/refresh` 응답뿐이다. 일반 요청이 두 번 실패했다고
        // 로그아웃시키면 게이트웨이 오설정 하나로 전 사용자가 튕긴다.
        StubURLProtocol.enqueue(401, Self.errorBody("INVALID_TOKEN", "유효하지 않은 토큰입니다."))
        StubURLProtocol.enqueue(401, Self.errorBody("INVALID_TOKEN", "유효하지 않은 토큰입니다."))

        await assertThrowsServerError(.invalidToken, message: "유효하지 않은 토큰입니다.") {
            try await self.makeClient().postVoid("/v1/proposal")
        }

        XCTAssertEqual(spy.refreshCallCount, 1, "재발급은 요청당 한 번 — 무한 루프가 없어야 합니다.")
        XCTAssertEqual(StubURLProtocol.requests.count, 2)
        XCTAssertNotNil(TokenStorage.shared.accessToken, "강제 로그아웃 대상이 아닙니다.")
    }

    func test_갱신이_세션_복구_불가로_실패하면_강제_로그아웃한다() async {
        // `/v1/auth/refresh` 가 USER_NOT_FOUND(탈퇴 등) — TokenRefreshHandler 가 복구 불가로 판정한다.
        spy.refreshResult = .failure(RepositoryError.server(code: .userNotFound, message: "사용자를 찾을 수 없습니다."))
        StubURLProtocol.enqueue(401, Self.errorBody("INVALID_TOKEN", "유효하지 않은 토큰입니다."))

        await assertThrows(RepositoryError.unauthorized) {
            try await self.makeClient().postVoid("/v1/proposal")
        }

        XCTAssertEqual(spy.refreshCallCount, 1)
        XCTAssertNil(TokenStorage.shared.accessToken, "강제 로그아웃으로 토큰이 정리돼야 합니다.")
        XCTAssertNil(TokenStorage.shared.refreshToken)
    }

    func test_갱신이_일시적_오류로_실패하면_세션을_유지한다() async {
        // 네트워크 오류 등은 세션 복구 불가가 아니다 — 로그아웃시키면 안 된다.
        spy.refreshResult = .failure(RepositoryError.network)
        StubURLProtocol.enqueue(401, Self.errorBody("INVALID_TOKEN", "유효하지 않은 토큰입니다."))

        await assertThrows(RepositoryError.network) {
            try await self.makeClient().postVoid("/v1/proposal")
        }

        XCTAssertEqual(TokenStorage.shared.accessToken, expiredToken, "세션이 유지돼야 합니다.")
    }

    // MARK: - 인터셉트하지 않는 클라이언트

    func test_unauthenticated_클라이언트는_401_을_그대로_넘긴다() async {
        // `/v1/auth/*` 는 이 클라이언트로 나간다. 갱신 요청이 자기 자신을 재귀 호출하지 않는 것도 이 분기가 보장한다.
        StubURLProtocol.enqueue(401, Self.errorBody("INVALID_TOKEN", "유효하지 않은 토큰입니다."))

        await assertThrowsServerError(.invalidToken, message: "유효하지 않은 토큰입니다.") {
            try await self.makeClient(authenticates: false).postVoid("/v1/auth/refresh")
        }

        XCTAssertEqual(spy.refreshCallCount, 0)
        XCTAssertEqual(StubURLProtocol.requests.count, 1)
        XCTAssertNil(
            StubURLProtocol.requests.first?.value(forHTTPHeaderField: "Authorization"),
            "인증 헤더를 붙이지 않아야 합니다."
        )
    }

    // MARK: - Helpers

    private static func errorBody(_ code: String, _ message: String) -> String {
        """
        {"success": false, "error": {"code": "\(code)", "message": "\(message)", "details": null},
         "timestamp": "2026-08-20T00:00:00+00:00"}
        """
    }

    private func makeClient(authenticates: Bool = true) -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        let refresher = TokenRefreshHandler(
            tokenStorage: .shared,
            refreshTokenUseCase: { [spy] in RefreshTokenUseCase(authRepository: spy!) }
        )
        return HTTPClient(
            tokenStorage: .shared,
            session: URLSession(configuration: configuration),
            authenticates: authenticates,
            tokenRefresher: refresher
        )
    }

    private func assertThrows(
        _ expected: RepositoryError,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ operation: () async throws -> Void
    ) async {
        do {
            try await operation()
            XCTFail("에러가 발생해야 합니다. (기대: \(expected))", file: file, line: line)
        } catch let error as RepositoryError {
            XCTAssertEqual(
                String(describing: error), String(describing: expected),
                "기대와 다른 에러입니다.", file: file, line: line
            )
        } catch {
            XCTFail("RepositoryError 가 아닙니다: \(error)", file: file, line: line)
        }
    }

    private func assertThrowsServerError(
        _ expectedCode: ServerErrorCode,
        message expectedMessage: String,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ operation: () async throws -> Void
    ) async {
        await assertThrows(.server(code: expectedCode, message: expectedMessage), file: file, line: line, operation)
    }
}

// MARK: - Stubs

/// 큐에 넣어둔 응답을 요청 순서대로 돌려주고, 나간 요청을 기록한다.
private final class StubURLProtocol: URLProtocol {
    private static var responses: [(status: Int, body: String)] = []
    private(set) static var requests: [URLRequest] = []

    static func enqueue(_ status: Int, _ body: String) {
        responses.append((status, body))
    }

    static func reset() {
        responses = []
        requests = []
    }

    override class func canInit(with _: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        Self.requests.append(request)
        guard !Self.responses.isEmpty else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        let next = Self.responses.removeFirst()
        let response = HTTPURLResponse(
            url: request.url!, statusCode: next.status, httpVersion: nil, headerFields: nil
        )!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data(next.body.utf8))
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

/// 갱신 호출 횟수와 결과만 통제한다. 나머지 메서드는 이 테스트에서 호출되지 않는다.
private final class SpyAuthRepository: AuthRepositoryProtocol, @unchecked Sendable {
    private(set) var refreshCallCount = 0
    var refreshResult: Result<String, Error> = .success(refreshedToken)

    func refresh(refreshToken _: String) async throws -> String {
        refreshCallCount += 1
        let token = try refreshResult.get()
        // 실제 AuthRepository 와 동일하게 갱신된 토큰을 저장한다. (재시도 요청이 이 값을 쓴다)
        TokenStorage.shared.accessToken = token
        return token
    }

    func sendSignupCode(name _: String, phone _: String, carrier _: String) async throws -> PhoneVerification {
        fatalError("이 테스트에서 호출되지 않습니다.")
    }

    func confirmSignupCode(code _: String, phone _: String) async throws -> AuthTokens {
        fatalError("이 테스트에서 호출되지 않습니다.")
    }

    func sendLoginCode(phone _: String) async throws -> PhoneVerification {
        fatalError("이 테스트에서 호출되지 않습니다.")
    }

    func confirmLoginCode(code _: String, phone _: String) async throws -> AuthTokens {
        fatalError("이 테스트에서 호출되지 않습니다.")
    }

    func signup(email _: String, password _: String, name _: String, phone _: String) async throws {
        fatalError("이 테스트에서 호출되지 않습니다.")
    }

    func logout(refreshToken _: String) async throws {
        fatalError("이 테스트에서 호출되지 않습니다.")
    }
}
