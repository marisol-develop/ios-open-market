# 🛍오픈마켓

>프로젝트 기간 2022.05.09 ~ 2022.06.03
>
>팀원 : [marisol](https://github.com/marisol-develop), [Eddy](https://github.com/kimkyunghun3) / 리뷰어 : [린생](https://github.com/jungseungyeo)

## 목차

- [프로젝트 소개](#프로젝트-소개)
- [키워드](#키워드)
- [고민한점](#고민한점)
- [오픈마켓I](#오픈마켓I)
- [오픈마켓II](#오픈마켓II)

## 프로젝트 소개

오픈마켓 만들기!

## 실행 화면
앱을 최초에 실행했을 때 데이터가 로드될 때까지 indicator를 보여준다.

![](https://i.imgur.com/L2pEY3Z.gif)

-----
동일한 데이터를 List, Grid 형식에 따라 다르게 보여준다.

![](https://i.imgur.com/vEAQwdy.gif)

-----
스크롤을 내리게 되면 네트워크 통신을 통해 데이터를 받아온다.

![](https://i.imgur.com/44O40S7.gif)

-----
스크롤을 위로 올리게 되면 refresh로 통신을 해서 새 데이터를 받아온다.

![](https://i.imgur.com/RWtu0o6.gif)

-----
상품을 등록하면 POST 호출을 통해 서버에 데이터를 등록한다.

![](https://i.imgur.com/LDbf0lB.gif)

-----
상품 수정하면 PATCH 호출을 통해 서버에 수정된 데이터를 등록한다.

![](https://i.imgur.com/CcI7gzE.gif)

-----
상품 삭제하면 DELETE 호출을 통해 서버에서도 데이터를 삭제한다.

![](https://i.imgur.com/orKtQgR.gif)

## 개발환경 및 라이브러리
![swift](https://img.shields.io/badge/swift-5.5-orange)
![xcode](https://img.shields.io/badge/Xcode-13.0-blue)
![iOS](https://img.shields.io/badge/iOS-13.0-yellow)

## 키워드

`git flow` `Test Double` `URLSession` `StubURLSession` `Protocol Oriented Programming` `추상화` `json` `HTTP method` `decode` `escaping closure` `Cache` `CompositionalLayout` `URLSession` `UIImagePickerController`

### 자세한 고민 보기

#### [STEP1](https://github.com/yagom-academy/ios-open-market/pull/142)
#### [STEP2](https://github.com/yagom-academy/ios-open-market/pull/153)
#### [STEP3](https://github.com/yagom-academy/ios-open-market/pull/164)
#### [STEP4](https://github.com/yagom-academy/ios-open-market/pull/170)

# 🛍오픈마켓I

## 🧐 고민한점 & 해결방법
### 📌 1. URLSessionDataTask의 init이 deprecated된 문제를 의존성 주입으로 해결

> Response라는 구조체를 활용해서 의존성 주입하여 URLSessionDataTask를 상속받는 게 아니라 만들어진 프로토콜 주입을 통해 해결했다.

```swift
import Foundation

typealias DataTaskCompletionHandler = (Response) -> Void

struct Response {
    var data: Data?
    var statusCode: Int
    var error: Error?
}

protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskCompletionHandler)
    func dataTask(with url: URL, completionHandler: @escaping DataTaskCompletionHandler)
}

extension URLSession: URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskCompletionHandler) {
        
        dataTask(with: request) { data, response, error in
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                return
            }
            
            let response = Response(data: data, statusCode: statusCode, error: error)
            completionHandler(response)
        }.resume()
    }
    
    func dataTask(with url: URL, completionHandler: @escaping DataTaskCompletionHandler) {
        dataTask(with: url) { data, response, error in
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                return
            }
            
            let response = Response(data: data, statusCode: statusCode, error: error)
            completionHandler(response)
        }.resume()
    }
}

```

### 📌 2. MockURLSession Unit Test
가짜 데이터를 활용해서 네트워크 통신이 잘 되는지 확인

```swift
 func test_Product_dummy데이터의_totalCount가_10과_일치한다() {
        // given
        let promise = expectation(description: "success")
        var totalCount: Int = 0
        let expectedResult: Int = 10

        guard let product = NSDataAsset(name: "products") else {
            XCTFail("Data 포맷팅 실패")
            return
        }
        
        let response = Response(data: product.data, statusCode: 200, error: nil)
        let dummyData = DummyData(response: response)
        let stubUrlSession = StubURLSession(dummy: dummyData)
        sutProduct.session = stubUrlSession

        // when
        sutProduct.execute(with: FakeAPI()) { result in
            switch result {
            case .success(let product):
                totalCount = product.totalCount
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            promise.fulfill()
        }

        wait(for: [promise], timeout: 10)

        // then
        XCTAssertEqual(totalCount, expectedResult)
    }
```

### 📌 3. list cell과 grid cell에 dataSource 활용
 
처음에 MainViewController의 makeDataSource 메서드 내부에서 데이터들을 가지고 cell을 구성해주었는데, 그렇게 하다보니 makeDataSource 메서드가 너무 길어지고 역할 분리도 애매해졌다는 생각이 들었다. 그래서 configureCell이라는 메서드에 파라미터로 product를 받도록 하고, cell 내부에서 파라미터의 product 데이터로 cell을 구성해주도록 변경했다.


> 각각 grid, list cell에 따라 View에 직접적으로 뿌려주게 되면 View에 로직이 더 필요하기 떄문에 Presenter라는 중간 매체를 사용했다. 이 곳에서는 cell에서 통신을 통해 받아온 데이터를 활용해서 뷰에 필요한 로직들을 구현했다.
예를 들어, 데이터포맷터를 통해 쉼표를 넣어주거나 재고 수량유무에 따라 cell에 다르게 보여줘야하는 부분을 처리하여서 View에서는 보여주는 역할만을 수행하도록 분리했다.

### 📌 4. collectionView의 cell에 구분선을 그리기

cell마다 구분선을 주는 방법에 대해 오래 고민했다 다른 캠퍼들에게 조언을 구해 view를 얇게 만들어서 넣는 방법이 있다는 것도 알게 되었고, CALayer를 extension해서 bottom에 구분선을 넣어주는 방법도 알게 되어, CALayer를 extension하는 방법을 채택했다.

> cell 속에 view를 넣어서 구분선을 넣는 방법이 존재한다는 것을 알게 되었다. 하지만 아래 코드로 CALayer를 확장하여 사용하면 더 편리하다고 판단하여 아래의 코드를 사용했다.
 
```swift=
extension CALayer {
    func addSeparator() {
        let separator = CALayer()
        
        separator.frame = CGRect.init(x: 10, y: frame.height - 0.5, width: frame.width, height: 0.5)
        
        separator.backgroundColor = UIColor.systemGray2.cgColor
        self.addSublayer(separator)
    }
}
```

### 📌 5. modern CollectionView의 뷰의 전환을 비동기로 구현
segmentedControl의 index를 활용해서 뷰의 전환을 구현했었다.
하지만 이 코드는 modern ColletctionView에서 제공하는 init의 비동기적으로 뷰의 전환을 활용하지 않는 코드였다.

그리하여 내부에 존재하는 init를 활용해서 처리해보았다.
```swift
  public init(sectionProvider: @escaping UICollectionViewCompositionalLayoutSectionProvider,
              configuration: UICollectionViewCompositionalLayoutConfiguration)

```

이 init는 뷰 안에 여러 Section들에 대한 전환을 비동기적으로 처리해주므로 이전 코드와 다르게 더 효율적으로 가능해진다.

아래처럼 구현했으며
```swift
   private lazy var layouts: UICollectionViewCompositionalLayout = {
        return UICollectionViewCompositionalLayout(sectionProvider: { _, _ in
            return LayoutType.section(self.layoutType)()
        }, configuration: .init())
    }()
```

이곳에서 layoutType는 enum를 활용해서 내부를 캡슐화해서 사용했다. 그러면 외부에서의 접근도 피할 수 있으며 segmentedIndex를 활용하지 않고도 뷰의 변환을 비동기적으로 처리할 수 있었다.

### 📌 6. 이미지 캐싱 처리 방법

NSCache를 사용해서 이미지를 캐싱하도록 했다.

UIImageView를 extension해서 `loadImage(_ urlString: String)`라는 메서드를 만들고, 
이미 캐시에 해당 url의 이미지가 존재한다면 해당 이미지를 사용하도록 하고, 캐시에 없는 이미지라면 해당 url로 이미지를 만들어 캐시에 저장하도록 했다.


### 📌 7. 뷰의 ancestor 문제
뷰의 레이아웃을 잡고 빌드를 했을 때 아래와 같은 문제가 자주 발생했다.
> Thread 1: "Unable to activate constraint with anchors <NSLayoutXAxisAnchor:0x6000034dcec0 \"UILabel:0x12260c090.centerX\"> and <NSLayoutXAxisAnchor:0x6000034dcf00 \"UIView:0x12260ab30.centerX\"> because they have no common ancestor. Does the constraint or its anchors reference items in different view hierarchies? That's illegal."

이 문제가 발생했을 시 2가지를 고려하면 된다.
1. addSubview가 잘되어있는지
2. addSubview -> Layout Constraint 순으로 잘했는지

### 📌 8. cell의 indexPath 비교 vs cell prepareForReuse

#### prepareForReuse 

- 셀을 재사용하는 메서드다
    - CollectionView의 장점은 셀을 재사용한다는것. 그래서 이 메서드가 효율적으로 발휘할 수 있다.

- 또한 Object 책에서 말하길, "객체지향에서 객체 사이에서 서로의 정보를 많이 알수록 의존 관계가 높아진다."고 하는데, indexPath가 cell의 정보를 아는 것이 객체 사이의 정보를 공유하는 것이기 떄문에 이는 의존관계를 높일 수 있는 결과를 초래한다.

- 값을 부분적으로 update할 수 있는 장점이 존재한다.
 

#### indexPath

- indexPath를 사용하면 고정적으로 update를 해줄 수 있다

- 여기에서는 재사용 셀을 사용하지 않고 고정적으로 적절한 곳에 업데이트 해주므로 고정적으로 사용한다면 유리할 듯싶다.

- 하지만 재사용성이 떨어지므로 이를 주의해야하며, 관리를 해줄 수 없는 단점이 존재한다.

> 위와 같은 특성이 있고, collectionView의 장점인 재사용성을 이용한 prepareForReuse를 사용하도록 변경하였다

---

# 🛍오픈마켓II
## 🧐 고민한점 & 해결방법
### 📌 1. 공통 코드에 프로토콜 기본 구현 활용

상품 등록화면, 상품 수정화면 View 프로토콜 추상화로 인한 은닉화 불가능 문제

> 프로토콜 추상화에 따른 은닉화 불가능하지만 노출되면 안되는 부분에 대해서는 추상화를 하면 안되고 재사용성 있으며 은닉화가 필요하지 않는 부분을 사용하면 된다.

```swift
protocol Drawable: UIView {
    var entireStackView: UIStackView { get }
    var productInfoStackView: UIStackView { get }
    var priceStackView: UIStackView { get }
    var priceTextField: UITextField { get }
    var segmentedControl: UISegmentedControl { get }
    var productNameTextField: UITextField { get }
    var discountedPriceTextField: UITextField { get }
    var stockTextField: UITextField { get }
    var descriptionTextView: UITextView { get }
    
    func configureView()
    func configurePriceStackView()
    func configureProductInfoStackView()
    func configureEntireStackViewLayout()
    func makeStackView(axis: NSLayoutConstraint.Axis, alignment: UIStackView.Alignment, distribution: UIStackView.Distribution, spacing: CGFloat) -> UIStackView
}
```

### 📌 2. 다른 뷰에 프로퍼티 전달하는 방법

다른 뷰에 프로퍼티 전달 시 동일한 상품을 알려주기 위해 id를 활용하는 시점에서의 id값의 은닉화 문제

> ProductDetailViewController와 ProductEditViewController가 초기화 될 때 id와 productDetail을 받도록 구현하여 은닉화 문제 해결
```swift
// ProductEditViewController.swift
private let products: Products

init(productDetail: ProductDetail) {
    self.productDetail = productDetail
    super.init(nibName: nil, bundle: nil)
}

// MainViewController.swift
extension MainViewController: UICollectionViewDelegate {
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         let productDetailViewController = ProductDetailViewController(products: item[indexPath.row])

         self.navigationController?.pushViewController(productDetailViewController, animated: true)
     }
 }

```

### 📌 3. UIImagePicker에서 선택한 이미지를 순서대로 보여주는 방법

image가 선택되었을때, `didFinishPickingMediaWithInfo` 메서드 내에서 
선택된 이미지를 `imageArray에` append한다.

그리고 `cellForItemAt` 메서드에서 `imageArray[indexPath.row]`번째 이미지를 `button.setImage` 해주는 방식으로 이미지를 순서대로 보여주도록 구현한다.


### 📌 4. 여러 개의 ImageView 보여지도록 하는 방법
이미지 뷰를 여러개 등록 시, 각각 다른 이미지뷰가 나오지 않는 에러 

> cellForItemAt 메서드가 불릴 때마다 cell에 imageView를 addSubview해주고,
presenter의 images 배열 중 indexPath.row 번째의 이미지를 해당 imageView의 image에 넣어주는 방식으로 해결했다.

```swift
func setImage(_ presenter: Presenter) {
        guard let productImages = presenter.images else {
            return
        }
        
        for image in productImages {
            guard let url = URL(string: image) else {
                return
            }
            
            guard let data = try? Data(contentsOf: url) else {
                return
            }
            
            imageView.image = UIImage(data: data)
            contentView.addSubview(imageView)
        }
    }
```

```swift
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditViewCell.identifier, for: indexPath) as? EditViewCell else {
            return UICollectionViewCell()
        }
        
        cell.contentView.addSubview(cell.imageView)
        
        guard let imageArray = presenter.images else {
            return UICollectionViewCell()
        }
        
        guard let imageString = imageArray[indexPath.row].url,
              let imageURL = URL(string: imageString),
              let imageData = try? Data(contentsOf: imageURL) else {
            return UICollectionViewCell()
        }
        
        let image = UIImage(data: imageData)
        cell.imageView.image = image

        return cell
    }
```

### 📌 5. ImageView 용량 사이즈 체크
이미지 용량을 체크한 후 resize하여 저장하도록 했다.
그러나 실제 리사이즈한 것을 보게 되면 요구사항 보다 더 작은 이미지 크기가 되는 것을 확인할 수 있었다. 그래서 이를 레이아웃으로 키워서 꽉차도록 해야 하는 것인지 아니면 이대로 작아진 크기가 적절한 방법이였는지 고민되었다.

```swift 
// 구현부 
extension UIImage {
    func resize(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale

        let size = CGSize(width: newWidth, height: newHeight)
        let renderer = UIGraphicsImageRenderer(size: size)
        let renderedImage = renderer.image { context in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        
        return renderedImage
    }
    
    func checkImageCapacity() -> Double {
        var capacity: Double = 0.0
        guard let data = self.pngData() else {
            return 0.0
        }
        
        capacity = Double(data.count) / 1024
        
        return capacity
    }
}
```

```swift
// 호출부
  guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
                return
        }

        let imageCapacity = image.checkImageCapacity()

        if imageCapacity > 300 {
            let resizedImage = image.resize(newWidth: 80)
            self.imageArray.append(resizedImage)

            guard let imageData = resizedImage.jpegData(compressionQuality: 1) else {
                return
            }

            let imageInfo = ImageInfo(fileName: "marisol.jpeg", data: imageData, type: "jpeg")
            self.networkImageArray.append(imageInfo)
        } else {
            self.imageArray.append(image)
            guard let imageData = image.jpegData(compressionQuality: 1) else {
                return
            }

            let imageInfo = ImageInfo(fileName: "marisol.jpeg", data: imageData, type: "jpeg")
            self.networkImageArray.append(imageInfo)
        }
```

> RegistrationViewCell에서 imageView의 frame을 cell의 width와 height로 설정해주어 이미지가 cell에 꽉 차게 나오도록 했다.
```swift
imageView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.width)
```

### 📌 6. 상품 secret 조회를 위한 secretPost 구현

DELETE 하기 전 secretPOST를 호출 시점 문제, 또 다른 httpMethod 케이스로 분리 결정 문제

> httpMethod는 GET/POST/PATCH/DELETE 이렇게 4개만 있어야 한다고 생각했고,
POST 내부에서 분기 처리하여 구현했다.
실제 호출부에서는 CompletionHandler를 활용해서 secretPOST가 실행되고 성공한 값을 이용하여 DELETE에 활용해서 구현했다.

```swift
mutating private func makePOSTRequest(apiAble: APIable) -> URLRequest? {
        let boundary = generateBoundary()
        
        if let item = apiAble.item {
            let urlString = apiAble.url + apiAble.path
            
            guard let url = URL(string: urlString) else {
                return nil
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("multipart/form-data; boundary=\"\(boundary)\"",
                             forHTTPHeaderField: "Content-Type")
            request.addValue(UserInformation.identifier, forHTTPHeaderField: "identifier")
            request.addValue("eddy123", forHTTPHeaderField: "accessId")
            request.httpBody = createPOSTBody(requestInfo: item, boundary: boundary)
            
            return request
        } else {
            return makeSecretPOSTRequest(apiAble: apiAble)
        }
```


### 📌 7. View의 로직을 VC에서 사용함에 따른 은닉화 문제
View에서 로직 구현을 하는 것이 옳지 않기에 VC에서 로직을 구현하려고 노력했다. 그렇게 하다보니 View에서 만든 Label를 접근해서 해야하기 때문에 은닉화를 할 수 없는 상황이 있었는데 다른 방식으로 은닉화를 시도해야할지 고민했다.

```swift
final class ProductDetailView: UIView {
    ...
    private let entireScrollView = UIScrollView()
    private let productImage = UIImageView()
    let stockLabel = UILabel()
    let priceLabel = UILabel()
    let discountedLabel = UILabel()
    let productNameLabel = UILabel()
    private let descriptionTextView = UITextView()
    private let currencyLabel = UILabel()
    let pageControl = UIPageControl()
}
// VC 사용처 
private func configureProductNameUI() {
    productDetailView.productNameLabel.font = UIFont.boldSystemFont(ofSize: 15)
}

private func configureStockUI() {
    productDetailView.stockLabel.textColor = .systemGray2
    }
```

> 이런 경우 view와 controller가 모두 해당 값에 접근해야 하기 때문에, view단에서 그대로 값을 노출하도록 두었다.

### 📌 8. 네트워크 추상화

우선 각 객체의 역할을 아래와 같이 생각했다.
- `ViewController`
    - 정보 (ex: pageNo, itemsPerPage, productId)를 가지고 APIable의 request 메서드 호출
- `APIable`
    - VC에게 받은 정보로 request 메서드에서 get / post / patch / delete 구분해서 NetworkManager의 메서드 (execute) 호출
- `NetworkManager`
    - APIable에게 전달받은 host, path, params 등 조합해서 url 생성
    - url로 request 만들어서 네트워크 통신
    - 통신한 결과를 VC에 전달

APIable을 먼저 구현했는데, 
VC는 APIable의 request 메서드를 호출할 때 GET인지, POST인지를 알고 있을 필요가 없기 때문에, request 메서드의 파라미터로 받은 값에 따라 request 메서드 내부에서 httpMethod를 정해줘야 한다고 생각했다.

그런데 파라미터의 형식이 다양하다보니, APIable의 변수들과 request의 파라미터 종류가 많아졌다..

```swift
protocol APIable {
    var method: HTTPMethod? { get }
    var baseUrl: String? { get }
    var listParams: [String: String]? { get }
    var registrationParams: String? { get }
    var updateParams: Int? { get }
    var deleteParams: String? { get }
    var secretParams: String? { get }
    var images: [ImageInfo]? { get }
    
    func request(_ list: [String: String]?, _ registration: String?, _ update: Int?, _ delete: String?, _ secret: String?, completionHandler: @escaping (Result<Any, Error>) -> Void)
}

```

> APIable에는 url을 만들기 위한 base url, path, params와 httpmethod만 가지고 있도록 구현했고,
등록, 상품 상세 조회, 수정, 삭제 등과 같은 상황마다 APIable을 채택하는 구조체를 만들어줬다.

```swift
protocol APIable {
    var url: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var item: Item? { get }
    var params: [String: String]? { get }
    var productId: Int? { get }
    var secret: String? { get }
}

struct List: APIable {
    let url: String = "https://market-training.yagom-academy.kr/"
    let path: String = "api/products"
    let method: HTTPMethod = .get
    let item: Item? = nil
    let pageNo: Int
    let itemsPerPage: Int
    var params: [String: String]? {
        return ["page_no": String(pageNo),
                "items_per_page": String(itemsPerPage)]
    }
    var productId: Int? = nil
    var secret: String? = nil
```


