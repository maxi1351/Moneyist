//
//  StarRatingView.swift
//  Moneyist
//
//  Created by Maxi Rapa on 07/04/2021.
//

import SwiftUI

// Source: Bookworm SwiftUI tutorial
struct StarRatingView: View {
    @Binding var rating: Int
    
    var label = ""
    var maxRating = 5
    
    var offImage: Image?
    var onImage = Image(systemName: "star.fill")
    
    var offColour = Color.gray
    var onColour = Color.yellow
    
    var body: some View {
        HStack {
            if label.isEmpty == false {
                Text(label)
            }
            
            ForEach(1..<maxRating + 1) { number in
                self.image(for: number)
                .foregroundColor(number > self.rating ? self.offColour : self.onColour)
                    .onTapGesture {
                        self.rating = number
                    }
            }
        }
    }
    
    func image(for number: Int) -> Image {
        if number > rating {
            return offImage ?? onImage
        } else {
            return onImage
        }
    }
}

struct StarRatingView_Previews: PreviewProvider {
    static var previews: some View {
        StarRatingView(rating: .constant(4))
    }
}
