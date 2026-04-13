

import SwiftUI

struct LoadingViewSKAKGRAY: View {
    @AppStorage("firstInApp") var firstInApp = true
    @AppStorage("urlString") var urlString = ""
    
    @Binding var showViewSKAKGRAY: Bool
     
    var body: some View {
        ZStack {
            Group {
                // Main content
            }
            
            if urlString != "error" && urlString != "" {
                webView(url: urlString)
            }
        }.onChange(of: urlString) { _ in
            skipLoadingView(withTime: 1)
        }
        .onAppear {
            guard !firstInApp else { return }
            skipLoadingView(withTime: 3)
        }
    }
    
    func skipLoadingView(withTime time: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(time)) {
            guard urlString == "error" else { return }
            AppDelegate.orientationLock = .portrait
            firstInApp = false
            withAnimation {
                showViewSKAKGRAY = false
                
            }
        }
    }
    
    func webView(url: String) -> some View {
        WebViewCont(urlString: url)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .padding(.top, 7)
            .padding(.bottom,  1)
            .background(Color.black)
    }
}

#Preview {
    LoadingViewSKAKGRAY(showViewSKAKGRAY: .constant(true))
}
