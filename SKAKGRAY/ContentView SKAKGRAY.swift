import SwiftUI

struct ContentViewSKAKGRAY: View {
    @State var showLoadingSKAKGRAY = true
    
    var body: some View {
        ZStack {
            if !showLoadingSKAKGRAY {
                //Main View
            }
            
            // Loading View
            if showLoadingSKAKGRAY {
                LoadingViewSKAKGRAY(showViewSKAKGRAY: $showLoadingSKAKGRAY)
            }
        }
    }
    
}


#Preview {
    ContentViewSKAKGRAY(showLoadingSKAKGRAY: false)
}

