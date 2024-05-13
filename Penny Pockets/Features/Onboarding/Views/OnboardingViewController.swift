//
//  OnboardingViewController.swift
//  Penny Pockets
//
//  Created by Mostafa Alaa on 04/03/2024.
//

import UIKit
import Combine
class OnboardingViewController: UIViewController {

    // MARK: - UI Outlets
    @IBOutlet weak var storyImage: UIImageView!
    @IBOutlet weak var progressBarStackView: UIStackView!
    @IBOutlet weak var nextStoryButton: UIButton!
    @IBOutlet weak var previousStoryButton: UIButton!
    @IBOutlet var progressBarList: [UIProgressView]!
    @IBOutlet weak var walkthroughSubtitleLabel: UILabel!
    @IBOutlet weak var walkthroughTitleLabel: UILabel!
    // MARK: - Properties
    private var timer: Timer?
    private var remainingTime: Float?
    private let storyDuration = 10.0
    private var animationStartTime: Date?
    private var remainingTimeAfterPause: Float?
    private var elapsedTimeTotalPauseCase: Float?
    var paused = false
    private var viewModel: OnboardingViewModel!
    var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = OnboardingViewModel()
        setupStories(index: 0)
        setupStoriesButtons()
        setupProgressViewsColors()
        // Do any additional setup after loading the view.
    }
    func setupProgressViewsColors() {
        // check this https://stackoverflow.com/questions/69928959/progressview-tintcolorissue
        self.progressBarList.forEach {
            $0.progressImage = UIImage.withColor(.primary)
        }
    }
    func setupStories(index: Int) {
        timer?.invalidate()
        timer = nil
        viewModel.$currentStory
            .sink{ [weak self] story in
                self?.walkthroughTitleLabel.text = story?.screenTitle
                self?.walkthroughSubtitleLabel.text = story?.screenSubtitle
                self?.storyImage.image = story?.asset
            }
            .store(in: &cancellables)
        self.progressBarList[index].progress = 0
        self.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(self.storyDuration), repeats: false) { [weak self] _ in
                self?.nextStoryPressed()
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
            self.animationStartTime = Date()
            UIView.animate(withDuration: self.storyDuration-0.1, delay: 0) {
                self.progressBarList[index].setProgress(1.0, animated: true)
            }
        })
    }
    func pauseStory() {
        if let fireDate = animationStartTime {
            let nowDate = Date()
            let elapsedTimeInterval = nowDate.timeIntervalSince(fireDate)
            let elapsedTime = Float(abs(elapsedTimeInterval))
            remainingTime = (remainingTimeAfterPause ?? Float(storyDuration)) - elapsedTime
            timer?.invalidate()
            timer = nil
            paused = true
            fadeAwayProgressView(elapsedTime: elapsedTime)
        }
    }

    private func fadeAwayProgressView(elapsedTime: Float) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                self.progressBarStackView.alpha = 0
            } completion: { finished in
                if finished {
                    self.removeAnimations()
                    self.progressBarList[self.viewModel.currentStoryIndex].progress = (elapsedTime+(self.elapsedTimeTotalPauseCase ?? 0))/Float((self.storyDuration-0.1))
                    print("progress paused at \(self.progressBarList[self.viewModel.currentStoryIndex].progress)")
                }
            }
        }
    }
    private func fadeInProgressView() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                self.progressBarStackView.alpha = 1
                print("progress resumed at \(self.progressBarList[self.viewModel.currentStoryIndex].progress)")
            }
        }
    }
    func resumeStory() {
        if !paused {
            return
        }
        fadeInProgressView()
        remainingTimeAfterPause = remainingTime
        elapsedTimeTotalPauseCase = Float(storyDuration) - (remainingTime ?? 0)
        timer = Timer.scheduledTimer(withTimeInterval: Double(remainingTime ?? 0), repeats: false) { [weak self] _ in
            self?.nextStoryPressed()
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
            self.animationStartTime = Date()
            UIView.animate(withDuration: Double(self.remainingTime ?? 0) - 0.1) {
                self.progressBarList[self.viewModel.currentStoryIndex].setProgress(1.0, animated: true)
            }
        })
    }
    func setupStoriesButtons() {
        nextStoryButton.addTarget(self, action: #selector(nextStoryPressed), for: .touchUpInside)
        let nextLongPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(pauseStoryHeld(_:)))
        nextLongPressRecognizer.minimumPressDuration = 0.3 // Adjust as needed
        nextStoryButton.addGestureRecognizer(nextLongPressRecognizer)
        previousStoryButton.addTarget(self, action: #selector(previousStoryPressed), for: .touchUpInside)
        let previousLongPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(pauseStoryHeld(_:)))
        previousLongPressRecognizer.minimumPressDuration = 0.3 // Adjust as needed
        previousStoryButton.addGestureRecognizer(previousLongPressRecognizer)
    }
    // MARK: - UI Actions
    @IBAction func nextButtonPressed(_ sender: Any) {

        if viewModel.storiesEnded {
            // TODO: navigate to home
        } else {
            self.nextStoryPressed()
        }
    }
    
    @IBAction func skipButtonPressed(_ sender: Any) {
        // TODO: navigate to home
    }
    @objc func previousStoryPressed() {
        self.remainingTimeAfterPause = nil
        self.elapsedTimeTotalPauseCase = nil
        guard viewModel.currentStoryIndex > 0 else {
            // restart story
            self.removeAnimations()
            setupStories(index: viewModel.currentStoryIndex)
            return
        }
        removeAnimations()
        self.progressBarList[viewModel.currentStoryIndex].progress = 0
        viewModel.currentStoryIndex -= 1
        setupStories(index: viewModel.currentStoryIndex)
    }

    @objc func nextStoryPressed() {
        self.remainingTimeAfterPause = nil
        self.elapsedTimeTotalPauseCase = nil
        guard !viewModel.storiesEnded else {
            return
        }
        removeAnimations()
        self.progressBarList[viewModel.currentStoryIndex].progress = 1
        viewModel.currentStoryIndex += 1
        setupStories(index: viewModel.currentStoryIndex)
    }
    @objc func pauseStoryHeld(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            pauseStory()
        } else if gesture.state == .ended {
            resumeStory()
        }
    }
    func removeAnimations() {
        progressBarList[viewModel.currentStoryIndex].layer.sublayers?.forEach {$0.removeAllAnimations()}
    }
}
