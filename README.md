

<div align="center"> 

# 트다 TDAA
  '트다'는 함께 여행간 사람들과의 같은 공간, 같은 경험에서 느꼈던 감정과 기억을 '공유'하는 것을 도와주는 iOS Application 입니다.
 <br/>
  
<!---- 배너 이미지 추가 ---->
  
[<img src = "https://user-images.githubusercontent.com/45297745/203068429-ed698278-9622-47ff-b6b7-e75531d7d88a.png" width="200">](https://apps.apple.com/kr/app/%ED%8A%B8%EB%8B%A4-tdaa/id6443840961)
 </div>
<br/>
<br/>

## 📱 Features

### 1. 공동 편집 (동시 편집)
   \- '트다' 공동 편집 기능을 제공합니다. 함께 여행간 사람들을 초대해 같이 여행 다이어리를 남겨보세요.
   \- 간편한 작성 도구 (위치, 사진, 스티커, 텍스트 추가 기능)

### 2. 여행 스탬프 콜렉션
   \- 내가 다녀온 여행지를 지도 상에서 모아봅니다. 방문한 여행지의 스탬프를 모아보세요.
   \- TDAA의 지도는 전세계를 지원합니다.

### 3. 사진 앨범
   \- 다이어리 작성에 사용된 모든 이미지들을 모아봅니다.
   \- 공동편집자들이 업로드한 사진을 공유 받을 수 있습니다.

<br/>
 
## 🖼 Screenshot

![ScreenShot](https://user-images.githubusercontent.com/45297745/203060105-5ba72653-9e7b-46be-bb64-aac450bf7d13.png) 

<br/>

## 🛠 Development

### Tech Skills

<img width="45" alt="UIKit" src="https://img.shields.io/badge/UIKit-9cf">  <img width="50" alt="MVVM" src="https://img.shields.io/badge/MVVM-DBCFC1">  <img width="55" alt="MapKit" src="https://img.shields.io/badge/MapKit-4FAF61">


### Libraries
<img width="100" alt="RxSwift" src="https://img.shields.io/badge/RxSwift-6.5.0-blueviolet">  <img width="145" alt="RxDataSources" src="https://img.shields.io/badge/RxDataSources-7.4.1-ff69b4">  <img width="105"  alt="Firebase" src="https://img.shields.io/badge/Firebase-9.6.0-yellow"> <img width="110" alt="Kingfisher" src="https://img.shields.io/badge/Kingfisher-7.4.1-blue">  <img width="100" alt="SnapKit" src="https://img.shields.io/badge/SnapKit-5.6.0-bright">

### Environment

<img width="77" alt="스크린샷 2021-11-19 오후 3 52 02" src="https://img.shields.io/badge/iOS-14.0+-silver">  <img width="95" alt="스크린샷 2021-11-19 오후 3 52 02" src="https://img.shields.io/badge/Xcode-14.0.1-blue">

### Project Structure

```
MacC-GoldenRatio (TDAA)
    |
    ├── Resources
    │       ├── Assets.xcassets       
    │       ├── Base.lproj
    │       ├── Fonts
    │       ├── AppDelegate.swift        
    │       └── SceneDelegate.swift    
    │
    ├── Sources                    
    │       ├── Presenter
    |       │       ├── HomeScene
    |       |       │       ├── Model
    |       |       │       ├── View 
    |       |       │       ├── ViewController 
    |       |       │       └── ViewModel  
    |       │       ├── SignInScene
    |       │       ├── DiaryDaysScene
    |       │       ├── DiaryConfigScene   
    |       │       ├── PageScene
    |       │       ├── UserScene  
    |       │       └── Common   
    |       |
    │       ├── Model         # Common Models for Data & Objects
    │       ├── Classe        # Common Class for components
    │       ├── Network       # Networking Related Classes	
    │       └── Extensions    # Type Extension Files
    │
    └── Info.plist
```

<br/>

## 👥 Authors

|PM|Design|Developer|Developer|Developer|
|:---:|:---:|:---:|:---:|:---:|
[@San](https://github.com/ocner1435) | [@Lau](https://github.com/lau0505) |   [@Cali](https://github.com/Dorodong96) |  [@Hatchling](https://github.com/woo0dev) | [@Drogba](https://github.com/iDrogba) |
|<img width="150" alt="산" src="https://user-images.githubusercontent.com/45297745/201825716-e34e3a9c-f85a-4f32-8e11-021dbbd27974.png">|<img width="150" alt="라우" src="https://user-images.githubusercontent.com/45297745/201825702-a2d91dae-32be-4613-82b7-069a5e8d7045.png">|<img width="150" alt="칼리" src="https://user-images.githubusercontent.com/45297745/201825720-5b422e0d-8450-432b-86dc-02715e9df3fe.png">|<img width="150" alt="해츨링" src="https://user-images.githubusercontent.com/45297745/201825731-466c8bfe-6dc3-4e24-be40-63358f639cd8.png">|<img width="150" alt="드록바" src="https://user-images.githubusercontent.com/45297745/201825687-19ca0874-bfa9-48c8-9a46-3909cbf9a8d7.png">|

<br/>

## 🔀 Git

### 1. 기본적인 작업 프로세스

- Issue 생성: Assignees 할당, Label 할당
- Branch 작성: Branch의 종류에 맞는 형태로 이름 지정
- Pull Request: Issue의 TODO에서 제시되었던 모든 작업을 마친 후 PR 신청
- 최소 2명 이상의 Reviewer의 Approve 후 Merge 가능

### 2. Phase: Issue
- Issue 생성 규칙
  - 기본적으로는 [이슈 템플릿](https://github.com/DeveloperAcademy-POSTECH/MacC-TeamID-TDAA/blob/dev/.github/ISSUE_TEMPLATE/---------.md)을 사용하여 작성

- 구현해야하는 요소들: 해결해야하는 문제에 대해 간략 서술
- 구현 방안: 위의 요소들의 실제 구현 시의 세부 사항 및 방법을 작성한다

### 3. Phase: Branch
- Branch 관리
  - Main Branch
  - Dev Branch: For Development
  - View Branch: Development Branch 중에서도 View 단위로 관리하기 위한 Branch들
- 개발 이외의 Branch는 언제든지 추가될 여지 존재
- Branch 생성 규칙
  - Default: `작업태그/이슈번호-Name`
  - ex) `feat/#50-HomeView`

### 4. Phase: Pull Request
- PR(Pull Request) 규칙
	- [PR 템플릿 활용](https://github.com/DeveloperAcademy-POSTECH/MacC-TeamID-TDAA/blob/dev/.github/pull_request_template.md), 작업 사항, 스크린샷, To Reviewers 등 활용
	- Default: `[작업태그]이슈번호 작업 사항 축약`
	- ex) `[Feat]#50 회원가입 뷰 추가`
- 작업태그 일괄
	- `Feat` : 새로운 기능 추가 / 일부 코드 추가 / 일부 코드 수정
	- `Fix` : 버그 수정
	- `Refactor` : 코드 리팩토링
	- `Design` : 디자인 수정

### 5. Phase: Code Review 

* [코드 리뷰 리소스 관리](https://circlekim.notion.site/PR-c2de64cb67b84ad8a173e642c14dfe98)
  * Pn룰 (코멘트 강조): p1 ~ p5 코멘트 활용
  * D-n룰 (리뷰 우선순위 선정): 리뷰 기간 및 우선순위 선정에 따른 태스크 관리

