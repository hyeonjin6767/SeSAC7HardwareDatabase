//
//  LocationViewController.swift
//  SeSAC7HardwareDatabase
//
//  Created by 박현진 on 9/9/25.
//

import UIKit
import SnapKit

// "프레임워크"의 기본 구조는 거의 동일 ex.카메라,블루투스,캘린더 등등 사용하려는 프레임워크들은 주로 import를 먼저 하고 관련된 "메니저"가 존재하며 기능들을 가지고 있는 프로토콜을 채택해서 사용하는 패턴들이 대부분 유사하다

import CoreLocation // 위치에 대한 // 1. 프레임워크 : import하고 관련 매니저가 존재: 기능들은 프로토콜에 들어있음
import MapKit

/*
 
 //MARK: - 위치 권한
 
 " 위치 권한 " : 면접시 질문
 
 Privacy & Authorization
 사용자 경험을 방해하지 않고 더 많은 통제권을 줄 수 있을까? : 유저가 피곤하지 않게끔
 
 ios12(약 5년전): "허용"과 "허용하지 안함" 2개뿐이었는데 : ios13부터 "한번만 허용"이 추가됨 : 14부턴 "정확한 위치" 추가 : 지금은 4가지..
 15부터 "위치 버튼" 추가: 화살표모양
 
 "권한 부여 상태"와 "정확도 값" 2가지 모두 확인 필요 : 아이폰에 "위치서비스" 자체가 켜져있는지도 확인 필요
 
 delegate
 swift concurrency
 
 코드로 짜보자: 플로우 이해 :import CoreLocation 필요
 
 
 */

class LocationViewController: UIViewController {

    let mapView = MKMapView()
    let button = UIButton()
    
    // 2. 위치 매니저 생성: 위치에 대한 대부분을 담당: 권한 허용, 위치 정보, 권한 거부, 변경하면 신호도 받아야 되고 할일이 많아..서 기능들을 다 프로토콜에 -> 3번
    lazy var locationManagger = CLLocationManager() // 앞의 CL은 import했던 CoreLocation 프레임워크의 prefix  // 필요한 시점에 생성이 되도록  lazy var로 변경
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        // 4. 프로토콜을 연결해주는 애 : 테이블뷰의 구조와 유사한 형태
        locationManagger.delegate = self
        
    }
    
    func configure() {
        view.backgroundColor = .white
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(50)
        }
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(button.snp.top)
        }
        button.backgroundColor = .systemRed
        button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
    }
    
    @objc func buttonClicked() {
        // 버튼 클릭시 권한을 띄워보고 싶다
        // 사용자가 아이폰 접근 전체를 막아두면 띄울 수 조차 없다: 그래서 먼저 뭐부터를 체크를 해야하냐면 아래 1번이 꼭 필요
        
        // 보라색 오류가 뜨는 이유: 권한 허용 체크는 메인에서 하면 안된다~
        // 우리가 다른 알바생에게 맡기는 이 행위: 워낙 앱이 바쁠 수 있으니까: 아이폰의 위치 권한을 확인하는 메서드는 백그라운드에서 진행을 해달라~
        DispatchQueue.global().async { // 글로벌 환경(백그라운드)에서 서비스가 잘 동작을 해서 권한 허용을 요청할 수 있는지 확인되면 그때서야 권한 얼럿을 띄우면됨
            
            // 1. ios 설정에 "위치 서비스" 활성화 여부부터 "먼저" 확인! : 이미 static 메서드로 정해져 있는데 조건문을 통해서 조회
            // 아까 위에서 만들어둔 locationManagger( 인스턴스 메서드에 접근하는 인스턴스)는 CLLocationManager클래스의 인스턴스이고 지금은 클래스 그 자체(타입 기준으로 접근하는 형태)를 가지고 와서~
            if CLLocationManager.locationServicesEnabled() { // 이 한줄로 ios 설정에 "위치 서비스"를 확인 : 뭘하든 항시 확인이 필요
                print("사용자가 위치 서비스를 켜놔서 권한 요청 가능한 상태")
                
                DispatchQueue.main.async { // 또 얼럿이 뜨는건 UI관련된거고 UI관련은 메인에서 띄워줘야 하니까 이건 메인에서 동작하게
                    self.checkCurrentLocationAuthorization()
                }
            } else {
                print("아이폰 위치 서비가 꺼져 있어서 위치 권한 요청을 할 수 없는 상태")
            }
        }
       
    }
    // 2. 현재 사용자 권한 상태 확인 후 얼럿 띄우기 : locationManagger하는 request를 하는 코드가 정해져 있음! : 항상 얼럿이 뜨는 것은 아님(사용자의 권한 허용 선택에 따라)
    func checkCurrentLocationAuthorization() {
        
        
        
        // 권한에 대한 상태를 분기처리할 수 있는 열거형?
        // requestWhenInUseAuthorization()가 얼럿을 띄워주는 역할인데 항상 띄워주는 것은 아니기 때문에 정렬이 필요 : 사용자의 선택에 따라 권한에 대한 여부를 확인(허용, 거부, 아직 결정X)하고 권한문구를 띄우도록 CLAuthorizationStatus(권한데 대한 상태를 분기처리할 수 있는 열거형) : 열거형의 case로 권한을 나누게 됨
        
        var status: CLAuthorizationStatus
        // 권한 문구 열거형 전에 ios14 기준에 따라서 체크할 수 있는 메서드가 달라서 조건문 추가~
        if #available(iOS 14.0, *) {
            status = locationManagger.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        
        switch status { // 많이 쓰이는 3개의 case에 대해서만 작성을 해보자
        case .notDetermined:
            print("주로 앱을 처음 실행시 거절도 안하고 허용도 안한 권한이 아직 결정되지 않은 상태로, 여기서만 권한 문구를 띄울 수 있음")
            
            
            
            // 권한을 요청하는 이 문구는 notDetermined 일때 즉, 아직 권한을 선택하지 않은 상태에서만 사용 가능
            locationManagger.requestWhenInUseAuthorization() // 어떤 권한을 띄울지 종류가 많은데 가장 많이 사용하는 권한 : "앱을 사용하는 동안(WhenInUse)"의 권한
            // Info 설정에서 Privacy - Location When In Use Usage Description 설정이 되어 있어야 권한 얼럿이 정상적으로 뜸!
            // 앱을 사용하는 동안 권한 상태 허용 체크: 사용자가 선택한거에 따라 항상 얼럿이 뜨는 것은 아님: // "한번 허용"이 테스트하기 좋아: 빌드시마다 계속 얼럿뜸

            
            
            // 정확도에 대한 : kCLLocationAccuracyNearestTenMeters : 사용자가 10미터 정도 이동했다 감지하면 didUpdateLocations를 호출
            locationManagger.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            
            
            
            
//        case .restricted: // 자녀 보호 모드 같은 사용자가 권한을 바꿀 수 없는 경우 :
//            <#code#>
        case .denied:
            print("사용자가 거부한 상황, ios 설정 창으로 이동하라는 얼럿 뛰우기") // 사용자가 이미 거부한 상태라 우리가 풀어줄 수가 없어서 사용자가 직접 설정창으로 가서 이동을 시켜주는 방법뿐

//        case .authorizedAlways: // 2개 나오는건 지워도되
//            <#code#>
//        case .authorizedAlways:
//            <#code#>
        case .authorizedWhenInUse:
            print("사용자가 허용한 상태이기 때문에 위치 정보를 얻어오는 로직을 구성할 수 있음") // 이미 허용이 되어있으면 권한을 허용해달라 할 필요가 없기 때문에
            
            
            
            // didUpdateLocations메서드를 실행시켜서 현재 위치의 위경도를 알려면~ startUpdatingLocation()메서드가 실행을 시켜달라고 해줘야 함!:
            locationManagger.startUpdatingLocation() // 이 실행 트리거가 없으면 위치 정보를 가져올 수 없음
            
            
            
            
            
//        case .authorized:
//            <#code#>
        default: print(status)
        }
     
    }
  
}
// 3. 위치 프로토콜 : 여러가지 기능을 담당 : 이 채택한 프로토콜을 누군가와 연결을 해줘야 하는데: 연결해주는 애가 매니저 얘: let locationManagger = CLLocationManager()
extension LocationViewController: CLLocationManagerDelegate { // CLLocationManagerDelegate에 있는 메서드들을 불러서 사용해보자~
    
    
    // 코드 구성에 따라 여러번 호출이 될 수 있다: kCLLocationAccuracyNearestTenMeters 같은 애 때문 : 러닝앱같은 경우 자주해도 오케이 : 날씨앱은 빈도가 낮겟지
    // didUpdateLocations : 사용자가 위치를 허용해서 필요한 시점에 성공적으로 위치를 조회한 경우
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(#function)
        print(locations.first?.coordinate) // locations의 0번 인덱스에 coordinate의 위도, 경도 값이 옴 :여기 이 메서드는 "실행시켜달라"는 메서드가 필요 :위에
        
        
        
        
        // 권한을 얻어와서 위치를 찾았을때 지도의 센터 맞춰주기
        let region = MKCoordinateRegion(center: locations.first!.coordinate,
                                        latitudinalMeters: 500,
                                        longitudinalMeters: 500) // 위경도, ,
        mapView.setRegion(region, animated: false) // animate는 줌되는 효과인데 어지러울 수 있어서 false
        
        // 매번 위치를 얻어올 필요가 없는 경우의 앱
        // start메서드를 썼으면, 더이상 위치를 얻어올 필요가 없는 시점에서는 stop을 해줘야 매번 위경도를 가져오지 않음: 사용자는 알 수 없지만 앱이 뜨거워지지 않음 : 상황에 따라 이 코드의 위치는 바뀔 수 있음
        locationManagger.stopUpdatingLocation()
        
        
        
    
    }
    
    
    // didFailWithError : 사용자가 권한을 거부해서 사용자의 위치 조회를 실패한 경우 : 보통 지도에 "현재위치 버튼"을 누르는 순간 사용자의 권한을 체크함 - 권한이 허용되고 있다하면 위에  didUpdateLocations 메서드가 실행이 되면서 현재 위치로 맵을 이동을 시켜줄 수 있고, 권한이 거부되어 있다면 현재위치 버튼 클릭시 권한 허용하겠냐는 얼럿이 뜸
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print(#function)
    }
    
    
    
    
    // 보통은 위치서비스가 다 켜져있을꺼라고 생각하지만.. 우리는 항상 예외의 1%를 생각해야 하기 때문에..
    // 지도가 켜진 상태에서 설정에 들어가서 위치를 꺼버리는 특이한 경우도 있어서 아래 꽤 자주 사용하게 되는 메서드들이 있다!
    // 즉, 앱을 사용하는 도중에 권한이 바뀐 경우를 체크하기 위해서 아래 메서드가 필요하다! - 사용하는 도중에 권한을 허용하지 않으면 얼럿이 잘뜨는가~

    
    
    
    
    // 권한이 변경이 되었을 때 사용하는 메서드 : 아래 2개 같은 기능인데 버전에 따라 메서드가 다름
    // (ios 14 미만)
    // 사용자 권한 상태가 변경된 경우
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(#function)
    }
    
    // (ios 14 이상) : 이게 프린트됨 근데........................
    // 사용자 권한 상태가 변경된 경우
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print(#function)
        // 빌드 하자마자 버튼을 누르지 않았는데도 실행됨 :
        // 빌드시 처음 생성될때(인스턴스)도 실행이 되는 특징이 있어서 시작부터 프린트됨 : 근데 // 네비게이션 컨트롤러를 임베드 하니까 빌드시 실행이 바로 실행이 안됨: 단독으로 뷰컨 실행시에는 바로 실행됨...: 이유는? :  CLLocationManager를 lazy var로 바꾸니까 또 실행됨..:
        
        
        // 다시 실행: 흐름 주의!!!!!
        buttonClicked() // 사용자가 권한을 선택(사용자 권한 상태가 변경된 경우)하게 되면 "다시" 권한을 체크해주는 메서드를 "싹 다 다시" 실행을 해줘야 하기 때문에 : 흐름 중요! 복잡 주의
        
    }
    
}
