//
//  RecordStoreView.swift
//  Project_G10
//
//  Created by Jansen Fung on 2023-03-25.
//

import SwiftUI
import FirebaseAuth

struct RecordStoreView: View {
    @EnvironmentObject private var fireDBHelper: FireDBHelper
    @State private var searchText: String = ""
    
    //filter the data
    var searchResult: [RecordStoreInfo] {
        if searchText.isEmpty{
            return self.fireDBHelper.recordStoreList
        }
        else {
            return self.fireDBHelper.recordStoreList.filter({$0.name.lowercased().contains(searchText.lowercased())})
        }
    }
    
    var body: some View {
        VStack{
            //Search bar
            HStack{
                Image(systemName: "magnifyingglass")
                
                TextField("Search by name", text:self.$searchText)
                    .padding(5)
                    .foregroundColor(.black)
                    .textFieldStyle(.roundedBorder)
            }//HStack
            
            //Record Store Info List
            List{
                if self.fireDBHelper.recordStoreList.isEmpty{
                    Text("Empty List")
                }
                else {
                    ForEach(self.searchResult.enumerated().map{$0}, id: \.element.self){ index, currentStore in
                        
                        NavigationLink(destination: RecordStoreDetailView(selectedIndex: index, selectedRecordStoreInfo: currentStore)){
                            CustomImageView(imageURl: currentStore.imageURL)
                            Text("\(currentStore.name)")
                        }//NavigationLink ends
                    }//ForEach ends
                }
            }//List ends
        }//VStack
        .onAppear(){
            //update the fireDBHelper record store list
            self.fireDBHelper.getAllRecordStoreInfo()
        }
    }
}

//Customer Image View
struct CustomImageView: View {
    var imageURl: String
    
    var body: some View{
        VStack{
            AsyncImage(url: URL(string:"\(imageURl)")){
                phase in
                
                //display default image if the image url link is not available
                if let error = phase.error {
                    Image(systemName: "photo.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                }
                
                else if let image = phase.image{
                    image.resizable()
                        .frame(width: 100, height: 100)
                        .overlay(RoundedRectangle(cornerRadius: 3).stroke(.gray, lineWidth: 2))
                }
            }
        }
    }
}
//struct RecordStoreView_Previews: PreviewProvider {
//    static var previews: some View {
//        RecordStoreView()
//    }
//}
