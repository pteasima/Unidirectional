//
//  ViewController.swift
//  Unidirectional
//
//  Created by pteasima on 08/05/2018.
//  Copyright (c) 2018 pteasima. All rights reserved.
//

import UIKit
import Unidirectional

class ViewController: UIViewController, Observer {
  typealias State = App.State

  func update(state: State) {
    incrementButton.setTitle(String(describing: state.value), for: .normal)
  }

  @IBOutlet weak var incrementButton: UIButton!
  override func viewDidLoad() {
    super.viewDidLoad()

    update(state: store.state)
    store.addObserver(self)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func incrementTapped() {
    store.dispatch(.increment)
  }
}

