import SwiftUI
import Firebase
import FLAnimatedImage

// AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Firebase when the app launches
        FirebaseApp.configure()
        return true
    }
}

// GIFImageView
struct GIFImageView: UIViewRepresentable {
    let gifName: String
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        
        // Load the GIF data asset
        guard let gifDataAsset = NSDataAsset(name: gifName) else {
            print("GIF data asset not found.")
            return view
        }
        
        let gifData = gifDataAsset.data
        let imageView = FLAnimatedImageView()
        let animatedImage = FLAnimatedImage(animatedGIFData: gifData)
        imageView.animatedImage = animatedImage
        imageView.contentMode = .scaleAspectFit
        
        view.addSubview(imageView)
        
        // Set constraints for the image view
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

// LaunchView
struct LaunchView: View {
    @State private var isActive = false
    
    var body: some View {
        Group {
            if isActive {
                // Navigate to LoginPage after the launch screen
                LoginPage()
            } else {
                // Display the launch GIF
                GIFImageView(gifName: "launch_gif")
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        // Set a delay of 5 seconds before transitioning to the LoginPage
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            withAnimation {
                                self.isActive = true
                            }
                        }
                    }
            }
        }
    }
}

// LoginPage
struct LoginPage: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var rememberMe = false
    @State private var isLoggedIn = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            ZStack {
                // Background image
                Image("Background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                
                // Overlay with semi-transparent black color
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Logo at the top
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .padding(.top, 20)
                       
                    Spacer()

                    // Input fields for email and password
                    VStack(spacing: 15) {
                        TextField("Email Address", text: $email)
                            .padding()
                            .background(Color(.darkGray))
                            .cornerRadius(10)
                            .padding(.horizontal, 20)

                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color(.darkGray))
                            .cornerRadius(10)
                            .padding(.horizontal, 20)

                        // Display error message if login fails
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding(.horizontal, 20)
                        }

                        // Remember me toggle and forgot password button
                        HStack {
                            Toggle(isOn: $rememberMe) {
                                Text("Remember me")
                                    .foregroundColor(.white)
                            }
                            .toggleStyle(CheckboxToggleStyle())
                            
                            Spacer()

                            Button(action: {
                                // Forgot password action
                            }) {
                                Text("Forgot password?")
                                    .foregroundColor(.yellow)
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    Spacer()

                    // Login button
                    Button(action: {
                        loginUser()
                    }) {
                        Text("Login Now")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding()
                            .frame(width: 220, height: 60)
                            .background(Color.yellow)
                            .cornerRadius(15.0)
                    }
                    .padding(.bottom, 20)

                    // Navigation link to create account view
                    HStack {
                        Text("Don’t have an account?")
                            .foregroundColor(.white)

                        NavigationLink(destination: CreateAccountView()) {
                            Text("Create one")
                                .foregroundColor(.yellow)
                        }
                    }
                    .padding(.bottom, 30)
                }
                .background(
                    // Navigation link to HomePageView after successful login
                    NavigationLink(
                        destination: HomePageView(),
                        isActive: $isLoggedIn,
                        label: { EmptyView() }
                    )
                )
            }
        }
    }

    // Login function
    private func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = "Login error: \(error.localizedDescription)"
                return
            }
            self.isLoggedIn = true
        }
    }
}

// CreateAccountView
struct CreateAccountView: View {
    @State private var name: String = ""
    @State private var surname: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            // Create Account title
            Text("Create Account")
                .font(.largeTitle)
                .foregroundColor(.yellow)
                .padding(.bottom, 50)

            // Input fields for name, surname, email, and password
            VStack(spacing: 20) {
                TextField("Name", text: $name)
                    .padding()
                    .background(Color(.darkGray))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)

                TextField("Surname", text: $surname)
                    .padding()
                    .background(Color(.darkGray))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)

                TextField("Email Address", text: $email)
                    .padding()
                    .background(Color(.darkGray))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.darkGray))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)

                // Display error message if account creation fails
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.horizontal, 20)
                }
            }

            Spacer()

            // Create Account button
            Button(action: {
                createAccount()
            }) {
                Text("Create Account")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding()
                    .frame(width: 220, height: 60)
                    .background(Color.yellow)
                    .cornerRadius(15.0)
            }
            .padding(.bottom, 10)

            // Cancel button
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Cancel")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 220, height: 60)
                    .background(Color.red)
                    .cornerRadius(15.0)
            }
            .padding(.bottom, 20)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }

    // Create account function
    private func createAccount() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = "Account creation error: \(error.localizedDescription)"
                return
            }
            
            let db = Firestore.firestore()
            db.collection("users").document(authResult!.user.uid).setData([
                "name": self.name,
                "surname": self.surname,
                "email": self.email
            ]) { error in
                if let error = error {
                    self.errorMessage = "Database error: \(error.localizedDescription)"
                    return
                }
                // Dismiss the view after successful account creation
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

// HomePageView
struct HomePageView: View {
    @State private var isLoggedOut = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                // Welcome message
                Text("Welcome Home")
                    .font(.largeTitle)
                    .foregroundColor(.yellow)
                Spacer()
                // Logout button
                Button(action: {
                    logoutUser()
                }) {
                    Text("Logout")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(width: 220, height: 60)
                        .background(Color.yellow)
                        .cornerRadius(15.0)
                }
                .padding(.bottom, 30)
            }
            .background(
                // Navigation link back to LoginPage after logout
                NavigationLink(
                    destination: LoginPage(),
                    isActive: $isLoggedOut,
                    label: { EmptyView() }
                )
            )
        }
    }

    // Logout function
    private func logoutUser() {
        do {
            try Auth.auth().signOut()
            self.isLoggedOut = true
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
        }
    }
}

// CheckboxToggleStyle
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                    .foregroundColor(configuration.isOn ? .green : .secondary)
                configuration.label
            }
        }
    }
}

// App Entry Point
@main
struct Kratos_3D_ProjectApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            LaunchView()
        }
    }
}

struct Kratos_3D_ProjectApp_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView()
    }
}

