import UIKit

final class TransitionLayoutViewController: UIViewController {

    // MARK: - Properties

    private lazy var layouts: [UICollectionViewFlowLayout] = {
        [17, 11, 9, 7, 5, 3, 1].map { makeFlowLayout(columns: $0) }
    }()
    private var currentLayoutIndex = 2
    private var interactiveLayout: UICollectionViewTransitionLayout?

    // MARK: - UI

    private lazy var collectionView: UICollectionView = {
        let layout = layouts[currentLayoutIndex]
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.addGestureRecognizer(pinchGesture)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private lazy var pinchGesture: UIPinchGestureRecognizer = {
        let gesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        gesture.delegate = self
        return gesture
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }

    // MARK: - Layout Helpers
    private func makeFlowLayout(columns: Int) -> UICollectionViewFlowLayout {
        let spacing: CGFloat = 1
        let totalSpacing = CGFloat(columns - 1) * spacing
        let width = (view.bounds.width - totalSpacing) / CGFloat(columns)

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: width, height: width)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        return layout
    }

    // MARK: - Gesture Handling
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .changed:
            handlePinchChanged(with: gesture.scale)

        case .ended, .cancelled:
            completeOrCancelTransition()

        default:
            break
        }
    }

    private func handlePinchChanged(with scale: CGFloat) {
        let logScale = log2(scale)
        
        if interactiveLayout == nil {
            guard let targetIndex = calculateTargetLayoutIndex(from: logScale) else { return }
            startInteractiveTransition(to: targetIndex)
        }

        guard let layout = interactiveLayout else { return }
        layout.transitionProgress = calculateProgress(from: logScale)
    }

    private func completeOrCancelTransition() {
        guard let layout = interactiveLayout else { return }

        if layout.transitionProgress > 0.5 {
            collectionView.finishInteractiveTransition()
        } else {
            collectionView.cancelInteractiveTransition()
        }

        interactiveLayout = nil
    }

    private func calculateTargetLayoutIndex(from logScale: CGFloat) -> Int? {
        let delta = Int(floor(logScale))
        let proposedIndex = currentLayoutIndex + (logScale < 0 ? delta : delta + 1)

        guard proposedIndex != currentLayoutIndex,
              (0..<layouts.count).contains(proposedIndex) else {
            return nil
        }

        return proposedIndex
    }

    private func startInteractiveTransition(to targetIndex: Int) {
        let targetLayout = layouts[targetIndex]

        interactiveLayout = collectionView.startInteractiveTransition(to: targetLayout) { [weak self] _, finished in
            guard let self = self else { return }
            if finished {
                self.currentLayoutIndex = targetIndex
            }
            self.interactiveLayout = nil
        }
    }

    private func calculateProgress(from logScale: CGFloat) -> CGFloat {
        return min(1.0, max(0.0, abs(logScale)))
    }
}

// MARK: - UICollectionViewDataSource

extension TransitionLayoutViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 200
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = UIColor(hue: CGFloat(indexPath.item) / 200, saturation: 0.8, brightness: 0.9, alpha: 1)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension TransitionLayoutViewController: UICollectionViewDelegate {}

// MARK: - UIGestureRecognizerDelegate

extension TransitionLayoutViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
