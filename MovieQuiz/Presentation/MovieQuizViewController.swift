import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {

    // MARK: - Outlets
    
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var questionTitleLabel: UILabel!
    @IBOutlet weak private var indexLabel: UILabel!
    @IBOutlet weak private var questionLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    private var alertPresenter: AlertPresenter?
    
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startUISetup()
        
        presenter = MovieQuizPresenter(viewController: self)
        
        alertPresenter = AlertPresenter(viewController: self)
        
        showLoadingIndicator()
    }
    
    // MARK: - Private Methods
    
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
    
    // MARK: - Public Methods
    
    func show(quiz result: QuizResultsViewModel) {
        let text = presenter.makeResultsMessage()
        
        let alert = AlertModel(title: result.title,
                               message: text,
                               buttonText: result.buttonText,
                               completion: { [weak self] in
            guard let self else { return }
            self.presenter.restartGame()
        }
        )
        
        alertPresenter?.showAlert(model: alert)
    }
    
    func showNetworkError(message: String) {
        showLoadingIndicator()
        
        let alert = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать ещё раз",
                               completion: { [weak self] in
            guard let self else { return }
            self.presenter.restartGame()
        })
        
        alertPresenter?.showAlert(model: alert)
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderWidth = 0
        imageView.image = step.image
        questionLabel.text = step.question
        indexLabel.text = step.questionNumber
        setAnswerButtonsState(isEnabled: true)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    // MARK: - Private Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
        setAnswerButtonsState(isEnabled: false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
        setAnswerButtonsState(isEnabled: false)
    }
}
