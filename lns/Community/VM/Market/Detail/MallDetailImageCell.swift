//
//  MallDetailImageCell.swift
//  lns
//
//  Created by Elavatine on 2025/9/8.
//

final class MallDetailImageCell: UITableViewCell {

    static let reuseId = "MallDetailImageCell"

    private var vm: MallDetailImageVM?
    private var taskUrl: String?

    var heightCalculated: ((MallDetailImageVM) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .COLOR_BG_WHITE
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageViewEx.kf.cancelDownloadTask()
        taskUrl = nil
    }

    private lazy var imageViewEx: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        img.backgroundColor = .COLOR_TEXT_TITLE_0f1214_03
        img.isUserInteractionEnabled = true
        img.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(imageTap))
        )
        return img
    }()
}

// MARK: - Bind
extension MallDetailImageCell {

    func bind(vm: MallDetailImageVM) {
        self.vm = vm
        self.taskUrl = vm.url

        // 1️⃣ 已有高度
        if let h = vm.height {
            applyHeight(h)
        }

        // 2️⃣ 已加载过
        if let _ = vm.heroModule {
            imageViewEx.setImgUrl(urlString: vm.url)
            return
        }

        guard vm.isLoading == false else { return }
        vm.isLoading = true

        imageViewEx.setImgUrlWithComplete(urlString: vm.url) { [weak self] in
            guard let self = self,
                  self.taskUrl == vm.url,
                  let image = self.imageViewEx.image else { return }

            let height = image.size.height / image.size.width * SCREEN_WIDHT
            vm.height = height
            vm.isLoading = false

            self.applyHeight(height)

            vm.heroModule = HeroBrowserNetworkImageViewModule(
                thumbailImgUrl: vm.url,
                originImgUrl: vm.url
            )

            self.heightCalculated?(vm)
        }
    }

    private func applyHeight(_ height: CGFloat) {
        imageViewEx.snp.remakeConstraints {
            $0.left.right.top.equalToSuperview()
            $0.height.equalTo(height)
            $0.bottom.equalToSuperview().priority(.low)
        }
    }
}

// MARK: - Action
private extension MallDetailImageCell {

    @objc func imageTap() {
        guard let vm = vm,
              let module = vm.heroModule,
              let vc = UIApplication.topViewController() else { return }

        vc.hero.browserPhoto(
            viewModules: [module],
            initIndex: 0
        ) {
            [.pageControlType(.pageControl),
             .heroView(self.imageViewEx)]
        }
    }
}

// MARK: - UI
private extension MallDetailImageCell {

    func initUI() {
        contentView.addSubview(imageViewEx)
        imageViewEx.snp.makeConstraints {
            $0.left.right.top.equalToSuperview()
            $0.height.equalTo(1) // 占位高度，防止第一次 update 崩
            $0.bottom.equalToSuperview().priority(.low)
        }
    }
}

