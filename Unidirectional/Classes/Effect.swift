//
//  Effect.swift
//  MVCFramework
//
//  Created by Petr Šíma on 16/06/2018.
//  Copyright © 2018 Petr Šíma. All rights reserved.
//

import Foundation

public protocol Effect {
  associatedtype Action

  typealias Run<Action> = (Dispatch<Action>) -> ()
  var run: Run<Action> { get }
  init(run: @escaping Run<Action>)

  static var empty: Self { get }
  static func batch(_ effects: [Self]) -> Self
}

public extension Effect {
  static var empty: Self { return .init { _ in } }
  static func batch(_ effects: [Self]) -> Self {
    return .init { dispatch in
      effects.forEach {
        $0.run(dispatch)
      }
    }
  }
}

public struct RunEffect<Action>: Effect {
  public let run: Run<Action>
  public init(run: @escaping Run<Action>) {
    self.run = run
  }
}
