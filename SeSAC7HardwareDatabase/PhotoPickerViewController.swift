//
//  PhotoPickerViewController.swift
//  SeSAC7HardwareDatabase
//
//  Created by 박현진 on 9/10/25.
//

import UIKit
import SnapKit


// PHPicker에서 사용하는 프레임워크
import PhotosUI // ios14부터 사용가능



class PhotoPickerViewController: UIViewController {

    let imageview = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(imageview)
        imageview.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(100)
        }
        imageview.backgroundColor = .lightGray
    }
    

    override func viewDidAppear(_ animated: Bool) { // 왜 viewDidAppear 에서 했을까 : 뷰디드로드 위에서 해도 되 지금은 그냥 한군데서 몰아서 한것뿐 : 유저의 사용빈도에 따라 위치는 유동적
        super.viewDidAppear(animated)
        
        
        
        // 다양한 피커뷰턴들이 많으다~
//        let picker = UIFontPickerViewController()
//        let picker = UIDocumentPickerViewController()
//        let picker = UIColorPickerViewController()
        
        
//
        
        
        // 앞의 PH : Photo의 prefix // 이제 UIImagePickerController() 대신에 PHPickerConfiguration()를 띄워보자~
        var config = PHPickerConfiguration() // 보면 구조체로 이루어져 있다 : 이 구조체 안에 어떤 프로퍼티들이 있는지 보면 되겠다~ : 구조체의 인스턴스를 만들어놓고 : 아래로
        // 아래 많이 사용하는 애들
        config.selectionLimit = 3 // 3장까지 선택이 되게 하겠다 : UIImagePickerController는 여러장 선택이 안되는데 PHPicker는 여러장 선택이 가능하니까
        
//        config.filter = .videos // 갤러리에서 영상만 가져오겠다 : 갤러리에 있는 것들 중에 갖고 올 수 있는걸 필터링해서 가져오겠다는 설정이 "필터"
        // 영상 하나만 가져오지 않고 여러 종류를 가져오고 싶을때 사용하는 거는 any
        config.filter = .any(of: [.screenshots, .images]) // 스크린샷과 사진만 가져오겠다
        
        
        // configuration을 보니 뭔가 셋팅에 관련된거겠다~ : 위로
        let picker = PHPickerViewController(configuration: config) // PHPicker는 촬영빼고 갤러리에 대한 기능을 다 담당 // UIImagePickerController()와 차이점이 여러장을 선택을 할 수 있다 : PickerViewController 다양한 종류O
        
        picker.delegate = self //PHPickerViewControllerDelegate
        
        present(picker, animated: true)
        
    }
    
}
// 이제 추가/취소 버튼을 눌렀을 때 어떤 기능들을 할지 만들어보자

extension PhotoPickerViewController: PHPickerViewControllerDelegate {
    
    // didFinishPicking : 사진을 선택할때 꼭 써야되는 애 : 딜리게이트 필수 메서드
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        
        
        
        
        // 매개변수 results 배열에 많은 정보들이 있을 텐데 프린트해서 일일히 다 확인해보자~ : 선택한 사진에 대한 정보들 : itemProvider 가 프린트 됨: 아래로
        print(#function, results) // 갤러리에서 오른쪽 위에 추가/취소 버튼을 누르면 실행됨
        
        picker.dismiss(animated: true) // 취소/추가 버튼 중 뭘 누르던 내려서 사라지게 해달라
        
        
        
        
        
        
        // 사진 선택시 이미지뷰에 사진 넣기를 해보자~
        
        // 1단계
        let itemProvider = results.first?.itemProvider // 내가 선택한 사진 중에 첫번째 사진
        // 윗줄에서 first에서 선택한게 없을 수도 있다보니까 옵셔널로 되어있어서 옵셔널 처리해주고
        
        
        // 2단계
        if let itemProvider = itemProvider, // 첫번째 itemProvider가 있는지 확인 해주고,
           itemProvider.canLoadObject(ofClass: UIImage.self) { // 실제로 갤러리에 있는 사진을 우리가 로드를 해서 조회를 해 올수 있는지를 : 이미를 가지고 올꺼라서 UIImage타입으로 로드가 되는지 확인 :왜 이거까지 확인하냐~: 만일의 만일에 대비헤서 앱이 실행중인 상태에서 사진을 선택해서 추가하려고 하는데 갤러리에 가서 사진을 삭제하거나 추가할 수도 있으니 로드가 실패할수도 있고 타입이 안맞아서 실패할 수도 있으니 확인 필요!
            
            
            // 3단계
            // 로드를 할 수 있다하면 그제야 : loadObject : 사진을 로드를 해오고 성공하면 image에 담기고 실패하면 error에 담기겟다~
            itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                
                
                
                // 나중에 갤러리에 되게 긴 영상이나 고화질 영상을 로드해오려면 당연히 시간이 오래 걸릴테고: 그때까지 다른 작업도 해야 하니까 다른 스레드에서 동작할 수 있게끔 만들어 뒀을테니 ui 업데이트는 메인에서 하게 해줘야 문제가 발생하지 않겠다~ : 그래서 하드웨어 곳곳에 "로드"하는데 오래 걸리니까 백그라운드 스레드(즉 닭벼슬이 아는 애들)로 일할 수 있는 코드들이 들어가다보니까 : 여태 알라모파이어를 쓰면서는 쓸일이 없었는데 이제 이게 많이 보일 것~
                DispatchQueue.main.async { // 또 보라섹에러: 메인으로 보내주거나 다른 알바생한테 맡기거나~
                    
                    // 로드 성공해서 가져온 이미지를 이미지뷰에 보여줘~
                    self.imageview.image = image as? UIImage // 가져온게 UIImage로 잘 변환된 형태인지 타입캐스팅이 필요!

                }
                
            }
        }
    }
    
}
