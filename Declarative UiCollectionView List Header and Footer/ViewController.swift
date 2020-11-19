//
//  ViewController.swift
//  Declarative UiCollectionView List Header and Footer
//
//  Created by Yurii Sameliuk on 19/11/2020.
//

import UIKit

// lesson: https://swiftsenpai.com/development/declarative-list-header-footer/

struct SFSymbolItem: Hashable {
    let name: String
    let image: UIImage
    
    init(name: String) {
        self.name = name
        self.image = UIImage(systemName: name)!
    }
}

struct HeaderItem: Hashable {
    let title: String
    let symbols: [SFSymbolItem]
}

class ViewController: UIViewController {
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<HeaderItem, SFSymbolItem>!
    override func viewDidLoad() {
        super.viewDidLoad()
        configLayout()
        HeaderConfig()
    }
    
    let modelObjects = [
        HeaderItem(title: "Devices", symbols: [SFSymbolItem(name: "iphone.homebutton"), SFSymbolItem(name: "pc"), SFSymbolItem(name: "headphones")]),
        HeaderItem(title: "Weather", symbols: [SFSymbolItem(name: "sun.min"), SFSymbolItem(name: "sunset.fill")]),
        HeaderItem(title: "Nature", symbols: [SFSymbolItem(name: "drop.fill"), SFSymbolItem(name: "flame"), SFSymbolItem(name: "bolt.circle.fill"), SFSymbolItem(name: "tortoise.fill")])
    ]
    
//MARK: - Create list layout
    private func configLayout() {
    var layoutConfig = UICollectionLayoutListConfiguration(appearance: UICollectionLayoutListConfiguration.Appearance.insetGrouped)
        
        //1 В представлении коллекции должен быть установлен режим верхнего и нижнего колонтитула .supplementary, чтобы активировать дополнительный поставщик представления источника данных
        layoutConfig.headerMode = .supplementary
        layoutConfig.footerMode = .supplementary
        let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        
        //MARK: - Configure collectionView
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: listLayout)
        //collectionView.backgroundColor = .blue
        view.addSubview(collectionView)
        
        //MARK: - make collection view take up the entire view
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        )
        
        //MARK: - cell registration
        // 2 Использовать SFSymbolItem как тип идентификатора элемента при регистрации ячейки
        let symbolCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SFSymbolItem> {
            (cell, indexPath, symbolItem) in
            // configure cell content
            var configuration = cell.defaultContentConfiguration()
            configuration.image = symbolItem.image
            configuration.text = symbolItem.name
            cell.contentConfiguration = configuration
        }
        
        //MARK: - Initialize data source
        // 3 Использовать SFSymbolItem как тип идентификатора элемента при инициализации источника данных для различий
       dataSource = UICollectionViewDiffableDataSource<HeaderItem, SFSymbolItem>(collectionView: collectionView) { (collectionView, indexPath, symbolItem) -> UICollectionViewCell? in
            
        // 4 В нашем примере приложения есть только 1 тип ячейки, поэтому в рамках закрытия поставщика ячеек источника данных нам нужно исключить из очереди только 1 тип ячейки
        // Dequeue symbol cell
        let cell = collectionView.dequeueConfiguredReusableCell(using: symbolCellRegistration, for: indexPath, item: symbolItem)
        
        return cell
        }
    }
    
    private func HeaderConfig() {
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { [unowned self] (headerView, elementKind, indexPath) in
            // Obtain header item using index path
            let headerItem = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            //configure header view content based on headerItem
            var configuration = headerView.defaultContentConfiguration()
            configuration.text = headerItem.title
            
            // customize header apperance to make it more to eye-catching
            configuration.textProperties.font = .boldSystemFont(ofSize: 16)
            configuration.textProperties.color = .systemBlue
            configuration.directionalLayoutMargins = .init(top: 20.0, leading: 0.0, bottom: 10.0, trailing: 0.0)
            
            // Apply the configuration to header view
            headerView.contentConfiguration = configuration
            
        }
        
        let footerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionFooter) {
            [unowned self] (footerView, elementKind, indexPaht) in
            let footerItem = self.dataSource.snapshot().sectionIdentifiers[indexPaht.section]
            let symbolCount = footerItem.symbols.count
            
            //Configure footer view content
            var configuration = footerView.defaultContentConfiguration()
            configuration.text = "Symbol count: \(symbolCount)"
            footerView.contentConfiguration = configuration
        }
        dataSource.supplementaryViewProvider = { [unowned self] (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
            
            if elementKind == UICollectionView.elementKindSectionHeader {
                //Dequeue header view
                return self.collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
            } else {
                
                // dequeue footer view
                return self.collectionView.dequeueConfiguredReusableSupplementary(using: footerRegistration, for: indexPath)
            }
        }
        var dataSourceSnapshot = NSDiffableDataSourceSnapshot<HeaderItem, SFSymbolItem>()
        // create collection view section based on number of Header in modelObjects
        dataSourceSnapshot.appendSections(modelObjects)
        
        // loop through each header item to append symbol to their respective section
        for headerItem in modelObjects {
            dataSourceSnapshot.appendItems(headerItem.symbols, toSection: headerItem)
        }
        dataSource.apply(dataSourceSnapshot)
    }
}

