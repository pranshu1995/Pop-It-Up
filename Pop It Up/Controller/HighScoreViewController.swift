

import UIKit


class HighScoreViewController: UIViewController {
    // High score page controller
    
    
    var currentName: String = "";
    var currentScore: Float = 0;
    var gamePLayFlag: Bool = false;
    var allScores: [Highscore] = [];
    
    let userDefaults = UserDefaults.standard;

    @IBOutlet weak var scoreLabel: UILabel!;
    @IBOutlet weak var scoreTable: UITableView!;
    @IBOutlet weak var playAgainBtn: UIButton!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
//        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Check entry pathway from game or home and modify screen accordingly
        if(gamePLayFlag){
            allScores = scoreComparision();
            scoreLabel.text = "🏆 You scored \(currentScore)";
        }
        else{
            fetchHighscores();
            scoreLabel.removeFromSuperview();
            playAgainBtn.removeFromSuperview();
        }
        
        // Do any additional setup after loading the view.
    }
    
    
    func fetchHighscores(){
        // Fetch highscore data from User defaults
        if let data = UserDefaults.standard.value(forKey:"HighScores") as? Data {
            allScores = try! PropertyListDecoder().decode(Array<Highscore>.self, from: data)
        }
    }
    
    func scoreComparision() -> [Highscore]{
        // Get scores from the highest scorers
        let player = Highscore(name: currentName, score: currentScore);
        var fetchedScores: [Highscore] = [];
        
        if let data = UserDefaults.standard.value(forKey:"HighScores") as? Data {
            fetchedScores = try! PropertyListDecoder().decode(Array<Highscore>.self, from: data)
        }
        
        if (fetchedScores.isEmpty == true){
            fetchedScores.append(player);
        }
        else{
            fetchedScores.sort{$0.score > $1.score}
            let count = fetchedScores.count;
            if(count<6){
                fetchedScores.append(player);
            }
            else if(count == 6){
                if(player.score > fetchedScores.last!.score){
                    fetchedScores.removeLast();
                    fetchedScores.append(player);
                }
            }
            fetchedScores.sort{$0.score > $1.score}
        }
        
        userDefaults.set(try? PropertyListEncoder().encode(fetchedScores), forKey: "HighScores");
        
        return fetchedScores;
        
    }
}


extension HighScoreViewController: UITableViewDelegate, UITableViewDataSource{
    // Extension for table data
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allScores.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "CELL");
        
        let cellVal = allScores[indexPath.row];
        
        cell.textLabel?.text = cellVal.name;
        cell.detailTextLabel?.text = String(cellVal.score);
        
        return cell;
    }
    
}
