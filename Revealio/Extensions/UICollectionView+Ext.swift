
import UIKit

extension UICollectionViewProtocol {

    func presentRVAlert(title: String, message: String, buttonTitle: String) {
        alertVC = RVAlertVC(title: title, message: message, buttonTitle: buttonTitle)
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        present(alertVC, animated: true)
    }
}

extension UICollectionView {
    func scrollToBottom<T>(collection: [T]) {
        let lastItemIndex = IndexPath(item: collection.count - 1, section: 0)
        self.scrollToItem(at: lastItemIndex, at: .bottom, animated: true)
    }


    func scrollToBottom<T, X>(snapshot: NSDiffableDataSourceSnapshot<T, X>){
        let lastSectionIdentifier = snapshot.sectionIdentifiers.count - 1
        var item = 0
        var lastItemIndex = IndexPath(item: item, section: lastSectionIdentifier)
        if snapshot.numberOfItems != 0 {
            item = snapshot.itemIdentifiers(inSection: snapshot.sectionIdentifiers[lastSectionIdentifier]).count - 1
            lastItemIndex = IndexPath(item: item, section: lastSectionIdentifier)
            self.scrollToItem(at: lastItemIndex, at: .bottom, animated: false)
        }
    }


    func estimatedFrameForText(text: String, fontSize: CGFloat) -> CGRect {
        let maxWidth = UIScreen.main.bounds.width * 0.7 // 70% of screen width
        let size = CGSize(width: maxWidth, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)

        let boundingRect = NSString(string: text).boundingRect(
            with: size,
            options: options,
            attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)],
            context: nil
        )

        // Add some extra height to account for padding and prevent squashing
        let extraHeight: CGFloat = 10
        return CGRect(
            x: 0,
            y: 0,
            width: ceil(boundingRect.width),
            height: ceil(boundingRect.height) + extraHeight
        )
    }
}
