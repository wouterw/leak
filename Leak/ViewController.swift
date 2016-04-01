import UIKit

import RxSwift
import RxCocoa
import RxDataSources

class ViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!

  typealias Section = AnimatableSectionModel<String, String>
  
  private let pollingSampler = Driver<Int>.interval(1)
  private var pollingDisposable: Disposable?
  
  private let dataSource = RxTableViewSectionedAnimatedDataSource<Section>()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    dataSource.configureCell = { _, tableView, indexPath, item in
      let cell = tableView.dequeueReusableCellWithIdentifier("myCell", forIndexPath: indexPath)
      cell.textLabel?.text = item.value
      return cell
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    pollingDisposable = pollingSampler
      .flatMapLatest { _ in Driver.just(["a", "b", "c"]) }
      .doOnNext { _ in print("=> Tick.") }
      .map { [Section(model: "", items: $0)] }
      .drive(tableView.rx_itemsAnimatedWithDataSource(dataSource))
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)

    pollingDisposable?.dispose()
  }
}
