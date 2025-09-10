//
//  CameraViewController.swift
//  SeSAC7HardwareDatabase
//
//  Created by 박현진 on 9/9/25.
//

import UIKit
import SnapKit

/*
 
 카메라 권한 코드도 정해져 있음
 
 시뮬레이터로 카메라 촬영 테스트 불가: 실기계 연결 필요
 캠이 없는 아이폰이 있을 수 있음..? : 아이폰에 카메라가 없는 애가 실제 존재해서 : 카메라가 있는 체크 필요
 
 카메라 권한 기능
 1. 카메라로 촬영
 2. 갤러리에서 사진 가져오기
 3. 사진을 갤러리에 저장
 -> 이 3개를 누가 담당하고 있었냐 : ios13까지 UIImagePickerController(시스템UI까지 담당) : ios14부터는 PHPicker(out of precess라는 키워드가 중요!) 가 등장하면서 2,3을 담당 : 1번은 여전히 UIImagePickerController가 담당
 UIImagePickerController는 갤러리에서 사진을 여러장 선택하는 것 불가능 : PHPicker는 여러장 가능
 
 
 // out of precess : "앱에서 접근할 수 없는 상태로 갤러리가 뜬다" : "단순히 사진을 갤러리에서 가져오는 것(읽은 행위)는 권한이 필요가 없다." : 마치 접근 가능한것처럼 보이게 뜨는 것뿐
 // process : 앱 하나하나가 프로그램이라고 하면 앱을 실행을 시키면 실행시킨 프로그램 공간 자체를 프로세스라고 하는데 : 앱을 실행시키면 프로세스라는 공간이 생김: 이 공간(프로세스)과 갤러리가 띄워지는 것은 별개라는 뜻. 갤러리가 띄워지는 것은 너의 프로세스 권한 밖이다 :갤러리를 띄우고는 있지만 접근권한은 없는 상태 : 갤러리가 띄워지는 것은 별개의 앱이 띄워지는 거라고 봐도 무방. 그래서 개발자가 사진에 접근할 수 없다는걸 아웃오브 프로세스라고 하는 것.
 
 
 
 */

class CameraViewController: UIViewController {

    // 담당자를 매니저로 필요
    let manager = UIImagePickerController() // 1. 갤러리 관련 요소들을 다 갖고 있는 이미지픽커를 가지고서
    
    let imageview = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        manager.delegate = self // 3. 프로토콜 연결
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 2. sourceType의 정의 , 이미지픽커를 어떤 방식으로 사용을 할지 결정
        manager.sourceType = .photoLibrary // .camera로 해서 실기계에서는 촬영 가능
        manager.allowsEditing = true // 시스템에서 지원해주는 이미지 선택시 편집이 가능하게
        
        
        // 갤러리 화면을 띄우는 것도 프레젠트 사용
        present(manager, animated: true) // 권한을 물어보지도 않았는데 시작하자마자 갤러리를 띄워주는 게 맞는지...? : 사실상 눈에 보이는 것뿐이지 접근가능한 상태가 아직 아님! : out of precess
        
        view.addSubview(imageview)
        imageview.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(100)
        }
        imageview.backgroundColor = .lightGray
    }
   

}

// UINavigationControllerDelegate 까지 왜 세트로 필요한가: 갤러리에서 뒤로가기나 상세화면으로 이동(네비게이션 동작들)이 가능해져서~
extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // 갤러리 화면에 이미지를 선택한 경우 : 사진 선택시 액션이 필요하니까 info로 접근해야
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print(#function)
        
        let image = info[.editedImage] as? UIImage // .originalImage는 갤러리에 있는 사진 : 편집 옵션이 있는 경우: .editedImage로 써야 편집한 사진도 갤러리에 저장이 됨(위에 manager.allowsEditing = true를 한 경우)
        
        if let image = image {
            print("이미지 있음")
            // 있으면 이미지 뷰에 보여줘
            imageview.image = image
            dismiss(animated: true)
        } else {
            print("잘못된 이미지")
        }
    }
    
    // 갤러리 화면에서 취소 버튼을 누른 경우 : 화면이 내려갈수 있어야 하니까 디스미스
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print(#function)
        
        dismiss(animated: true)
    }
    
}
