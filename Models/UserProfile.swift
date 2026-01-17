import Foundation

struct UserProfile: Codable, Identifiable {
    let id: UUID
    var interests: [String]
    var strengths: [StrengthResponse]
    var values: [ValueRanking]
    var flowDiaryEntries: [FlowDiaryEntry]
    var valuesQuestions: ValuesQuestions?
    var resourceInventory: ResourceInventory?
    var acquiredStrengths: AcquiredStrengths?
    var feasibilityAssessment: FeasibilityAssessment?
    var lifeBlueprint: LifeBlueprint?
    var actionPlan: ActionPlan?
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), interests: [String] = [], strengths: [StrengthResponse] = [], values: [ValueRanking] = [], flowDiaryEntries: [FlowDiaryEntry] = [], valuesQuestions: ValuesQuestions? = nil, resourceInventory: ResourceInventory? = nil, acquiredStrengths: AcquiredStrengths? = nil, feasibilityAssessment: FeasibilityAssessment? = nil, lifeBlueprint: LifeBlueprint? = nil, actionPlan: ActionPlan? = nil, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.interests = interests
        self.strengths = strengths
        self.values = values
        self.flowDiaryEntries = flowDiaryEntries
        self.valuesQuestions = valuesQuestions
        self.resourceInventory = resourceInventory
        self.acquiredStrengths = acquiredStrengths
        self.feasibilityAssessment = feasibilityAssessment
        self.lifeBlueprint = lifeBlueprint
        self.actionPlan = actionPlan
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct StrengthResponse: Codable, Identifiable {
    let id: UUID
    let questionId: Int
    let question: String
    var selectedKeywords: [String]
    var userNotes: String?
    
    init(id: UUID = UUID(), questionId: Int, question: String, selectedKeywords: [String] = [], userNotes: String? = nil) {
        self.id = id
        self.questionId = questionId
        self.question = question
        self.selectedKeywords = selectedKeywords
        self.userNotes = userNotes
    }
}

struct ValueRanking: Codable, Identifiable {
    let id: UUID
    let value: CoreValue
    var rank: Int
    var relatedMemory: String?
    
    init(id: UUID = UUID(), value: CoreValue, rank: Int, relatedMemory: String? = nil) {
        self.id = id
        self.value = value
        self.rank = rank
        self.relatedMemory = relatedMemory
    }
}

enum CoreValue: String, Codable, CaseIterable {
    case integrity = "誠信/真實"
    case growth = "成長/學習"
    case connection = "關愛/連結"
    case freedom = "自由/自主"
    case achievement = "成就/貢獻"
    case security = "安全/穩定"
    case creativity = "創意/創新"
    case justice = "公正/公平"
    case health = "健康/平衡"
    case happiness = "快樂/樂趣"
    
    var description: String {
        switch self {
        case .integrity:
            return "對自己和他人保持誠實，言行一致，活出真實的自我"
        case .growth:
            return "持續學習新知、發展技能，不斷提升自我和擴展視野"
        case .connection:
            return "與他人建立深度關係，關心他人福祉，維繫重要的人際連結"
        case .freedom:
            return "擁有選擇權和決定權，能按自己的意願安排生活和工作"
        case .achievement:
            return "完成有意義的目標，對社會或他人產生正面影響和貢獻"
        case .security:
            return "追求生活和工作的穩定性，建立可預測和安全的環境"
        case .creativity:
            return "產生新想法，嘗試新方法，在生活中展現原創性和想像力"
        case .justice:
            return "重視公平正義，確保每個人都得到應有的待遇和機會"
        case .health:
            return "維持身心健康，在工作、家庭、個人時間間取得良好平衡"
        case .happiness:
            return "享受生活的樂趣，保持積極樂觀的心態，創造歡樂時光"
        }
    }
}

struct FlowDiaryEntry: Codable, Identifiable {
    let id: UUID
    var date: Date
    var activity: String
    var description: String
    var energyLevel: Int // 1-10
    
    init(id: UUID = UUID(), date: Date = Date(), activity: String = "", description: String = "", energyLevel: Int = 5) {
        self.id = id
        self.date = date
        self.activity = activity
        self.description = description
        self.energyLevel = energyLevel
    }
}

struct ValuesQuestions: Codable {
    var admiredPeople: String?
    var favoriteCharacters: String?
    var idealChild: String?
    var legacyDescription: String?
    var reflectionAnswers: [ReflectionAnswer]
    
    init(admiredPeople: String? = nil, favoriteCharacters: String? = nil, idealChild: String? = nil, legacyDescription: String? = nil, reflectionAnswers: [ReflectionAnswer] = []) {
        self.admiredPeople = admiredPeople
        self.favoriteCharacters = favoriteCharacters
        self.idealChild = idealChild
        self.legacyDescription = legacyDescription
        self.reflectionAnswers = reflectionAnswers
    }
}

struct ReflectionAnswer: Codable, Identifiable {
    let id: UUID
    let questionId: Int
    let question: String
    var answer: String
    
    init(id: UUID = UUID(), questionId: Int, question: String, answer: String = "") {
        self.id = id
        self.questionId = questionId
        self.question = question
        self.answer = answer
    }
}

struct ResourceInventory: Codable {
    var time: String?
    var money: String?
    var items: String?
    var network: String?
}

struct AcquiredStrengths: Codable {
    var experience: String?
    var knowledge: String?
    var skills: String?
    var achievements: String?
}

struct FeasibilityAssessment: Codable {
    var path1: String?
    var path2: String?
    var path3: String?
    var path4: String?
    var path5: String?
    var path6: String?
}

struct LifeBlueprint: Codable {
    var vocationDirections: [VocationDirection]
    var strengthsSummary: String
    var feasibilityAssessment: String
    
    init(vocationDirections: [VocationDirection] = [], strengthsSummary: String = "", feasibilityAssessment: String = "") {
        self.vocationDirections = vocationDirections
        self.strengthsSummary = strengthsSummary
        self.feasibilityAssessment = feasibilityAssessment
    }
}

struct VocationDirection: Codable, Identifiable {
    let id: UUID
    var title: String
    var description: String
    var marketFeasibility: String
    
    init(id: UUID = UUID(), title: String = "", description: String = "", marketFeasibility: String = "") {
        self.id = id
        self.title = title
        self.description = description
        self.marketFeasibility = marketFeasibility
    }
}

struct ActionPlan: Codable {
    var shortTerm: [ActionItem]
    var midTerm: [ActionItem]
    var longTerm: [ActionItem]
    var milestones: [Milestone]
    
    init(shortTerm: [ActionItem] = [], midTerm: [ActionItem] = [], longTerm: [ActionItem] = [], milestones: [Milestone] = []) {
        self.shortTerm = shortTerm
        self.midTerm = midTerm
        self.longTerm = longTerm
        self.milestones = milestones
    }
}

struct ActionItem: Codable, Identifiable {
    let id: UUID
    var title: String
    var description: String
    var isCompleted: Bool
    var dueDate: Date?
    
    init(id: UUID = UUID(), title: String = "", description: String = "", isCompleted: Bool = false, dueDate: Date? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.dueDate = dueDate
    }
}

struct Milestone: Codable, Identifiable {
    let id: UUID
    var title: String
    var description: String
    var targetDate: Date?
    var isCompleted: Bool
    var successIndicators: [String]
    
    init(id: UUID = UUID(), title: String = "", description: String = "", targetDate: Date? = nil, isCompleted: Bool = false, successIndicators: [String] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.targetDate = targetDate
        self.isCompleted = isCompleted
        self.successIndicators = successIndicators
    }
}
