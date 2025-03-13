//
//  PokerGameVC.swift
//  PokerPioneerPro
//
//  Created by PokerPioneerPro on 2025/3/13.
//


import UIKit
import SpriteKit

class PioneerPokerGameVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var cardsContainerView: UIView!
    @IBOutlet weak var targetCardsStackView: UIStackView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var movesLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var hintButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var howToPlayButton: UIButton!
    @IBOutlet weak var newCardsButton: UIButton!
    
    // MARK: - Properties
    let arrCards = [
        ["🂢", "🂣", "🂤", "🂥", "🂦", "🂧", "🂨", "🂩", "🂪", "🂫", "🂭", "🂮", "🂡"], // Spades
        ["🂲", "🂳", "🂴", "🂵", "🂶", "🂷", "🂸", "🂹", "🂺", "🂻", "🂽", "🂾", "🂱"], // Hearts
        ["🃂", "🃃", "🃄", "🃅", "🃆", "🃇", "🃈", "🃉", "🃊", "🃋", "🃍", "🃎", "🃁"], // Diamonds
        ["🃒", "🃓", "🃔", "🃕", "🃖", "🃗", "🃘", "🃙", "🃚", "🃛", "🃝", "🃞", "🃑"]  // Clubs
    ]
    
    private var cardViews: [CardView] = []
    private var targetArrangement: [(suit: Int, rank: Int)] = []
    private var currentLevel = 1
    private var moves = 0
    private var timeRemaining = 0
    private var timer: Timer?
    private var isGamePaused = false
    private var hintsRemaining = 3
    private var lastDraggedCard: CardView?
    private var comboMultiplier = 1
    private var lastMoveTime: Date?
    private var placeholderViews: [UIView] = []
    private var magicEmitterNode: SKEmitterNode?
    private var celebrationEmitterNode: SKEmitterNode?
    private var starEmitterNode: SKEmitterNode?
    private var skView: SKView?
    
    // MARK: - Level Configuration
    struct LevelConfig {
        let cardCount: Int
        let timeLimit: Int
        let targetPattern: TargetPattern
        let requiredScore: Int
    }
    
    enum TargetPattern {
        case ascending
        case descending
        case sameSuit
        case alternatingColors
        case custom([(suit: Int, rank: Int)])
    }
    
    private let levelConfigurations: [LevelConfig] = {
        var levels: [LevelConfig] = []
        
        // Helper function to create custom patterns
        func createCustomPattern(count: Int, style: Int) -> [(suit: Int, rank: Int)] {
            var pattern: [(suit: Int, rank: Int)] = []
            
            switch style % 5 {
            case 0: // Random sequence in same suit
                let randomSuit = Int.random(in: 0...3)
                var availableRanks = Array(0...12)
                availableRanks.shuffle()
                for i in 0..<count {
                    pattern.append((suit: randomSuit, rank: availableRanks[i]))
                }
            case 1: // Random alternating suits
                let suit1 = Int.random(in: 0...3)
                var suit2: Int
                repeat {
                    suit2 = Int.random(in: 0...3)
                } while suit2 == suit1
                
                var availableRanks = Array(0...12)
                availableRanks.shuffle()
                for i in 0..<count {
                    pattern.append((suit: i % 2 == 0 ? suit1 : suit2, rank: availableRanks[i]))
                }
            case 2: // Random four suit pattern
                var suits = [0, 1, 2, 3]
                suits.shuffle()
                var availableRanks = Array(0...12)
                availableRanks.shuffle()
                for i in 0..<count {
                    pattern.append((suit: suits[i % 4], rank: availableRanks[i]))
                }
            case 3: // Random pairs in same suit
                var suits = [0, 1, 2, 3]
                suits.shuffle()
                var availableRanks = Array(0...12)
                availableRanks.shuffle()
                for i in 0..<count {
                    pattern.append((suit: suits[(i/2) % 4], rank: availableRanks[i]))
                }
            case 4: // Random descending sequence
                let randomSuit = Int.random(in: 0...3)
                var availableRanks = Array(0...12)
                availableRanks.shuffle()
                availableRanks = Array(availableRanks.prefix(count)).sorted(by: >)
                for i in 0..<count {
                    pattern.append((suit: randomSuit, rank: availableRanks[i]))
                }
            default:
                break
            }
            
            return pattern
        }
        
        // Create 100 levels
        for level in 0..<100 {
            // Calculate card count (2 to 10)
            let baseCount = 2 + (level / 20) // Increases every 20 levels
            let cardCount = min(10, max(2, baseCount + (level % 3))) // Varies between levels
            
            // Calculate time limit (increases with card count)
            let timeLimit = 30 + (cardCount * 10) // 30 seconds base + 10 seconds per card
            
            // Calculate required score
            let requiredScore = 200 * (level + 1)
            
            // Determine pattern type
            let patternStyle = level % 5
            let customPattern = createCustomPattern(count: cardCount, style: level)
            
            // Create level config
            let config = LevelConfig(
                cardCount: cardCount,
                timeLimit: timeLimit,
                targetPattern: .custom(customPattern),
                requiredScore: requiredScore
            )
            
            levels.append(config)
        }
        
        return levels
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGame()
        setupMagicEffect()
    }
    
    // MARK: - Game Setup
    private func setupGame() {
        setupUI()
        setupGestureRecognizers()
        updateLabels()
    }
    
    private func setupUI() {
        cardsContainerView.layer.cornerRadius = 12
        cardsContainerView.layer.borderWidth = 2
        cardsContainerView.layer.borderColor = UIColor.systemGray4.cgColor
        
        hintButton.isEnabled = false
        pauseButton.isEnabled = false
        newCardsButton.isEnabled = false
        
        // Set initial labels with larger font
        let labelFont = UIFont.systemFont(ofSize: 20, weight: .bold)
        scoreLabel.font = labelFont
        levelLabel.font = labelFont
        movesLabel.font = labelFont
        timerLabel.font = labelFont
        
        scoreLabel.text = "Score: 0"
        levelLabel.text = "Level: 1"
        movesLabel.text = "Moves: 0"
        timerLabel.text = "00:00"
    }
    
    private func setupGestureRecognizers() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        cardsContainerView.addGestureRecognizer(panGesture)
    }
    
    private func startLevel() {
        guard currentLevel <= levelConfigurations.count else {
            showGameComplete()
            return
        }
        
        showStarEffect(at: view.center)
        
        let config = levelConfigurations[currentLevel - 1]
        timeRemaining = config.timeLimit
        moves = 0
        hintsRemaining = 3
        comboMultiplier = 1
        
        createTargetArrangement(for: config.targetPattern)
        createCards(count: config.cardCount)
        
        startTimer()
        updateLabels()
        
        hintButton.isEnabled = true
        pauseButton.isEnabled = true
        newCardsButton.isEnabled = true
        startButton.isEnabled = false
    }
    
    private func createTargetArrangement(for pattern: TargetPattern) {
        targetArrangement.removeAll()
        targetCardsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let config = levelConfigurations[currentLevel - 1]
        
        switch pattern {
        case .ascending:
            // Create ascending sequence of spades
            for rank in 0..<config.cardCount {
                targetArrangement.append((suit: 0, rank: rank))
            }
        case .descending:
            // Create descending sequence of spades
            for rank in (0..<config.cardCount).reversed() {
                targetArrangement.append((suit: 0, rank: rank))
            }
        case .sameSuit:
            // All cards of spades in sequence
            for rank in 0..<config.cardCount {
                targetArrangement.append((suit: 0, rank: rank))
            }
        case .alternatingColors:
            // Alternating black and red suits in sequence
            for rank in 0..<config.cardCount {
                let suit = rank % 2 == 0 ? 0 : 1 // Alternate between spades and hearts
                targetArrangement.append((suit: suit, rank: rank))
            }
        case .custom(let arrangement):
            targetArrangement = arrangement
        }
        
        for card in targetArrangement {
            let label = UILabel()
            label.textColor = .yellow
            label.text = arrCards[card.suit][card.rank]
            label.font = .systemFont(ofSize: 60)
            label.textAlignment = .center
            targetCardsStackView.addArrangedSubview(label)
        }
        
    }
    
    private func createCards(count: Int) {
        cardViews.forEach { $0.removeFromSuperview() }
        cardViews.removeAll()
        placeholderViews.forEach { $0.removeFromSuperview() }
        placeholderViews.removeAll()
        
        let cardWidth: CGFloat = 60
        let cardHeight: CGFloat = 80
        let containerWidth = cardsContainerView.bounds.width
        let containerHeight = cardsContainerView.bounds.height
        let spacing: CGFloat = 15
        
        // Create target arrangement first
        let arrangement = targetArrangement
        
        // Create semi-transparent target cards in original order
        for (index, targetCard) in arrangement.enumerated() {
            // Create semi-transparent target card
            let placeholder = CardView(frame: CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight))
            placeholder.suit = targetCard.suit
            placeholder.rank = targetCard.rank
            placeholder.text = arrCards[targetCard.suit][targetCard.rank]
            placeholder.alpha = 0.08 // Semi-transparent
            
            // Calculate position in a single row
            let totalWidth = CGFloat(count) * (cardWidth + spacing) - spacing
            let startX = (containerWidth - totalWidth) / 2
            let x = startX + CGFloat(index) * (cardWidth + spacing) + cardWidth/2
            let y = containerHeight / 3 // Position in upper third
            
            placeholder.center = CGPoint(x: x, y: y)
            placeholderViews.append(placeholder)
            cardsContainerView.addSubview(placeholder)
        }
        
        // Create shuffled arrangement for original cards
        let shuffledArrangement = arrangement.shuffled()
        
        // Create original cards at the bottom
        let bottomY = containerHeight - cardHeight/2 - 20 // 20pt from bottom
        let cardSpacing = min(spacing, (containerWidth - CGFloat(count) * cardWidth) / CGFloat(count + 1))
        let cardStartX = (containerWidth - (CGFloat(count) * cardWidth + CGFloat(count - 1) * cardSpacing)) / 2
        
        // Create original cards in shuffled order
        for (index, targetCard) in shuffledArrangement.enumerated() {
            let cardView = CardView(frame: CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight))
            cardView.suit = targetCard.suit
            cardView.rank = targetCard.rank
            cardView.text = arrCards[targetCard.suit][targetCard.rank]
            
            let x = cardStartX + CGFloat(index) * (cardWidth + cardSpacing) + cardWidth/2
            cardView.center = CGPoint(x: x, y: bottomY)
            
            cardViews.append(cardView)
            cardsContainerView.addSubview(cardView)
        }
    }
    
    private func checkCardPosition(_ cardView: CardView) -> Bool {
        guard let position = getCardPosition(at: cardView.center) else {
            return false
        }
        
        // Get target card for this position
        guard position < targetArrangement.count else {
            return false
        }
        
        let targetCard = targetArrangement[position]
        
        // Check if card matches target
        return cardView.suit == targetCard.suit && cardView.rank == targetCard.rank
    }
    
    private func getCardPosition(at point: CGPoint) -> Int? {
        for (index, placeholder) in placeholderViews.enumerated() {
            let distance = hypot(point.x - placeholder.center.x, point.y - placeholder.center.y)
            if distance < 30 { // Threshold for matching position
                return index
            }
        }
        return nil
    }
    
    private func findNearestSnapPoint(to point: CGPoint) -> CGPoint {
        guard !placeholderViews.isEmpty else { return point }
        
        var nearestPoint = placeholderViews[0].center
        var minDistance = CGFloat.greatestFiniteMagnitude
        
        for placeholder in placeholderViews {
            let distance = hypot(point.x - placeholder.center.x, point.y - placeholder.center.y)
            if distance < minDistance {
                minDistance = distance
                nearestPoint = placeholder.center
            }
        }
        
        return nearestPoint
    }
    
    // MARK: - Game Logic
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard !isGamePaused else { return }
        
        let location = gesture.location(in: cardsContainerView)
        
        switch gesture.state {
        case .began:
            if let cardView = cardViewAt(location) {
                lastDraggedCard = cardView
                cardView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                UIView.animate(withDuration: 0.2) {
                    cardView.center = location
                }
            }
            
        case .changed:
            if let cardView = lastDraggedCard {
                cardView.center = location
            }
            
        case .ended:
            if let cardView = lastDraggedCard {
                handleCardDrop(cardView, at: location)
                cardView.transform = .identity
                lastDraggedCard = nil
                moves += 1
                updateLabels()
                checkForCompletion()
            }
            
        default:
            break
        }
    }
    
    private func cardViewAt(_ point: CGPoint) -> CardView? {
        return cardViews.first { $0.frame.contains(point) }
    }
    
    private func handleCardDrop(_ cardView: CardView, at location: CGPoint) {
        let snapPoint = findNearestSnapPoint(to: location)
        
        UIView.animate(withDuration: 0.2) {
            cardView.center = snapPoint
        }
        
        if let index = getCardPosition(at: snapPoint) {
            if index < placeholderViews.count {
                let isCorrect = checkCardPosition(cardView)
                animatePlaceholder(placeholderViews[index], isCorrect: isCorrect)
                if isCorrect {
                    showMagicAt(point: snapPoint)
                    showStarEffect(at: snapPoint)
                }
            }
        }
        
        updateScore(for: cardView, at: snapPoint)
    }
    
    private func animatePlaceholder(_ placeholder: UIView, isCorrect: Bool) {
        let color = isCorrect ? UIColor.green.withAlphaComponent(0.3) : UIColor.red.withAlphaComponent(0.3)
        
        UIView.animate(withDuration: 0.3) {
            placeholder.backgroundColor = color
        } completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 0.5) {
                placeholder.backgroundColor = UIColor.white.withAlphaComponent(0.1)
            }
        }
    }
    
    private func updateScore(for cardView: CardView, at point: CGPoint) {
        let correctPosition = checkCardPosition(cardView)
        
        if correctPosition {
            // Calculate time-based bonus
            var timeBonus = 1
            if let lastMove = lastMoveTime {
                let timeDiff = Date().timeIntervalSince(lastMove)
                if timeDiff < 2.0 { // Quick move bonus
                    timeBonus = 2
                }
            }
            
            // Base score is now 50 points instead of 10
            let baseScore = 50
            // Update score with combo multiplier and time bonus
            score += baseScore * comboMultiplier * timeBonus
            comboMultiplier += 1
            
            // Cap the combo multiplier at 5
            comboMultiplier = min(comboMultiplier, 5)
            
            // Visual feedback
            showScorePopup(at: point, score: baseScore * comboMultiplier * timeBonus)
        } else {
            // Reset combo multiplier on incorrect placement
            comboMultiplier = 1
            // Penalty for incorrect placement
            score = max(0, score - 25)
        }
        
        lastMoveTime = Date()
        updateLabels()
    }
    
    private func showScorePopup(at point: CGPoint, score: Int) {
        let popupLabel = UILabel()
        popupLabel.text = "+\(score)"
        popupLabel.textColor = .systemGreen
        popupLabel.font = .boldSystemFont(ofSize: 24)
        popupLabel.sizeToFit()
        popupLabel.center = point
        
        cardsContainerView.addSubview(popupLabel)
        
        UIView.animate(withDuration: 0.5, animations: {
            popupLabel.transform = CGAffineTransform(translationX: 0, y: -50)
            popupLabel.alpha = 0
        }) { _ in
            popupLabel.removeFromSuperview()
        }
    }
    
    private func checkForCompletion() {
        // Check if all cards are in correct positions
        var allCardsCorrect = true
        
        for cardView in cardViews {
            guard let position = getCardPosition(at: cardView.center) else {
                allCardsCorrect = false
                break
            }
            
            guard position < targetArrangement.count else {
                allCardsCorrect = false
                break
            }
            
            let targetCard = targetArrangement[position]
            if cardView.suit != targetCard.suit || cardView.rank != targetCard.rank {
                allCardsCorrect = false
                break
            }
        }
        
        if allCardsCorrect {
            // Add completion bonus based on remaining time and moves
            let timeBonus = timeRemaining * 10  // 10 points per second remaining
            let moveBonus = max(0, 1000 - (moves * 50))  // Fewer moves = bigger bonus
            score += timeBonus + moveBonus
            
            timer?.invalidate()
            showLevelComplete()
        }
    }
    
    // MARK: - Timer
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    private func updateTimer() {
        timeRemaining -= 1
        
        if timeRemaining <= 0 {
            timer?.invalidate()
            showGameOver()
        }
        
        updateLabels()
    }
    
    // MARK: - UI Updates
    private func updateLabels() {
        scoreLabel.text = "Score: \(score)"
        levelLabel.text = "Level: \(currentLevel)"
        movesLabel.text = "Moves: \(moves)"
        timerLabel.text = timeString(from: timeRemaining)
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    // MARK: - Actions
    @IBAction func startButtonTapped(_ sender: UIButton) {
        vibrate(.soft)
        startLevel()
    }
    
    @IBAction func newCardsButtonTapped(_ sender: UIButton) {
        // Preserve current game state
        vibrate(.soft)
        let config = levelConfigurations[currentLevel - 1]
        
        // Clear existing cards and create new ones
        cardViews.forEach { $0.removeFromSuperview() }
        cardViews.removeAll()
        
        // Create new shuffled arrangement
        createTargetArrangement(for: config.targetPattern)
        createCards(count: config.cardCount)
        
        // Reset move-related stats but keep time and score
        moves = 0
        comboMultiplier = 1
        updateLabels()
    }
    
    @IBAction func hintButtonTapped(_ sender: UIButton) {
        vibrate(.soft)
        guard hintsRemaining > 0 else { return }
        
        hintsRemaining -= 1
        hintButton.setTitle("HINTS: \(hintsRemaining)", for: .normal)
        
        // Show hint animation
        for (index, cardView) in cardViews.enumerated() {
            guard index < targetArrangement.count else { break }
            
            let targetCard = targetArrangement[index]
            let isCorrect = cardView.suit == targetCard.suit && cardView.rank == targetCard.rank
            
            UIView.animate(withDuration: 0.3, animations: {
                cardView.backgroundColor = isCorrect ? .systemGreen.withAlphaComponent(0.3) : .systemRed.withAlphaComponent(0.3)
            }) { _ in
                UIView.animate(withDuration: 0.3, delay: 0.5) {
                    cardView.backgroundColor = .white
                }
            }
        }
    }
    
    @IBAction func pauseButtonTapped(_ sender: UIButton) {
        vibrate(.soft)
        isGamePaused = !isGamePaused
        
        if isGamePaused {
            timer?.invalidate()
            pauseButton.setTitle("RESUME", for: .normal)
            showPauseOverlay()
        } else {
            startTimer()
            pauseButton.setTitle("PAUSE", for: .normal)
            removePauseOverlay()
        }
    }
    
    @IBAction func howToPlayButtonTapped(_ sender: UIButton) {
        vibrate(.soft)
        showInstructions()
    }
    
    private func showInstructions() {
        let alert = UIAlertController(title: "How to Play", message: """
            🎮 Game Instructions:
            
            1. Start the Game:
               - Press 'Start Game' to begin
               - Each level has different card patterns to match
            
            2. Playing the Game:
               - Drag cards to arrange them in the correct pattern
               - Match the pattern shown at the top of the screen
               - Complete the pattern before time runs out
            
            3. Scoring:
               - Get points for correct card placements
               - Quick moves earn bonus points
               - Consecutive correct moves increase your multiplier
            
            4. Features:
               - Use hints (3 per level) to see correct positions
               - Pause anytime to take a break
               - Complete levels to unlock harder challenges
            
            5. Winning:
               - Reach the required score to complete each level
               - Try to complete all levels with the highest score!
            
            Good luck! 🍀
            """, preferredStyle: .alert)
        
        alert.view.subviews.first?.subviews.first?.subviews.first?.subviews.first?.backgroundColor = .gray
        let bg = UIImageView(image: UIImage(named: "bg"))
        bg.alpha = 0.3
        alert.view.subviews.first?.subviews.first?.subviews.first?.subviews.first?.insertSubview(bg,at: 0)
        alert.view.subviews.first?.subviews.first?.subviews.first?.subviews.last?.subviews.first?.backgroundColor = .black
        alert.addAction(UIAlertAction(title: "Got it!", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Game State Handlers
    private func showGameOver() {
        vibrate(.rigid)
        
        let alert = UIAlertController(title: "Game Over",
                                    message: "Time's up! Final Score: \(score)", 
                                    preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Try Again", style: .default) { [weak self] _ in
            self?.resetGame()
        })
        
        present(alert, animated: true)
    }
    
    private func showLevelComplete() {
        vibrate(.medium)
        showCelebrationEffect()
        
        let timeBonus = timeRemaining * 10
        let moveBonus = max(0, 1000 - (moves * 50))
        
        let alert = UIAlertController(
            title: "Level Complete!", 
            message: """
                Pattern Completed!
                Score: \(score)
                Moves: \(moves)
                Time Bonus: +\(timeBonus)
                Move Bonus: +\(moveBonus)
                """, 
            preferredStyle: .alert)
        
        alert.view.subviews.first?.subviews.first?.subviews.first?.subviews.first?.backgroundColor = .gray
        let bg = UIImageView(image: UIImage(named: "bg"))
        bg.alpha = 0.3
        alert.view.subviews.first?.subviews.first?.subviews.first?.subviews.first?.insertSubview(bg,at: 0)
        alert.view.subviews.first?.subviews.first?.subviews.first?.subviews.last?.subviews.first?.backgroundColor = .black
        
        alert.addAction(UIAlertAction(title: "Next Level", style: .default) { [weak self] _ in
            self?.currentLevel += 1
            self?.startLevel()
        })
        
        present(alert, animated: true)
    }
    
    private func showGameComplete() {
        
        vibrate(.heavy)
        showCelebrationEffect()
        
        let alert = UIAlertController(title: "Congratulations!",
                                    message: "You've completed all levels!\nFinal Score: \(score)", 
                                    preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Play Again", style: .default) { [weak self] _ in
            self?.resetGame()
        })
        
        alert.view.subviews.first?.subviews.first?.subviews.first?.subviews.first?.backgroundColor = .gray
        let bg = UIImageView(image: UIImage(named: "bg"))
        bg.alpha = 0.3
        alert.view.subviews.first?.subviews.first?.subviews.first?.subviews.first?.insertSubview(bg,at: 0)
        alert.view.subviews.first?.subviews.first?.subviews.first?.subviews.last?.subviews.first?.backgroundColor = .black
        
        present(alert, animated: true)
    }
    
    private func resetGame() {
        currentLevel = 1
        score = 0
        startLevel()
    }
    
    private func showPauseOverlay() {
        let overlay = UIView(frame: cardsContainerView.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        overlay.tag = 100
        
        let label = UILabel()
        label.text = "PAUSED"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 32)
        label.sizeToFit()
        label.center = overlay.center
        
        overlay.addSubview(label)
        cardsContainerView.addSubview(overlay)
    }
    
    private func removePauseOverlay() {
        cardsContainerView.viewWithTag(100)?.removeFromSuperview()
    }
    
    private func setupMagicEffect() {
        // Create SKView
        skView = SKView(frame: view.bounds)
        skView?.allowsTransparency = true
        skView?.backgroundColor = .clear
        
        // Create empty scene
        let scene = SKScene(size: view.bounds.size)
        scene.backgroundColor = .clear
        skView?.presentScene(scene)
        
        // Load magic particles
        if let particles = SKEmitterNode(fileNamed: "MagicParticles") {
            magicEmitterNode = particles
            particles.position = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
            particles.particleLifetime = 1.0
            particles.particleBirthRate = 100
            scene.addChild(particles)
            particles.isPaused = true
        }
        
        // Load celebration particles
        if let particles = SKEmitterNode(fileNamed: "MagicParticles") {
            celebrationEmitterNode = particles
            particles.position = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
            particles.particleLifetime = 2.0
            particles.particleBirthRate = 200
            particles.particleColor = .blue
            scene.addChild(particles)
            particles.isPaused = true
        }
        
        // Load star particles
        if let particles = SKEmitterNode(fileNamed: "MagicParticles") {
            starEmitterNode = particles
            particles.position = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
            particles.particleLifetime = 1.5
            particles.particleBirthRate = 50
            particles.particleColor = .white
            scene.addChild(particles)
            particles.isPaused = true
        }
        
        // Add SKView behind the game elements
        if let skView = skView {
            view.insertSubview(skView, at: 0)
        }
    }
    
    private func showMagicAt(point: CGPoint) {
        magicEmitterNode?.position = point
        magicEmitterNode?.isPaused = false
        
        // Stop particles after a short duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.magicEmitterNode?.isPaused = true
        }
    }
    
    private func showCelebrationEffect() {
        celebrationEmitterNode?.position = view.center
        celebrationEmitterNode?.isPaused = false
        
        // Create multiple particle sources
        let positions = [
            CGPoint(x: view.bounds.width * 0.25, y: view.bounds.height * 0.75),
            CGPoint(x: view.bounds.width * 0.75, y: view.bounds.height * 0.75),
            CGPoint(x: view.bounds.width * 0.5, y: view.bounds.height * 0.5)
        ]
        
        for position in positions {
            if let particles = celebrationEmitterNode?.copy() as? SKEmitterNode {
                particles.position = position
                skView?.scene?.addChild(particles)
                
                // Remove after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    particles.removeFromParent()
                }
            }
        }
        
        // Stop main celebration emitter
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.celebrationEmitterNode?.isPaused = true
        }
    }
    
    private func showStarEffect(at point: CGPoint) {
        starEmitterNode?.position = point
        starEmitterNode?.isPaused = false
        
        // Stop particles after a short duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.starEmitterNode?.isPaused = true
        }
    }
}

// MARK: - CardView
class CardView: UIView {
    var suit: Int = 0
    var rank: Int = 0
    var text: String = "" {
        didSet {
            label.text = text
        }
    }
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 80)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .white
        layer.cornerRadius = 8
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 4
        
        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(label)
    }
    
}
