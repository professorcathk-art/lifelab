import Foundation
import SwiftUI
import Combine

@MainActor
class ValuesQuestionsViewModel: ObservableObject {
    @Published var valuesQuestions: ValuesQuestions
    @Published var reflectionAnswers: [ReflectionAnswer]
    
    let totalQuestions: Int
    
    init() {
        let reflectionQuestions = ReflectionQuestions.shared.questions
        let initialAnswers = reflectionQuestions.map { question in
            ReflectionAnswer(questionId: question.id, question: question.question)
        }
        totalQuestions = 4 + reflectionQuestions.count // 4 quick questions + reflection questions
        
        // Initialize reflectionAnswers first
        reflectionAnswers = initialAnswers
        
        // Load existing data
        if let existing = DataService.shared.userProfile?.valuesQuestions {
            valuesQuestions = existing
            // Merge with existing answers
            reflectionAnswers = initialAnswers.map { answer in
                if let existingAnswer = existing.reflectionAnswers.first(where: { $0.questionId == answer.questionId }) {
                    var updatedAnswer = answer
                    updatedAnswer.answer = existingAnswer.answer
                    return updatedAnswer
                }
                return answer
            }
        } else {
            // Initialize with empty reflectionAnswers first, then update
            valuesQuestions = ValuesQuestions(reflectionAnswers: [])
            valuesQuestions.reflectionAnswers = reflectionAnswers
        }
    }
    
    var answeredQuestions: Int {
        var count = 0
        if !(valuesQuestions.admiredPeople?.isEmpty ?? true) { count += 1 }
        if !(valuesQuestions.favoriteCharacters?.isEmpty ?? true) { count += 1 }
        if !(valuesQuestions.idealChild?.isEmpty ?? true) { count += 1 }
        if !(valuesQuestions.legacyDescription?.isEmpty ?? true) { count += 1 }
        count += reflectionAnswers.filter { !$0.answer.isEmpty }.count
        return count
    }
    
    var isComplete: Bool {
        answeredQuestions == totalQuestions
    }
    
    func saveProgress() {
        valuesQuestions.reflectionAnswers = reflectionAnswers
        DataService.shared.updateUserProfile { profile in
            profile.valuesQuestions = valuesQuestions
        }
    }
    
    func completeValuesQuestions() {
        valuesQuestions.reflectionAnswers = reflectionAnswers
        DataService.shared.updateUserProfile { profile in
            profile.valuesQuestions = valuesQuestions
        }
    }
}
