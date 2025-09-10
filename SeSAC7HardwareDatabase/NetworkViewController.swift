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
        callRequest()
        
        
        navigationItem.title = "로또 결과"
    }
    
    func callRequest() {
        
/*
        // 1. shared 2. dataTask 3. completionHandler(클로저) : shared라서 컴플리션핸들러밖에 없
 
 
 
 
 // shared만 싱글턴 패턴으로 만들어져 있어서
        URLSession.shared.dataTask(with: <#T##URLRequest#>)
 
 // 그래서 shared를 제외한 나머지 3개만 이니셜라이즈로 뜨는것
        URLSession(configuration: .default).dataTask(with: <#T##URLRequest#>)
        
 // 그래서 위 두개는 같은 "일반모드"로 같은 뜻이다
 
 
 
 
 
 
 
        // ex. 카톡 이미지 30장 다운로드 중에 중간 과정을 알고 싶을 때
        URLSession(configuration: .default, delegate: self, delegateQueue: .main)
*/
        
        
        
        let url = URL(string: "https://www.dhlottery.co.kr/common.do?method=getLottoNumber&drwNo=1150")!
        let resquest = URLRequest(url: url,
                                  cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                  timeoutInterval: 5) // 5초가 지나도 응답이 없으면 실패로 하겠다
        
        // 로또 API 호출해보자
        // URLSession이라는 클래스 안에 네트워크와 관련된 모든것들이 다 들어있다! : 가장 많이 사용하는 형태는 : shared
        URLSession.shared.dataTask(with: resquest) { data, response, error in
            
            
            
            // DispatchQueue.main.async가 3군데나 반복되는 형태를 개선: 애초에 클로저문 전체를 메인으로 다 돌려버리는 사람도 있다
            DispatchQueue.main.async {
                
                
                
                
                
                
                print(data)
                print(response)
                print(error)
                // data, response, error 3개 다 옵셔널타입이라 옵셔널 처리를 해줘야
                
                if let error = error {
                    // 에러가 있다면 문제가 생긴 상황
                    
//                    DispatchQueue.main.async {
                        print("오류가 발생했다")
//                    }
                    
                    return // 함수 종료가 필요
                }
                // 아래는 에러가 nil이면 통신이 성공했다고 볼 수 있는 상태
                guard let response = response as? HTTPURLResponse,
                      response.statusCode == 200 else {
                    // 상태코드가 200이 아니면
                    
  //                  DispatchQueue.main.async {
                        print("상태코드 오류가 발생했다") // 얼럿을 띄워준다면 ui관련이라 메인에서 돌려야 하니 메인스레드가 필요
 //                   }
                    
                    return
                }
                // 상태코드가 200이면 : 원하는 데이터가 잘 온 것 : 이 데이터에서 내용을 꺼내줘야 : decodable로 담아서 알라모가 해주던걸 우리가 수동으로 해줘야
                if let data = data {
                    
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
            
        }.resume() //resume()가 없으면 네트워크 요청이 서버한테 가지 않음: 트리거(인섬니아에서 send 버튼 누르는 것처럼)
        
    }
}

// 경우에 따라 DownloadDelegate 를 쓰면 되겠다~ 하고 각자의 상황별로 판단하면 됨
//extension NetworkViewController: URLSessionDownloadDelegate {
//
//    
//}
