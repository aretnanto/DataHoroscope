//
//  ContentView.swift
//  DataHoroscope
//
//  Created by Aditya Retnanto on 10/20/21.
import SwiftUI
import CoreLocation
import HealthKit
import Foundation

struct ContentView: View {
    private var healthData : HKData?
    @State private var steps : Double?
    @State private var cals : Double?
    init() {
        healthData = HKData()
    }
    @StateObject var locationModel = LocationViewModel()
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors:[.blue,.white]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            //Initialize Health Info
                .onAppear {if let healthData = healthData {
                    healthData.requestAuthorization{success in
                        if success {
                            healthData.getSteps {statisticsCollection in if let statisticsCollection = statisticsCollection
                                {
                                statisticsCollection.enumerateStatistics(from: Calendar.current.date(byAdding: .day, value: -1,to: Date())!, to: Date()) {
                                    (statistics, stop) in
                                    steps = statistics.averageQuantity()? .doubleValue(for: HKUnit(from: "meter"))
                                }
                            }
                                healthData.getCals {statisticsCollection in if let statisticsCollection = statisticsCollection
                                    {
                                    statisticsCollection.enumerateStatistics(from: Calendar.current.date(byAdding: .day, value: -1,to: Date())!, to: Date()) {
                                        (statistics, stop) in
                                        cals = statistics.averageQuantity()? .doubleValue(for: HKUnit(from: "meter"))
                                    }
                                }
                                }
                            }
                        }
                    }
                }
                }
            VStack {
                Text("Data Horoscope")
                    .font(.system(size:40, weight: .medium, design: .default))
                    .foregroundColor(.white)
                    .padding()
                Text("Take it Easy King👑").font(.system(size:30, weight: .medium))
                    .foregroundColor(.white)
                VStack(spacing:10) {
                    Image(systemName: "heart.fill")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width:120, height: 120)
                }
                HStack(spacing: 20){
                    VStack{
                        Text("Country")
                            .font(.system(size:27, weight: .medium))
                            .foregroundColor(.white)
                        if (locationModel.curLoc?.country != nil) {
                            Circle()
                                .fill(.green)                            .frame(width: 14, height: 14).offset(y:10)
                        }
                        else {
                            Circle()
                                .fill(.red)                            .frame(width: 14, height: 14).offset(y:10)
                        }
                        Text(String( locationModel.curLoc?.country ?? "Nowhere"))                      .font(.system(size:12, weight: .light))
                            .foregroundColor(.white)
                    }
                    VStack {
                        Text("City").font(.system(size:27, weight: .medium))
                            .foregroundColor(.white)
                        if (locationModel.curLoc?.administrativeArea != nil) {
                            Circle()
                                .fill(.green)                            .frame(width: 14, height: 14).offset(y:10)
                        }
                        else {
                            Circle()
                            .fill(.red).offset(y:10)                            .frame(width: 14, height: 14)};
                        Text(String( locationModel.curLoc?.administrativeArea ?? "Nowhere"))          .font(.system(size:12, weight: .light))
                            .foregroundColor(.white)
                    }
                    VStack {
                        Text("Altitude").font(.system(size:27, weight: .medium))
                            .foregroundColor(.white)
                        Circle()
                            .fill(Color.green)
                            .frame(width: 14, height: 14).offset(y:10)
                        Text("High On Life").font(.system(size:12, weight: .light))
                            .foregroundColor(.white)
                    }
                }
                VStack{
                    HStack(spacing: 50) {
                        VStack{
                            Text("Walked").font(.system(size:27, weight: .medium))
                                .foregroundColor(.white)
                            HStack{                            Text(String(steps ?? 0))          .font(.system(size:18, weight: .medium))
                                    .foregroundColor(.white)
                                Text("🥾").font(.system(size:18, weight: .medium))
                                .foregroundColor(.white)}
                        }
                        VStack{
                            Text("Burnt").font(.system(size:27, weight: .medium))
                                .foregroundColor(.white)
                            HStack{
                                Text(String(cals ?? 0))          .font(.system(size:18, weight: .medium))
                                    .foregroundColor(.white)
                                Text("🔥").font(.system(size:18, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                ZStack{
                    RoundedRectangle(cornerRadius: 25.0).foregroundColor(.black).opacity(0.3).frame(width: 300, height: 200).offset(y:-70)
                    VStack{
                        HStack(spacing:70){
                            VStack {
                                Text("Do")
                                    .font(.system(size:24, weight: .light))
                                    .foregroundColor(.white)
                                Text("Drink Water")         .font(.system(size:16, weight: .light))
                                    .foregroundColor(.white)
                                Text("Sleep").font(.system(size:16, weight: .light))
                                    .foregroundColor(.white)
                            }
                            VStack{
                                Text("Avoid")
                                    .font(.system(size:24, weight: .light))
                                    .foregroundColor(.white)
                                Text("Starting Beef")         .font(.system(size:16, weight: .light))
                                    .foregroundColor(.white)
                                Text("Veggies")         .font(.system(size:16, weight: .light))
                                    .foregroundColor(.white)
                            }
                        }
                        VStack{
                            ZStack{
                                RoundedRectangle(cornerRadius: 25.0).foregroundColor(.green).opacity(0.7).frame(width: 300, height: 50).offset(y: 200)
                                Text("Nearest McDonalds").font(.system(size:24, weight: .light))
                                    .foregroundColor(.white).offset(y:200)
                            }
                        }
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

final class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var auth: CLAuthorizationStatus
    @Published var curLoc: CLPlacemark?
    private let locationManager: CLLocationManager
    override init() {
        locationManager = CLLocationManager()
        auth = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func locationManager( _manager: CLLocationManager, didUpdateLocation locations: [CLLocation]) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(locations.first!) {(placemarks, errors) in self.curLoc = placemarks?.first
        }
    }
}


final class HKData: ObservableObject {
    var healthData: HKHealthStore?
    
    let calsburned = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!
    let distancewalk = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!
    init() {
        if HKHealthStore.isHealthDataAvailable(){
            healthData = HKHealthStore()
        }
    }
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard let healthData = self.healthData else {return completion(false)}
        healthData.requestAuthorization(toShare: [], read: Set([calsburned,distancewalk]))
        { (success, error) in
            completion(success)
        }
    }
    func getCals(completion: @escaping (HKStatisticsCollection?) -> Void) {
        let startDate = Calendar.current.date(byAdding : .hour, value : -3, to: Date())
        let anchorDate = Calendar.current.startOfDay(for: startDate ?? Date())
        let curData = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        let query = HKStatisticsCollectionQuery(quantityType: calsburned, quantitySamplePredicate: curData, options: .cumulativeSum, anchorDate: anchorDate, intervalComponents: DateComponents(hour: 1))
        
        query.initialResultsHandler = { query, statisticsCollection, error in completion(statisticsCollection)
        }
        if let healthData = healthData
        {
            healthData.execute(query)
        }
    }
    func getSteps(completion: @escaping (HKStatisticsCollection?) -> Void) {
        let startDate = Calendar.current.date(byAdding : .hour, value : -1, to: Date())
        let anchorDate = Calendar.current.startOfDay(for: startDate ?? Date())
        let curData = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        let query = HKStatisticsCollectionQuery(quantityType: distancewalk, quantitySamplePredicate: curData, options: .cumulativeSum, anchorDate: anchorDate, intervalComponents: DateComponents(hour: 1))
        query.initialResultsHandler =  { query, statisticsCollection, error in completion(statisticsCollection)
        }
        if let healthData = healthData
        {
            healthData.execute(query)
        }
    }
}

//Resources
//https://developer.apple.com/documentation/corelocation/converting_between_coordinates_and_user-friendly_place_names
//https://nyxo.app/statistical-queries-with-swift-and-healthkit
//https://www.andyibanez.com/posts/using-corelocation-with-swiftui/
