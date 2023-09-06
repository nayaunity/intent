//
//  ControllableScrollView.swift
//  Intent
//
//  Created by Nyaradzo Bere on 9/5/23.
//

import Foundation
import SwiftUI

struct ControllableScrollView<Content: View>: UIViewRepresentable {
    let content: Content
    @Binding var startFromTop: Bool

    init(startFromTop: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.content = content()
        self._startFromTop = startFromTop
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = context.coordinator
        let hostView = UIHostingController(rootView: content)
        hostView.view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(hostView.view)

        NSLayoutConstraint.activate([
            hostView.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostView.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostView.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostView.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hostView.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        return scrollView
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        if startFromTop {
            scrollView.setContentOffset(.zero, animated: false)
            DispatchQueue.main.async {
                self.startFromTop = false
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: ControllableScrollView

        init(_ parent: ControllableScrollView) {
            self.parent = parent
        }
    }
}
