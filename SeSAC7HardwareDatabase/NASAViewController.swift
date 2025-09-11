//
//  NASAViewController.swift
//  SeSAC7HardwareDatabase
//
//  Created by 박현진 on 9/11/25.
//

import UIKit


// 고해상도 이미지 가져오는 열거형 : 로드되는데 꽤 시간이 걸리는 데이터 : 컴플리션 핸들러 사용해서 얼마나 오래 걸리는지 확인
enum Nasa: String, CaseIterable {
        
        static let baseURL = "https://apod.nasa.gov/apod/image/"
    
    // https://apod.nasa.gov/apod/image/2308/sombrero_spitzer_3000.jpg
        
        case one = "2308/sombrero_spitzer_3000.jpg"
        case two = "2212/NGC1365-CDK24-CDK17.jpg"
        case three = "2307/M64Hubble.jpg"
        case four = "2306/BeyondEarth_Unknown_3000.jpg"
        case five = "2307/NGC6559_Block_1311.jpg"
        case six = "2304/OlympusMons_MarsExpress_6000.jpg"
        case seven = "2305/pia23122c-16.jpg"
        case eight = "2308/SunMonster_Wenz_960.jpg"
        case nine = "2307/AldrinVisor_Apollo11_4096.jpg"
         
        static var photo: URL {
            return URL(string: Nasa.baseURL + Nasa.allCases.randomElement()!.rawValue)!
        }
    }



class NASAViewController: UIViewController {
    
    var total: Double = 0 // 총 이미지의 크기를 프로퍼티로 담아둬야 사용자에게 보여줄 퍼센트 계산이 가능하겠다~

    var buffer = Data() // 처음에는 빈 데이터타입으로 만들어서~ : didReceive에서 계속 덧데어서 이미지를 만들어 나가야함
    
    let imageView = UIImageView()
    
    var session: URLSession! // URLSession을 프로퍼티로 갖고 있을 필요가 있다 : 옵셔널 처리 안해도 되게끔 !를 사용
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.size.equalTo(200)
            make.center.equalTo(view)
        }
        imageView.backgroundColor = .lightGray

//        callResquest()
        callRequsetDelegate()
        
    }
    
    
    
    
    // 화면이 완벽하게 사라질때 호출되는 이 viewDidDisappear 메서드를 쓰는 이유 : 화면전환을 하고 고용량 이미지가 뜨는 상황에서 사용자가 이미지를 다 받지도 않았는데 다시 전화면으로 돌아가버렸다면 이때도 이미디를 다 받아야 되나 일시정지를 해야하나
    
    // 화면이 사라질때, 화면 전환 할때, 앱을 종료하거나 뷰가 사라질 때
    // 네트워크와 관련된 리소스 정리가 필요!
    // ex. 다운로드 중에 뒤로 가기를 누르면 계속 받아야 할까 취소해야 할까 일시정지 해야할까
    // 이런 예외케이스를 잘 처리 하는게 시니어와 주니어 개발자의 차이 : 사실 코드는 시니어나 주니어나 나중엔 비슷해지기 마련
    // ex. 카톡방에서 30장 이미지를 받는 중인데 중요한 푸쉬 알림이 와서 다른 톡방을 열어버린다면? : 때에 따라 다르지만 : 이런 시스템적인 부분은 개발자가 고민해야하는 부분 : 그래서 두가지 메서드를 소개해 주겠다~
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // 유효화하고 취소한다의 의미는: 다운로드 중인 리소스도 무시하고 화면이 사라진다면 네트워크 통신도 함께 중단해버리겠다
//        URLSession().invalidateAndCancel()
        session.invalidateAndCancel() //  session.어쩌구로 바꾸면 그럼 경고가 안 뜸 : 어딘가에서 담고서 사용해야 닐처리도 하고 등등~: 아래에 코드들 중에서도 "URLSession.~" 되어있는 형태들을 다 "session.~"로 변경하자~
        
        // 다운로드가 완료될때까지 기다렸다가, 다운로드가 완료되면 리소스를 정리
//        URLSession().finishTasksAndInvalidate()
        session.finishTasksAndInvalidate()

        
        
    }
    
    
    
    
    
    func callRequsetDelegate() {
        print(#function)
        
        URLSession(configuration: .default, delegate: self, delegateQueue: .main).dataTask(with: Nasa.photo).resume() // main : 보라색 에러 방지
        // URLSessionDataDelegate를 채택해달라는 에러 발생
        
//        URLSession.shared.dataTask(with: Nasa.photo).resume() // 컴플리션핸들러가 없는 dataTask를 쓰면 컴플리션핸들러로 안받겠다는 뜻: 근데 shared는 딜리게이트를 못받으니~ 바꿔보자 : 일반모드 default에서는 딜리게이트를 받을 수 있으니 윗줄에 상수로 받아서 default를 사용해보자~
        
        
    }
    
    func callResquest() {
        print(#function)
        
        // Nasa.photo에서 url 꺼내오기
        URLSession.shared.dataTask(with: Nasa.photo) { data, response, error in

            
            // 컴플리션핸들러가 백프로 완료되기 전까지는 신호를 받지 못함
            // 백프로 완료되고 나서 단 한번만 클로저 실행
            // 100mb를 10초동안 받는다는 가정 하에, 9.9s가지 어떤 신호도 못받음
            print("NASA >>>>>>>>>>>> ", data) // 로드하는데 오래 걸리는 대용량 이미지를 가져올 때는 언제쯤 실행이 되는지만 확인해보자
            // print(#function)이후에 2,3뒤에 옴 : 조각별로 쪼개서 넘겨줌: 한번만 호출했는데 그래프가 여러번 호출된느낌으로 온 이유 : 조각들이 다와야 컴플리션 핸들러가 작동하는 형태 : 유저 입장에서는 로딩이 오래걸리니까 불편
            
        }.resume()
        
    }
    
}

extension NASAViewController: URLSessionDataDelegate {
    
    // 여기서 response담당 메서드 하나, data담당 메서드 하나, error담당 메서드 하나 이런식으로 쓰임
    
    //1. 서버에서 최초로 응답 받은 경우에 호출( 상태코드에 대한 확인을 하는 메서드 : 그래서 response가 매개변수로 있음 )
    func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        print("111111")
        dump(response) // "Content-Length"로 완성 이미지 크기를 미리 알려줌!
        
        if let response = response as? HTTPURLResponse, response.statusCode == 200 { // 200이면 데이터를 받을 수 있도록 컴플리션핸들러를 허용해주는 조건문 필요
            
            // 총 데이터의 양 얻기
            let contentLength = response.value(forHTTPHeaderField: "Content-Length")!
            print("내가 앞으로 받을 총 데이터 >>>>>> ", contentLength) // print("다 합친 바이트 : ", buffer) 맨 마지막 이 크기와 여기 크기가 같다면 유실없이 잘 왔다는 뜻
            total = Double(contentLength)!
            
            completionHandler(.allow)
        } else { // 문제생겨서 컴플리션핸들러로 데이터를 안받아도됨
            
            completionHandler(.cancel)
        }
        
        
        
    }
    
    //2. 서버에서 데이터를 받아올 때마다 반복적으로 호출: 실질적으로 내가 쓸 데이터: 그래서 매개변수에 data가 있음
    func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    didReceive data: Data) {
        
        print("222222 : ", data) // 쪼개서 오는 이미지 조각들을 다 append로 합쳐줘야 함: 바이트를 싹 다 합치면 원래의 크기 나옴 : 이 쪼개서 오는 조각들을 "패킷"이라고 함
        // 쪼개서 오니까 사용자한테 데이터가 잘 오고 있느지 레이블에 실시간으로 보여줄 수 있겠다~ 네비게이션 타이틀에
//        navigationItem.title = "\(buffer)" // 사용자에겐 퍼센트로 보여주면 좋겠다~ : 그럼 처음부터 100프로 받았을 때으 최종 크기를 미리 알고 있어야 퍼센트 계산이 가능하단 얘기: 이걸 어디서 확인할 수 있나 : 위에 didReceive에서 dump로 상태코드외에 response가 어떻게오는지 확인해 보면 먼저 알 수 있다! :"Content-Length"
        
        
        // 한번에 다 받을 수 없으니 쪼개서 받을것을 다 합쳐줘야 하나의 이미지가 로드
        buffer.append(data)
        
        
        let result = Double(buffer.count) / total
        navigationItem.title = "\(result * 100)% / 100%" // 사용자에게 퍼센트로 보여주기~
    }
    
    //3. 오류가 발생했거나 응답이 완료가 될 때 호출(100프로 완료되서 : 보통 이미지뷰에 이미지를 띄우는 코드를 여기서 작성)
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: (any Error)?) {
        
        print("333333 : ", error)
        print("다 합친 바이트 : ", buffer) // 합친거 확인: 이미지가 완성되면 이미지뷰에 띄울 수 있으니 여기서 이미지뷰에서 띄우자
        
        imageView.image = UIImage(data: buffer) // UIImage(data: <#T##Data#>)로 애플이 데이터로 받아온 이미지를 띄울 수 있게 제공해줌
        
    }
    
}


