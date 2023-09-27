//
//  AdminView.swift
//  Project_G10
//
//  Created by Jansen Fung on 2023-03-26.
//

import SwiftUI

struct AdminView: View {
    @EnvironmentObject private var fireDBHelper: FireDBHelper
    
    var body: some View {
        VStack{
            if self.fireDBHelper.unClaimedRecordStoreList.isEmpty{
                Text("Empty List")
            }
            else {
                //list of unclaimed record store info
                List{
                    ForEach(self.fireDBHelper.unClaimedRecordStoreList.enumerated().map{$0}, id:\.element.self){
                        index, unclaimedRecordStore in
                        
                        NavigationLink(destination: UnclaimedRecordStoreDetailView(selectedIndex: index, selectedUnClaimedInfo: unclaimedRecordStore)){
                            CustomImageView(imageURl: unclaimedRecordStore.imageURL)
                            Text("\(unclaimedRecordStore.name)")
                        }//NavigationLink ends
                    }//ForEach
                    .onDelete(){
                        indexSet in
                        
                        //delete unclaimed record store info
                        for index in indexSet {
                            self.fireDBHelper.deleteUnClaimedRecordStoreInfo(recordStoreInfoToDelete: self.fireDBHelper.unClaimedRecordStoreList[index])
                        }
                    }
                }//List ends
            }//end if
        }//VStack
        .onAppear(){
            self.fireDBHelper.getAllUnClaimedRecordStoreInfo()
            print(#function, self.fireDBHelper.unClaimedRecordStoreList.count)
        }
    }
}

struct AdminView_Previews: PreviewProvider {
    static var previews: some View {
        AdminView()
    }
}
