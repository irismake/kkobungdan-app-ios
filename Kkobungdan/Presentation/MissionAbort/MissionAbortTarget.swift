//
//  MissionAbortTarget.swift
//  Kkobungdan
//
//  임무 중단 화면이 어떤 분쟁 엔드포인트를 호출할지 가르는 라우팅 대상.
//  오더러(proposal)·러너(offer) 분쟁 엔드포인트가 갈라지므로 진입 지점에서 결정한다.
//

import Foundation

/// 임무 중단 라우팅 값. 어떤 분쟁 대상인지만 담는다(use case 주입은 `AppRouteFactory` → `MissionAbortViewModel.Submit`).
enum MissionAbortTarget: Hashable {
  /// 오더러(행님)가 자기 의뢰를 중단. `POST /v1/proposal/{id}/dispute`
  case proposal(proposalID: Int64)
  /// 러너(꼬붕)가 자기 지원을 중단. `POST /v1/offer/{id}/dispute`
  case offer(offerID: Int64)
}
