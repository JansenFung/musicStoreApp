//
//  RecordStoreDetailView.swift
//  Project_G10
//
//  Created by Jansen Fung on 2023-03-25.
//

import SwiftUI
import MapKit
import FirebaseAuth

struct RecordStoreDetailView: View {
    @EnvironmentObject private var fireDBHelper: FireDBHelper
    @EnvironmentObject private var locationHelper: LocationHelper
    @Environment(\.dismiss) private var dismiss
    
    @State private var region = MKCoordinateRegion()
    @State private var coordinate = CLLocationCoordinate2D()
    @State private var locations = [Location]()
    @State private var address = CLLocation()
    @State private var showAlert: Bool = false
    @State private var inFavorite: Bool = false
    @State private var disableButton: Bool = false
        
    let selectedIndex: Int
    let selectedRecordStoreInfo: RecordStoreInfo
    
    var body: some View {
        ScrollView{
            VStack{
                //if !self.fireDBHelper.recordStoreList.isEmpty{
                            //store name
                            Text("\(self.selectedRecordStoreInfo.name)")
                                .padding(3)
                                .font(.title2)
                                .bold()
    
                            //image
                            AsyncImage(url: URL(string:"\(self.selectedRecordStoreInfo.imageURL)")){
                                phase in
    
                                //diplay default image if the image url is not available
                                if let error = phase.error {
                                    Image(systemName: "photo.fill")
                                        .resizable()
                                        .aspectRatio(contentMode:.fit)
                                }
                                else if let image = phase.image{
                                    image.resizable()
                                        .frame(width: 250, height: 250)
                                        .overlay(RoundedRectangle(cornerRadius: 3).stroke(.gray, lineWidth: 2))
                                }
                            }
    
                            VStack{
                                Text("\(self.selectedRecordStoreInfo.isClaimed ? "Clamied" : "Unclamied")")
                                    .padding(3)
                                    .font(.title3)
    
                                //address
                                Text("\(self.selectedRecordStoreInfo.address)")
                                    .padding(.horizontal, 100)
                                    .padding(3)
                                    .font(.title3)
    
                                //business hours
                                Text("Business Hours:").font(.title3)
                                    .bold()
                                ForEach(self.selectedRecordStoreInfo
                                    .businessHours.enumerated().map{$0}, id:\.element.self){
                                        index, businessHours in
                                        Text("\(businessHours)")
                                            .padding(3)
                                            .font(.title3)
                                            .underline()
                                    }
    
                                Text("Contact:")
                                    .padding(3)
                                    .font(.title3)
                                    .bold()
    
                                //phone number
                                Text("\(self.selectedRecordStoreInfo.phoneNumber)")
                                    .padding(3)
                                    .font(.title3)
                                    .foregroundColor(.blue)
                                    .underline()
                                    .onTapGesture {
                                        guard let phoneURL = URL(string: "tel://\(self.selectedRecordStoreInfo.phoneNumber)") else{
                                            print(#function, "Unable to convert to url")
                                            return
                                        }
                                        UIApplication.shared.open(phoneURL)
                                    }
    
                                //email address
                                Text("\(self.selectedRecordStoreInfo.email)")
                                    .padding(3)
                                    .font(.title3)
    
                                //website
                                Text("\(self.selectedRecordStoreInfo.website)")
                                    .underline()
                                    .foregroundColor(.blue)
                                    .padding(3)
                                    .font(.title3)
                                    .onTapGesture {
                                        let link = "https://\(self.selectedRecordStoreInfo.website)"
    
                                        guard let url = URL(string: link) else {
                                            print(#function, "Unable to convert to url")
                                            return
                                        }
    
                                        UIApplication.shared.open(url)
                                    }
    
                                HStack{
                                    //share link
                                    if #available(iOS 16.0, *){
                                        let name = self.selectedRecordStoreInfo.name
    
                                        let address =
                                        self.selectedRecordStoreInfo.address
    
                                        let phoneNumber = self.selectedRecordStoreInfo.phoneNumber
    
                                        let website = self.selectedRecordStoreInfo.website
    
                                        //share store's name, address, phoneNumber, and website
                                        let message = """
                                        store: \(name)
                                        address: \(address)
                                        phoneNumber: \(phoneNumber)
                                        website: \(website)
                                        """
    
                                        ShareLink(item: message){
                                            Image(systemName: "square.and.arrow.up.fill")
                                                .resizable()
                                                .frame(width: 35, height: 35)
                                        }
                                   // }//end if
    
                                    //add to favorite button
                                    Button(action:{
                                        //no current logged in user
                                        if Auth.auth().currentUser == nil{
                                            self.showAlert.toggle()
                                        }
                                        else{
    //                                        if !self.fireDBHelper.currentUserFavorites.contains(where: {$0.id == self.fireDBHelper.recordStoreList[self.selectedIndex].id}){
    //                                            self.fireDBHelper.insertToFavotites(selectedRecordStore: self.fireDBHelper.recordStoreList[selectedIndex])
    //
    //                                            self.inFavorite.toggle()
    //                                            self.disableButton.toggle()
    //                                        }
                                        //insert to Firestore
                                        self.fireDBHelper.insertToFavotites(selectedRecordStore: self.selectedRecordStoreInfo)

                                        dismiss()
                                    }
                                }){
                                    if self.inFavorite {
                                        Image(systemName: "heart.fill")
                                            .resizable()
                                            .frame(width: 35, height: 35)
                                    }
                                    else{
                                        Image(systemName: "heart")
                                            .resizable()
                                            .frame(width: 35, height: 30)

                                    }
                                }
                                .alert(isPresented: self.$showAlert){
                                    Alert(title: Text("Please sign In"),
                                          message: Text(""),
                                          dismissButton: .default(Text("Continue")))
                                }
                                .disabled(self.disableButton)
                            }//HStack ends
                        }//VStack ends

                    //Store location
                    ZStack{
                        Map(coordinateRegion: self.$region, userTrackingMode: .constant(.follow), annotationItems: self.locations){
                            location in
                           MapMarker(coordinate: location.coordinate)
                                
//                                  {
//                                        AnnotationView(title: location.name)
//                                    }
                        }.frame(width: 500, height: 400).ignoresSafeArea()

                        VStack(alignment: .trailing){
                            Spacer()
                            HStack{
                                Button(action:{
                                    self.region.span.longitudeDelta *= 0.6
                                    self.region.span.latitudeDelta *= 0.6
                                }){
                                    Image(systemName: "plus.app.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                }

                                Button(action:{
                                    self.region.span.longitudeDelta /= 0.6
                                    self.region.span.latitudeDelta /= 0.6
                                }){
                                    Image(systemName: "minus.square.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                }

                            }//HStack ends
                        }//VStack ends
                    }//ZStack ends
                    .padding()
                }//end if
            }//VStack ends
        }//ScrollView ends
        .padding()
    .onAppear(){
        //            if !self.fireDBHelper.currentUserFavorites.contains(where: {$0.name == self.selectedRecordStoreInfo.name}){
        //
        //                print(#function, "Match")
        //                self.inFavorite = false
        //                self.disableButton = false
        //            }
        //            else{
        //                print(#function, "notMatch")
        //                self.inFavorite = true
        //                self.disableButton = true
        //            }
        
            //Gecoding the address into coressponding coordinate
            self.locationHelper.doForwordGecoding(address: self.selectedRecordStoreInfo.address){
                coordinate in
                
                self.coordinate = coordinate ?? CLLocationCoordinate2D(latitude: 80.3, longitude: -6.1)
                
                print(#function, "\(self.coordinate.latitude), \(self.coordinate.longitude)")
                
                let storeAddress = Location(name: self.selectedRecordStoreInfo.name, coordinate: coordinate ?? CLLocationCoordinate2D(latitude: 80.3, longitude: -6.1))
                
                self.locations.append(storeAddress)
                
                self.region = MKCoordinateRegion(center: coordinate ?? CLLocationCoordinate2D(latitude: 80.3, longitude: -6.1), span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003))
            }
        }//onAppera ends
    }
}

//struct RecordStoreDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        RecordStoreDetailView()
//    }
//}
