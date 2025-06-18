import UIKit
import PhotosUI
import InputBarAccessoryView
import FirebaseAuth

extension MessagingVC {

    func configureDataSource() {
        let currentUserId = Auth.auth().currentUser?.uid

        dataSource = UICollectionViewDiffableDataSource<MessageSectionHeader, MessageDoc>(collectionView: collectionView) { collectionView, indexPath, message in
            // Configure cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RVMessageCell.reuseID, for: indexPath) as! RVMessageCell
            // Configure the rest of the cell
            if message.message.senderId == currentUserId {
                cell.isOutgoing = true
            } else {
                cell.isOutgoing = false
            }

            cell.setMessage(message.message)

            return cell
        }
        configureHeader()
    }


    func configureHeader() {
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                   withReuseIdentifier: CollectionHeaderView.reuseIdentifier, for: indexPath) as? CollectionHeaderView
                else { fatalError("Unable to dequeue now playing header view")}
                return self.configureCellDate(collectionHeaderView: header, index: indexPath.section)
            case UICollectionView.elementKindSectionFooter:
                return UICollectionReusableView()
            default:
                fatalError("Unable to dequeue reusable view or idnex out of range")
            }
        }
    }


    // I work out the height of each cell by checking the height for each of the messages text
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        let padding: CGFloat = 26 // Increased padding
        let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
        let itemsAtSection = self.dataSource.snapshot().itemIdentifiers(inSection: section)

        if itemsAtSection[indexPath.item].message.type == .text {
            if !messageHeader.isEmpty {
                height = estimatedFrameForText(text: itemsAtSection[indexPath.item].message.content ?? "").height
                return CGSize(width: view.frame.width, height: height + padding)
            }
        } else if itemsAtSection[indexPath.item].message.type == .image || itemsAtSection[indexPath.item].message.type == .video || itemsAtSection[indexPath.item].message.type == .gif {
            return CGSize(width: view.frame.width, height: 250)
        }

        return CGSize(width: view.frame.width, height: height)
    }
    

    func handleMessageError(_ error: Error) {
        self.presentRVAlert(
            title: "Error",
            message: "Failed to send message: \(error.localizedDescription)",
            buttonTitle: "OK"
        )
    }


    func configureCellDate(collectionHeaderView: CollectionHeaderView, index: Int) -> CollectionHeaderView {
        guard index < messageHeader.count else { return collectionHeaderView }

        let header = messageHeader[index]
        let headerDate = header.date

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let dateString: String

        if calendar.isDate(headerDate, inSameDayAs: today) {
            dateString = "Today"
        } else if calendar.isDate(headerDate, inSameDayAs: yesterday) {
            dateString = "Yesterday"
        } else if calendar.isDate(headerDate, equalTo: today, toGranularity: .weekOfYear) {
            // Same week
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE" // Day name (Monday, Tuesday, etc.)
            dateString = formatter.string(from: headerDate)
        } else {
            // Different week/year
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d, yyyy" // January 1, 2023
            dateString = formatter.string(from: headerDate)
        }

        // Update your collection header view with the formatted date string
        collectionHeaderView.dateLabel.text = dateString

        return collectionHeaderView
    }
}


extension MessagingVC: InputBarAccessoryViewDelegate, RVInputAccessoryViewDelegate, PHPickerViewControllerDelegate, DrawingVCDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        DispatchQueue.main.async {
            let formattedText = text.formatText(text)
            do {
                try self.sendMessage(text: formattedText)
            } catch {
                self.handleMessageError(error)
            }
        }
    }


    func didTapPhotoButton(pickerController: PHPickerViewController) {
        pickerController.delegate = self
        present(pickerController, animated: true)
    }


    func didTapDrawingButton() {
        drawingVC = DrawingVC()
        drawingVC.callbackDelegate = self
        drawingVC.modalPresentationStyle = .overFullScreen
        drawingVC.modalTransitionStyle = .crossDissolve
        navigationController?.pushViewController(drawingVC, animated: true)
    }


    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard !results.isEmpty else { return }

        var images: [Data] = []
        var gifs: [Data] = []
        var videos: [Data] = []
        let dispatchGroup = DispatchGroup()

        results.forEach { result in
            dispatchGroup.enter()

            if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.gif.identifier) {
                // Handle GIF
                result.itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.gif.identifier) { data, error in
                    defer { dispatchGroup.leave() }
                    guard let data = data, error == nil else { return }
                    DispatchQueue.main.async {
                        gifs.append(data)
                    }
                }
            } else if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                // Handle Video
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                    defer { dispatchGroup.leave() }
                    guard let url = url, error == nil else { return }
                    do {
                        let data = try Data(contentsOf: url)
                        DispatchQueue.main.async {
                            videos.append(data)
                        }
                    } catch {
                        print("Error loading video: \(error)")
                    }
                }
            } else {
                // Handle regular Image
                result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                    defer { dispatchGroup.leave() }
                    guard let image = reading as? UIImage, error == nil else { return }
                    if let imageData = image.jpegData(compressionQuality: 0.7) {
                        DispatchQueue.main.async {
                            images.append(imageData)
                        }
                    }
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            do {
                try self.sendPictureMessage(images: images, gifs: gifs, videos: videos)
            } catch {
                self.handleMessageError(error)
            }
        }
    }


    func didFinishDrawing(with image: UIImage) {
        loadMessages() // have to renable listener
        drawingVC.navigationController?.popViewController(animated: true)
        drawingVC = nil
        var images = [Data]()
        if let imageData = image.jpegData(compressionQuality: 0.7) {
            images.append(imageData)
            do {
                try sendPictureMessage(images: images)
            } catch {
                self.handleMessageError(error)
            }
        }
    }
}
