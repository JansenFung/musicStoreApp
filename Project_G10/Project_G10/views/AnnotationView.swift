//
//  AnnotationView.swift
//  Project_G10
//
//  Created by Jansen Fung on 2023-03-25.
//

import SwiftUI
//igorne this class
struct AnnotationView: View {
    @State private var showTitle = true
    let title: String
    var body: some View {
    
        VStack{
            Text(title)
                .padding(5)
                .background(.white)
                .cornerRadius(10)
                .opacity(showTitle ? 0 : 1)
            
            
            Image(systemName: "mappin.circle.fill")
                .font(.title)
                .foregroundColor(.red)
            
            Image(systemName: "arrowtriangle.down.fill")
                .font(.caption)
                .foregroundColor(.red)
                .offset(x:0, y: -5)
        }
        .onTapGesture {
            withAnimation(.easeInOut){
                showTitle.toggle()
            }
        }
    }
}
