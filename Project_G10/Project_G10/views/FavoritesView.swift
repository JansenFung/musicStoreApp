//
//  FavoritesView.swift
//  Project_G10
//
//  Created by Jansen Fung on 2023-03-26.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var fireDBHelper: FireDBHelper
    
    var body: some View {
        VStack{
            if self.fireDBHelper.currentUserFavorites.isEmpty{
                Text("Empty List")
            }
            else {
                //current user favorite list
                List{
                    ForEach(self.fireDBHelper.currentUserFavorites.enumerated().map{$0}, id:\.element.self){
                        index, favorite in
                        HStack{
                            CustomImageView(imageURl: favorite.imageURL)
                            Text("\(favorite.name)")
                        }
                    }
                    .onDelete{
                        indexSet in
                        
                        //delete record store info from favorite list
                        for index in indexSet{
                            self.fireDBHelper.deleteFavorite(selectedRecordStore: self.fireDBHelper.currentUserFavorites[index])
                        }
                    }
                }
            }
        }//VStack ends
        .onAppear(){
            self.fireDBHelper.getCurrentUserFavorites()
        }
    }
}

//struct FavoritesView_Previews: PreviewProvider {
//    static var previews: some View {
//        FavoritesView()
//    }
//}
