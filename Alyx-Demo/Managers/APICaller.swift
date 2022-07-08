//
//  APICaller.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//


import UIKit
import CoreData

final class APICaller {
    
    static let shared = APICaller()
    
    private init() {}
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    public var historyIsPaginating = false
    
    enum CoreDataError: Error {
        case noAppDelegate
    }
    
    enum APIError: Error {
        case failedToGetData
    }
    
    public func cacheToken(result: AuthResponse) {
        UserDefaults.standard.setValue(result.token, forKey: Constants.access_token)
//        UserDefaults.standard.setValue(result.user_email, forKey: Constants.token_user_email)
//        UserDefaults.standard.setValue(result.user_nicename, forKey: Constants.token_user_nicename)
//        UserDefaults.standard.setValue(result.user_email, forKey: Constants.token_user_display_name)
    }
    
    public func cacheToken2(result: AuthResponse) {
        UserDefaults.standard.setValue(result.token, forKey: Constants.access_token2)
    }
    
    
// MARK: - Saving to CoreData
    
    public func storeToken(result: AuthResponse) {
//        let newItem = Cart_Entity(context: context)
        let tokenEntity = Token_Entity(context: context)
        tokenEntity.token_user_display_name = result.user_display_name
        tokenEntity.token_user_email = result.user_email
        tokenEntity.token_user_nicename = result.user_nicename
        tokenEntity.token_value = result.token
        
        do {
            try context.save()
        } catch {
            print("Error storing token: \(error.localizedDescription)")
        }
    }
    
    private var cachedDeviceID: String? = {
        return UserDefaults.standard.string(forKey: "generated_device_id")
        // return AuthManager.shared.cachedDeviceID
    }()
    
    private var cachedDomainName: String? = {
        return UserDefaults.standard.string(forKey: "domain_name")
        // return AuthManager.shared.domainName
    }()
    
// MARK: - JEEVES APICALLS
    public func getCurrentUserProfile(completion: @escaping(Result<UserProfile, Error>) -> Void) {}
    
    public func getToken(completion: @escaping(Result<AuthResponse, Error>) -> Void) {
        // get Token
        guard let cachedDeviceID = cachedDeviceID,
              let url = URL(string: Constants.tokenAPIURL+"/?username=\(Constants.username)&password=\(Constants.password)") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, _, error) in
            guard let safeData = data, error == nil else {
                completion(.failure(APIError.failedToGetData))
                return
            }
            
            do {
//                let result = try JSONSerialization.jsonObject(with: safeData, options: .allowFragments)
                let result = try JSONDecoder().decode(AuthResponse.self, from: safeData)
                
                self?.cacheToken(result: result)
                self?.storeToken(result: result)
//                print("SUCCESS get Token: - \(result)")
                completion(.success(result))
            } catch {
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    public func getTokenWithDomain(with domain: String, completion: @escaping(Result<AuthResponse, Error>) -> Void) {
        // get Token
//        guard let cachedDeviceID = cachedDeviceID,
//              let url = URL(string: "\(Constants.https)\(domain)\(Constants.tokenAPIURL)username=\(Constants.username)&password=\(Constants.password)&device_id=\(cachedDeviceID)") else { return }
//
        guard let url = URL(string: "\(Constants.https)\(domain)\(Constants.tokenAPIURL)username=\(Constants.username)&password=\(Constants.password)") else {
            print("getTokenWithDomain error: ")
            return
        }
        
        print("getTokenWithDomain url: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, _, error) in
            guard let safeData = data, error == nil else {
                completion(.failure(APIError.failedToGetData))
                return
            }
            
            do {
//                let result = try JSONSerialization.jsonObject(with: safeData, options: .allowFragments)
                let result = try JSONDecoder().decode(AuthResponse.self, from: safeData)
                self?.cacheToken(result: result)
                self?.storeToken(result: result)
                
                print("SUCCESS get Token: - \(result)")
                completion(.success(result))
            } catch {
                print("getTokenWithDomain ERROR: ", error.localizedDescription)
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    
    public func getTokenWithDomainAndDeviceID(with domain: String, with deviceID: String, completion: @escaping(Result<AuthResponse, Error>) -> Void) {
//    https://alyx-staging.codedisruptors.com/new-franchisee/wp-json/jwt-auth/v1/token?username=user&password=12345aA!&device_id=SIMULATOR_IP13PM
        
        guard let url = URL(string: "\(Constants.https)\(domain)\(Constants.tokenAPIURL)username=\(Constants.username)&password=\(Constants.password)&device_id=\(deviceID)") else {
            print("getTokenWithDomainAndDeviceID error: ")
            return
        }
        
        print("getTokenWithDomainAndDeviceID url: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, _, error) in
            guard let safeData = data, error == nil else {
                completion(.failure(APIError.failedToGetData))
                return
            }
            
            do {
//                let result = try JSONSerialization.jsonObject(with: safeData, options: .allowFragments)
                let result = try JSONDecoder().decode(AuthResponse.self, from: safeData)
                self?.cacheToken2(result: result)
                
                print("SUCCESS get Token2: - \(result)")
                completion(.success(result))
            } catch {
                print("getTokenWithDomainAndDeviceID ERROR: ", error.localizedDescription)
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    public func getAllFranchisees(completion: @escaping(Result<FranchiseesResponse, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseURL+"/franchisees"), with: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
//                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let result = try JSONDecoder().decode(FranchiseesResponse.self, from: data)
//                    print("getAllFranchisees: (result)")
                    completion(.success(result))
                } catch {
//                    print("getAllFranchisees: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func postDevice(with deviceID: String, completion: @escaping(Result<PostDeviceIDResponse, Error>) -> Void) {
        
        guard let cachedDomainName = UserDefaults.standard.string(forKey: "domain_name") else {
            print("postDevice No cachedDomainName")
            return
        }
        
//        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/device?title=\(deviceModelName)&device_id=\(deviceID)"
        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/device"
        
        print("postDevice urlString: \(urlString)")
            
        createRequest(with: URL(string: urlString), with: .POST) { baseRequest in
            let deviceTitle = "\(UIDevice.deviceSystemName) \(UIDevice.deviceSystemVersion) - \(UIDevice.modelName) - \(Constants.buildNumber)"
            let postDeviceModel = PostDeviceModel(device_id: deviceID, title: deviceTitle)
            
            var request = baseRequest
            let jsonData = try! JSONEncoder().encode(postDeviceModel)
            request.httpBody = jsonData
            
            print("postDeviceModel: \(postDeviceModel)")
            
            // create post request
            request.setValue("\(String(describing: jsonData.count))", forHTTPHeaderField: "Content-Length")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
//                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let result = try JSONDecoder().decode(PostDeviceIDResponse.self, from: data)
                    print("postDevice result: \(result)")
                    completion(.success(result))
                } catch {
                    print("APICaller postDevice: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func postForm(with name: String, with contact: String, with email: String, with company: String?, with location: String?, completion: @escaping(Result<SubmitFormResponse, Error>) -> Void) {
        // https://alyx.codedisruptors.com/demofranchise/wp-json/jwt-auth/v1/jeeves/submit?name=demoUser&contact_no=0912345678&email=demoTestEmail@gmail.com&company=PostMan&location=Manila
        
        guard let cachedDomainName = UserDefaults.standard.string(forKey: "domain_name") else {
            print("postDevice No cachedDomainName")
            return
        }
        
//        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/device?title=\(deviceModelName)&device_id=\(deviceID)"
        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/submit?name=\(name)&contact_no=\(contact)&email=\(email)&company=\(company ?? "")&location=\(location ?? "")"
        
        print("postForm urlString: \(urlString)")

        createRequestWithToken2(with: URL(string: urlString), with: .POST) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
//                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let result = try JSONDecoder().decode(SubmitFormResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    print("APICaller postForm: \(error)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getDevices(completion: @escaping(Result<GetDevicesResponse, Error>) -> Void) {
        
        guard let cachedDomainName = UserDefaults.standard.string(forKey: "domain_name") else {
            print("getDevices No cachedDomainName")
            return
        }
        
//        guard let cachedDeviceID = UserDefaults.standard.string(forKey: "generated_device_id") else {
//            print("getDevices No cachedDeviceID")
//            return
//        }
        
//        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/devices?device_id=\(cachedDeviceID)"
        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/devices"
        
        print("getDevices urlString: \(urlString)")

        createRequest(with: URL(string: urlString), with: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
//                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let result = try JSONDecoder().decode(GetDevicesResponse.self, from: data)
//                    print("getDevices: \(result)")
                    completion(.success(result))
                } catch {
                    print("APICaller getDevices: \(error)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func checkIfDeviceIsAuthorized(completion: @escaping(Bool) -> Void) {
        
        guard let cachedDomainName = UserDefaults.standard.string(forKey: "domain_name") else {
            print("getDevices No cachedDomainName")
            return
        }
        
        guard let cachedDeviceID = UserDefaults.standard.string(forKey: "generated_device_id") else {
            print("getDevices No cachedDeviceID")
            return
        }
        
//        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/devices?device_id=\(cachedDeviceID)"
        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/devices"
        
        print("getDevices urlString: \(urlString)")

        createRequestWithToken2(with: URL(string: urlString), with: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(false)
                    return
                }
                do {
//                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let result = try JSONDecoder().decode(GetDevicesResponse.self, from: data)
                    
//                    let fetchData =  result.data.contains(where: { $0.device_id == cachedDeviceID && $0.device_id_status == true })
                    
                    let fetchData =  result.data.filter({ $0.device_id == cachedDeviceID && $0.device_id_status == true })
                    
//                    print("fetchData: \(fetchData)")
                    
                    if !fetchData.isEmpty {
                        completion(true)
                    } else {
                        completion(false)
                    }
                } catch {
                    print("APICaller checkIfDeviceIsAuthorized: \(error)")
                    completion(false)
                }
            }
            task.resume()
        }
    }
    
    public func getUsers(completion: @escaping(Result<UsersResponse, Error>) -> Void) {
        
        
        guard let cachedDomainName = UserDefaults.standard.string(forKey: "domain_name") else {
            print("getUsers No cachedDomainName")
            return
        }
        
        guard let cachedDeviceID = UserDefaults.standard.string(forKey: "generated_device_id") else {
            print("getUsers No cachedDeviceID")
            return
        }
        
//        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/users?device_id=\(cachedDeviceID)"
        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/users"
        
        
        createRequestWithToken2(with: URL(string: urlString), with: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
//                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let result = try JSONDecoder().decode(UsersResponse.self, from: data)
//                    print("getUsers", result)
                    completion(.success(result))
                } catch {
                    print("getUsers: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getAllUsers(completion: @escaping(Result<UsersResponse, Error>) -> Void) {
        
        guard let cachedDomainName = UserDefaults.standard.string(forKey: "domain_name") else {
            print("getAllUsers No cachedDomainName")
            return
        }
        
        guard let cachedDeviceID = UserDefaults.standard.string(forKey: "generated_device_id") else {
            print("getAllUsers No cachedDeviceID")
            return
        }
        
//        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/users?device_id=\(cachedDeviceID)"
        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/users"
        
        
        createRequest(with: URL(string: urlString), with: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
//                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let result = try JSONDecoder().decode(UsersResponse.self, from: data)
//                    print("getAllUsers: ", result)
                    completion(.success(result))
                } catch {
                    print("getUsers: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getAllUsers2(completion: @escaping(Result<UsersResponse, Error>) -> Void) {
        
        guard let cachedDomainName = UserDefaults.standard.string(forKey: "domain_name") else {
            print("getAllUsers2 No cachedDomainName")
            return
        }
        
        guard let cachedDeviceID = UserDefaults.standard.string(forKey: "generated_device_id") else {
            print("getAllUsers2 No cachedDeviceID")
            return
        }
        
//        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/users?device_id=\(cachedDeviceID)"
        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/users"
        
        
        createRequestWithToken2(with: URL(string: urlString), with: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
//                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let result = try JSONDecoder().decode(UsersResponse.self, from: data)
//                    print("getAllUsers2: ", result)
                    completion(.success(result))
                } catch {
                    print("getAllUsers2: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    
    public func getJeevesEmployeeShifts(completion: @escaping(Result<EmployeeShiftsResponse, Error>) -> Void) {
        
        guard let cachedDomainName = UserDefaults.standard.string(forKey: "domain_name") else {
            print("getJeevesEmployeeShifts No cachedDomainName")
            return
        }
        
        guard let cachedDeviceID = UserDefaults.standard.string(forKey: "generated_device_id") else {
            print("getJeevesEmployeeShifts No cachedDeviceID")
            return
        }
        
//        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/empshifts?device_id=\(cachedDeviceID)"
        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/empshifts"
        
        print("getJeevesEmployeeShifts urlString: \(urlString)")
        
        createRequest(with: URL(string: urlString), with: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
//                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let result = try JSONDecoder().decode(EmployeeShiftsResponse.self, from: data)
//                    print("getJeevesEmployeeShifts result: ", result)
                    completion(.success(result))
                } catch {
                    print("getJeevesEmployeeShifts: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    
    public func getAddOns(completion: @escaping(Result<[AddOnsData], Error>) -> Void) {
        
        guard let cachedDomainName = UserDefaults.standard.string(forKey: "domain_name") else {
            print("getAddOns No cachedDomainName")
            return
        }
        
        guard let cachedDeviceID = UserDefaults.standard.string(forKey: "generated_device_id") else {
            print("getAddOns No cachedDeviceID")
            return
        }
        
//        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/add-ons"
        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/add-ons"
        
        
//        createRequestWithToken2(with: URL(string: urlString), with: .GET) { baseRequest in
        createRequest(with: URL(string: urlString), with: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
//                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let result = try JSONDecoder().decode(AddOnsResponse.self, from: data)
//                    print("getAddOns result: ", result)
                    completion(.success(result.data))
                } catch {
                    print("getAddOns: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
//    public func postAttendance(userId: String, superID: String, type: String, shift: String, workDate: String, deviceID: String, completion: @escaping(Bool) -> Void) {
    public func postAttendance(userId: String, superID: String, type: String, shift: String, workDate: String, deviceID: String, completion: @escaping(Result<AttendanceResponse, Error>) -> Void) {
        
//        let urlString = Constants.baseURL + "/attendance?user_id=\(userId)&super_id=\(superID)&type=\(type)&shift=\(shift)&workdate=\(workDate)&device_id=\(deviceID)"
        
        guard let cachedDomainName = UserDefaults.standard.string(forKey: "domain_name") else {
            print("postAttendance No cachedDomainName")
            return
        }
        
        guard let cachedDeviceID = UserDefaults.standard.string(forKey: "generated_device_id") else {
            print("postAttendance No cachedDeviceID")
            return
        }
        
        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/attendance?user_id=\(userId)&super_id=\(superID)&type=\(type)&shift=\(shift)&workdate=\(workDate)&device_id=\(cachedDeviceID)"
        
//        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/attendance?user_id=\(userId)&super_id=\(superID)&type=\(type)&shift=\(shift)&workdate=\(workDate)"
        
        print("postAttendance urlString: \(urlString)")
        
        createRequestWithToken2(with: URL(string: urlString), with: .POST) { baseRequest in
            
            print("posting started...")
            
            let task = URLSession.shared.dataTask(with: baseRequest) { data, response, error in
                guard let data = data, error == nil
                else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
//                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let result = try JSONDecoder().decode(AttendanceResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    print("postAttendance failed: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getUnclosedAttendance(completion: @escaping(Result<GetAttendanceResponse, Error>) -> Void) {
        guard let cachedDomainName = UserDefaults.standard.string(forKey: "domain_name") else {
            print("getUnclosedAttendance No cachedDomainName")
            return
        }
        
        guard let cachedDeviceID = UserDefaults.standard.string(forKey: "generated_device_id") else {
            print("getUnclosedAttendance No cachedDeviceID")
            return
        }
        
        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/attendance/device/\(cachedDeviceID)"
        
        //        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/attendance?user_id=\(userId)&super_id=\(superID)&type=\(type)&shift=\(shift)&workdate=\(workDate)"
        
        print("getUnclosedAttendance urlString: \(urlString)")
        
        createRequestWithToken2(with: URL(string: urlString), with: .GET) { baseRequest in
            
            let task = URLSession.shared.dataTask(with: baseRequest) { data, response, error in
                guard let data = data, error == nil
                else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
//                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let result = try JSONDecoder().decode(GetAttendanceResponse.self, from: data)
//                    print("getUnclosedAttendance result: \(result)")
                    completion(.success(result))
                } catch {
                    print("getAttendance failed: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    
    public func updateCouponWithCode(with orderID: String, with couponCode: Int, with couponDatamodel: UpdateCouponDataModel, completion: @escaping(Bool) -> Void) {
        
        guard let cachedDomainName = UserDefaults.standard.string(forKey: "domain_name") else {
            print("updateCouponWithCode No cachedDomainName")
            return
        }
        
        guard let cachedDeviceID = UserDefaults.standard.string(forKey: "generated_device_id") else {
            print("updateCouponWithCode No cachedDeviceID")
            return
        }
        
        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsWCV3)/coupons/\(couponCode)?device_id=\(cachedDeviceID)"
//        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV3)/coupons/\(couponCode)"
        
        print("updateCouponWithCode urlString: ", urlString)
        
        createRequestWithToken2(with: URL(string: urlString), with: .PUT) { baseRequest in
            
            
            var request = baseRequest
            let jsonData = try! JSONEncoder().encode(couponDatamodel)
            request.httpBody = jsonData
            
            // create post request
            request.setValue("\(String(describing: jsonData.count))", forHTTPHeaderField: "Content-Length")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // insert json data to the request
            
            print("updateCouponWithCode URL: ", baseRequest)
            print("couponDatamodel: \(couponDatamodel)")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil
                else {
                    completion(false)
                    return
                }
                do {
                    
                    let couponDatamodelJson = try JSONEncoder().encode(couponDatamodel)
                    let couponDatamodelJSONtoString = String(data: couponDatamodelJson, encoding: .utf8)
                    print("couponCode: \(couponCode), couponDatamodelJSONtoString: \(couponDatamodelJSONtoString!)")
                    
                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    
                    print("updateCouponWithCode success for \(orderID) with result: \(result)")
                    completion(true)
                } catch {
                    print("updateCouponWithCode failed: \(error.localizedDescription)")
                    completion(false)
                }
            }
            task.resume()
        }
    }
    
    public func postOrder(with order: PostOrderModel, completion: @escaping(Bool) -> Void) {
        
        guard let cachedDomainName = UserDefaults.standard.string(forKey: "domain_name") else {
            print("postOrder No cachedDomainName")
            return
        }
        
        guard let cachedDeviceID = UserDefaults.standard.string(forKey: "generated_device_id") else {
            print("postOrder No cachedDeviceID")
            return
        }
        
        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsWCV3)/orders?device_id=\(cachedDeviceID)"
//        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV3)/orders"
        
        createRequestWithToken2(with: URL(string: urlString), with: .POST) { baseRequest in
            
//            self.getAllItems()
//            guard let data = order else { return }
            
            var request = baseRequest
            let jsonData = try! JSONEncoder().encode(order)
            request.httpBody = jsonData
            
            // create post request
            request.setValue("\(String(describing: jsonData.count))", forHTTPHeaderField: "Content-Length")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // insert json data to the request
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    completion(false)
                    return
                }
                do {
                    let orderID = order.meta_data.first(where: { $0.key == "order_id" })?.value.returnValue() ?? "NO ORDER ID"
                    
                    let orderJson = try JSONEncoder().encode(order)
                    let orderJSONtoString = String(data: orderJson, encoding: .utf8)!
                    print("orderJSONtoString \(orderID): \(orderJSONtoString)")
                    
                    let responseJSON = try JSONSerialization.jsonObject(with: data, options: .allowFragments) // options: []
//                    print("postOrder response: ",response ?? "no postOrder response")
                    
                    
                    print("postOrder response for \(orderID): \(responseJSON)")
                    completion(true)
                    
                    if let result = responseJSON as? [String: Any] {
//                        print("post order error response: ", result["message"] ?? "error getting message")
                        let responseData = result["data"] as? [String: Int]
//                        print("post order error responseData: ", responseData ?? "error getting responseData")
                        let statusCode = responseData?.first?.value
//                        print("statusCode: ",statusCode ?? "error getting status code")
                        if let code = statusCode {
                            if code == 400 {
                                completion(false)
//                                print("response status code: \(code)")
                            }
//                            else {
//                                completion(true)
//                            }
                        }
                    }
                    
                } catch {
                    print("postOrder Error: ", error.localizedDescription)
                    completion(false)
                }
            }
            task.resume()
        }
    }
    
    public func postCashCount(with model: CashCountPostModel, completion: @escaping(Bool) -> Void) {
        
        guard let cachedDomainName = UserDefaults.standard.string(forKey: "domain_name") else {
            print("postCashCount No cachedDomainName")
            return
        }
        
        guard let cachedDeviceID = UserDefaults.standard.string(forKey: "generated_device_id") else {
            print("postCashCount No cachedDeviceID")
            return
        }
//        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/cash"
        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/cash?device_id=\(cachedDeviceID)"
        
        createRequestWithToken2(with: URL(string: urlString), with: .POST) { baseRequest in
            
//            self.getAllItems()
//            guard let data = order else { return }
            
            var request = baseRequest
            let jsonData = try! JSONEncoder().encode(model)
            request.httpBody = jsonData
            
            // create post request
            request.setValue("\(String(describing: jsonData.count))", forHTTPHeaderField: "Content-Length")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // insert json data to the request
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    completion(false)
                    return
                }
                do {
                    let responseJSON = try JSONSerialization.jsonObject(with: data, options: .allowFragments) // options: []
//                    print("postCashCount response: ",response ?? "no postOrder response")
                    
                    if let result = responseJSON as? [String: Any] {
                        print("postCashCount response: ", result) //Code after Successfull POST Request
                        if let isSuccess = result["success"] as? Bool {
                            print("isSuccess: \(isSuccess)")
                        }
                    }
                    
                    completion(true)
                } catch {
                    print("postCashCount Error: ", error.localizedDescription)
                    completion(false)
                }
            }
            task.resume()
        }
    }
        
    public func getMenuCategories(completion: @escaping(Result<CategoriesResponse, Error>) -> Void) {
        
        guard let cachedDomainName = UserDefaults.standard.string(forKey: "domain_name") else {
            print("getMenuCategories No cachedDomainName")
            return
        }
    
//        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/products/categories?device_id=\(cachedDeviceID)"
        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/products/categories"
        
        print("getMenuCategories urlString: \(urlString)")
        
//        createRequestWithToken2(with: URL(string: urlString), with: .GET) { baseRequest in
        createRequest(with: URL(string: urlString), with: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
//                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let result = try JSONDecoder().decode(CategoriesResponse.self, from: data)
                    print("Categories Response: \(result)")
                    completion(.success(result))
                } catch {
                    print("getJeevesCategory: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    /// product response from API
    public func getMenuProducts(completion: @escaping(Result<ProductsResponse, Error>) -> Void) {
        
        guard let cachedDomainName = UserDefaults.standard.string(forKey: "domain_name") else {
            print("getMenuProducts No cachedDomainName")
            return
        }
        
//        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV3)/products?device_id=\(cachedDeviceID)"
        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV3)/products"
        //https://alyx-staging.codedisruptors.com/new-franchisee/wp-json/jwt-auth/v3/jeeves/products
        print("getMenuProducts urlString: \(urlString)")
        
//        createRequestWithToken2(with: URL(string: urlString), with: .GET) { baseRequest in
        createRequest(with: URL(string: urlString), with: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
//                print("products data: ", data)
                do {
//                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let result = try JSONDecoder().decode(ProductsResponse.self, from: data)
//                    print("Products Response: \(result)")
                    completion(.success(result))
                } catch {
//                    print("getJeevesProducts: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    /// product response from API
    public func getMenuUpdatedProductsSince(with sinceStringDate: String, completion: @escaping(Result<ProductsResponse, Error>) -> Void) {
        
        guard let cachedDomainName = UserDefaults.standard.string(forKey: "domain_name") else {
            print("getMenuProducts No cachedDomainName")
            return
        }
        
        guard let cachedDeviceID = UserDefaults.standard.string(forKey: "generated_device_id") else {
            print("getMenuProducts No cachedDeviceID")
            return
        }
        
//        let formattedDate = sinceStringDate.sinceDateFormat()
//        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV2)/products/2022-04-01/08/00??device_id=\(cachedDeviceID)"
        //        let urlString = "https://alyx-staging.codedisruptors.com/new-franchisee/wp-json/jwt-auth/v2/jeeves/products/22-04-26-18-11-38"
        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV2)/products/\(sinceStringDate)"
        
        print("getMenuUpdatedProductsSince urlString: \(urlString)")
        
        createRequestWithToken2(with: URL(string: urlString), with: .GET) { baseRequest in
//        createRequest(with: URL(string: urlString), with: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
//                print("products data: ", data)
                do {
//                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let result = try JSONDecoder().decode(ProductsResponse.self, from: data)
                    print("getMenuUpdatedProductsSince result: \(result)")
                    
                    if !result.data.isEmpty {
                        // saving date since fetched updated product
                        let currentDate = Date().sinceDateFormat()
                        UserDefaults.standard.setValue(currentDate, forKey: Constants.date_since_last_update)
                    }
                    
                    completion(.success(result))
                } catch {
//                    print("getJeevesProducts: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    /// getHistory response from API
    public func getHistory(pagination: Bool = false, page: Int, completion: @escaping(Result<[HistoryData], Error>) -> Void) {
        if pagination {
            historyIsPaginating = true
        }
        guard let cachedDomainName = UserDefaults.standard.string(forKey: "domain_name") else {
            print("getHistory No cachedDomainName")
            return
        }
        
//        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV2)/orders/\(page)?device_id=\(cachedDeviceID)"
        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV2)/orders/\(page)"
        print("getHistory urlString: \(urlString)")
        
        
        //Constants.baseURL+"/orders/\(page)
        createRequestWithToken2(with: URL(string: urlString), with: .GET) { baseRequest in
//            createRequest(with: URL(string: urlString), with: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { [weak self] data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
//                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let result = try JSONDecoder().decode(HistoryResponse.self, from: data)
//                    print("getHistory", result)
                    completion(.success(result.data))
                    
                    if pagination {
                        self?.historyIsPaginating = false
                    }
                } catch {
//                    print("getJeevesProducts: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    /// getHistory response from API
    public func getAllHistory(completion: @escaping(Result<[HistoryData], Error>) -> Void) {
        
        guard let cachedDomainName = UserDefaults.standard.string(forKey: "domain_name") else {
            print("getAllHistory No cachedDomainName")
            return
        }
        
        guard let cachedDeviceID = UserDefaults.standard.string(forKey: "generated_device_id") else {
            print("getAllHistory No cachedDeviceID")
            return
        }
        
        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/orders?device_id=\(cachedDeviceID)"
//        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/orders"
        
        
        //Constants.baseURL+"/orders/"
        createRequestWithToken2(with: URL(string: urlString), with: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
//                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let result = try JSONDecoder().decode(HistoryResponse.self, from: data)
//                    print("getHistory", result)
                    completion(.success(result.data))
                } catch {
//                    print("getJeevesProducts: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    /// getHistory response from API
    public func searchHistory(with query: String, completion: @escaping(Result<[HistoryData], Error>) -> Void) {
        
        guard let cachedDomainName = UserDefaults.standard.string(forKey: "domain_name") else {
            print("searchHistory No cachedDomainName")
            return
        }
        
        guard let cachedDeviceID = UserDefaults.standard.string(forKey: "generated_device_id") else {
            print("searchHistory No cachedDeviceID")
            return
        }
        //        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/orders/id/\(query)?device_id=\(cachedDeviceID)"
        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV2)/orders/id/\(query)"
        print("searchHistory urlString: \(urlString)")
        
        //Constants.baseURL+"/orders/id/\(query)"
        createRequestWithToken2(with: URL(string: urlString), with: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
//                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let result = try JSONDecoder().decode(HistoryResponse.self, from: data)
//                    print("getHistory", result)
                    completion(.success(result.data))
                } catch {
//                    print("getJeevesProducts: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getReceiptByOrderID(orderID: Int, completion: @escaping(Result<ReceiptResponse, Error>) -> Void) {
        
        guard let cachedDomainName = UserDefaults.standard.string(forKey: "domain_name") else {
            print("getHistoryItemByID No cachedDomainName")
            return
        }
        
        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/receipt/\(orderID)"
        createRequestWithToken2(with: URL(string: urlString), with: .GET) { baseRequest in
            
            print("getHistoryItemByID: \(baseRequest)")
            
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
//                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let result = try JSONDecoder().decode(ReceiptResponse.self, from: data)
//                    print("getHistory", result)
                    completion(.success(result))
                } catch {
//                    print("getJeevesProducts: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    /// getHistory response from API
    public func getHistoryItemByID(orderID: Int, completion: @escaping(Result<HistoryItemByIDResponse, Error>) -> Void) {
        
        guard let cachedDomainName = UserDefaults.standard.string(forKey: "domain_name") else {
            print("getHistoryItemByID No cachedDomainName")
            return
        }
        
        guard let cachedDeviceID = UserDefaults.standard.string(forKey: "generated_device_id") else {
            print("getHistoryItemByID No cachedDeviceID")
            return
        }
        
//        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV2)/order/id/\(orderID)?device_id=\(cachedDeviceID)"
        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV2)/order/id/\(orderID)"
        
        
//        Constants.baseURLV2+"/order/id/\(orderID)/"
        createRequestWithToken2(with: URL(string: urlString), with: .GET) { baseRequest in
            
            print("getHistoryItemByID: \(baseRequest)")
            
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
//                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let result = try JSONDecoder().decode(HistoryItemByIDResponse.self, from: data)
//                    print("getHistory", result)
                    completion(.success(result))
                } catch {
//                    print("getJeevesProducts: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    
    
    public func voidOrder(with orderID: Int, completion: @escaping(Bool) -> Void) {
        
        guard let cachedDomainName = UserDefaults.standard.string(forKey: "domain_name") else {
            print("voidOrder No cachedDomainName")
            return
        }
        
        guard let cachedDeviceID = UserDefaults.standard.string(forKey: "generated_device_id") else {
            print("voidOrder No cachedDeviceID")
            return
        }
        
//        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV3)/orders/\(orderID)?device_id=\(cachedDeviceID)"
        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsWCV3)/orders/\(orderID)"
        
        
//        Constants.voidOrder + "\(orderID)"
        createRequestWithToken2(with: URL(string: urlString), with: .POST) { baseRequest in
            
            print("POST void URL: ", baseRequest)
            
            var request = baseRequest
            let voidOrderBody = VoidOrderModel(status: "cancelled")
            let jsonData = try! JSONEncoder().encode(voidOrderBody)
            request.httpBody = jsonData
            
            // create post voidOrder
            request.setValue("\(String(describing: jsonData.count))", forHTTPHeaderField: "Content-Length")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            print("voidOrder httpBody: ", voidOrderBody)
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil
                else {
                    completion(false)
                    return
                }
                do {
                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    print("voidOrder success with result: \(result)")
                    completion(true)
                } catch {
                    print("voidOrder failed: \(error.localizedDescription)")
                    completion(false)
                }
            }
            task.resume()
        }
    }
    
    /// most recent order ID from API
    public func getMostRecentOrderID(completion: @escaping(Result<LastOrderResponse, Error>) -> Void) {
        
        guard let cachedDomainName = UserDefaults.standard.string(forKey: "domain_name") else {
            print("getMostRecentOrderID No cachedDomainName")
            return
        }
        
        guard let cachedDeviceID = UserDefaults.standard.string(forKey: "generated_device_id") else {
            print("getMostRecentOrderID No cachedDeviceID")
            return
        }
        
//        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/lastorder?device_id=\(cachedDeviceID)"
        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/lastorder"
        
        print("getMostRecentOrderID urlString: \(urlString)")
        
        //Constants.baseURL+"/lastorder"
        createRequestWithToken2(with: URL(string: urlString), with: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
//                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let result = try JSONDecoder().decode(LastOrderResponse.self, from: data)
                    print("getMostRecentOrderID result: ", result)
                    completion(.success(result))
                } catch {
//                    print("getMostRecentOrderID: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    
    /// getSurcharges
    public func getSurcharges(completion: @escaping(Result<[SurchargeData], Error>) -> Void) {
        
        guard let cachedDomainName = UserDefaults.standard.string(forKey: "domain_name") else {
            print("getSurcharges No cachedDomainName")
            return
        }
        
        guard let cachedDeviceID = UserDefaults.standard.string(forKey: "generated_device_id") else {
            print("getSurcharges No cachedDeviceID")
            return
        }
        
//        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/surcharges?device_id=\(cachedDeviceID)"
        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/surcharges"
        
        print("getSurcharges urlString: \(urlString)")
        
//        createRequestWithToken2(with: URL(string: urlString), with: .GET) { baseRequest in
        createRequest(with: URL(string: urlString), with: .GET) { baseRequest in
            
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
//                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let result = try JSONDecoder().decode(SurchargeResponse.self, from: data)
                    print("getSurcharges data: ", result.data)
                    completion(.success(result.data))
                } catch {
                    print("getSurcharges error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    
    
    /// getSurcharges
    public func getCoupons(completion: @escaping(Result<[CouponData], Error>) -> Void) {
        
        guard let cachedDomainName = UserDefaults.standard.string(forKey: "domain_name") else {
            print("getCoupons No cachedDomainName")
            return
        }
        
        guard let cachedDeviceID = UserDefaults.standard.string(forKey: "generated_device_id") else {
            print("getCoupons No cachedDeviceID")
            return
        }
        
//        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/coupons?device_id=\(cachedDeviceID)"
        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/coupons"
        
        print("getCoupons urlString: \(urlString)")
        
//        createRequestWithToken2(with: URL(string: urlString), with: .GET) { baseRequest in
            createRequest(with: URL(string: urlString), with: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
//                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let result = try JSONDecoder().decode(CouponsResponse.self, from: data)
                    print(result.data)
                    completion(.success(result.data))
                } catch {
//                    print("getMostRecentOrderID: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    
    public func getDemo(completion: @escaping(Result<DemoData, Error>) -> Void) {
        guard let cachedDomainName = UserDefaults.standard.string(forKey: "domain_name") else {
            print("getMenuCategories No cachedDomainName")
            return
        }
    
//        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/products/categories?device_id=\(cachedDeviceID)"
        let urlString = "\(Constants.https)\(cachedDomainName)\(Constants.httpsAuthV1)/demo/ios"
        //https://alyx.codedisruptors.com/demofranchise/wp-json/jwt-auth/v1/jeeves/demo/ios
        
        print("getDemo urlString: \(urlString)")
        
//        createRequestWithToken2(with: URL(string: urlString), with: .GET) { baseRequest in
        createRequest(with: URL(string: urlString), with: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
//                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let result = try JSONDecoder().decode(DemoResponse.self, from: data)
                    print("getDemo Response: \(result)")
                    completion(.success(result.data))
                } catch {
                    print("getDemo: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    
    
// MARK: - FAKE APICALLs
    
    public func getNewShifts(completion: @escaping(Result<NewEmployeeShiftsResponse, Error>) -> Void) {
        let url = "https://raw.githubusercontent.com/jervygu/jeeves-test-api/master/shifts_new.json"
        let task = URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(.failure(APIError.failedToGetData))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(NewEmployeeShiftsResponse.self, from: data)
//                print("getNewShifts: \(result.shifts)")
                completion(.success(result))
            } catch {
                print("getNewShifts from Caller: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task.resume()
        
        
//        let task = URLSession.shared.dataTask(with: Constants.testShifts!) { data, _, error in
//            guard let data = data, error == nil else {
//                completion(.failure(APIError.failedToGetData))
//                return
//            }
//            do {
////                let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
//                let result = try JSONDecoder().decode(ShiftsResponse.self, from: data)
////                print(result)
//                completion(.success(result))
//            } catch {
//                print("getShifts from Caller: \(error.localizedDescription)")
//                completion(.failure(error))
//            }
//        }
//        task.resume()
    }
    
    public func getShifts(completion: @escaping(Result<ShiftsResponse, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: Constants.testShifts!) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(APIError.failedToGetData))
                return
            }
            do {
//                let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                let result = try JSONDecoder().decode(ShiftsResponse.self, from: data)
//                print(result)
                completion(.success(result))
            } catch {
                print("getShifts from Caller: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    public func getCategory(completion: @escaping(Result<FakeCategoryResponse, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: Constants.testCategories!) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(APIError.failedToGetData))
                return
            }
            do {
//                let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                let result = try JSONDecoder().decode(FakeCategoryResponse.self, from: data)
                //                    print(result)
                completion(.success(result))
            } catch {
                print("getCategory from Caller: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    public func getProducts(completion: @escaping(Result<FakeProductResponse, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: Constants.testProducts!) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(APIError.failedToGetData))
                return
            }
            do {
//                let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                let result = try JSONDecoder().decode(FakeProductResponse.self, from: data)
//                print(result)
                completion(.success(result))
            } catch {
                print("getProducts from Caller: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    public func getQueue(completion: @escaping(Result<FakeQueueResponse, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: Constants.testQueue!) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(APIError.failedToGetData))
                return
            }
            do {
//                let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                let result = try JSONDecoder().decode(FakeQueueResponse.self, from: data)
//                print(result)
                completion(.success(result))
            } catch {
                print("getQueue from Caller: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    
    public func getQueueOrders(completion: @escaping(Result<FakeQueue, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: Constants.testQueueOrders!) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(APIError.failedToGetData))
                return
            }
            do {
//                let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                let result = try JSONDecoder().decode(FakeQueue.self, from: data)
//                print(result)
                completion(.success(result))
            } catch {
                print("getQueueOrders from Caller: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    public func getCartData(completion: @escaping(Result<CartData, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: Constants.testCartData!) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(APIError.failedToGetData))
                return
            }
            do {
//                let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                let result = try JSONDecoder().decode(CartData.self, from: data)
//                print(result)
                completion(.success(result))
            } catch {
                print("getCartData from Caller: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    public func search(with query: String, completion: @escaping(Result<FakeQueue, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: Constants.testQueueOrders!) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(APIError.failedToGetData))
                return
            }
            do {
//                let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                let result = try JSONDecoder().decode(FakeQueue.self, from: data)
//                print(result)
                completion(.success(result))
            } catch {
                print("search from Caller: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    public func getSchedules(completion: @escaping(Result<Schedule, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: Constants.testScheduleData!) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(APIError.failedToGetData))
                return
            }
            do {
//                let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                let result = try JSONDecoder().decode(Schedule.self, from: data)
//                print(result)
                completion(.success(result))
            } catch {
                print("getSchedules from Caller: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    public func getWeapons(completion: @escaping(Result<APIResponse, Error>) -> Void) {
        guard let url = Constants.testUrl else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(.failure(APIError.failedToGetData))
                return
            }
            do {
                let result = try JSONDecoder().decode(APIResponse.self, from: data)
                print(result)
                completion(.success(result))
            } catch {
                print("UserProfile: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

// MARK: - Private

extension APICaller {
    enum HTTPMethod: String {
        case GET
        case POST
        case PUT
        case DELETE
        case PATCH
    }
    
    // escaping completion block when we have to use closures inside our methods, and its going to be asynchronous
    /// URLRequest with Authorization header
    private func createRequestWithToken2(with url: URL?, with type: HTTPMethod, completion: @escaping(URLRequest) -> Void) {
        
        guard let token = UserDefaults.standard.string(forKey: Constants.access_token2),
              let apiURL = url else {
            print("createRequestWithToken2, access_token2 is nil or url")
            return
        }
        
        var request = URLRequest(url: apiURL)
        // set value for Authorization header
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = type.rawValue
        request.timeoutInterval = 60
        completion(request)
    }
    
    private func createRequest(with url: URL?, with type: HTTPMethod, completion: @escaping(URLRequest) -> Void) {
        
        guard let token = UserDefaults.standard.string(forKey: Constants.access_token),
              let apiURL = url else {
            print("createRequest access_token is nil or url")
            return
        }
        
        var request = URLRequest(url: apiURL)
        // set value for Authorization header
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = type.rawValue
        request.timeoutInterval = 60
        completion(request)
    }
}


/// How to make HTTP Post request with JSON body in Swift
/// prepare json data
//let json: [String: Any] = ["title": "ABC",
//                           "dict": ["1":"First", "2":"Second"]]
//
//let jsonData = try? JSONSerialization.data(withJSONObject: json)
//
//// create post request
//let url = URL(string: "http://httpbin.org/post")!
//var request = URLRequest(url: url)
//request.httpMethod = "POST"
//
//// insert json data to the request
//request.httpBody = jsonData
//
//let task = URLSession.shared.dataTask(with: request) { data, response, error in
//    guard let data = data, error == nil else {
//        print(error?.localizedDescription ?? "No data")
//        return
//    }
//    let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
//    if let responseJSON = responseJSON as? [String: Any] {
//        print(responseJSON)
//    }
//}
//task.resume()
//




