//
//  WHAlbumPickerCollectionCell.swift
//  lns
//
//  Created by Elavatine on 2024/12/5.
//

class WHAlbumPickerCollectionCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        
        return img
    }()
}

extension WHAlbumPickerCollectionCell{
    func initUI() {
        contentView.addSubview(imgView)
        
        setConstrait()
    }
    func setConstrait() {
        imgView.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
    }
}
