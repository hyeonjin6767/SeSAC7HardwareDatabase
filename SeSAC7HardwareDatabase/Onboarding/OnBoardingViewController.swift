//
//  OnBoardingViewController.swift
//  SeSAC7HardwareDatabase
//
//  Created by 박현진 on 9/8/25.
//

import UIKit

class FirstViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemYellow
    }
}
class SecondViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .purple
    }
}
class ThirdViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .brown
    }
}

// 뷰컨의 종류다 가정하고
// 멤버와 값을 분리 하는 복습을 해보자: rawValue, CaseIterable이라는 프로토콜
private enum Onboarding: Int {
    case first = 0
    case second
    case third
    // 이것도 여기서만 쓰인다면 private 습관
}

class OnBoardingViewController: UIPageViewController {

    
    private var list: [UIViewController] = []     // 이것도 여기서만 쓰인다면 private 습관

    
    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        // 책넘기는 애니메이션이 기본값 : 변경가능
        super .init(transitionStyle: .scroll, navigationOrientation: .horizontal) // 디폴트 : .pageCurl , .vertical
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        // Optional도 열거형으로 이루어져 있음.. : 면접 단골 질문
        // @frozen 이라는 키워드가 내부 정의에 들어가 있음 : 이건 @unknown default가 안나옴..: frozen Enum: 절대로 앞으로 멤버가 달라질 일이 없는 애는 @frozen(성능 최적화)이 붙어있음: 우리가 개인이 쓰는건 크게 의미 없고 오픈소스로 사용할 거 정도는 활용하면 좋지만 우린 굳이 안써도됨 // 겨울왕국 인투디 언논
//        let c = Optional. // 얘는 @unknown default 경고 메세지 안뜸
        
        
        // 글자 aligment
//        let b = NSTextAlignment.center // 이것도 자체적으로 열거형으로 만들어져 있음
//        switch b {
//        case .left:
//            <#code#>
//        case .center:
//            <#code#>
//        case .right:
//            <#code#>
//        case .right:
//            <#code#>
//        case .center:
//            <#code#>
//        case .justified:
//            <#code#>
//        case .natural:
//            <#code#>
//            // @unknown : 멤버가 추가될 가능성이 있는 열거형 : unfrozen Enum(라이브러리나 프레임워크에서 주로 볼 수있음)
//        @unknown default: // 추후에 새로운 케이스가 생길수도 있어서 그 케이스가 있을때 이 코드 실행시 문제가 발생할 수 있으니 미리 대비해서 작성해두라고 알려주는 경고
//            fatalError()
//        }
        
        
//        let a = Onboarding.first
//        switch a {
//        case .first:
//            <#code#>
//        case .second:
//            <#code#>
//        case .third:
//            <#code#>
//        }
//        
//        
        
        
        view.backgroundColor = .systemPink // 화면 아래 쩜쩜쩜 배경색과 동일하게 됨
        
        
        // 페이지뷰컨인 내자신의 대한 델리게이트
        delegate = self
        dataSource = self
        
        list = [FirstViewController(), SecondViewController(), ThirdViewController()] // 지금은 3개로 설정했지만 이것도 재사용 구조로 바꿀 수도 있음
        
        // 배열을 세팅해달라 : 뷰컨 담아둔 베열
        // setViewControllers : 처음에 시작할 부분을 담당하는 애라 리스트의 첫번째가 있는지 확인하고 "배열"로
        guard let first = list.first else { return } // list[0]와 같은 의미 : list.first 는 nil처리가 가능해서 런타임 오류가 생기지 않게 방지 할 수 있음
        setViewControllers([first], direction: .forward, animated: true)
        
        
        // 간단한 문법 공부: 반환값을 사용안한다는 경고메세지 : 무시해도 되긴하지만 해결해보자
        getRandom()
        
    }
    
    // 내가 필요할때 반환값을 사용하겠다 : @discardableResult: 경고메세지 사라짐 : 앞의 "@ 골뱅이" : swift의 attrubute라고 함: 스위프트에서 편하라고 만든 것
    @discardableResult func getRandom() -> Int {
        let random = Int.random(in: 1...100)
        print(random)
        return random
    }
}

extension OnBoardingViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    // 페이지 갯수 보여주는 : 화면 아래 쩜쩜쩜 : 뷰컨의 백그라운드 색상과 동일하게 됨 :scroll로 하면 동일하게 되고 pagecurl로 하면 보이지 않음
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return list.count
    }
    // 어떤 인덱스가 제일 먼저뜨면 좋겠냐
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        // return 0로 보통 하는데 최대한 리스트에 의존하는 형태로 만들면
        guard let first = viewControllers?.first,
                let index = list.firstIndex(of: first) else
        {
            return 0
        }
        return index
        
    }
    
    // 아래는 필수 메서드
    
    // 일일히 다 연산을 해주는 : 수평으로 페이지 이동시
    // 이전화면을 뭘 준비하면되는지 알려주는 메서드
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        // 현재보고있는 뷰컨 배열의 인덱스가 조회 가능!
        // 현재보고 잇는 뷰컨의 인덱스보다 한단계 앞의 인덱스가 필요
        guard let currentIndex = list.firstIndex(of: viewController) else { return nil } // viewController의 인덱스를 알려주고 없으면 닐
        let previousIndex = currentIndex - 1
        return previousIndex < 0 ? nil : list[previousIndex]
    }
    
    // 다음 화면을 뭘 준비하는지 알려주는 메서드 : 끝화면 뒤에는 nil
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        // 현재 보고있는 뷰컨에서 그 다음 뷰컨 인덱스가 필요
        guard let currentIndex = list.firstIndex(of: viewController) else { return nil } // viewController의 인덱스를 알려주고 없으면 닐
        let nextIndex = currentIndex + 1
        
//        return list[nextIndex] // 리스트의 넥스트인덱스 띄워달라 : 이렇게하면 3번 인덱스부터는 없어서 계속 넘기다 보면 에러
        return nextIndex >= list.count ? nil : list[nextIndex]
        
    }
    
}
