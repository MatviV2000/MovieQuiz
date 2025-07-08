import UIKit

final class MovieQuizPresenter {
    //MARK: - Properties
    
    private var currentQuestionIndex: Int = 0
    
    let questionsAmount: Int = 10
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel (
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    //MARK: - Methods
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func noButtonClicked() {
        guard let currentQuestion = currentQuestion else { return }
        
        viewController?.showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    
    func yesButtonClicked() {
        guard let currentQuestion = currentQuestion else { return }
        
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
}
    


