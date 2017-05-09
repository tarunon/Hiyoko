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

public class TableViewCellQueue {
    internal lazy var cell: UITableViewCell = undefined(message: "Should call presenter.present")
    internal weak var tableView: UITableView!
    internal lazy var indexPath: IndexPath = undefined()
    
    internal init(tableView: UITableView) {
        self.tableView = tableView
    }

    public func dequeue<C: UITableViewCell, V: View, R: Reactor>(dequeue: (_ tableView: UITableView, _ indexPath: IndexPath) -> C, view: @escaping (C) -> V, reactor: R) -> Observable<R.Result> where V.Action == R.Action, V.State == R.State {
        let cell = dequeue(tableView, indexPath)
        self.cell = cell
        return Observable
            .create { (observer) -> Disposable in
                do {
                    return try bind(view(cell), reactor)
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

    public func dequeue<V: View, R: Reactor>(dequeue: (_ tableView: UITableView, _ indexPath: IndexPath) -> V, reactor: R) -> Observable<R.Result> where V: UITableViewCell, V.Action == R.Action, V.State == R.State {
        return self.dequeue(dequeue: dequeue, view: { $0 }, reactor: reactor)
    }
}

public extension Reactive where Base: UITableView {
    public func reloadItem<O: ObservableConvertibleType, E, R: ObservableConvertibleType>(configureDataSource: ((RxTableViewSectionedReloadDataSource<O.E.Iterator.Element>) -> Void)? = nil) -> (_ source: O) -> (_ cellFactory: @escaping (TableViewCellQueue, E) -> R) -> Observable<R.E> where O.E: Sequence, O.E.Iterator.Element: SectionModelType, E == O.E.Iterator.Element.Item {
        return { [unowned base=base as UITableView] (source) in
            return { (cellFactory) in
                return Observable<R>
                    .create { (observer) in
                        let dataSource = RxTableViewSectionedReloadDataSource<O.E.Iterator.Element>()
                        let queue = TableViewCellQueue(tableView: base)
                        dataSource.configureCell = { (_, _, indexPath, element) in
                            queue.indexPath = indexPath
                            observer.onNext(cellFactory(queue, element))
                            return queue.cell
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
                    .flatMap { $0 }
            }
        }
    }
    
    public func animatedItem<O: ObservableConvertibleType, E, R: ObservableConvertibleType>(configureDataSource: ((RxTableViewSectionedAnimatedDataSource<O.E.Iterator.Element>) -> Void)? = nil) -> (_ source: O) -> (_ cellFactory: @escaping (TableViewCellQueue, E) -> R) -> Observable<R.E> where O.E: Sequence, O.E.Iterator.Element: AnimatableSectionModelType, E == O.E.Iterator.Element.Item {
        return { [unowned base=base as UITableView] (source) in
            return {  (cellFactory) in
                return Observable<R>
                    .create { (observer) in
                        let dataSource = RxTableViewSectionedAnimatedDataSource<O.E.Iterator.Element>()
                        let queue = TableViewCellQueue(tableView: base)
                        dataSource.configureCell = { (_, _, indexPath, element) in
                            queue.indexPath = indexPath
                            observer.onNext(cellFactory(queue, element))
                            return queue.cell
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
                    .flatMap { $0 }
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

public class CollectionViewCellQueue {
    internal lazy var cell: UICollectionViewCell = undefined(message: "Should call presenter.present")
    internal weak var collectionView: UICollectionView!
    internal lazy var indexPath: IndexPath = undefined()

    internal init(collectionView: UICollectionView) {
        self.collectionView = collectionView
    }
    
    public func dequeue<C: UICollectionViewCell, V: View, R: Reactor>(dequeue: (_ collectionView: UICollectionView, _ indexPath: IndexPath) -> C, view: @escaping (C) -> V, reactor: R) -> Observable<R.Result> where V.Action == R.Action, V.State == R.State {
        let cell = dequeue(collectionView, indexPath)
        self.cell = cell
        return Observable
            .create { (observer) -> Disposable in
                do {
                    return try bind(view(cell), reactor)
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

    public func dequeue<V: View, R: Reactor>(dequeue: (_ collectionView: UICollectionView, _ indexPath: IndexPath) -> V, reactor: R) -> Observable<R.Result> where V: UICollectionViewCell, V.Action == R.Action, V.State == R.State {
        return self.dequeue(dequeue: dequeue, view: { $0 } , reactor: reactor)
    }
}

public extension Reactive where Base: UICollectionView {
    
    public func reloadItem<O: ObservableConvertibleType, E, R: ObservableConvertibleType>(configureDataSource: ((RxCollectionViewSectionedReloadDataSource<O.E.Iterator.Element>) -> Void)? = nil) -> (_ source: O) -> (_ cellFactory: @escaping (CollectionViewCellQueue, E) -> R) -> Observable<R.E> where O.E: Sequence, O.E.Iterator.Element: SectionModelType, E == O.E.Iterator.Element.Item {
        return { [unowned base=base as UICollectionView] (source) in
            return { (cellFactory) in
                return Observable<R>
                    .create { (observer) in
                        let dataSource = RxCollectionViewSectionedReloadDataSource<O.E.Iterator.Element>()
                        let queue = CollectionViewCellQueue(collectionView: base)
                        let d1 = CompositeDisposable()
                        dataSource.configureCell = { (_, _, indexPath, element) in
                            queue.indexPath = indexPath
                            observer.onNext(cellFactory(queue, element))
                            return queue.cell
                        }
                        configureDataSource?(dataSource)
                        let d2 = source.asObservable()
                            .map { Array($0) }
                            .bind(to: base.rx.items(dataSource: dataSource))
                        let d3 = source.asObservable()
                            .flatMap { _ in Observable.empty() }
                            .bind(to: observer)
                        return Disposables.create(d1, d2, d3)
                    }
                    .flatMap { $0 }
            }
        }
    }
    
    public func animatedItem<O: ObservableConvertibleType, E, R: ObservableConvertibleType>(configureDataSource: ((RxCollectionViewSectionedAnimatedDataSource<O.E.Iterator.Element>) -> Void)? = nil) -> (_ source: O) -> (_ cellFactory: @escaping (CollectionViewCellQueue, E) -> R) -> Observable<R.E> where O.E: Sequence, O.E.Iterator.Element: AnimatableSectionModelType, E == O.E.Iterator.Element.Item {
        return { [unowned base=base as UICollectionView] (source) in
            return { (cellFactory) in
                return Observable<R>
                    .create { (observer) in
                        let dataSource = RxCollectionViewSectionedAnimatedDataSource<O.E.Iterator.Element>()
                        let queue = CollectionViewCellQueue(collectionView: base)
                        let d1 = CompositeDisposable()
                        dataSource.configureCell = { (_, _, indexPath, element) in
                            queue.indexPath = indexPath
                            observer.onNext(cellFactory(queue, element))
                            return queue.cell
                        }
                        configureDataSource?(dataSource)
                        let d2 = source.asObservable()
                            .map { Array($0) }
                            .bind(to: base.rx.items(dataSource: dataSource))
                        let d3 = source.asObservable()
                            .flatMap { _ in Observable.empty() }
                            .bind(to: observer)
                        return Disposables.create(d1, d2, d3)
                    }
                    .flatMap { $0 }
            }
        }
    }
}
