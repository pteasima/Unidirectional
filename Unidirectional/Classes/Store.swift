public protocol Observer: class {
  associatedtype State

  func update(state: State)
}
class AnyObserver<State> {
  weak var observer: AnyObject? {
    willSet {
      assert(newValue == nil)
      assert(observer != nil)
      onDeinit()
    }
  }
  let update: (State) -> ()
  let onDeinit: () -> ()
  init<O: Observer>(_ o: O, _ onDeinit: @escaping () -> ()) where O.State == State {
    update = o.update
    self.observer = o
    self.onDeinit = onDeinit
  }
}

public class Store<State, Action>{
  public var state: State
  public init<E: Effect>(effect _: E.Type, initialState: State, reduce: @escaping Reduce<State, E>) where E.Action == Action {
    state = initialState
    _dispatch = { [weak self] action in
      guard let `self` = self else { return }
      let effect: E = reduce(&self.state, action)
      effect.run(self.dispatch)
      if !self.queue.isEmpty {
        self._dispatch(self.queue.removeFirst())
      } else {
        self.observers.forEach { $0.update(self.state) }
      }
    }
  }

  private var queue: [Action] = []
  private var _dispatch: ((Action) -> ())!
  public func dispatch(_ action: Action) {
    if queue.isEmpty {
      _dispatch(action)
    } else {
      queue.append(action)
    }
  }

  private var observers: [AnyObserver<State>] = []
  public func addObserver<O: Observer>(_ o: O) where O.State == State {
    observers.append(AnyObserver(o) { [weak self, unowned o] in
      self?.removeObserver(o)
    })
  }
  public func removeObserver<O: Observer>(_ o: O) where O.State == State {
    observers.removeFirst { $0.observer === o }
  }
}

private extension Array {
  @discardableResult
  mutating func removeFirst(where predicate: (Element) throws -> Bool) rethrows -> Element? {
    guard let idx = try firstIndex(where: predicate) else { return nil }
    return remove(at: idx)
  }
}
