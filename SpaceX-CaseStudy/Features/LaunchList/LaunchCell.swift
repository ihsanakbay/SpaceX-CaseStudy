//
//  LaunchCell.swift
//  SpaceX-CaseStudy
//
//  Created by İhsan Akbay on 13.04.2025.
//

import UIKit

class LaunchCell: UITableViewCell {
    // MARK: - UI Components

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.systemGray5.cgColor
        return view
    }()
    
    private let labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        return stackView
    }()
        
    private let rocketImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .black
        imageView.layer.cornerRadius = 22
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .systemGray3
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
                
        contentView.addSubview(containerView)
        labelStackView.addArrangedSubview(nameLabel)
        labelStackView.addArrangedSubview(dateLabel)
                
        containerView.addSubview(rocketImageView)
        containerView.addSubview(labelStackView)
        containerView.addSubview(chevronImageView)
                
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
                
        rocketImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
//            make.centerY.equalToSuperview()
            make.centerY.equalTo(labelStackView)
            make.size.equalTo(44)
        }
                
        labelStackView.snp.makeConstraints { make in
            make.leading.equalTo(rocketImageView.snp.trailing).offset(20)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(chevronImageView.snp.leading).offset(-12)
        }
                
        chevronImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
    }
    
    func configure(with launch: Launch, dateFormatter: (Int?) -> String) {
        nameLabel.text = launch.name ?? "-"
        dateLabel.text = dateFormatter(launch.dateUnix)
        if let originalImage = UIImage(named: "rocket") {
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 24, height: 24))
            let resizedImage = renderer.image { _ in
                originalImage.draw(in: CGRect(x: 0, y: 0, width: 24, height: 24))
            }
            rocketImageView.image = resizedImage
        }
        rocketImageView.tintColor = .white
        rocketImageView.contentMode = .center
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        rocketImageView.image = nil
        nameLabel.text = nil
        dateLabel.text = nil
    }
}
