import Foundation

public typealias Dispatch<Action> = (Action) -> ()
public typealias Reduce<State, Effect: Effect> = (inout State, Effect.Action) -> Effect
