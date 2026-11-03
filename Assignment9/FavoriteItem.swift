import UIKit

struct FavoriteItem {
    let title: String
    let subtitle: String
    let imageName: String
    let rating: Int
}

let favoriteBooks: [FavoriteItem] = [
    .init(title: "The Picture of Dorian Gray", subtitle: "Oscar Wilde · Gothic fiction", imageName: "book01", rating: 5),
    .init(title: "Pride and Prejudice", subtitle: "Jane Austen · Romance", imageName: "book02", rating: 5),
    .init(title: "Jane Eyre", subtitle: "Charlotte Brontë · Classic", imageName: "book03", rating: 5),
    .init(title: "Wuthering Heights", subtitle: "Emily Brontë · Gothic romance", imageName: "book04", rating: 4),
    .init(title: "Frankenstein", subtitle: "Mary Shelley · Gothic fiction", imageName: "book05", rating: 5),
    .init(title: "Dracula", subtitle: "Bram Stoker · Horror", imageName: "book06", rating: 4),
    .init(title: "The Great Gatsby", subtitle: "F. Scott Fitzgerald · Classic", imageName: "book07", rating: 4),
    .init(title: "1984", subtitle: "George Orwell · Dystopian fiction", imageName: "book08", rating: 5),
    .init(title: "Brave New World", subtitle: "Aldous Huxley · Dystopian fiction", imageName: "book09", rating: 4),
    .init(title: "The Stranger", subtitle: "Albert Camus · Philosophical fiction", imageName: "book10", rating: 4),
    .init(title: "The Metamorphosis", subtitle: "Franz Kafka · Novella", imageName: "book11", rating: 5),
    .init(title: "Crime and Punishment", subtitle: "Fyodor Dostoevsky · Psychological fiction", imageName: "book12", rating: 5),
    .init(title: "The Master and Margarita", subtitle: "Mikhail Bulgakov · Satire", imageName: "book13", rating: 5),
    .init(title: "The Bell Jar", subtitle: "Sylvia Plath · Literary fiction", imageName: "book14", rating: 4),
    .init(title: "Rebecca", subtitle: "Daphne du Maurier · Gothic mystery", imageName: "book15", rating: 5),
    .init(title: "The Secret History", subtitle: "Donna Tartt · Dark academia", imageName: "book16", rating: 5),
    .init(title: "The Song of Achilles", subtitle: "Madeline Miller · Mythological fiction", imageName: "book17", rating: 4),
    .init(title: "The Handmaid's Tale", subtitle: "Margaret Atwood · Dystopian fiction", imageName: "book18", rating: 4),
    .init(title: "Little Women", subtitle: "Louisa May Alcott · Classic", imageName: "book19", rating: 4),
    .init(title: "The Brothers Karamazov", subtitle: "Fyodor Dostoevsky · Philosophy", imageName: "book20", rating: 5)
]
