import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Structures
    
    // MARK: - Outlets
    
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var questionTitleLabel: UILabel!
    @IBOutlet weak private var indexLabel: UILabel!
    @IBOutlet weak private var questionLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    private var correctAnswers = 0
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticServiceProtocol?
    private let presenter = MovieQuizPresenter()
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startUISetup()
        
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        self.questionFactory = questionFactory
        
        questionFactory.loadData()
        
        alertPresenter = AlertPresenter(viewController: self)
        
        statisticService = StatisticServiceImplementation()
        
        showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Private Methods
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderWidth = 0
        imageView.image = step.image
        questionLabel.text = step.question
        indexLabel.text = step.questionNumber
        setAnswerButtonsState(isEnabled: true)
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            statisticService?.store(correct: self.correctAnswers, total: self.presenter.questionsAmount)
            
            guard let bestGame = statisticService?.bestGame else { return }
            
            let viewModel = QuizResultsViewModel(title: "Этот раунд окончен!",
                                                 text:
 """
 Ваш результат \(correctAnswers)\\\(presenter.questionsAmount)
 Колличество сыгранных квизов \(statisticService?.gamesCount ?? 0)
 Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
 Средняя точность \(String(format: "%.2f", statisticService?.totalAccuracy ?? 0))%
 """,
                                                 buttonText: "Сыграть еще раз")
            show(quiz: viewModel)
        } else {
            presenter.switchToNextQuestion()
            
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        setAnswerButtonsState(isEnabled: false)
        
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 20
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
            guard let self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = AlertModel(title: result.title,
                               message: result.text,
                               buttonText: result.buttonText,
                               completion: { [weak self] in
            guard let self else { return }
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        )
        
        alertPresenter?.showAlert(model: alert)
    }
    
    private func startUISetup() {
        noButton.titleLabel?.font = .ysDisplayMedium
        yesButton.titleLabel?.font = .ysDisplayMedium
        questionTitleLabel.font = .ysDisplayMedium
        indexLabel.font = .ysDisplayMedium
        questionLabel.font = .ysDisplayMedium(size: 23)
    }
    
    private func setAnswerButtonsState(isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        showLoadingIndicator()
        
        let alert = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать ещё раз",
                               completion: { [weak self] in
            guard let self else { return }
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            
            let questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
            self.questionFactory = questionFactory
            
            questionFactory.loadData()
            
        })
        
        alertPresenter?.showAlert(model: alert)
    }
    
    // MARK: - Public Methods
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        hideLoadingIndicator()
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - Private Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
}
