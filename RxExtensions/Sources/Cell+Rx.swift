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

public class TableViewCellPresenter {
    internal lazy var cell: UITableViewCell = undefined(message: "Should call presenter.present")
    internal weak var tableView: UITableView!
    internal lazy var indexPath: IndexPath = undefined()
    
    internal init(tableView: UITableView) {
        self.tableView = tableView
    }
    
    public func present<C: UITableViewCell, M: RxViewModel>(dequeue: (_ tableView: UITableView, _ indexPath: IndexPath) -> C, viewModel: M, presenter: @escaping (C) -> M.Presenter) -> Observable<M.Result> {
        let cell = dequeue(tableView, indexPath)
        self.cell = cell
        return Observable
            .create { (observer) -> Disposable in
                do {
                    return try viewModel.emit(presenter: presenter(cell))
                        .takeUntil(cell.rx.reused)
                        .concat(Observable.never())
                        .takeUntil(cell.rx.deallocated)
                        .bind(to: observer)
                } catch {
                    observer.onError(error)
                    return Disposables.create()
                }
            }
    }
}

public extension Reactive where Base: UITableView {
    public func reloadItem<O: ObservableConvertibleType, E, R>(configureDataSource: ((RxTableViewSectionedReloadDataSource<O.E.Iterator.Element>) -> Void)? = nil) -> (_ source: O) -> (_ cellFactory: @escaping (TableViewCellPresenter, E) -> R) -> Observable<(element: E, result: R)> where O.E: Sequence, O.E.Iterator.Element: SectionModelType, E == O.E.Iterator.Element.Item {
        return { [unowned base=base as UITableView] (source) in
            return { (cellFactory) in
                return Observable<(element: E, result: R)>.create { (observer) in
                    let dataSource = RxTableViewSectionedReloadDataSource<O.E.Iterator.Element>()
                    let presenter = TableViewCellPresenter(tableView: base)
                    dataSource.configureCell = { (_, _, indexPath, element) in
                        presenter.indexPath = indexPath
                        observer.onNext((element, cellFactory(presenter, element)))
                        return presenter.cell
                    }
                    configureDataSource?(dataSource)
                    let d1 = source.asObservable()
                        .map { Array($0) }
                        .bind(to: base.rx.items(dataSource: dataSource))
                    let d2 = source.asObservable()
                        .flatMap { _ in Observable.empty() }
                        .bind(to: observer)
                    return Disposables.create(d1, d2)
                }
            }
        }
    }
    
    public func animatedItem<O: ObservableConvertibleType, E, R>(configureDataSource: ((RxTableViewSectionedAnimatedDataSource<O.E.Iterator.Element>) -> Void)? = nil) -> (_ source: O) -> (_ cellFactory: @escaping (TableViewCellPresenter, E) -> R) -> Observable<(element: E, result: R)> where O.E: Sequence, O.E.Iterator.Element: AnimatableSectionModelType, E == O.E.Iterator.Element.Item {
        return { [unowned base=base as UITableView] (source) in
            return {  (cellFactory) in
                return Observable<(element: E, result: R)>.create { (observer) in
                    let dataSource = RxTableViewSectionedAnimatedDataSource<O.E.Iterator.Element>()
                    let presenter = TableViewCellPresenter(tableView: base)
                    dataSource.configureCell = { (_, _, indexPath, element) in
                        presenter.indexPath = indexPath
                        observer.onNext((element, cellFactory(presenter, element)))
                        return presenter.cell
                    }
                    configureDataSource?(dataSource)
                    let d1 = source.asObservable()
                        .map { Array($0) }
                        .bind(to: base.rx.items(dataSource: dataSource))
                    let d2 = source.asObservable()
                        .flatMap { _ in Observable.empty() }
                        .bind(to: observer)
                    return Disposables.create(d1, d2)
                }
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

public class CollectionViewCellPresenter {
    internal lazy var cell: UICollectionViewCell = undefined(message: "Should call presenter.present")
    internal weak var collectionView: UICollectionView!
    internal lazy var indexPath: IndexPath = undefined()

    internal init(collectionView: UICollectionView) {
        self.collectionView = collectionView
    }
    
    public func present<C: UICollectionViewCell, M: RxViewModel>(dequeue: (_ collectionView: UICollectionView, _ indexPath: IndexPath) -> C, viewModel: M, presenter: @escaping (C) -> M.Presenter) -> Observable<M.Result> {
        let cell = dequeue(collectionView, indexPath)
        self.cell = cell
        return Observable
            .create { (observer) -> Disposable in
                do {
                    return try viewModel.emit(presenter: presenter(cell))
                        .takeUntil(cell.rx.reused)
                        .concat(Observable.never())
                        .takeUntil(cell.rx.deallocated)
                        .bind(to: observer)
                } catch {
                    observer.onError(error)
                    return Disposables.create()
                }
        }
    }
}

public extension Reactive where Base: UICollectionView {
    
    public func reloadItem<O: ObservableConvertibleType, E, R>(configureDataSource: ((RxCollectionViewSectionedReloadDataSource<O.E.Iterator.Element>) -> Void)? = nil) -> (_ source: O) -> (_ cellFactory: @escaping (CollectionViewCellPresenter, E) -> R) -> Observable<(element: E, result: R)> where O.E: Sequence, O.E.Iterator.Element: SectionModelType, E == O.E.Iterator.Element.Item {
        return { [unowned base=base as UICollectionView] (source) in
            return { (cellFactory) in
                return Observable<(element: E, result: R)>.create { (observer) in
                    let dataSource = RxCollectionViewSectionedReloadDataSource<O.E.Iterator.Element>()
                    let presenter = CollectionViewCellPresenter(collectionView: base)
                    dataSource.configureCell = { (_, _, indexPath, element) in
                        presenter.indexPath = indexPath
                        observer.onNext((element, cellFactory(presenter, element)))
                        return presenter.cell
                    }
                    configureDataSource?(dataSource)
                    let d1 = source.asObservable()
                        .map { Array($0) }
                        .bind(to: base.rx.items(dataSource: dataSource))
                    let d2 = source.asObservable()
                        .flatMap { _ in Observable.empty() }
                        .bind(to: observer)
                    return Disposables.create(d1, d2)
                }
            }
        }
    }
    
    public func animatedItem<O: ObservableConvertibleType, E, R>(configureDataSource: ((RxCollectionViewSectionedAnimatedDataSource<O.E.Iterator.Element>) -> Void)? = nil) -> (_ source: O) -> (_ cellFactory: @escaping (CollectionViewCellPresenter, E) -> R) -> Observable<(element: E, result: R)> where O.E: Sequence, O.E.Iterator.Element: AnimatableSectionModelType, E == O.E.Iterator.Element.Item {
        return { [unowned base=base as UICollectionView] (source) in
            return { (cellFactory) in
                return Observable<(element: E, result: R)>.create { (observer) in
                    let dataSource = RxCollectionViewSectionedAnimatedDataSource<O.E.Iterator.Element>()
                    let presenter = CollectionViewCellPresenter(collectionView: base)
                    dataSource.configureCell = { (_, _, indexPath, element) in
                        presenter.indexPath = indexPath
                        observer.onNext((element, cellFactory(presenter, element)))
                        return presenter.cell
                    }
                    configureDataSource?(dataSource)
                    let d1 = source.asObservable()
                        .map { Array($0) }
                        .bind(to: base.rx.items(dataSource: dataSource))
                    let d2 = source.asObservable()
                        .flatMap { _ in Observable.empty() }
                        .bind(to: observer)
                    return Disposables.create(d1, d2)
                }
            }
        }
    }
}
