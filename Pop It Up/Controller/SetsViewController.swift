
import UIKit

class SetsViewController: UIViewController {
    // Settings Controller
    
    @IBOutlet weak var playerName: UITextField!
    @IBOutlet weak var gameTime: UISlider!
    @IBOutlet weak var bubbleCount: UISlider!
    
    @IBOutlet weak var bubbleCountLabel: UILabel!
    @IBOutlet weak var gameTimeLabel: UILabel!
    
    let userDefaults = UserDefaults.standard;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        // Remove navigation bar
        navigationController?.setNavigationBarHidden(true, animated: false)

        // Do any additional setup after loading the view.
        let initGameTime = Float(userDefaults.value(forKey: "gameTime") as? Int ?? 60);
        let initBubbleCount = Float(userDefaults.value(forKey: "bubbleCount") as? Int ?? 15);
        
        playerName.text = userDefaults.value(forKey: "playerName") as? String ?? "Player1";
        
        gameTime.setValue(initGameTime, animated: true);
        gameTimeLabel.text = String(Int(initGameTime))
        
        bubbleCount.setValue(initBubbleCount , animated: true);
        bubbleCountLabel.text = String(Int(initBubbleCount))
    }
    
    
    @IBAction func timeUpdate(_ sender: Any) {
        // Update time label
        gameTimeLabel.text = String(Int(gameTime.value))
    }
    
    @IBAction func bubbleUpdate(_ sender: Any) {
        // Update max bubbles label
        bubbleCountLabel.text = String(Int(bubbleCount.value))
    }
    
    
    @IBAction func setSettings(_ sender: Any) {
        
        // Set data in User defaults
        userDefaults.set(playerName.text, forKey: "playerName");
        userDefaults.set(Int(gameTime.value), forKey: "gameTime");
        userDefaults.set(Int(bubbleCount.value), forKey: "bubbleCount");
        
        // Navigate to home
        let vc = storyboard?.instantiateViewController(identifier: "HomeViewController") as! HomeViewController
        self.navigationController?.pushViewController(vc, animated: true)
        vc.navigationItem.setHidesBackButton(true, animated: true)
        
    }
    

}

