import UIKit

final class ViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    private let reuseIdentifier = "FavoriteCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Favorite Books"
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 112
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        favoriteBooks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: reuseIdentifier,
            for: indexPath
        ) as? FavoriteCell else {
            fatalError("Check FavoriteCell class and reuse identifier in Storyboard.")
        }

        cell.configure(with: favoriteBooks[indexPath.row])
        return cell
    }
}
