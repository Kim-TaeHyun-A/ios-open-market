## iOS 커리어 스타터 캠프

### 오픈마켓 프로젝트 저장소
> 프로젝트 기간: 2022-05-09 ~ 2022-06-03 
> 프로젝트 팀원: [@티아나](https://github.com/Kim-TaeHyun-A), [@파프리](https://github.com/papriOS), 리뷰어: [@올라프](https://github.com/1Consumption)


## 구현 화면
![](https://i.imgur.com/JElqAPE.gif) ![](https://i.imgur.com/Vn8Zb8g.gif) 
![](https://i.imgur.com/8lylxba.gif)

![](https://i.imgur.com/Hmdo906.gif) ![](https://i.imgur.com/N5lSB35.gif)

![](https://i.imgur.com/8J6wpSs.gif)


## 목차

- [STEP 1](#STEP-1)
    + [고민한 점 및 질문](#고민한_점_및_질문)
- [STEP 2](#STEP-2)
    + [고민한 점 및 질문](#고민한_점_및_질문)
- [STEP 3](#STEP-3)
    + [고민한 점 및 질문](#고민한_점_및_질문)
- [그라운드 룰](#그라운드-룰)
    + [스크럼](#스크럼)
    + [코딩 컨벤션](#코딩-컨벤션) 


---

### PR 바로가기
- [STEP 1](https://github.com/yagom-academy/ios-open-market/pull/138)
- [STEP 2](https://github.com/yagom-academy/ios-open-market/pull/152)
- [STEP 3](https://github.com/yagom-academy/ios-open-market/pull/160)

### 키워드
`URLSession`
`test double` 
`modern collectionView`
`clean architecture`
`layout`


## STEP 1


### 구현내용

* Product, OpenMarketProductList
: 서버에서 받아올 Data에 매칭하기 위한 모델, 각각

* HTTPManager.swift
: 서버와 네트워크 통신을 담당하기 위한 모델

* OpenMarketTests
: Product, OpenMarkerProductList로 JSON 형태의 데이터가 디코딩 되는지 테스트
: HTTPManager의 loadData(), listenHealthChecker() 호출 시 completionHandler가 수행되는지 테스트

* StubURLSessionTests
: 네트워크 통신 없이 의존성 주입을 활용해 테스트 케이스 작성

---

### 고민한 점 및 질문

#### test double

test double이란 테스트를 진행하기 어려운 경우 대신하여 테스트를 진행할 수 있도록 만들어주는 객체라고 합니다. 따라서, 네트워크 통신을 직접하지 않고(외부적인 요인에 영향을 받지 않는 상태로) 테스트할 수 있습니다.

mock과 stub의 가장 큰 차이는 mock은 behavior verification을 진행하고, stub은 status verification을 진행하는 것이 있음을 알았습니다.

status verification 은 다른 타입에 의존적이지만 behavior verifation은 그렇지 않고, 너무 오래걸리거나 다른 것에 영향을 받는 경우에도 간단하게 테스트를 진행할 수 있습니다.

Mock 객체는 expectation을 부여하고 미리 프로그래밍된 object입니다.
여기서 말하는 expectation은 mock 객체가 받을 것이라고 예상되는 call들로 이해하였습니다.
Mock객체는 expectation이 충족되었는지, 즉 불려야할 method(MockURLProtocol의 경우 dataTask 메서드)가 불렸는지를 verify해야하고, 이것이 behavior verification을 진행하는 것이라고 이해했습니다.

* Dummy: 매개변수 만들 때만 사용되는 객체
* Fake: 실제와 유사, but 간단하게 구현된 객체
* Stub: 준비된 결과를 반환, 외부 요인에 따라 응답 않는 객체
* Spy: stub의 일종으로 호출 어떻게 됐는지 기록하는 객체
* Mock: expectation에 대응하는 결과 확인하는 객체

![](https://i.imgur.com/bG73Xdv.png)


```swift
import XCTest
import Foundation

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func stopLoading() { }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            XCTFail("Received unexpected request with no handler set")
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
}
```

```swift
func test_loadData_호출하면_productList_GET하는지_확인() {
        // given
        var products: [Product] = []
        
        MockURLProtocol.requestHandler = {request in
            let exampleData = self.dummyProductListData
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type" : "application/json"])!
            return (response, exampleData)
        }
        
        let expectation = XCTestExpectation(description: "It gives productList")
        
        // when
        httpManager.loadData(targetURL: HTTPManager.TargetURL.productList(pageNumber: 2, itemsPerPage: 10)) { data in
            switch data {
            case .success(let data):
                let decodedData = try! JSONDecoder().decode(OpenMarketProductList.self, from: data)
                products = decodedData.products
            default:
                break
            }
            
            // then
            XCTAssertEqual(products.first?.name, "Test Product")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
}
```


#### 비동기 테스트 
HTTPManager의 listenHealthChecker()와 loadData() 메소드는 비동기적으로 동작하는 URLSession.shared.dataTask()를 호출하기 때문에 비동기적으로 작업을 처리합니다.
이러한 비동기 메소드를 테스트하기 위해 expectation(description:), fulfill(), wait(for: timeout:) 라는 세가지 테스트 메소드를 활용했습니다.
* expectation(description:) 으로 어떤 것이 수행되어야하는가에 대한 description을 지정하고,
* fulfill()를 정의된 expectation이 충족되는 시점에 호출하여 동작이 수행되었음을 알립니다.
* wait(for: timeout:)은 for: 에 expectation을 배열로 담을 수 있습니다. 배열에 들어간 expectation이 모두 timeout으로 지정해둔 시간 동안 fulfill되길 기다립니다.
    
#### 서버에서 데이터 fetch
competionHandler를 사용하는 방식과 delegate를 사용하는 방식 중에 전자를 사용해서 구현했습니다.
product 목록(2.5. 상품 리스트 조회)과 product 상세내용(GET2.4. 상품 상세 조회)을 가져오는 경우 url을 제외한 내부 구현이 동일해서 둘 다 loadData 메서드를 사용해서 GET 합니다.
현재 API 서비스의 동작여부 및 Listen을 확인하는 Application HealthChekcer의 경우 따로 받아오는 데이터가 없어서 별도의 메서드(listenHealthChecker)로 구현했습니다. statusCode를 통해 성공여부를 확인합니다.

#### result type
네트워크 성공과 실패를 명확하게 보여주기 위해서 Result type을 사용했습니다.
dataTask의 completionHandler가 throws가 아니라서 에러를 던져서 처리하는 것을 불가능합니다. 따라서 completionHandler에 실패한 결과나 성공한 결과를 담도록 구현했습니다.


---

## STEP 2

### 구현 내용

#### IPHONEOS_DEPLOYMENT_TARGET
modern collection view를 활용하면서
> setNeedsUpdateConfiguration()
UICellConfigurationState
UIConfigurationStateCustomKey
UICollectionLayoutListConfiguration
UICollectionViewCompositionalLayout.list(using: configuration)
UICollectionView.CellRegistration<ProductListCell, Product> { }
collectionView.dequeueConfiguredReusableCell(using: listCellRegisteration, for: indexPath, item: itemIdentifier)

메소드와 타입을 활용하여 target 버전 14이상으로 구현했습니다

#### UI
* 스토리보드를 제거하고 코드로 UI를 구현하였습니다
* 하나의 collectionView의 layout이 List Layout 과 Grid Layout 두가지 모두로 보일 수 있도록 구현하였습니다

#### CollectionView

* Layout object
`applyGridLayout()`, `applyListLayout()` 매서드를  통해 layout object에 대한 설정이 가능합니다


* DataSource
`UICollectionViewDiffableDataSource` 을 활용하였습니다
snapshot에 section은 최초 한 번만 추가합니다.
snapshot으로 셀에 데이터를 넣습니다.
`registerCell()`: ProductListCell과 ProductGridCell의 registration을 진행합니다
`configureDataSource()`: segmentedControl의 변화에 따라 dequeue하는 reusable한 cell이 변경됩니다



#### collectionViewCell
list와 grid에서 공통적으로 사용되는 요소를 한 파일(CellUIComponent)이 구현했습니다.
list와 gird에서 각각 구현하려는 레이아웃에 맞게 stackview 내부 뷰에 요소를 배치했습니다.
state에 값에 대한 상태를 추가하기 위해 `configurationState`를 오버라이딩하고 `updateConfiguration` 매서드를 통해 셀 값이 세팅되도록 구현했습니다.

---

### 고민한 점 및 질문 사항

#### 중복요청에 대한 처리
DataProvider 타입에서 isLoading이라는 플래그를 사용해서 로딩이 진행 중이지 않을 때만 요청을 보낼 수 있도록 구현했습니다. viewcontroller에서는 불필요한 매개변수 없이 단순히 해당 메서드의 호출만으로 데이터를 가져올 수 있습니다.

#### 목록을 로드할 때, 빈 화면을 대신할 무언가  
각 cell의 `prepareForReuse()` 메소드에
기본제공 이미지가 삽입되도록 수정하여, 이미지가 아직 로드되지 않았을때 빈화면 대신 swift 이미지가 보입니다


#### loadView() vs viewDidLoad()
기본 view를 커스텀하기 위해서는 loadView에 구현하고 뷰가 생성된 이후의 설정하기 위해서는 viewDidLoad에 구현합니다. 따라서, viewController에서 제공하는 기본 view를 교체하는 경우는 loadView에서 구현합니다.

#### 클로저 내부의 함수 구현
segmented control을 생성하는 경우 여러 속성을 설정해야 합니다. 가독성을 위해 클로저 내부에 설정과 관련된 함수를 구현하고 이를 호출하는 식으로 구현했습니다.

#### lazy 키워드
프로퍼티의 생성하는 과정에서 다른 프로퍼티를 사용해야 하는 경우나 해당 프로퍼티가 사용될 때 생성됐으면 하는 경우가 아니면 let으로 프로퍼티를 선언하도록 구현했습니다.

#### prepareForReuse
cell을 재사용하는 경우 이전에 설정된 label의 attribute이나 이미지를 초기화하고 올바른 데이터를 cell에 할당할 수 있도록 prepareForReuse 메서드를 오버라이딩했습니다.
cell이 재활용되기 이전에 로딩 중이던 이미지 task가 있으면 취소합니다.

#### datasource의 분기문
분기문이 안에 위치하는 경우 indexPath, itemIdentifier, section을 활용해서 더 세밀하게 datasource를 처리할 수 있기 때문에 더 유연한 코드가 됩니다.

```swift
dataSource = UICollectionViewDiffableDataSource<Section, Product>(collectionView: collectionView) { [self] (collectionView, indexPath, itemIdentifier) -> UICollectionViewCell? in
             if baseView.segmentedControl.selectedSegmentIndex == 0 {
                 return collectionView.dequeueConfiguredReusableCell(using: listCellRegisteration, for: indexPath, item: itemIdentifier)
             } else {
                 return collectionView.dequeueConfiguredReusableCell(using: gridCellRegisteration, for: indexPath, item: itemIdentifier)
             }
```

#### UUID
서버에서 가져오는 데이터(Product)의 identifier로 UUID를 사용하는 경우 매번 새로운 아이디를 생성하기 때문에 서버의 데이터와 일치하지 않을 수 있습니다. diffable은 identifier로 데이터를 식별하기 때문에 animation에서 문제가 생길 수 있습니다. 따라서, 서버에서 가져오는 값을 사용해서 identifier 지정하도록 구현했습니다. 만약, 서버에서 identifier를 제공하지 않으면 서버에서 제공하는 데이터들의 조합으로 identifier를 구성하게 됩니다.

---

## STEP 3

### 구현 내용

상품을 등록하는 화면을 구현
등록한 상품을 수정하는 화면을 구현
서버 API 요구사항에 맞게 상품을 등록/수정 할 수 있도록 구현

#### View Controller
> UpdateProductViewController
* 상품 등록과 수정이 이뤄지는 화면을 보여주는 ViewController
* 로직분기는 여기서 이뤄지지 않도록 구현
* 이벤트를 전달하거나, View Model에서 진행된 로직의 결과를 띄우기만 한다

#### View Model
> UpdateImageViewModel, UpdateProductViewModel
* UpdateImageViewModel: Image를 업데이트하기위한 로직을 수행
* UpdateProductViewModel: Product를 업데이트하기 위한 로직을 수행

#### Network Model
> HTTPManager, DataProvider, DataSender
* HTTPManager: 서버와의 통신을 담당한다
* DataProvider: 서버로부터 Load 받은 데이터를 모델타입으로 변환하여 View Model에게 제공한다.
* DataSender: 서버에게 View Model의 로직을 통해 얻은 모델타입을 데이터 타입으로 변환하여 POST, PATCH하도록 한다.

#### Alert을 통한 에러처리
> Alert

* enum Title: 알럿의 종류
* setUpTitle: updateProductViewModel의 상황에 맞게 title 세팅
* showWarning: 알럿을 띄움

--- 

### 고민한 점 및 질문 사항


#### 1. 키보드 높이에 따른 레이아웃 조절
Notifiacation을 통해서 userInfo에서 키보드의 높이를 알아냅니다.
collectionView의 botton의 constant를 수정하면서 레이아웃을 조절합니다.


#### 2. 뷰와 모델의 역할 분리
[UpdateProductViewController에 클린 아키텍처 적용해보기](https://github.com/Kim-TaeHyun-A/ios-open-market/tree/STEP3-Clean-Architecture)

구현하는 기능이 많아지면서 viewController의 길이가 너무 길어졌고 역할 분리가 제대로 되지 않는다고 생각했습니다.
따라서 클린 아키텍처를 적용시키며 여러 레이어를 나누어 추상화 했습니다.
뷰에는 분기문이 없고 대부분의 일을 메서드 호출로만 처리할 수 있도록 리팩토링 진행했습니다.

UpdateViewController의 프로퍼티를 뷰모델(UpdateImageViewModel, UpdateProductViewModel)로 만들어서 뷰 컨트롤러에서는 뷰 모델과 관련된 일은 진행하지 않고 불필요한 데이터는 은닉화합니다.
셀이나 모델의 데이터 세팅은 셀이나 모델 내부의 메서드에서만 진행합니다.
메서드 내부에서는 하나의 기능만 수행하도록 작게 분리했습니다.

#### 3. 네트워크에서의 역할 분리
DataProvider는 HTTPManger와 ViewController의 인터페이스 역할을 합니다.

#### 4. 새로운 데이터로 가져오는 조건문
데이터가 존재하는지를 currentSnapshot 나 dataSource, 또는 cell의 indexPath와의 비교를 통해 확인할 수 있습니다.

아래 코드는 snapShot의 item을 확인해서 last의 index와 화면의 띄우려는 셀의 indexPath를 비교해서 같으면 데이터를 fetch 합니다.
+1과 같은 연산이 따로 필요없어서 가장 깔끔한 방식인 것 같아서 아래의 코드로 구현했습니다.
```swift
        guard let product = currentSnapshot?.itemIdentifiers.last else {return}
        guard currentSnapshot?.indexOfItem(product) != indexPath.row else {
            dataProvider.fetchData() { products in
                DispatchQueue.main.async { [self] in
                    updateSnapshot(products: products)
                }
            }
            return
        }
```

아래 코드는 dataSource에서 `IndexPath(row: indexPath.row + 1, section: 0)` 에 값이 있는지를 확인하고 값이 없으면 fetch합니다.
```swift
       guard dataSource?.itemIdentifier(for: IndexPath(row: indexPath.row + 1, section: 0)) != nil else {
            dataProvider.fetchData() { products in
                DispatchQueue.main.async { [self] in
                    updateSnapshot(products: products)
                }
            }
            return
        }
```

아래 코드는 collectionview에서 해당 `IndexPath(row: indexPath.row + 1, section: 0)`로 cell을 만들 수 있냐를 확인합니다.
cellForItem 메서드는 cell을 반환해줍니다.
```swift
        guard let _ = collectionView.cellForItem(at: IndexPath(row: indexPath.row + 1, section: 0)) else {
            dataProvider.fetchData() { products in
                DispatchQueue.main.async { [self] in
                    updateSnapshot(products: products)
                }
            }
            return
        }
```

#### 5. designated init vs convenience init
designated init은 부모 init을 호출해야 하지만 convenience init은 self init을 호출 할 수 있습니다. 따라서 다른 init에서 구현한 내용을 중복해서 구현하는 것을 막습니다.

#### 6. contentView 위 button과의 interaction
`collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath)` 메서드를 통해 사용자의 탭 행위를 감지합니다. 버튼이 contentView의 subView로 바로 등록된 경우 버튼이 interaction을 감지해서 collectionView가 반응하지 않습니다.
따라서, UIBotton의 isUserInteractionEnabled 프로퍼티에 false를 주고 해결했습니다.


#### 7. refreshControl
refresh control을 통해 스크롤을 내리면 새로고침이 진행되도록 구현했습니다. refresh를 begin하고, end하는 시점과 서버로부터의 응답이 오는 시간을 고려하여 자연스럽게 동작하도록 하였습니다.

#### 8. delegate를 통한 동작의 위임
모델에과 뷰에서 하는 일을 분리해서 구현하기 delegate 패턴을 사용해서 구현했습니다.

#### 9. 클로저 캡쳐로 인한 약한 참조
클로저는 정의된 context안의 상수/변수에 대한 참조를 캡쳐하여 클로저 body 내에서 사용할 수 있습니다. 클로저가 캡쳐하고 있는 값이 reference type이면 강한 순환 참조가 발생합니다. 이를 방지하기 위해 내부에서 약한 참조를 하도록 하였습니다.

---

## 그라운드 룰
### 활동시간
오전: 10시 ~ 12시
오후: 2시 ~ 6시(활동학습 있으면 10분 쉬고 만나기)
저녁: 7시반 ~ 상황에 따라(12시 이전까지)

### 커밋 Title 규칙
feat: 새로운 기능의 생성
add: 라이브러리 추가
fix: 버그 수정
docs: 문서 수정
refactor: 코드 리펙토링
test: 테스트 코트, 리펙토링 테스트 코드 추가
chore: 빌드 업무 수정, 패키지 매니저 수정(ex .gitignore 수정 같은 경우)

### 커밋 Body 규칙
title로 설명 끝내기

