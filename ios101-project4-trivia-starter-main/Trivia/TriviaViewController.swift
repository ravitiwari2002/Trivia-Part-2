//
//  ViewController.swift
//  Trivia
//
//  Created by Mari Batilando on 4/6/23.
//

import UIKit

//to decode html elements
extension String {
    var decodedHTMLString: String? {
        guard let data = data(using: .utf8) else { return nil }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributedString.string
        }
        return nil
    }
}

class TriviaViewController: UIViewController {
    
    @IBOutlet weak var currentQuestionNumberLabel: UILabel!
    @IBOutlet weak var questionContainerView: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var answerButton0: UIButton!
    @IBOutlet weak var answerButton1: UIButton!
    @IBOutlet weak var answerButton2: UIButton!
    @IBOutlet weak var answerButton3: UIButton!
    
    private let triviaQuestionService = TriviaQuestionService()
    private var questions = [TriviaQuestion]()
    private var currQuestionIndex = 0
    private var numCorrectQuestions = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradient()
        questionContainerView.layer.cornerRadius = 8.0
        
        currentQuestionNumberLabel.text = ""
        questionLabel.text = ""
        categoryLabel.text = ""
        answerButton0.setTitle("", for: .normal)
        answerButton1.setTitle("", for: .normal)
        answerButton2.setTitle("", for: .normal)
        answerButton3.setTitle("", for: .normal)
        answerButton1.isHidden = true
        answerButton2.isHidden = true
        answerButton3.isHidden = true
        
        fetchTriviaQuestions()
    }
    
    // Function to fetch new questions
    private func fetchTriviaQuestions() {
        TriviaQuestionService().fetchQuestions(amount: 10) { [weak self] (questions, error) in
            if let questions = questions {
                self?.questions = questions
                self?.numCorrectQuestions = 0
                self?.currQuestionIndex = 0
                self?.updateQuestion(withQuestionIndex: 0)
            } else if let error = error {
                print("Error fetching questions: \(error)")
            }
        }
    }
    
    private func updateQuestion(withQuestionIndex questionIndex: Int) {
        print("Updating question with index: \(questionIndex)")
        
        DispatchQueue.main.async {
            self.currentQuestionNumberLabel.text = "Question: \(questionIndex + 1)/\(self.questions.count)"
            let question = self.questions[questionIndex]
            
            if let decodedQuestion = question.question.decodedHTMLString {
                self.questionLabel.text = decodedQuestion
            } else {
                self.questionLabel.text = question.question
            }
            
            self.categoryLabel.text = question.category
            let answers = ([question.correctAnswer] + question.incorrectAnswers).shuffled()
            
            self.answerButton0.setTitle(answers[0].decodedHTMLString, for: .normal)
            
            self.answerButton1.isHidden = true
            self.answerButton2.isHidden = true
            self.answerButton3.isHidden = true
            
            if answers.count > 1 {
                self.answerButton1.setTitle(answers[1].decodedHTMLString, for: .normal)
                self.answerButton1.isHidden = false
            }
            if answers.count > 2 {
                self.answerButton2.setTitle(answers[2].decodedHTMLString, for: .normal)
                self.answerButton2.isHidden = false
            }
            if answers.count > 3 {
                self.answerButton3.setTitle(answers[3].decodedHTMLString, for: .normal)
                self.answerButton3.isHidden = false
            }
        }
    }
    
    private func updateToNextQuestion(answer: String) {
        print("Answer selected: \(answer)")
        if isCorrectAnswer(answer) {
            numCorrectQuestions += 1
        }
        currQuestionIndex += 1
        guard currQuestionIndex < questions.count else {
            showFinalScore()
            return
        }
        updateQuestion(withQuestionIndex: currQuestionIndex)
    }
    
    private func isCorrectAnswer(_ answer: String) -> Bool {
        return answer == questions[currQuestionIndex].correctAnswer
    }
    
    private func showFinalScore() {
        let alertController = UIAlertController(title: "Game over!",
                                                message: "Final score: \(numCorrectQuestions)/\(questions.count)",
                                                preferredStyle: .alert)
        let resetAction = UIAlertAction(title: "Restart", style: .default) { [unowned self] _ in
            self.currQuestionIndex = 0
            self.numCorrectQuestions = 0
            self.fetchTriviaQuestions() // Fetch new questions on restart
        }
        alertController.addAction(resetAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func addGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor(red: 0.54, green: 0.88, blue: 0.99, alpha: 1.00).cgColor,
                                UIColor(red: 0.51, green: 0.81, blue: 0.97, alpha: 1.00).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    @IBAction func didTapAnswerButton0(_ sender: UIButton) {
        updateToNextQuestion(answer: sender.titleLabel?.text ?? "")
    }
    
    @IBAction func didTapAnswerButton1(_ sender: UIButton) {
        updateToNextQuestion(answer: sender.titleLabel?.text ?? "")
    }
    
    @IBAction func didTapAnswerButton2(_ sender: UIButton) {
        updateToNextQuestion(answer: sender.titleLabel?.text ?? "")
    }
    
    @IBAction func didTapAnswerButton3(_ sender: UIButton) {
        updateToNextQuestion(answer: sender.titleLabel?.text ?? "")
    }
}
