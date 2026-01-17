import Foundation

enum AppStage: String, Codable {
    case initialScan = "initial_scan"
    case deepeningExploration = "deepening_exploration"
    case aiPlanGeneration = "ai_plan_generation"
    case reviewAndEdit = "review_and_edit"
    case taskManagement = "task_management"
}

enum InitialScanStep: Int, Codable {
    case interests = 1
    case strengths = 2
    case values = 3
    case aiSummary = 4
    case payment = 5
    case blueprint = 6
}

enum DeepeningExplorationStep: Int, Codable {
    case flowDiary = 1
    case valuesQuestions = 2
    case resourceInventory = 3
    case acquiredStrengths = 4
    case feasibilityAssessment = 5
}
