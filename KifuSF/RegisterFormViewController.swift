//
//  KFCRegisterForm.swift
//  KifuSF
//
//  Created by Alexandru Turcanu on 07/10/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import UIKit
import PureLayout
import FirebaseAuth
import FirebaseStorage

class RegisterFormViewController: UIScrollableViewController {
    
    private enum UserProfileSource {
        case fromUrl(URL)
        case fromPhotoLibrary(UIImage)
    }
    
    //MARK: - Variables
    var signInProvderInfo: UserService.SignInProviderInfo?

    private let upperStackView = UIStackView(axis: .vertical, alignment: .fill, spacing: KFPadding.ContentView, distribution: .fill)
    private let inputStackView = UIStackView(axis: .vertical, alignment: .fill, spacing: KFPadding.StackView, distribution: .fill)

    private let profileImageInputView = UIGroupView<UIImageView>(title: "Profile Image",
                                                                      contentView: UIImageView(image: .kfPlusImage))

    private let fullNameInputView: UIGroupView<UITextFieldContainer> = {
        let container = UITextFieldContainer(textContentType: .name,
                                             returnKeyType: .next,
                                             placeholder: "Kifu SF")
        container.textField.autocorrectionType = .no
        container.textField.autocapitalizationType = .words
        
        return UIGroupView<UITextFieldContainer>(title: "Full Name",
                                                 contentView: container)
    }()

    private let usernameInputView: UIGroupView<UITextFieldContainer> = {
        let container = UITextFieldContainer(textContentType: .nickname,
                                             returnKeyType: .next,
                                             placeholder: "@Pondorasti")
        container.textField.autocorrectionType = .no
        container.textField.autocapitalizationType = .none
        
        return UIGroupView<UITextFieldContainer>(title: "Username",
                                                 contentView: container)
    }()
    
    private let phoneNumberInputView: UIGroupView<UITextFieldContainer> = {
        let container = UITextFieldContainer(textContentType: .telephoneNumber,
                                             returnKeyType: .next,
                                             keyboardType: .phonePad,
                                             placeholder: "+12345678")
        container.textField.autocorrectionType = .no
        container.textField.autocapitalizationType = .none
        
        return UIGroupView<UITextFieldContainer>(title: "Phone Number",
                                                 contentView: container)
    }()
    
    private let phoneNumberDisclaimerLabel: UILabel = {
        let label = UILabel(font: UIFont.preferredFont(forTextStyle: .footnote),
                            textColor: UIColor.Text.Body)
        
        return label
    }()
    
    private let emailInputView: UIGroupView<UITextFieldContainer> = {
        let container = UITextFieldContainer(textContentType: .emailAddress,
                                             returnKeyType: .next,
                                             keyboardType: .emailAddress,
                                             placeholder: "example@kifu.com")
        container.textField.autocorrectionType = .no
        container.textField.autocapitalizationType = .none
        
        return UIGroupView<UITextFieldContainer>(title: "Email",
                                                 contentView: container)
    }()
    
    private let passwordInputView: UIGroupView<UITextFieldContainer> = {
        let container = UITextFieldContainer(textContentType: .password,
                                             returnKeyType: .done,
                                             isSecureTextEntry: true,
                                             placeholder: "Password")
        container.textField.autocorrectionType = .no
        container.textField.autocapitalizationType = .none
        
        return UIGroupView<UITextFieldContainer>(title: "Password",
                                                 contentView: container)
    }()
    
    private let disclaimerLabel = UILabel(font: UIFont.preferredFont(forTextStyle: .footnote),
                                          textColor: UIColor.Text.Body)
    private let errorLabel = UILabel(font: UIFont.preferredFont(forTextStyle: .footnote),
                                     textColor: UIColor.Pallete.Red)
    
    private let continueButton = UIAnimatedButton(backgroundColor: UIColor.Pallete.Green,
                                                  andTitle: "Sign up")

    private let profileImageHelper = PhotoHelper()
    private var userSelectedAProfileImage: UserProfileSource? = nil

    //MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillShow(_:)),
                                               name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                               name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureData()
        configureStyling()
        configureLayout()
        configureDelegates()
        configureGestures()
        
        profileImageHelper.completionHandler = { [unowned self] (image) in
            self.profileImageInputView.contentView.image = image
            self.userSelectedAProfileImage = .fromPhotoLibrary(image)
        }
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardHeight = notification.getKeyboardHeight() else {
            return assertionFailure("Could not retrieve keyboard height")
        }

        contentScrollView.updateBottomPadding(keyboardHeight + 20)
    }

    //TODO: this method gets called twice find out why
    @objc func keyboardWillHide(_ notification: Notification) {
        contentScrollView.updateBottomPadding(KFPadding.StackView)
    }

    //MARK: - Functions
    @objc func continueButtonTapped() {
        //unwrap all values and make sure the string is not empty
        guard let userProfileSource = userSelectedAProfileImage,
            let image = profileImageInputView.contentView.image,
            let fullName = fullNameInputView.contentView.textField.text, !fullName.isEmpty,
            let username = usernameInputView.contentView.textField.text, !username.isEmpty,
            let phoneNumber = phoneNumberInputView.contentView.textField.text, !phoneNumber.isEmpty,
            let email = emailInputView.contentView.textField.text, !email.isEmpty else{
                return showErrorMessage("Please complete all the fields")
        }

        let normalizedPhoneNumber = phoneNumber.deleteOccurrences(of: ["(", ")", " "])
        //TODO: check for unique username
        if let signInProvider = signInProvderInfo {
            let loadingVC = KFCLoading(style: .whiteLarge)
            let continueRegisterHandler: (URL) -> Void = { url in
                UserService.completeSigninProviderLogin(
                withUid: signInProvider.uid ,
                username: username,
                imageLink: url,
                contactNumber: normalizedPhoneNumber) { (user) in
                    loadingVC.dismiss {
                        guard let user = user else {
                            fatalError("User not returned back after trying to completeSigninProviderLogin")
                        }
                        
                        // persist the user only in this current session and not in User Defaults
                        User.setCurrent(user)
                        
                        OnBoardingDistributer.presentNextStepIfNeeded(from: self)
                    }
                }
            }
            loadingVC.present()
            switch userProfileSource {
            case .fromPhotoLibrary(let image):
                let imageRef = StorageReference.newUserImageRefence(with: signInProvider.uid)
                
                StorageService.uploadImage(image, at: imageRef) { (url) in
                    guard let url = url else {
                        return self.showErrorMessage("Something went wrong. Please try again.")
                    }
                    
                    continueRegisterHandler(url)
                }
            case .fromUrl(let url):
                continueRegisterHandler(url)
            }
        } else {
            guard let password = passwordInputView.contentView.textField.text, !password.isEmpty else {
                return showErrorMessage("Please complete all the fields")
            }
            
            let loadingVC = KFCLoading(style: .whiteLarge)
            loadingVC.present()
            UserService.register(
                with: fullName,
                username: username,
                image: image,
                contactNumber: normalizedPhoneNumber,
                email: email,
                password: password) { [unowned self] (user, error) in
                    loadingVC.dismiss {
                        guard let user = user else {
                            
                            //check if we have an error when the user is nil
                            guard let error = error else {
                                fatalError(KFErrorMessage.seriousBug)
                            }
                            
                            let errorMessage = UserService.retrieveAuthErrorMessage(for: error)
                            return self.showErrorMessage(errorMessage)
                        }
                        
                        // persist the user only in this current session and not in User Defaults
                        User.setCurrent(user)
                        
                        OnBoardingDistributer.presentNextStepIfNeeded(from: self)
                    }
            }
        }
    }
    
    private func showErrorMessage(_ errorMessage: String) {
        errorLabel.isHidden = false
        errorLabel.text = errorMessage

        UIView.animate(withDuration: UIView.microInteractionDuration, animations: { [unowned self] in
            self.view.layoutIfNeeded()
        })
        
        continueButton.resetState()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

//MARK: - UITextFieldDelegate
extension RegisterFormViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTextFieldTag = textField.tag + 1
        
        switch nextTextFieldTag {
        case 1:
            usernameInputView.contentView.textField.becomeFirstResponder()
        case 2:
            phoneNumberInputView.contentView.textField.becomeFirstResponder()
        case 3:
            emailInputView.contentView.textField.becomeFirstResponder()
        case 4:
            passwordInputView.contentView.textField.becomeFirstResponder()
        case 5:
            continueButtonTapped()
            fallthrough
        default:
            textField.resignFirstResponder()
        }
        
        return true
    }
}

//MARK: - UIGroupViewDelegate
extension RegisterFormViewController: UIGroupViewDelegate {
    func didSelectContentView() {
        profileImageHelper.presentActionSheet(from: self)
    }
}

//MARK: - UIConfigurable
extension RegisterFormViewController: UIConfigurable {
    func configureDelegates() {
        profileImageInputView.delegate = self
        fullNameInputView.contentView.textField.delegate = self
        usernameInputView.contentView.textField.delegate = self
        phoneNumberInputView.contentView.textField.delegate = self
        emailInputView.contentView.textField.delegate = self
        passwordInputView.contentView.textField.delegate = self

        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    }
    
    func configureStyling() {
        view.backgroundColor = UIColor.Pallete.White
        contentScrollView.updateBottomPadding(KFPadding.StackView)

        profileImageInputView.contentView.makeItKifuStyle()
        profileImageInputView.contentView.isUserInteractionEnabled = true
        
        errorLabel.isHidden = true
        errorLabel.textAlignment = .center
        
        continueButton.autoReset = false
        
        fullNameInputView.contentView.setTag(0)
        usernameInputView.contentView.setTag(1)
        phoneNumberInputView.contentView.setTag(2)
        emailInputView.contentView.setTag(3)
        passwordInputView.contentView.setTag(4)
    }
    
    func configureData() {
        title = "Register Form"
        disclaimerLabel.text = "By signing up you agree to our Terms and Privacy Policy."
        
        phoneNumberDisclaimerLabel.text = "for verifcation and communication purposes in the app"
        phoneNumberDisclaimerLabel.numberOfLines = 0
        
        guard let signInProviderInfo = signInProvderInfo else { return }
        
        if let fullName = signInProvderInfo?.displayName {
            fullNameInputView.contentView.textField.text = fullName
            fullNameInputView.contentView.textField.textColor = UIColor.black.withAlphaComponent(0.6)
            fullNameInputView.contentView.textField.isUserInteractionEnabled = false
        }
        
        if let email = signInProvderInfo?.email {
            emailInputView.contentView.textField.text = email
            emailInputView.contentView.textField.textColor = UIColor.black.withAlphaComponent(0.6)
            emailInputView.contentView.textField.isUserInteractionEnabled = false
        }
        
        if let profileUrl = signInProviderInfo.photoUrl {
            profileImageInputView.contentView.kf.setImage(with: profileUrl)
            userSelectedAProfileImage = .fromUrl(profileUrl)
        }
        
        if let phoneNumber = signInProviderInfo.phoneNumber {
            phoneNumberInputView.contentView.textField.text = phoneNumber
        }
    }
    
    func configureGestures() {
        let keyboardTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        keyboardTap.cancelsTouchesInView = false
        view.addGestureRecognizer(keyboardTap)

        profileImageInputView.configureGestures()
    }
    
    func configureLayout() {
        configureLayoutForInputStackView()
        configureLayoutForUpperStackView()
        configureLayoutForOuterStackView()

        configureConstraintsForProfileImageView()
    }

    func configureConstraintsForProfileImageView() {
        profileImageInputView.contentView.translatesAutoresizingMaskIntoConstraints = false

        profileImageInputView.contentView.autoMatch(.width, to: .height, of: profileImageInputView.contentView)
        profileImageInputView.contentView.autoSetDimension(.height, toSize: UIImageView.Size.medium.get())

        profileImageInputView.horizontalStackView.addArrangedSubview(UIView())
    }
    
    func configureLayoutForOuterStackView() {
        outerStackView.addArrangedSubview(upperStackView)
        outerStackView.addArrangedSubview(errorLabel)
        outerStackView.addArrangedSubview(continueButton)
    }
    
    func configureLayoutForUpperStackView() {
        upperStackView.addArrangedSubview(inputStackView)
        upperStackView.addArrangedSubview(disclaimerLabel)
    }
    
    func configureLayoutForInputStackView() {
        inputStackView.addArrangedSubview(profileImageInputView)
        inputStackView.addArrangedSubview(fullNameInputView)
        inputStackView.addArrangedSubview(usernameInputView)
        inputStackView.addArrangedSubview(phoneNumberInputView)
        inputStackView.addArrangedSubview(phoneNumberDisclaimerLabel)
        inputStackView.addArrangedSubview(emailInputView)
        if signInProvderInfo == nil {
            inputStackView.addArrangedSubview(passwordInputView)
        }
    }
}
