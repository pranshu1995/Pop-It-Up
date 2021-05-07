
import UIKit



class GameViewController: UIViewController {
    // Game Controller
    
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var gameScoreLabel: UILabel!
    
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var initTimerLabel: UILabel!
    @IBOutlet weak var bubbleViewContainer: UIView!
    

    // Game Variables
    var playerName: String = "";
    var gameScore: Float = 0;
    var remainingTime: Int = 60;
    var maxBubbles: Int = 15;
    
    // Timer variables
    var initTimerCount: Int = 3;
    var initTimer = Timer();
    var timer = Timer();
    var initialGameTime: Int = 60;
    
    // Highscore check variables
    var highScore: Float = 0;
    var highScoreExceededFlag: Bool = false;
    
    
    // Data store
    let userDefaults = UserDefaults.standard;
    
    // Combo check
    var lastPopped: UIColor!;
    var comboLength: Int = 0;
    
    // Bubble counters
    var bubblesRemoved: Int = 0;
    var randomBubbles: Int = 0;
    var bubblesAvailable: Int = 0;
    
    var bubbleViewContainerColor: UIColor = .lightGray;
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
//        navigationController?.setNavigationBarHidden(true, animated: false);

        //Fetch and set initial data
        
        playerName = userDefaults.value(forKey: "playerName") as? String ?? "Player1";
        remainingTime = userDefaults.value(forKey: "gameTime") as? Int ?? 60;
        maxBubbles = userDefaults.value(forKey: "bubbleCount") as? Int ?? 15;
        initialGameTime = remainingTime;

        remainingTimeLabel.text = String(remainingTime);
        gameScoreLabel.text = String(gameScore);
        
        fetchHighScore();
        
        // Start Flash timer
        initTimerLabel.text = "Ready \(playerName)";
        initTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
            initTimer in
            self.initCountdown()
        }
        
    }
    
    @objc func fetchHighScore(){
        // Get highest score from data or set as 0 if empty
        var fetchedScores: [Highscore];
        if let data = UserDefaults.standard.value(forKey:"HighScores") as? Data {
            fetchedScores = try! PropertyListDecoder().decode(Array<Highscore>.self, from: data)
            if(fetchedScores.isEmpty == false){
                highScore = fetchedScores[0].score;
            }
            else{
            highScore = 0;
            }
            highScoreLabel.text = String(highScore);
        }
        
    }
    
    @objc func initCountdown(){
        // Game start countdown
        if(initTimerCount>0){
        initTimerLabel.text = String(initTimerCount);
        initTimerCount = initTimerCount - 1;
        }
        else if(initTimerCount == 0){
            initTimerLabel.text = "GO";
            initTimerCount = initTimerCount - 1;
        }
        else{
            initTimerLabel.removeFromSuperview();
            // Launch game on countdown end
            launchGame();
            initTimer.invalidate();
        }
        
    }
    
  
    
    @objc func launchGame(){
        
        // Set frame reference for positioning
        userDefaults.set(Int(bubbleViewContainer.frame.width), forKey: "frameWidth");
        userDefaults.set(Int(bubbleViewContainer.frame.height), forKey: "frameHeight");
        
        // Gradient for background color
        bubbleViewContainer.applyGradient(colors: [bubbleViewContainerColor.cgColor, bubbleViewContainerColor.withAlphaComponent(0.7).cgColor, bubbleViewContainerColor.withAlphaComponent(0.35).cgColor, bubbleViewContainerColor.withAlphaComponent(0.15).cgColor, bubbleViewContainerColor.withAlphaComponent(0.35).cgColor, bubbleViewContainerColor.withAlphaComponent(0.7).cgColor,  bubbleViewContainerColor.withAlphaComponent(1).cgColor]);
        
        // Game timer starts
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
            timer in
            self.generateBubble()
            self.counting()
            self.removeBubble()
        }
    }
    
    
    @objc func counting() {
        // Time elapsing for game
        remainingTime = remainingTime - 1;
        remainingTimeLabel.text = String(remainingTime);
        
       
        
        if remainingTime == 0 {
            timer.invalidate();
            
            // Navigate to highscore screen when time ends
            // Variables sent for display
            let vc = storyboard?.instantiateViewController(identifier: "HighScoreViewController") as! HighScoreViewController
            self.navigationController?.pushViewController(vc, animated: true)
            vc.navigationItem.setHidesBackButton(true, animated: true)
            vc.currentName = self.playerName;
            vc.currentScore = gameScore;
            vc.gamePLayFlag = true;
        }
        
    }
    
    
    @objc func randomisedColor() -> UIColor{
        // Generate random color for the bubble
        
        var color: UIColor;
        let number: Int = Int.random(in: 1...100);
        
        switch number {
        case 1...40:
            color = .red;
            break;
        case 41...70:
            color = .magenta;
            break;
        case 71...85:
            color = .green;
            break;
        case 86...95:
            color = .blue;
            break;
        case 95...100:
            color = .black;
            break;
        default:
            color = .red;
            break;
        }
        return color;
    }
    
   
    
    
    @objc func generateBubble() {
        // Create bubble
        // Generate random bubbles based on bubbles present on screen
        
        if(maxBubbles == bubblesAvailable){
            randomBubbles = 1;
        }
        else{
        randomBubbles = Int.random(in: 1...maxBubbles-bubblesAvailable);
        }

        
        // Check if bubble generated doesn't intersect already present bubble
        for _ in 1...randomBubbles{
            let bubble = Bubble()
            bubble.setProperties(color: randomisedColor());
            bubble.animation();
            bubble.addTarget(self, action: #selector(bubblePressed), for: .touchUpInside);
        
            var intersectionCheck = 0;
        
            
            for i in bubbleViewContainer.subviews{
                if(bubble.frame.intersects(i.frame) && type(of: i) == Bubble.self){
                    intersectionCheck = 1;
                }
            }
        
            if(intersectionCheck == 0){
                bubbleViewContainer.addSubview(bubble);
                bubblesAvailable = bubblesAvailable + 1; // Bubble counter

            }
        }

    }
    
    @objc func removeBubble(){
        // Remove random bubbles from screen

        bubblesRemoved = Int.random(in: 1...bubblesAvailable);
        if(bubblesRemoved == bubblesAvailable){
            bubblesRemoved = bubblesRemoved - 1;
        }

        for i in bubbleViewContainer.subviews{
            if(type(of: i) == Bubble.self && bubblesRemoved>0){
                i.removeFromSuperview();
                bubblesAvailable = bubblesAvailable - 1;
                bubblesRemoved = bubblesRemoved - 1;
            }
        }

    }
    
    
    @objc func scoreCard(color: UIColor) -> Float{
        // Calculate score according to color of bubble popped
        
        var score: Float;
        switch color.accessibilityName {
        case "dark red":
            score = 1;
            break;
        case "dark magenta":
            score = 2;
            break;
        case "vibrant green":
            score = 5;
            break;
        case "dark blue":
            score = 8;
            break;
        case "black":
            score = 10;
            break;
        default:
            score = 1;
            break;
        }
        return score;
    }
    
    @objc func showToast(message : String, font: UIFont) {
        // Show toast notification if player exceeds high score
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-75, width: 150, height: 35));
        toastLabel.backgroundColor = UIColor.darkGray.withAlphaComponent(0.6);
        toastLabel.textColor = UIColor.white;
        toastLabel.font = font;
        toastLabel.textAlignment = .center;
        toastLabel.text = message;
        toastLabel.alpha = 1.0;
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true;
        self.view.addSubview(toastLabel);
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0;
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview();
        })
    }
    
    @objc func highScoreUpdate(){
        // Update high score if crossed
        
        if(gameScore > highScore){
            if(highScoreExceededFlag == false){
                self.showToast(message: "High Score reached", font: .systemFont(ofSize: 15.0))
                highScoreExceededFlag = true;
            }
            if(highScoreExceededFlag == true){
                highScore = gameScore;
                highScoreLabel.text = String(highScore);
            }
        }
    }
    
    @objc func popTag(cX: Int, cY: Int, score: Float, comboLength: Int){
        // Show score earned for each bubble popped
        
        let popLabel = UILabel(frame: CGRect(x: cX, y: cY-25, width: 100, height: 20));
        popLabel.textColor = UIColor.red;
        popLabel.font = UIFont(name: "ChalkboardSE-Bold", size: 22)
        popLabel.textAlignment = .center;
        
        if(comboLength == 0){
            popLabel.text = "+ \(score)"
        }
        else{
            popLabel.text = "+ \(1.5 * score)"
        }

        bubbleViewContainer.addSubview(popLabel);
        
        UIView.animate(withDuration: 0.5, delay: 0.6, options: .curveEaseOut, animations: {
            popLabel.alpha = 0.0;
        }, completion: {(isCompleted) in
            popLabel.removeFromSuperview();
        })
        
        if(comboLength > 0){
            // Show combo earned
            
            let comboLabel = UILabel(frame: CGRect(x: cX, y: cY-50, width: 100, height: 20));
            comboLabel.textColor = UIColor.red;
            comboLabel.font = UIFont(name: "ChalkboardSE-Bold", size: 22);
            comboLabel.textAlignment = .center;
            comboLabel.text = "Combo \(comboLength)!";
            bubbleViewContainer.addSubview(comboLabel);
            
            UIView.animate(withDuration: 0.5, delay: 0.6, options: .curveEaseOut, animations: {
                comboLabel.alpha = 0.0;
            }, completion: {(isCompleted) in
                comboLabel.removeFromSuperview();
            })
        }
    }
    
    @IBAction func bubblePressed(_ sender: UIButton) {
        // Remove pressed bubble from view
        
        
        
        let popScore = scoreCard(color: sender.backgroundColor!);

        // Check for combos and length
        if(sender.backgroundColor == lastPopped){
            comboLength = comboLength + 1;
            gameScore = gameScore + 1.5 * popScore;
        }
        else{
            comboLength = 0;
            gameScore = gameScore + popScore;
        }
        
        lastPopped = sender.backgroundColor!;
        gameScoreLabel.text = String(gameScore);
        
        highScoreUpdate();
        

        sender.removeFromSuperview();
        // Update Bubble pop count
        bubblesAvailable = bubblesAvailable - 1;
        bubblesRemoved = bubblesRemoved - 1;

        
        popTag(cX: Int(sender.frame.origin.x),cY: Int(sender.frame.origin.y),score: popScore, comboLength: comboLength);
    }
}

extension UIView
{
    // Extension for gradient color
    func applyGradient(colors: [CGColor])
    {
        let gradientLayer = CAGradientLayer();
        gradientLayer.colors = colors;
        gradientLayer.startPoint = CGPoint(x: 0, y: 0);
        gradientLayer.endPoint = CGPoint(x: 1, y: 0);
        gradientLayer.frame = self.bounds;
        self.layer.insertSublayer(gradientLayer, at: 0);
    }
}
