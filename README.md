# LMZMoveableCellTableView

一个功能强大、流畅易用的可拖拽排序 TableView 组件，支持长按拖拽、边缘滚动、多 Section 管理等特性。

## ✨ 特性

- 🎯 **长按拖拽排序** - 长按 0.5 秒后即可开始拖拽，轻松重排列表项
- 📜 **边缘自动滚动** - 拖拽到边缘时自动滚动，支持长列表操作
- 🎨 **自定义快照视图** - 支持自定义拖拽时显示的截图样式
- 📦 **多 Section 支持** - 支持多个 Section，可单独控制每个 Section 是否可移动
- 💫 **流畅动画** - 平滑的拖拽动画和位置更新
- 📳 **触觉反馈** - iOS 10+ 支持触觉反馈，提供更好的交互体验
- 🚫 **不可移动提示** - 尝试拖拽不可移动的 Cell 时提供动画提示
- ✅ **边界优化** - 优化了拖拽到顶部时的抖动问题

## 📋 要求

- iOS 10.0+
- Swift 5.0+
- Xcode 11.0+

## 🚀 快速开始

### 1. 基本使用

```swift
import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, 
                      LMZMovableCellTableViewDataSource, LMZMovableCellTableViewDelegate {
    
    var dataSource: [IMoveableItemSection] = [
        MoveableItemSection(titleString: "Section 1", sectionHeight: 20, can: true, cells: [
            MoveableItemDetail(titleString: "Item 1", detailString: "Detail 1", heigh: 60),
            MoveableItemDetail(titleString: "Item 2", detailString: "Detail 2", heigh: 60)
        ])
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tableView = LMZMoveableTableView(frame: view.bounds, style: .plain)
        tableView.lmz_delegate = self
        tableView.lmz_dataSource = self
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        tableView.reloadData()
    }
    
    // MARK: - LMZMovableCellTableViewDataSource
    func dataSourceArrayInTableView(tableView: LMZMoveableTableView) -> [IMoveableItemSection] {
        return dataSource
    }
    
    func snapshotViewWithCell(cell: IMoveableTableViewCell) -> UIView {
        return cell.bgView
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 返回你的自定义 Cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return dataSource[indexPath.section].moveAble
    }
}
```

### 2. 实现协议方法

#### 必需方法

```swift
// 返回数据源数组
func dataSourceArrayInTableView(tableView: LMZMoveableTableView) -> [IMoveableItemSection] {
    return dataSource
}

// 返回用于生成快照的视图（通常是 Cell 的背景视图）
func snapshotViewWithCell(cell: IMoveableTableViewCell) -> UIView {
    return cell.bgView
}
```

#### 可选方法

```swift
// 自定义快照样式
func tableView(_ tableView: LMZMoveableTableView, customizeMovalbeCell movableCellsnapshot: UIImageView) {
    movableCellsnapshot.layer.shadowColor = UIColor.black.cgColor
    movableCellsnapshot.layer.cornerRadius = 10
    movableCellsnapshot.layer.shadowOpacity = 1
    movableCellsnapshot.layer.shadowRadius = 10
}

// 自定义开始拖拽动画
func tableView(_ tableView: LMZMoveableTableView, customizeStartMovingAnimation movableCellsnapshot: UIImageView, fingerPoint point: CGPoint) {
    // 自定义动画
}

// 拖拽开始
func tableView(_ tableView: LMZMoveableTableView, willMoveCellAtIndexPath indexPath: IndexPath) {
    print("开始拖拽: \(indexPath)")
}

// Cell 位置改变（每次位置改变时调用）
func tableView(_ tableView: LMZMoveableTableView, didMoveCellFromIndexPath indexPath: IndexPath) {
    print("移动到: \(indexPath)")
    // 注意：这里的 indexPath 是目标位置，可以通过 tableView.selectedIndexPath 获取当前选中的位置
}

// 拖拽结束
func tableView(_ tableView: LMZMoveableTableView, endMoveCellAtIndexPath indexPath: IndexPath) {
    print("拖拽结束: \(indexPath)")
    // 在这里保存数据
}

// 尝试拖拽不可移动的 Cell
func tableView(_ tableView: LMZMoveableTableView, tryMoveUnmovableCellAtIndexPath indexPath: IndexPath) {
    print("该 Cell 不可移动: \(indexPath)")
}
```

## ⚙️ 配置选项

### 基本属性

```swift
// 启用/禁用触觉反馈（默认: false）
tableView.canFeedback = true

// 启用/禁用边缘滚动（默认: true）
tableView.canEdgeScroll = true

// 启用/禁用不可移动提示（默认: true）
tableView.canHintWhenCannotMove = true
```

### 边缘滚动配置

```swift
// 边缘滚动触发范围（默认: 150.0）
tableView.edgeScrollTriggerRange = 150.0

// 每帧最大滚动速度（默认: 20.0）
tableView.maxScrollSpeedPerFrame = 20.0
```

### 长按手势配置

长按手势的最小持续时间在初始化时设置为 0.5 秒，如需修改可在代码中调整：

```swift
tableView.longPressGesture?.minimumPressDuration = 0.5
```

## 📐 数据模型

### IMoveableItemSection

```swift
protocol IMoveableItemSection {
    var title: String { get set }
    var height: CGFloat { get set }
    var moveAble: Bool { get set }  // 该 Section 是否可移动
    var items: [IMoveableItemDetail] { get set }
}

// 使用示例
let section = MoveableItemSection(
    titleString: "Section Title",
    sectionHeight: 20,
    can: true,  // 该 Section 是否可以移动
    cells: [item1, item2, item3]
)
```

### IMoveableItemDetail

```swift
protocol IMoveableItemDetail {
    var title: String { get set }
    var detail: String { get set }
    var cellHeight: CGFloat { get set }
}

// 使用示例
let item = MoveableItemDetail(
    titleString: "Title",
    detailString: "Detail",
    heigh: 60.0
)
```

### IMoveableTableViewCell

你的 Cell 需要实现此协议：

```swift
protocol IMoveableTableViewCell {
    var bgView: UIView { get set }  // 用于生成快照的背景视图
}

// 实现示例
class MyCell: UITableViewCell, IMoveableTableViewCell {
    @IBOutlet weak var bgView: UIView!
    // ... 其他代码
}
```

## 🎯 核心功能说明

### 1. 长按拖拽

- 长按 Cell 0.5 秒后开始拖拽
- 自动生成 Cell 的快照视图
- 支持自定义快照样式和动画

### 2. 边缘滚动

- 当拖拽到 TableView 顶部或底部边缘时自动滚动
- 滚动速度根据距离边缘的距离动态调整
- 优化了拖拽到顶部时的抖动问题

### 3. Section 控制

- 每个 Section 可以独立设置是否可移动
- 支持通过 `canMoveRowAt` 方法控制单个 Cell 是否可移动
- 不同 Section 之间的 Cell 不会交换位置

### 4. 触觉反馈

- iOS 10+ 支持触觉反馈
- 在开始拖拽和位置改变时提供反馈
- 可通过 `canFeedback` 属性控制是否启用

### 5. 不可移动提示

- 尝试拖拽不可移动的 Cell 时显示抖动动画
- 可通过 `canHintWhenCannotMove` 属性控制

## 🔧 高级用法

### 自定义快照样式

```swift
func tableView(_ tableView: LMZMoveableTableView, customizeMovalbeCell movableCellsnapshot: UIImageView) {
    // 添加阴影
    movableCellsnapshot.layer.shadowColor = UIColor.black.cgColor
    movableCellsnapshot.layer.shadowOffset = CGSize(width: 0, height: 2)
    movableCellsnapshot.layer.shadowOpacity = 0.3
    movableCellsnapshot.layer.shadowRadius = 8
    
    // 添加圆角
    movableCellsnapshot.layer.cornerRadius = 10
    movableCellsnapshot.layer.masksToBounds = false
    
    // 添加变换
    movableCellsnapshot.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
}
```

### 保存拖拽后的数据

由于 `UITableView` 的 `moveRow(at:to:)` 方法在拖拽过程中已经逐步更新了界面，你需要同步更新数据源以保持一致性。

```swift
// 在拖拽过程中跟踪位置变化
var dragStartIndexPath: IndexPath?

func tableView(_ tableView: LMZMoveableTableView, willMoveCellAtIndexPath indexPath: IndexPath) {
    dragStartIndexPath = indexPath  // 记录拖拽开始的位置
}

func tableView(_ tableView: LMZMoveableTableView, didMoveCellFromIndexPath indexPath: IndexPath) {
    // 每次位置改变时调用
    // indexPath 是目标位置，tableView.selectedIndexPath 是移动后的当前位置
    // 由于 moveRow 已经更新了界面，这里通常不需要额外操作
    // 如果需要，可以在这里同步更新数据源
}

func tableView(_ tableView: LMZMoveableTableView, endMoveCellAtIndexPath indexPath: IndexPath) {
    // 拖拽结束，indexPath 是最终位置
    // 由于 UITableView 的 moveRow 已经逐步更新了界面
    // 如果需要在结束时统一处理，可以重新读取当前的数据排列状态
    // 或者在整个拖拽过程中已经同步更新了数据源
    
    // 保存数据（如果需要持久化）
    saveDataSource(dataSource)
    dragStartIndexPath = nil
}
```

**提示**: 由于拖拽过程中会多次调用 `moveRow`，如果需要在每次移动时同步数据源，可以在 `didMoveCellFromIndexPath` 中处理。如果只需要在结束时保存，可以在 `endMoveCellAtIndexPath` 中根据最终的排列保存数据。

### 动态控制 Cell 可移动性

```swift
func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    // 根据业务逻辑动态判断
    if indexPath.section == 0 && indexPath.row == 0 {
        return false  // 第一个 Cell 不可移动
    }
    return dataSource[indexPath.section].moveAble
}
```

## 🐛 注意事项

1. **数据源管理**: 在拖拽过程中，UITableView 会自动调用 `moveRow(at:to:)` 方法来更新界面。你需要在 `endMoveCellAtIndexPath` 回调中同步更新你自己的数据源，确保数据一致性。

2. **Section 限制**: 不同 Section 之间的 Cell 不会交换位置，这是设计如此。

3. **Cell 重用**: 确保你的 Cell 实现了 `IMoveableTableViewCell` 协议，并正确设置了 `bgView` 属性。

4. **性能优化**: 对于大量数据的列表，建议在 `endMoveCellAtIndexPath` 中进行批量更新操作。

5. **边界处理**: 组件已经优化了拖拽到顶部时的抖动问题，但如果仍有问题，可以调整 `edgeScrollTriggerRange` 和 `maxScrollSpeedPerFrame` 参数。

## 📝 更新日志

### 最新版本
- ✅ 优化了拖拽到 TableView 顶部时的抖动问题
- ✅ 改进了边缘滚动的判断逻辑，使用手势真实位置而非 snapshot 位置
- ✅ 修复了 `limitContentOffsetY` 的逻辑错误
- ✅ 优化了 `limitSnapshotCenterY` 的边界计算
- ✅ 改进了代码健壮性，添加了边界检查

## 📄 许可证

本项目采用 MIT 许可证。详情请参阅 LICENSE 文件。

## 👤 作者

Created by mac on 2021/7/7

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

