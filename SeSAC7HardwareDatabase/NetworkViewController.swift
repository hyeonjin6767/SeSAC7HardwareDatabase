//
//  NetworkViewController.swift
//  SeSAC7HardwareDatabase
//
//  Created by 박현진 on 9/10/25.
//

import UIKit

/*
 
 
 Alamofire를 쓸 수 있는 이유는 Alamofire의 내부에 URLSession가 맵핑이 되어있기 때문이다!
 
 
 
 
 
 
 " URLSession " : 나중에 사용할 때 어떤것들을 변경하면 사용해야 하는지 3가지로 나눌 수 있어
 
 " 네트워크 통신을 할 때 어떤 것들을 잘 해줘야 하나 "
 
 1.  네트워크 통신전에 "환경설정"이 중요 : "Configuration" : ex) 웹 사용시 일반 모드, 시크릿 모드 , 백그라운드 모드(앱을 사용하지 않는 환경에서도(=백그라운드에서도) 다운로드 받을 수 있는)
 :  시크릿모드같은 보안적으로 매우 중요할 때 시크릿모드 처럼 숨겨서 통신을 할건지 3가지 중에 어떤 스타일로 통신을 할건지 네트워크 요청 전에 필요한 준비에서 셋팅
 총 4가지: shared(일반모드: 가장 기본), dafault(일반모드), ephemeral(시크릿모드), background(백그라운드모드) : 앱의 성격에 따라 판단 가능
 
 2. "요청하는 데이터"에 따라 종류가 달라 : "Task" : 요청한 데이터의 전달방식(post, get , host, delete 등등 같은 성격이라고 생각하면 쉬워)에 따라 결정
 종류가 많은데 : data Task, upload task, download task, stream task 등등
 
 3. 응답(response를 "어떻게" 받을지) : completionHandler(클로저)(100퍼센트 다왔을때 단 1번만 응답) 혹은, delegate(중간과정을 알고 싶을 때 몇퍼센트 정도 왔다 알고 싶을 때 ex.ott영상 몇 회차까지 받았나) 둘 중 하나로 받을 수 있음
 
 
 
 
 ex1. 영화 검색 api 조회: get요청, json으로 간단하게 응답이 오는 : 일반적인 환경설정에 간단하 데이터 요청에다가 응답도 한번에 바로 올꺼니까 ~
 : 일반모드(shared,dafault 둘중 하나) + dataTask + completionHandler
 ex2. 카톡 이미지 30장 그룹으로 다운로드 하고 싶다 : 원본이라 크로 몇장 받았는지 중간과정을 알 수 있어야 하는
 : 일반모드(shared,dafault 둘중 하나)or 너무 고해상도면 background로 쓸가나  + downloadTask + delegate
 ex3. 넷플릭스 선덕여왕 50,60부작 전체 다운로드 : 엄청난 용량
 : background + downloadTask + delegate
 
 
 
 cf) 왜 일반모드는 shared와 default 두개인가? : 차이점이 존재 : shared(중간지점을 받을 수 없: completionHandler 밖에 못써): default(중간과정 받을 수 있: Delegate 사용가능)
 
 
 여태 1.  2. data task 3. completionHandler 로 Alamofire를 사용하고 있었음~
 
 
 
 */

struct Lotto: Decodable {
    let drwNoDate: String
    let drwtNo1: Int
}

class NetworkViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
//        callRequest()
        callLotto() 
        
        
        navigationItem.title = "로또 결과"
        
    }
    
    
    func callLotto() {
        
        let url = URL(string: "https://www.dhlottery.co.kr/common.do?method=getLottoNumber&drwNo=1150")!

        // URLrequest 자리에 그냥 바로 url 들어가도 괜춘
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard error == nil else {
                
                print("Failed Request")
                
                return
            }
            
            guard let data = data else {
                
                print("No Data Request")
                
                return
            }
            
            guard let response = response as? HTTPURLResponse else { // HTTPURLResponse로 응답을 받아왔을때 이상이 없는지 체크
                
                print("Unable Response")
                
                return
            }
            guard response.statusCode == 200 else {
                
                print("Status Code Error")
                
                return
            }
            // 위에 가드문 다 무사 통과시
            print("이제 식판에 담을 수 있는 상태!")
            
            do {
                let result = try JSONDecoder().decode(Lotto.self, from: data)
                
                print("sucess : ", result)
            } catch {
                print("error")
            }
            
        }.resume()
        
    }
    
    
    
    
    
    func callRequest() {
        
/*
        // 1. shared 2. dataTask 3. completionHandler(클로저) : shared라서 컴플리션핸들러밖에 안되니까
 
 
 
 
 // shared만 싱글턴 패턴으로 만들어져 있어서
        URLSession.shared.dataTask(with: <#T##URLRequest#>)
 
 // 그래서 shared를 제외한 나머지 3개만 이니셜라이즈로 뜨는것
        URLSession(configuration: .default).dataTask(with: <#T##URLRequest#>)
        
 // 그래서 위 두개는 같은 "일반모드"로서 같은 뜻이다
 
 
 
 
 
 
        // ex. 카톡 이미지 30장 다운로드 중에 중간 과정을 알고 싶을 때
 // 큰 골자로 이렇게 알고 있자~
        URLSession(configuration: .default, delegate: self, delegateQueue: .main) // delegateQueue는 ui적인 업데이트를 하다보니까 메인에서 쓰겠다

 
 
*/
        
        
        // 로또 API 호출해보자
        let url = URL(string: "https://www.dhlottery.co.kr/common.do?method=getLottoNumber&drwNo=1150")!
        
        let resquest = URLRequest(url: url,
                                  cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, // 캐싱 관련 정책: 캐시를 무시를 할건지 쓸건지
                                  timeoutInterval: 5) // 5초가 지나도 응답이 없으면 실패로 하겠다
        
        
        // URLSession이라는 클래스 안에 네트워크와 관련된 모든것들이 다 들어있다! : 가장 많이 사용하는 형태는 : shared
        URLSession.shared.dataTask(with: resquest) { data, response, error in
            
            
            
            // DispatchQueue.main.async가 3군데나 반복되는 형태를 개선: 애초에 클로저문 전체를 메인으로 다 돌려버리는 사람도 있다
            DispatchQueue.main.async {
                
                
                
                
                print(data)
                print(response)
                print(error)
                // Alamofire에서 response를 switch문을 통해서 성공/실패를 나눠서 사용해왔었던것을 : 여기 URLSeeeion 기준으로 따져보면은
                // 여기선 data가 성공시 데이터, error는 실패시, 가운데 response는 : Alamofire에서 response.response?.statusCode 이런식으로 접근이 가능했던 이유는 response안에 response라는 프로퍼티가 들어있어서 그랬던것 : 여기서 두번째에 있는 response라는 프로퍼티가 여기에서의 response를 뜻한다!
                
                
                
                
                
                // data, response, error 3개 전부 옵셔널타입이라 옵셔널 처리를 해줘야~
                
                if let error = error { // 에러가 있다면 문제가 생긴 상황
                    
                    
//                    DispatchQueue.main.async {
                        print("오류가 발생했다")
//                    }
                    
                    return // 문제가 생긴 상황이라 함수 종료가 필요
                }
                // 아래는 에러가 nil이면 통신이 성공했다고 볼 수 있는 상태 : 그 다음은 상태코드 확인이 필요 : 왜냐 문제가 발생했어도 에러메세지 같은 구조체가 올 수 있으니까
                guard let response = response as? HTTPURLResponse, // 응답을 HTTPURLResponse로 타입캐스팅해가지고 닐인지 체크해야 오류코드번호를 확인 가능
                      response.statusCode == 200 else { // 상태코드가 200이 아니면 실패이니까
                    
  //                  DispatchQueue.main.async {
                        print("상태코드 오류가 발생했다") // 얼럿을 띄워준다면 ui관련이라 메인에서 돌려야 하니 메인스레드가 필요
 //                   }
                    
                    return
                }
                // 아래는 상태코드가 200인 상황 : 원하는 데이터가 잘 온 것 : data를 통해 내용을 꺼내줘야 : decodable로 담아서 구조체로 바꾸어주는 과정을 Alamofire에서는 responseDecoddable(of: 구조체.self) 하던것을 : 우리가 수동으로 해줘야 함!
                if let data = data { // 데이터가 있다고 하면
                    
                    // 두트라이캐치를 안하고 프린트해보면 성공했는지 알기 어려워
                    //                let result = try? JSONDecoder().decode(Lotto.self, from: data)
                    //                print("result >>>>> ", result)
                    
                    //우선 디코딩을 해서 잘 담기면: 데이터를 구조체로 잘 바꿔주는 과정
                    do {
                        let result = try? JSONDecoder().decode(Lotto.self, from: data)
                        print("잘 담긴 데이터 확인 : ", result)
                        
                        // 또 보라색 에러
  //                      DispatchQueue.main.async {
                            self.navigationItem.title = result?.drwNoDate // 네비게이션컨트롤러가 임베드 됐는지 확인해줘야 정상 작독하겠지
  //                      }
                        
                    }
                    catch {
                        print("디코딩 오류가 발생했다")
                    }
                }
                
                
                
                
            } // 전체 메인스레드 돌리는거의 중괄호
            
            
            
            
            
            
            
            // dataTask랑 shared 환경설정 준비를 해줬으니까 요청을 해주세요라고 해서 : Alamofire에서 썼던 AF.request 메서드 대신에 .resume()를 통해서 task를 요청을 해달라하는게 필요하다! : 없으면 서버에 요청이 안감!
        }.resume() // resume()가 없으면 네트워크 요청이 서버한테 가지 않음: 트리거 (인섬니아에서 send 버튼 누르는 것처럼) 역할: 달리기 준비땅(트리거)
        
    }
    
}

// URLSession(configuration: .default, delegate: self, delegateQueue: .main)에서 딜리게이트에는 뭐가 있나~ :  아래 예시

// 경우에 따라 DownloadDelegate 를 쓰면 되겠다~ 하고 각자의 상황별로 판단하면 됨
//extension NetworkViewController: URLSessionDownloadDelegate {
//
//    
//}
