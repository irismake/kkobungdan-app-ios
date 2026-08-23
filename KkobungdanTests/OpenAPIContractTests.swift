//
//  OpenAPIContractTests.swift
//  KkobungdanTests
//
//  서버 OpenAPI 스펙(Secrets.xcconfig 의 API_BASE_HOST + /openapi.json)과 Swift DTO 의 "계약"을 검증한다.
//  스펙·픽스처는 `Scripts/sync-openapi.py` 가 자동 생성하므로 손으로 만들지 않는다.
//
//  세 가지를 자동으로 잡는다:
//   1. maximal 픽스처 디코딩 → 필드명/타입 변경
//   2. minimal 픽스처 디코딩 → DTO 가 서버 optional 필드를 required 로 잘못 선언
//   3. contract lock 비교    → 필드 추가/삭제/optional 여부 변경 (사람이 DTO 반영해야 하는 변경)
//

@testable import Kkobungdan
import XCTest

final class OpenAPIContractTests: XCTestCase {
    /// DTO ↔ 서버 스키마 매핑. 새 응답 DTO 를 추적하려면 여기 한 줄만 추가한다.
    /// (값은 `Scripts/sync-openapi.py` 가 생성한 `generated/<schema>.json` 파일명과 일치해야 함)
    private static let contracts: [DecodeContract] = [
        // Proposal
        DecodeContract("ProposalResponse", decoding(ProposalResponseDTO.self)),
        DecodeContract("ProposalDetailResponse", decoding(ProposalDetailResponseDTO.self)),
        DecodeContract("ProposalOwnOfferResponse", decoding(ProposalOwnOfferResponseDTO.self)),
        DecodeContract("ProposalOwnResponse", decoding(MyProposalResponseDTO.self)), // GET /v1/proposal/own
        // POST /v1/offer · 액션(complete-delivery·dispute) · GET /v1/offer/own — 모두 같은 OfferResponse 스키마라 DTO 공유
        DecodeContract("OfferResponse", decoding(OfferResponseDTO.self)),
        DecodeContract("OfferSummaryResponse", decoding(OfferSummaryResponseDTO.self)), // GET /v1/offer
        DecodeContract("OfferDetailResponse", decoding(OfferDetailResponseDTO.self)), // GET /v1/offer/{id}
        DecodeContract("OfferAcceptResponse", decoding(OfferAcceptResponseDTO.self)),
        // User / Settlement / Terms
        DecodeContract("UserDetailResponse", decoding(UserDetailResponseDTO.self)),
        DecodeContract("UserWithdrawalReasonQuestionResponse", decoding(UserWithdrawalReasonQuestionResponseDTO.self)), // GET /v1/user/withdrawal-reasons
        DecodeContract("SettlementAccountResponse", decoding(SettlementAccountResponseDTO.self)),
        DecodeContract("SettlementBankNamesResponse", decoding(SettlementBankNamesResponseDTO.self)),
        DecodeContract("TermsAgreementResponse", decoding(TermsAgreementResponseDTO.self)),
        // Dispute survey
        DecodeContract("DisputeSurveyQuestionResponse", decoding(DisputeSurveyQuestionResponseDTO.self)),
        DecodeContract("DisputeEvidenceResponse", decoding(DisputeEvidenceResponseDTO.self)), // GET /v1/dispute-evidence

        DecodeContract("ProposalReportReasonQuestionResponse", decoding(ProposalReportReasonQuestionResponseDTO.self)), // GET /v1/proposal-report-reasons
        DecodeContract("ProposalReportResponse", decoding(ProposalReportResponseDTO.self)), // POST /v1/proposal/{id}/reports
        // Notification
        DecodeContract("NotificationListResponse", decoding(NotificationListResponseDTO.self)),
        DecodeContract("NotificationResponse", decoding(NotificationDTO.self)),
        DecodeContract("NotificationMarkReadResponse", decoding(NotificationMarkReadResponseDTO.self)),
        DecodeContract("NotificationStatsResponse", decoding(NotificationStatsResponseDTO.self)),
        // Auth
        DecodeContract("AuthTokenResponse", decoding(AuthTokenResponseDTO.self)), // login/signup confirm
        DecodeContract("AuthVerificationSendResponse", decoding(PhoneVerificationResponseDTO.self)), // login/signup send
        DecodeContract("AuthAccessTokenResponse", decoding(RefreshTokenResponseDTO.self)), // refresh
        // 공통 에러 (non-2xx 바디)
        DecodeContract("ErrorResponse", decoding(ApiErrorDTO.self)),
        DecodeContract("ErrorDetail", decoding(ApiErrorDetailDTO.self))
        // ⚠️ Oauth 3종(LoginResponseDTO/AppleLoginResponseDTO/KakaoLoginResponseDTO)은
        //    호출 엔드포인트(/v1/auth/login, /v1/auth/oauth/*)가 현재 서버 스펙에 없어 추적 불가.
    ]

    /// 서버 응답 스키마지만 의도적으로 DTO 를 두지 않는 것(클라이언트 미사용/미연동)을 인지 처리한다.
    /// 여기에 추가하면 "DTO 누락" 검증에서 제외된다. 실제 DTO 를 구현하면 여기서 빼고 `contracts` 에 등록한다.
    /// 빈 set = 서버의 모든 응답 스키마에 대응 DTO 가 있어야 함(미구현이면 빨간불).
    private static let knownUnregisteredResponseSchemas: Set<String> = [
        // 예) "NotificationStatsResponse",  // 알림 통계 — UI 미연동
    ]

    /// 요청 바디(Encodable) ↔ 서버 요청 스키마 매핑. 인코딩한 JSON 키가 서버 스키마와 맞는지 검증한다.
    /// 새 요청 바디를 internal DTO 로 승격하면 여기에 한 줄 등록한다.
    /// ⚠️ /v1/auth/signup(SignupRequestBody, email/password)·Oauth 는 현재 서버 스펙에 없어 대조 불가 → 미등록.
    private static let requestContracts: [EncodeContract] = [
        // Offer
        EncodeContract("OfferCreate", CreateOfferBody(proposalID: 0)),
        EncodeContract("DisputeRequest", DisputeRequest(surveyQuestionID: 1, disputeReason: "사유")),
        // Settlement / User
        EncodeContract("SettlementAccountRequest", SettlementAccountRequest(
            bankName: "국민은행", accountNumber: "123", accountHolder: "홍길동"
        )),
        EncodeContract("UserNameUpdateRequest", UserNameUpdateRequest(name: "홍길동")),
        EncodeContract("UserAlarmRequest", UserAlarmRequest(alarmEnabled: true)),
        EncodeContract("UserFcmTokenRequest", UserFcmTokenRequest(fcmToken: "token")),
        EncodeContract("UserWithdrawalRequest", UserWithdrawalRequest(reasonQuestionID: 1, detailReason: "상세 사유")), // DELETE /v1/user
        // Auth
        EncodeContract("AuthSignupSendRequest", AuthSignupSendRequest(carrier: "SKT", name: "홍길동", phone: "01012345678")),
        EncodeContract("AuthSignupConfirmRequest", AuthSignupConfirmRequest(code: "123456", fcmToken: "token", phone: "01012345678")),
        EncodeContract("AuthLoginSendRequest", AuthLoginSendRequest(phone: "01012345678")),
        EncodeContract("AuthLoginConfirmRequest", AuthLoginConfirmRequest(code: "123456", fcmToken: "token", phone: "01012345678")),
        EncodeContract("AuthRefreshRequest", AuthRefreshRequest(refreshToken: "refresh")),
        EncodeContract("AuthLogoutRequest", AuthLogoutRequest(refreshToken: "refresh")),
        // Terms
        EncodeContract("TermsAgreementRequest", TermsAgreementRequest(
            termsOfService: true, privacyPolicy: true, paymentRefundPolicy: true
        )),
        // Notification
        EncodeContract("NotificationMarkReadRequest", NotificationMarkReadRequest(notificationIDs: [1, 2])),
        // Proposal
        EncodeContract("ProposalRequest", ProposalRequestBody(
            title: "제목", content: "내용", deadline: "2026-12-31T23:59:59", errandFee: 5000
        )),
        // Report
        EncodeContract("ProposalReportCreateRequest", ProposalReportCreateRequest(
            reasonQuestionID: 1, detailReason: "상세 사유"
        ))
    ]

    /// 서버 스펙 enum ↔ Swift enum 매핑. 새 스펙 enum 에 Swift enum 을 만들면 여기 한 줄 추가한다.
    /// (스키마명은 openapi.json `components/schemas` 의 enum 이름)
    private static let enumContracts: [EnumContract] = [
        EnumContract("NotificationStatus", NotificationStatus.self),
        EnumContract("NotificationType", NotificationType.self),
        EnumContract("OfferStatus", OfferStatus.self),
        // REPORTED — 배지 등 UI 가 없는 클라이언트 미사용 상태라 Swift 케이스를 두지 않는다.
        EnumContract("ProposalStatus", ProposalStatus.self, knownMissingValues: ["REPORTED"]),
        EnumContract("DisputeSurveyTargetType", DisputeSurveyTargetType.self)
    ]

    /// 서버 스펙 enum 이지만 의도적으로 Swift enum 을 두지 않는 것 (DTO 가 String 으로 유지, 클라이언트 미사용).
    /// Swift enum 을 만들면 여기서 빼고 `enumContracts` 에 등록한다.
    private static let knownUnregisteredEnumSchemas: Set<String> = [
        "ProposalReportStatus" // 신고 처리 상태 — 클라이언트 미사용 (ProposalReportResponseDTO.status: String)
    ]

    // MARK: - 1. maximal: 모든 필드가 채워진 응답을 DTO 가 읽는가 (필드명·타입 변경 감지)

    func test_maximal_픽스처가_DTO로_디코딩된다() throws {
        for contract in Self.contracts {
            let data = try generatedFixture(contract.schema, minimal: false)
            do {
                try contract.decode(data)
            } catch {
                XCTFail("[\(contract.schema)] maximal 디코딩 실패 — 서버가 필드명/타입을 바꿨을 수 있음:\n\(error)")
            }
        }
    }

    // MARK: - 2. minimal: required 필드만 왔을 때도 디코딩되는가 (DTO 과잉 required 감지)

    func test_minimal_픽스처가_DTO로_디코딩된다() throws {
        for contract in Self.contracts {
            let data = try generatedFixture(contract.schema, minimal: true)
            do {
                try contract.decode(data)
            } catch let DecodingError.keyNotFound(key, _) {
                XCTFail("""
                [\(contract.schema)] minimal 디코딩 실패: '\(key.stringValue)' 없음.
                → 서버 스펙상 optional 인 필드를 DTO 가 required(non-optional)로 선언했을 가능성. \
                해당 DTO 프로퍼티를 `?` 로 바꿔야 한다.
                """)
            } catch {
                XCTFail("[\(contract.schema)] minimal 디코딩 실패:\n\(error)")
            }
        }
    }

    // MARK: - 3. contract lock: 승인된 기준선 대비 서버 스키마가 바뀌었는가

    func test_서버_스키마가_기준선과_일치한다() throws {
        let current = try contractJSON("contract.current")
        let lock = try contractJSON("contract.lock")

        let diffs = Self.diff(lock: lock, current: current)
        if !diffs.isEmpty {
            XCTFail("""
            서버 스키마가 기준선(contract.lock.json)과 다릅니다. DTO 반영 여부를 확인하세요.
            반영을 마쳤으면 `python3 Scripts/sync-openapi.py --accept` 로 기준선을 갱신하세요.

            \(diffs.joined(separator: "\n"))
            """)
        }
    }

    // MARK: - 4. DTO 누락: 서버 응답 스키마에 대응하는 DTO 가 등록돼 있는가

    func test_서버_응답_스키마가_모두_DTO로_등록됐다() throws {
        let manifest = try responseSchemasManifest() // [스키마명: "GET /path"]
        let registered = Set(Self.contracts.map(\.schema))

        let missing = manifest.keys
            .filter { !registered.contains($0) && !Self.knownUnregisteredResponseSchemas.contains($0) }
            .sorted()

        if !missing.isEmpty {
            let lines = missing.map { "  ＋ \($0)  ⟵  \(manifest[$0] ?? "")" }
            XCTFail("""
            서버 응답 스키마에 대응하는 DTO 가 없습니다. 아래 API 의 응답 DTO 를 추가하고 `contracts` 에 등록하세요.
            (의도적으로 미구현이면 `knownUnregisteredResponseSchemas` 에 추가해 인지 처리)

            \(lines.joined(separator: "\n"))
            """)
        }
    }

    // MARK: - 5. 요청 인코딩 계약: 요청 바디(Encodable)가 서버 요청 스키마와 맞는가

    func test_요청_바디가_서버_요청_스키마와_일치한다() throws {
        let schemas = try contractJSON("contract.current")

        for contract in Self.requestContracts {
            guard let schema = schemas[contract.schema] else {
                XCTFail("[\(contract.schema)] 서버 요청 스키마를 찾지 못함 — `python3 Scripts/sync-openapi.py` 실행/스키마명을 확인하세요.")
                continue
            }
            let serverProps = Set((schema["properties"] as? [String: String])?.keys ?? [:].keys)
            let serverRequired = Set((schema["required"] as? [String]) ?? [])

            let encoded: [String: Any]
            do {
                let data = try contract.encode()
                encoded = try (JSONSerialization.jsonObject(with: data) as? [String: Any]) ?? [:]
            } catch {
                XCTFail("[\(contract.schema)] 요청 바디 인코딩 실패:\n\(error)")
                continue
            }
            let encodedKeys = Set(encoded.keys)
            let serverTypes = (schema["properties"] as? [String: String]) ?? [:]

            let unknown = encodedKeys.subtracting(serverProps).sorted() // 서버에 없는 키를 보냄
            let missingRequired = serverRequired.subtracting(encodedKeys).sorted() // 서버 required 누락

            // 전송한(=nil 이 아니라 인코딩된) 키의 JSON 타입이 서버 스키마 타입과 맞는지 확인한다.
            // 서버 optional(`anyOf(T|null)`)은 inner 타입 T 로 비교한다. nil 이라 생략된 optional 키는
            // 인코딩 결과에 없으므로 검사 대상에서 자연히 빠진다.
            let typeMismatches = encoded.keys.sorted().compactMap { key -> String? in
                guard let serverType = serverTypes[key] else { return nil } // unknown 은 위에서 별도 보고
                guard !Self.jsonType(serverType, matches: encoded[key]!) else { return nil }
                return "\(key): 서버=\(serverType), 전송=\(Self.actualTypeName(encoded[key]!))"
            }

            if !unknown.isEmpty || !missingRequired.isEmpty || !typeMismatches.isEmpty {
                XCTFail("""
                [\(contract.schema)] 요청 바디가 서버 스키마와 어긋납니다. CodingKeys/필드/타입을 확인하세요.
                - 서버에 없는 키를 전송: \(unknown.isEmpty ? "없음" : "\(unknown)")
                - 서버 required 인데 누락: \(missingRequired.isEmpty ? "없음" : "\(missingRequired)")
                - 타입 불일치: \(typeMismatches.isEmpty ? "없음" : "\(typeMismatches)")
                """)
            }
        }
    }

    // MARK: - 6. enum 계약: 스펙 enum 값 전체가 Swift enum 케이스로 표현되는가

    /// 서버가 보낼 수 있는 enum 값이 Swift enum 에 없으면 — 직접 디코딩하는 enum(Notification 계열)은
    /// 리스트 전체 디코딩 실패, `init(rawValue:) ?? fallback` 매핑 enum 은 조용한 오분류가 난다.
    /// (예: 서버가 NotificationStatus 에 `skipped` 를 추가했을 때 알림 목록이 통째로 안 뜬 사고)
    func test_스펙_enum_값이_Swift_enum_케이스로_모두_표현된다() throws {
        let specEnums = try specEnumValues()

        for contract in Self.enumContracts {
            guard let specValues = specEnums[contract.schema] else {
                XCTFail("[\(contract.schema)] 스펙에서 string enum 을 찾지 못함 — `python3 Scripts/sync-openapi.py` 실행/스키마명을 확인하세요.")
                continue
            }

            let missing = specValues
                .filter { !contract.hasCase($0) && !contract.knownMissingValues.contains($0) }
            if !missing.isEmpty {
                XCTFail("""
                [\(contract.schema)] 서버가 보낼 수 있는 값이 Swift \(contract.swiftName) 에 없습니다: \(missing)
                → 디코딩 실패 또는 fallback 오분류가 납니다. 케이스를 추가하세요.
                (UI 반영 전이라 의도적으로 미구현이면 `knownMissingValues` 에 TODO 와 함께 추가해 인지 처리)
                """)
            }

            let stale = contract.swiftRawValues.filter { !specValues.contains($0) }
            if !stale.isEmpty {
                XCTFail("[\(contract.schema)] Swift \(contract.swiftName) 에만 있고 스펙에 없는 케이스: \(stale) — 서버가 값을 삭제했는지 확인하세요.")
            }

            let resolved = contract.knownMissingValues.filter { contract.hasCase($0) || !specValues.contains($0) }
            if !resolved.isEmpty {
                XCTFail("[\(contract.schema)] `knownMissingValues` 의 \(resolved.sorted()) 는 더 이상 인지 처리가 필요 없습니다 — 목록에서 제거하세요.")
            }
        }
    }

    func test_스펙_enum_스키마가_모두_등록됐다() throws {
        let specEnums = try specEnumValues()
        let registered = Set(Self.enumContracts.map(\.schema))

        let missing = specEnums.keys
            .filter { !registered.contains($0) && !Self.knownUnregisteredEnumSchemas.contains($0) }
            .sorted()

        if !missing.isEmpty {
            let lines = missing.map { "  ＋ \($0): \(specEnums[$0] ?? [])" }
            XCTFail("""
            서버 스펙 enum 에 대응하는 Swift enum 이 등록돼 있지 않습니다. `enumContracts` 에 등록하세요.
            (Swift enum 없이 String 으로 받는 게 의도면 `knownUnregisteredEnumSchemas` 에 추가해 인지 처리)

            \(lines.joined(separator: "\n"))
            """)
        }

        let resolved = Self.knownUnregisteredEnumSchemas.filter { registered.contains($0) || specEnums[$0] == nil }
        if !resolved.isEmpty {
            XCTFail("`knownUnregisteredEnumSchemas` 의 \(resolved.sorted()) 는 더 이상 인지 처리가 필요 없습니다 — 목록에서 제거하세요.")
        }
    }

    /// 서버 타입 토큰(`string`/`integer`/`boolean`/`array<...>`/`anyOf(T|null)` …)이
    /// 실제 인코딩된 JSON 값과 맞는지 본다. optional(`anyOf(T|null)`)은 inner 타입으로 비교한다.
    private static func jsonType(_ serverType: String, matches value: Any) -> Bool {
        let type = unwrapNullable(serverType)
        switch type {
        case "string": return value is String
        case "integer", "number": return isNumber(value)
        case "boolean": return isBool(value)
        case "object": return value is [String: Any]
        case "unknown": return true
        default:
            if type.hasPrefix("array<") {
                guard let array = value as? [Any] else { return false }
                let element = String(type.dropFirst("array<".count).dropLast())
                return array.allSatisfy { jsonType(element, matches: $0) }
            }
            // ref:Enum / 다중 anyOf 등은 JSON 표현만으로 타입을 단정하기 어려워 통과시킨다.
            return true
        }
    }

    /// `anyOf(string|null)` → `string` 처럼 nullable 래퍼를 벗긴다. (단일 비-null 타입일 때만)
    private static func unwrapNullable(_ type: String) -> String {
        guard type.hasPrefix("anyOf("), type.hasSuffix(")") else { return type }
        let inner = type.dropFirst("anyOf(".count).dropLast()
        let nonNull = inner.split(separator: "|").map(String.init).filter { $0 != "null" }
        return nonNull.count == 1 ? nonNull[0] : type
    }

    /// JSONSerialization 은 Bool 도 NSNumber 로 주므로 CFBoolean 으로 구분한다.
    private static func isBool(_ value: Any) -> Bool {
        guard let number = value as? NSNumber else { return false }
        return CFGetTypeID(number) == CFBooleanGetTypeID()
    }

    private static func isNumber(_ value: Any) -> Bool {
        value is NSNumber && !isBool(value)
    }

    private static func actualTypeName(_ value: Any) -> String {
        if isBool(value) { return "boolean" }
        if isNumber(value) { return "number" }
        if value is String { return "string" }
        if value is [Any] { return "array" }
        if value is [String: Any] { return "object" }
        if value is NSNull { return "null" }
        return "\(Swift.type(of: value))"
    }

    // MARK: - Helpers

    /// `Fixtures/generated/<schema>(.min).json` 로드 (blue folder reference).
    private func generatedFixture(_ schema: String, minimal: Bool) throws -> Data {
        let name = minimal ? "\(schema).min" : schema
        let bundle = Bundle(for: Self.self)
        guard let url = bundle.url(forResource: name, withExtension: "json", subdirectory: "generated") else {
            XCTFail("생성 픽스처 \(name).json 없음 — `python3 Scripts/sync-openapi.py` 를 먼저 실행하세요.")
            throw ContractTestError.missingResource(name)
        }
        return try Data(contentsOf: url)
    }

    /// `Contract/<name>.json` 로드 (blue folder reference).
    private func contractJSON(_ name: String) throws -> [String: [String: Any]] {
        let bundle = Bundle(for: Self.self)
        guard let url = bundle.url(forResource: name, withExtension: "json", subdirectory: "Contract") else {
            XCTFail("\(name).json 없음 — `python3 Scripts/sync-openapi.py` 를 먼저 실행하세요.")
            throw ContractTestError.missingResource(name)
        }
        let raw = try Data(contentsOf: url)
        let obj = try JSONSerialization.jsonObject(with: raw)
        return (obj as? [String: [String: Any]]) ?? [:]
    }

    /// `Contract/openapi.json` 의 `components/schemas` 에서 string enum 만 추출 — { enum 스키마명: [값] }.
    /// (contract.current.json 은 properties 만 담아 enum 값 변경을 못 보므로 원본 스펙을 직접 읽는다)
    private func specEnumValues() throws -> [String: [String]] {
        let bundle = Bundle(for: Self.self)
        guard let url = bundle.url(forResource: "openapi", withExtension: "json", subdirectory: "Contract") else {
            XCTFail("openapi.json 없음 — `python3 Scripts/sync-openapi.py` 를 먼저 실행하세요.")
            throw ContractTestError.missingResource("openapi")
        }
        let raw = try Data(contentsOf: url)
        let obj = try JSONSerialization.jsonObject(with: raw) as? [String: Any]
        let components = obj?["components"] as? [String: Any]
        let schemas = (components?["schemas"] as? [String: Any]) ?? [:]

        var out: [String: [String]] = [:]
        for (name, schema) in schemas {
            guard let dict = schema as? [String: Any],
                  dict["type"] as? String == "string",
                  let values = dict["enum"] as? [String] else { continue }
            out[name] = values
        }
        return out
    }

    /// `Contract/response-schemas.json` 로드 — { 응답 payload 스키마명: "GET /path" }.
    private func responseSchemasManifest() throws -> [String: String] {
        let bundle = Bundle(for: Self.self)
        guard let url = bundle.url(forResource: "response-schemas", withExtension: "json", subdirectory: "Contract") else {
            XCTFail("response-schemas.json 없음 — `python3 Scripts/sync-openapi.py` 를 먼저 실행하세요.")
            throw ContractTestError.missingResource("response-schemas")
        }
        let raw = try Data(contentsOf: url)
        let obj = try JSONSerialization.jsonObject(with: raw)
        return (obj as? [String: String]) ?? [:]
    }

    /// lock → current 스키마 변경점을 사람이 읽을 메시지로.
    private static func diff(lock: [String: [String: Any]], current: [String: [String: Any]]) -> [String] {
        var out: [String] = []
        let lockNames = Set(lock.keys), curNames = Set(current.keys)

        for added in curNames.subtracting(lockNames).sorted() {
            out.append("＋ 스키마 추가됨: \(added)")
        }
        for removed in lockNames.subtracting(curNames).sorted() {
            out.append("－ 스키마 삭제됨: \(removed)")
        }

        for name in lockNames.intersection(curNames).sorted() {
            let lockedSchema = lock[name] ?? [:], currentSchema = current[name] ?? [:]
            let lockedRequiredFields = Set((lockedSchema["required"] as? [String]) ?? [])
            let currentRequiredFields = Set((currentSchema["required"] as? [String]) ?? [])
            let lockedProperties = (lockedSchema["properties"] as? [String: String]) ?? [:]
            let currentProperties = (currentSchema["properties"] as? [String: String]) ?? [:]
            let lockedFieldNames = Set(lockedProperties.keys), currentFieldNames = Set(currentProperties.keys)

            for fieldName in currentFieldNames.subtracting(lockedFieldNames).sorted() {
                out.append("  [\(name)] ＋ 필드 추가: \(fieldName): \(currentProperties[fieldName] ?? "?")")
            }
            for fieldName in lockedFieldNames.subtracting(currentFieldNames).sorted() {
                out.append("  [\(name)] － 필드 삭제: \(fieldName)")
            }
            for fieldName in lockedFieldNames.intersection(currentFieldNames).sorted()
                where lockedProperties[fieldName] != currentProperties[fieldName] {
                out.append("  [\(name)] ~ 타입 변경: \(fieldName): \(lockedProperties[fieldName] ?? "?") → \(currentProperties[fieldName] ?? "?")")
            }
            for fieldName in currentRequiredFields.subtracting(lockedRequiredFields).sorted() {
                out.append("  [\(name)] ! optional→required: \(fieldName)")
            }
            for fieldName in lockedRequiredFields.subtracting(currentRequiredFields).sorted() {
                out.append("  [\(name)] ! required→optional: \(fieldName)")
            }
        }
        return out
    }
}

// MARK: - DecodeContract

private struct DecodeContract {
    let schema: String
    let decode: (Data) throws -> Void
    init(_ schema: String, _ decode: @escaping (Data) throws -> Void) {
        self.schema = schema
        self.decode = decode
    }
}

private enum ContractTestError: Error {
    case missingResource(String)
}

// MARK: - EnumContract

/// 서버 스펙 enum ↔ Swift `String` raw-value enum 매핑.
private struct EnumContract {
    let schema: String
    let swiftName: String
    let hasCase: (String) -> Bool
    let swiftRawValues: [String]
    /// 스펙에는 있지만 Swift 가 의도적으로 아직 안 받는 값 (UI 미반영 등 — TODO 와 함께 인지 처리)
    let knownMissingValues: Set<String>

    init<T>(_ schema: String, _: T.Type, knownMissingValues: Set<String> = [])
        where T: RawRepresentable & CaseIterable, T.RawValue == String {
        self.schema = schema
        swiftName = String(describing: T.self)
        hasCase = { T(rawValue: $0) != nil }
        swiftRawValues = T.allCases.map(\.rawValue)
        self.knownMissingValues = knownMissingValues
    }
}

// MARK: - EncodeContract

/// 요청 바디 ↔ 서버 요청 스키마 매핑. 보관한 인스턴스를 앱과 동일하게 인코딩한다.
private struct EncodeContract {
    let schema: String
    let encode: () throws -> Data
    init<T: Encodable>(_ schema: String, _ value: T) {
        self.schema = schema
        encode = { try appEncoder.encode(value) }
    }
}

/// 앱(HTTPClient)과 동일하게 설정한 디코더. 서버가 일부 엔드포인트(Notification 등)는
/// snake_case 로 응답하므로, 실제 디코딩과 일치시키려면 같은 전략을 써야 한다.
private let appDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
}()

/// 앱(HTTPClient.buildRequest)과 동일한 인코더. 키 전략 없이 각 DTO 의 CodingKeys 로만 직렬화한다.
private let appEncoder = JSONEncoder()

/// `T` 를 디코딩만 하고 결과는 버리는 클로저. (디코딩 성공 여부만 본다)
private func decoding<T: Decodable>(_: T.Type) -> (Data) throws -> Void {
    { _ = try appDecoder.decode(T.self, from: $0) }
}
