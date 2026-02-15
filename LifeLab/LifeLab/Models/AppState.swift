import Foundation

enum AppStage: String, Codable {
    case initialScan = "initial_scan"
    case deepeningExploration = "deepening_exploration"
    case aiPlanGeneration = "ai_plan_generation"
    case reviewAndEdit = "review_and_edit"
    case taskManagement = "task_management"
}

enum InitialScanStep: Int, Codable {
    case basicInfo = 1  // New: Basic user information
    case interests = 2
    case strengths = 3
    case values = 4
    case aiSummary = 5
    case loading = 6  // Loading animation BEFORE payment
    case payment = 7
    case blueprint = 8
}

enum DeepeningExplorationStep: Int, Codable {
    case flowDiary = 1
    case valuesQuestions = 2
    case resourceInventory = 3
    case acquiredStrengths = 4
    case feasibilityAssessment = 5
}
