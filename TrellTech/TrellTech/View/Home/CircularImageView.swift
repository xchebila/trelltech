import SwiftUI

struct CircularImageView: View {
    @StateObject var dataManager = TrelloAPIManager()
    
    let name: String
    let size: CGFloat
    
    var body: some View {
        Image(name)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size, height: size)
            .clipShape(Circle())
    }
}

struct CircularImageView_Previews: PreviewProvider {
    static var previews: some View {
        CircularImageView(name: "profile", size: 42)
    }
}
