//
//  OpenAPIContractTests.swift
//  OderRunTests
//
//  서버 OpenAPI 스펙(Secrets.xcconfig 의 API_BASE_HOST + /openapi.json)과 Swift DTO 의 "계약"을 검증한다.
//  스펙·픽스처는 `Scripts/sync-openapi.py` 가 자동 생성하므로 손으로 만들지 않는다.
//
//  세 가지를 자동으로 잡는다:
//   1. maximal 픽스처 디코딩 → 필드명/타입 변경
//   2. minimal 픽스처 디코딩 → DTO 가 서버 optional 필드를 required 로 잘못 선언
//   3. contract lock 비교    → 필드 추가/삭제/optional 여부 변경 (사람이 DTO 반영해야 하는 변경)
//

@testable import OderRun
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
        DecodeContract("OfferResponse", decoding(OfferResponseDTO.self)), // 액션(complete-delivery·dispute)
        DecodeContract("OfferSummaryResponse", decoding(OfferSummaryResponseDTO.self)), // GET /v1/offer
        DecodeContract("OfferDetailResponse", decoding(OfferDetailResponseDTO.self)), // GET /v1/offer/{id}
        DecodeContract("OfferResponse", decoding(MyOfferResponseDTO.self)), // GET /v1/offer/own
        DecodeContract("OfferAcceptResponse", decoding(OfferAcceptResponseDTO.self)),
        // User / Settlement / Terms
        DecodeContract("UserDetailResponse", decoding(UserDetailResponseDTO.self)),
        DecodeContract("SettlementAccountResponse", decoding(SettlementAccountResponseDTO.self)),
        DecodeContract("SettlementBankNamesResponse", decoding(SettlementBankNamesResponseDTO.self)),
        DecodeContract("TermsAgreementResponse", decoding(TermsAgreementResponseDTO.self)),
        // Dispute survey
        DecodeContract("DisputeSurveyQuestionResponse", decoding(DisputeSurveyQuestionResponseDTO.self)),
        // Notification
        DecodeContract("NotificationListResponse", decoding(NotificationListResponseDTO.self)),
        DecodeContract("NotificationResponse", decoding(NotificationDTO.self)),
        // Auth
        DecodeContract("AuthTokenResponse", decoding(AuthTokenResponseDTO.self)), // login/signup confirm
        DecodeContract("AuthVerificationSendResponse", decoding(PhoneVerificationResponseDTO.self)), // login/signup send
        DecodeContract("AuthAccessTokenResponse", decoding(RefreshTokenResponseDTO.self)), // refresh
        // ⚠️ Oauth 3종(LoginResponseDTO/AppleLoginResponseDTO/KakaoLoginResponseDTO)은
        //    호출 엔드포인트(/v1/auth/login, /v1/auth/oauth/*)가 현재 서버 스펙에 없어 추적 불가.
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
            let l = lock[name] ?? [:], c = current[name] ?? [:]
            let lReq = Set((l["required"] as? [String]) ?? [])
            let cReq = Set((c["required"] as? [String]) ?? [])
            let lProps = (l["properties"] as? [String: String]) ?? [:]
            let cProps = (c["properties"] as? [String: String]) ?? [:]
            let lKeys = Set(lProps.keys), cKeys = Set(cProps.keys)

            for k in cKeys.subtracting(lKeys).sorted() {
                out.append("  [\(name)] ＋ 필드 추가: \(k): \(cProps[k] ?? "?")")
            }
            for k in lKeys.subtracting(cKeys).sorted() {
                out.append("  [\(name)] － 필드 삭제: \(k)")
            }
            for k in lKeys.intersection(cKeys).sorted() where lProps[k] != cProps[k] {
                out.append("  [\(name)] ~ 타입 변경: \(k): \(lProps[k] ?? "?") → \(cProps[k] ?? "?")")
            }
            for k in cReq.subtracting(lReq).sorted() {
                out.append("  [\(name)] ! optional→required: \(k)")
            }
            for k in lReq.subtracting(cReq).sorted() {
                out.append("  [\(name)] ! required→optional: \(k)")
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

/// 앱(HTTPClient)과 동일하게 설정한 디코더. 서버가 일부 엔드포인트(Notification 등)는
/// snake_case 로 응답하므로, 실제 디코딩과 일치시키려면 같은 전략을 써야 한다.
private let appDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
}()

/// `T` 를 디코딩만 하고 결과는 버리는 클로저. (디코딩 성공 여부만 본다)
private func decoding<T: Decodable>(_: T.Type) -> (Data) throws -> Void {
    { _ = try appDecoder.decode(T.self, from: $0) }
}
