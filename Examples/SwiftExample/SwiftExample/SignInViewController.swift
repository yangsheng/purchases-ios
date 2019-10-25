//
//  SignInController.swift
//  SwiftExample
//
//  Created by César de la Vega  on 10/24/19.
//  Copyright © 2019 RevenueCat. All rights reserved.
//

import UIKit
import AuthenticationServices
import Purchases

@available(iOS 13.0, *)
class SignInViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    var signInButton : ASAuthorizationAppleIDButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInButton = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .black)
        signInButton.addTarget(self, action: #selector(appleIDButtonTapped), for: .touchUpInside)
        view.addSubview(signInButton)
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            signInButton.heightAnchor.constraint(equalToConstant: 60),
            signInButton.widthAnchor.constraint(equalToConstant: 150),
            signInButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        print(signInButton.frame)
    }
    
    @objc func appleIDButtonTapped() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {

        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userID = credential.user
            UserDefaults.standard.set(userID, forKey: "signedInUserID")
            Purchases.shared.identify(userID) { (info, error) in
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
