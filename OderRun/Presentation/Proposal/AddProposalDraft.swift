//
//  AddProposalDraft.swift
//  OderRun
//
//  Created by 김가희 on 4/28/26.
//

import Foundation

/// 새 의뢰 등록 다단계 플로우(AddProposal → DateTime → Fee)에서 단계 간 전달되는 입력 묶음.
struct AddProposalDraft: Hashable {
  var title: String = ""
  var content: String = ""
  var deadline: Date?
  var errandFee: Int?
}
