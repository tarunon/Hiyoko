//
//  Cell+Rx.swift
//  mstdn
//
//  Created by tarunon on 2017/04/23.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import Base

public extension Reactive where Base: UITableViewCell {
    public var reused: Observable<Void> {
        return base.rx.methodInvoked(#selector(UITableViewCell.prepareForReuse))
            .map { _ in }
    }
}

public extension Reactive where Base: UITableViewHeaderFooterView {
    public var reused: Observable<Void> {
        return base.rx.methodInvoked(#selector(UITableViewHeaderFooterView.prepareForReuse))
            .map { _ in }
    }
}

public class TableViewCellPresenter<E> {
    internal lazy var cell: UITableViewCell = undefined(message: "Should call presenter.present")
    internal weak var tableView: UITableView!
    internal lazy var indexPath: IndexPath = undefined()
    internal lazy var element: E = undefined()
    
    internal init(tableView: UITableView) {
        self.tableView = tableView
    }
    
    public func present<C: UITableViewCell, M: RxViewModel>(dequeue: (_ tableView: UITableView, _ indexPath: IndexPath, _ element: E) -> C, viewModel: @escaping (C) -> M) -> Observable<M.Result> {
        let cell = dequeue(tableView, indexPath, element)
        self.cell = cell
        return viewModel(cell).result
            .takeUntil(cell.rx.reused)
    }
    
    public func present(dequeue: (_ tableView: UITableView, _ indexPath: IndexPath, _ element: E) -> UITableViewCell) -> Disposable {
        self.cell = dequeue(tableView, indexPath, element)
        return Disposables.create()
    }
}

public extension Reactive where Base: UITableView {
    public func reloadItem<O: ObservableConvertibleType, E>(configureDataSource: ((RxTableViewSectionedReloadDataSource<O.E.Iterator.Element>) -> Void)? = nil) -> (_ source: O) -> (_ cellFactory: @escaping (TableViewCellPresenter<E>) -> Disposable) -> Disposable where O.E: Sequence, O.E.Iterator.Element: SectionModelType, E == O.E.Iterator.Element.Item {
        return { [unowned base=base as UITableView] (source) in
            return { (cellFactory) in
                let dataSource = RxTableViewSectionedReloadDataSource<O.E.Iterator.Element>()
                let presenter = TableViewCellPresenter<E>(tableView: base)
                let disposable = CompositeDisposable()
                dataSource.configureCell = { (_, _, indexPath, element) in
                    presenter.indexPath = indexPath
                    presenter.element = element
                    _ = disposable.insert(cellFactory(presenter))
                    return presenter.cell
                }
                configureDataSource?(dataSource)
                _ = disposable.insert(
                    source.asObservable()
                        .map { Array($0) }
                        .bind(to: base.rx.items(dataSource: dataSource))
                )
                return disposable
            }
        }
    }
    
    public func animatedItem<O: ObservableConvertibleType, E>(configureDataSource: ((RxTableViewSectionedAnimatedDataSource<O.E.Iterator.Element>) -> Void)? = nil) -> (_ source: O) -> (_ cellFactory: @escaping (TableViewCellPresenter<E>) -> Disposable) -> Disposable where O.E: Sequence, O.E.Iterator.Element: AnimatableSectionModelType, E == O.E.Iterator.Element.Item {
        return { [unowned base=base as UITableView] (source) in
            return {  (cellFactory) in
                let dataSource = RxTableViewSectionedAnimatedDataSource<O.E.Iterator.Element>()
                let presenter = TableViewCellPresenter<E>(tableView: base)
                let disposable = CompositeDisposable()
                dataSource.configureCell = { (_, _, indexPath, element) in
                    presenter.indexPath = indexPath
                    presenter.element = element
                    _ = disposable.insert(cellFactory(presenter))
                    return presenter.cell
                }
                configureDataSource?(dataSource)
                _ = disposable.insert(
                    source.asObservable()
                        .map { Array($0) }
                        .bind(to: base.rx.items(dataSource: dataSource))
                )
                return disposable
            }
        }
    }
}

public extension Reactive where Base: UICollectionReusableView {
    public var reused: Observable<Void> {
        return base.rx.methodInvoked(#selector(UICollectionReusableView.prepareForReuse))
            .map { _ in }
    }
}

public class CollectionViewCellPresenter<E> {
    internal lazy var cell: UICollectionViewCell = undefined(message: "Should call presenter.present")
    internal weak var collectionView: UICollectionView!
    internal lazy var indexPath: IndexPath = undefined()
    internal lazy var element: E = undefined()
    
    internal init(collectionView: UICollectionView) {
        self.collectionView = collectionView
    }
    
    public func present<C: UICollectionViewCell, M: RxViewModel>(dequeue: (_ collectionView: UICollectionView, _ indexPath: IndexPath, _ element: E) -> C, viewModel: @escaping (C) -> M) -> Observable<M.Result> {
        let cell = dequeue(collectionView, indexPath, element)
        self.cell = cell
        return viewModel(cell).result
            .takeUntil(cell.rx.reused)
    }
    
    public func present(dequeue: (_ collectionView: UICollectionView, _ indexPath: IndexPath, _ element: E) -> UICollectionViewCell) -> Disposable {
        self.cell = dequeue(collectionView, indexPath, element)
        return Disposables.create()
    }
}

public extension Reactive where Base: UICollectionView {
    
    public func reloadItem<O: ObservableConvertibleType, E>(configureDataSource: ((RxCollectionViewSectionedReloadDataSource<O.E.Iterator.Element>) -> Void)? = nil) -> (_ source: O) -> (_ cellFactory: @escaping (CollectionViewCellPresenter<E>) -> Disposable) -> Disposable where O.E: Sequence, O.E.Iterator.Element: SectionModelType, E == O.E.Iterator.Element.Item {
        return { [unowned base=base as UICollectionView] (source) in
            return { (cellFactory) in
                let dataSource = RxCollectionViewSectionedReloadDataSource<O.E.Iterator.Element>()
                let presenter = CollectionViewCellPresenter<E>(collectionView: base)
                let disposable = CompositeDisposable()
                dataSource.configureCell = { (_, _, indexPath, element) in
                    presenter.indexPath = indexPath
                    presenter.element = element
                    _ = disposable.insert(cellFactory(presenter))
                    return presenter.cell
                }
                configureDataSource?(dataSource)
                _ = disposable.insert(
                    source.asObservable()
                        .map { Array($0) }
                        .bind(to: base.rx.items(dataSource: dataSource))
                )
                return disposable
            }
        }
    }
    
    public func animatedItem<O: ObservableConvertibleType, E>(configureDataSource: ((RxCollectionViewSectionedAnimatedDataSource<O.E.Iterator.Element>) -> Void)? = nil) -> (_ source: O) -> (_ cellFactory: @escaping (CollectionViewCellPresenter<E>) -> Disposable) -> Disposable where O.E: Sequence, O.E.Iterator.Element: AnimatableSectionModelType, E == O.E.Iterator.Element.Item {
        return { [unowned base=base as UICollectionView] (source) in
            return { (cellFactory) in
                let dataSource = RxCollectionViewSectionedAnimatedDataSource<O.E.Iterator.Element>()
                let presenter = CollectionViewCellPresenter<E>(collectionView: base)
                let disposable = CompositeDisposable()
                dataSource.configureCell = { (_, _, indexPath, element) in
                    presenter.indexPath = indexPath
                    presenter.element = element
                    _ = disposable.insert(cellFactory(presenter))
                    return presenter.cell
                }
                configureDataSource?(dataSource)
                _ = disposable.insert(
                    source.asObservable()
                        .map { Array($0) }
                        .bind(to: base.rx.items(dataSource: dataSource))
                )
                return disposable
            }
        }
    }
}
