//
//  Lesson.swift
//  EduFortune
//
//  Created by Вячеслав on 8/20/25.
//

import Foundation

struct Lesson: Identifiable, Codable {
    let id = UUID()
    let title: String
    let content: String
    let type: LessonType
    let duration: Int // in minutes
    let questions: [Question]
    let financialTip: String?
    let vocabulary: [VocabularyItem]
    let isCompleted: Bool
    let order: Int
    
    enum LessonType: String, CaseIterable, Codable {
        case vocabulary = "Vocabulary"
        case listening = "Listening"
        case reading = "Reading"
        case quiz = "Quiz"
        case financial = "Financial Concept"
        
        var icon: String {
            switch self {
            case .vocabulary: return "book.fill"
            case .listening: return "ear.fill"
            case .reading: return "doc.text.fill"
            case .quiz: return "questionmark.circle.fill"
            case .financial: return "dollarsign.circle.fill"
            }
        }
    }
}

struct Question: Identifiable, Codable {
    let id = UUID()
    let question: String
    let options: [String]
    let correctAnswer: Int
    let explanation: String
    let type: QuestionType
    
    enum QuestionType: String, Codable {
        case multipleChoice = "Multiple Choice"
        case trueFalse = "True/False"
        case fillInBlank = "Fill in the Blank"
    }
}

struct VocabularyItem: Identifiable, Codable {
    let id = UUID()
    let word: String
    let definition: String
    let example: String
    let financialContext: String?
    let pronunciation: String?
}

extension Lesson {
    static let sampleLessons: [Lesson] = [
        Lesson(
            title: "Banking Basics",
            content: "Learn fundamental banking terms and concepts that will help you navigate financial institutions with confidence.",
            type: .financial,
            duration: 15,
            questions: [
                Question(
                    question: "What is a checking account primarily used for?",
                    options: ["Long-term savings", "Daily transactions", "Investment", "Loans"],
                    correctAnswer: 1,
                    explanation: "A checking account is designed for daily transactions like paying bills and making purchases.",
                    type: .multipleChoice
                ),
                Question(
                    question: "Interest rates on savings accounts are always fixed.",
                    options: ["True", "False"],
                    correctAnswer: 1,
                    explanation: "Interest rates on savings accounts can be variable and may change based on market conditions.",
                    type: .trueFalse
                )
            ],
            financialTip: "Always compare interest rates between different banks before opening a savings account.",
            vocabulary: [
                VocabularyItem(
                    word: "Interest",
                    definition: "Money paid regularly at a particular rate for the use of money lent",
                    example: "The bank pays 2% interest on savings accounts.",
                    financialContext: "Interest is how your money grows in savings accounts",
                    pronunciation: "/ˈɪntrəst/"
                ),
                VocabularyItem(
                    word: "Balance",
                    definition: "The amount of money in a bank account",
                    example: "My account balance is $1,500.",
                    financialContext: "Always keep track of your account balance to avoid overdraft fees",
                    pronunciation: "/ˈbæləns/"
                )
            ],
            isCompleted: false,
            order: 1
        ),
        Lesson(
            title: "Credit and Debt",
            content: "Understanding credit scores, credit cards, and managing debt responsibly.",
            type: .vocabulary,
            duration: 20,
            questions: [
                Question(
                    question: "What is a good credit score range?",
                    options: ["300-500", "500-650", "650-750", "750-850"],
                    correctAnswer: 3,
                    explanation: "A credit score between 750-850 is considered excellent and will qualify you for the best interest rates.",
                    type: .multipleChoice
                )
            ],
            financialTip: "Pay your credit card bills on time to maintain a good credit score.",
            vocabulary: [
                VocabularyItem(
                    word: "Credit Score",
                    definition: "A number that represents your creditworthiness",
                    example: "Her credit score of 780 qualified her for a low-interest loan.",
                    financialContext: "A higher credit score means better loan terms and lower interest rates",
                    pronunciation: "/ˈkredɪt skɔr/"
                )
            ],
            isCompleted: true,
            order: 2
        )
    ]
    
    static let sampleBusinessLessons: [Lesson] = [
        Lesson(
            title: "Meeting Etiquette",
            content: "Professional communication skills for business meetings and presentations.",
            type: .listening,
            duration: 25,
            questions: [
                Question(
                    question: "What should you do before speaking in a meeting?",
                    options: ["Interrupt immediately", "Wait for a pause", "Raise your hand", "Send a message"],
                    correctAnswer: 1,
                    explanation: "Waiting for a natural pause shows respect for other speakers and maintains professional decorum.",
                    type: .multipleChoice
                )
            ],
            financialTip: "Good communication skills can lead to better career opportunities and higher salaries.",
            vocabulary: [
                VocabularyItem(
                    word: "Agenda",
                    definition: "A list of items to be discussed at a formal meeting",
                    example: "Please review the agenda before tomorrow's meeting.",
                    financialContext: "Following meeting agendas helps maximize productivity and business outcomes",
                    pronunciation: "/əˈdʒendə/"
                )
            ],
            isCompleted: false,
            order: 1
        )
    ]
}
