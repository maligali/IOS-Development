import UIKit

final class FavoriteCell: UITableViewCell {
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var ratingStackView: UIStackView!
    
    func configure(with item: FavoriteItem) {
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        coverImageView.image = UIImage(named: item.imageName)
        
        ratingStackView.arrangedSubviews.forEach {
            ratingStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        let ratingLabel = UILabel()
        ratingLabel.font = .systemFont(ofSize: 16)
        ratingLabel.text = String(
            repeating: "★", count: item.rating
        ) + String(
            repeating: "☆", count: 5 - item.rating
        )
        ratingLabel.textColor = .systemYellow
        ratingLabel.textAlignment = .left
        ratingLabel.sizeToFit()
        
        ratingStackView.addArrangedSubview(ratingLabel)
    }
}
