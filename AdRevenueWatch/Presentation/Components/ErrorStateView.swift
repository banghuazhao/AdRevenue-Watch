import SwiftUI

struct ErrorStateView: View {
    var headerImage: String = "exclamationmark.triangle" // Default SF Symbol
    var title: String
    var subtitle: String
    var buttonTitle: String
    var buttonAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: headerImage)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.red)

            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text(subtitle)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundColor(.gray)

            Button(action: buttonAction) {
                Text(buttonTitle)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 40)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .padding()
    }
}

#Preview {
    ErrorStateView(
        title: "title",
        subtitle: "subtitle",
        buttonTitle: "buttonTitle",
        buttonAction: {})
}
