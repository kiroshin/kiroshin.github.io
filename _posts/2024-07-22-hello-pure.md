---
layout: post
title: 미니멀로 구성하기
categories: [Swift, Kotlin]
tags: [architecture, pure, simple, clean]
teaser: "/assets/architecture-preview.svg"
brief: 저는 클린 아키텍처의 기본 개념에 앱상태를 좀 간략히 해서 적용하고 있습니다. 아키텍처가 단순하고 직관적이면 처음 프로젝트를 열어보는 사람도 금방 적응합니다. 기존 코드를 덜어내거나 추가하기도 쉽고 데이터 흐름을 추적하는 것도 편해서 유지보수하는데 특히 도움이 됩니다.
---

안드로이드와 아이폰은 플랫폼이 다르기 때문에 동일한 결과를 내는 방법이 좀 다를 수 있습니다. 그래서 디자인만 맞추고 내부는 각자 플랫폼에 맞게 구성하는 것이 더 편할지도 모릅니다. 저는 `Android` 와 `iOS` 구성을 일관되게 끌고 가고 싶었습니다. 그래서 특정 플랫폼에만 유효한 방식은 크게 고려하지 않았어요.

물론 플랫폼에 최적화된 좀 멋지고 우아하고 신박한 방법을 찾아보지 않았던 것은 아닙니다. 개발자라면 누구나 이런 것에 흥미가 많을 테니까요. 그런데, 말이죠. 유지보수 할 때 진짜 도움이 됐는지는 사람마다 좀 다를 수 있잖아요? 이해가 좀 떨어질 수도 있고요.

이건 저에게 해당하는 말입니다. 제가 도저히 공감 못하는 것을 들고 와서 좋다고 할 때, 솔직히 어떻게 말해야 할지 모르겠습니다. 우버나 메타에서도 사용한다는데, 제가 안 된다고 할 때는 그 이유가 있어야 할 거 아닙니까. 느닷없이 그 뒷배경에 서 있는 기업들이 저의 싸움 상대가 되어버립니다.

저는 싸우기 싫습니다. 제가 집니다.


## 단순하고 직관적인 아키텍처

욕심을 한껏 부리다가, 이제 완벽해. 아름다워! 할 때가 있어요. 다음날 바로 삭제하죠. 가끔 코드 쓰는 게 허무합니다. 저는 너무 자주 틀립니다. 아키텍처 설계도 마찬가지예요. 한껏 적용해보고 얼마 지나지 않아 오버 엔지니어링으로 판단되어 폐기한 적이 많으니까요. 지금은 정말 별 거 없이 만듭니다. 여러가지 이유로 한껏 옷을 껴입었다가, 중요 부위만 가리고 다 벗는 그런 묘한 느낌이 들기도 한단 말이죠. 넘어오지 말라고 담장을 높이 쌓기 보다는, 그냥 이제는 마당에 금 몇 줄 긋고 맙니다.

제가 구성하는 건 정말 별 거 없어요. 클린 아키텍처의 기본 개념에 앱상태를 좀 간략히 해서 적용한 것 정도입니다. 저는 편하지만 이런 식의 방법은 별로 인기가 없으니 참고만 하세요.

- 종합 컨테이너 `Vessel`
- `Usecase` 는 클래스에서 함수로
- 관찰 가능한 전역 상태 `AppState`
- 상태변화는 `Action`, 자료읽기는 `Query`
- 잠깐 거쳐가는 도메인 모델
- `Gear` 는 `Worker`를 움직이는 힘
- Statefull `View`, Stateless `Show`
- 양방향도 괜찮아!

> * <https://github.com/kiroshin/PureAOS>
> * <https://github.com/kiroshin/PureIOS>


## 종합 컨테이너 `Vessel`


```kotlin
// Android
class MainActivity : ComponentActivity() {
    private lateinit var service: Vessel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            service = Vessel(LocalContext.current.applicationContext)
            Surface {
              ContentView(service)
            }
        }
    }
}
```

```swift
// iOS
@main
struct MainApp: App {
    let service = Vessel()

    var body: some Scene {
        WindowGroup {
            ContentView(service)
        }
    }
}
```

엔트리포인트를 보겠습니다. 메인은 `Vessel` 을 초기화한 뒤 자신이 소유하고, 제일 바닥에 올라가는 `ContentView` 에 서비스 컨테이너로 주입하게 됩니다. 선언형 UI입니다. 명령형 UI라고 해서 다르지는 않습니다. 어쨌든 동일한 구성입니다.

![Serving Working](/assets/architecture-serving-working.svg)

개념적인 명칭은 조금 바꿨습니다. 뷰 파트는 `Screen`, 데이터 파트는 `Worker` 입니다. 워커는 `working` 인터페이스로 서비스 컨테이너에 할당되며, 컨테이너는 `Serving` 인터페이스로 스크린에 노출됩니다.

스크린이 네비게이터라면 앞으로 생성될 뷰에 넣어줘야 하니까 컨테이너를 저장합니다. 그런데 일반적인 뷰나 뷰모델이라면 `AppState` 와 `Usecase` 를 가져간 뒤 컨테이너를 버리게 됩니다. 하나하나 주입해주는 게 아니라 박스로 줄테니 알아서 꺼내가라 정도의 설정입니다.

더 좋은 방법이 있다면 나중에라도 여기서 조금씩 바꾸면 되죠. 뭐, 괜찮습니다.

```kotlin
// Serving.kt
interface Serving {
    val appState: AppState
    val loadPersonAction: LoadPersonUsecase
    val applyRegionAction: ApplyRegionUsecase
    val moveHereAction: MoveHereUsecase
}

typealias LoadPersonUsecase = suspend (PersonIdType) -> Person
typealias ApplyRegionUsecase = suspend (Boolean) -> Unit
typealias MoveHereUsecase = suspend (Boolean, Boolean) -> String
```

```swift
// Working.swift
protocol PersonWebWork {
    func getAllPerson() async throws -> [Person]
    func walk(isLeg: Bool) async throws -> String
}

protocol PersonDBWork {
    func readAllPersonMeta() async throws -> [Person.Meta]
    func readPerson(id: Person.ID) async throws -> Person
    func updateManyPerson(_ persons: [Person]) async throws
    func fly(isWing: Bool) async throws -> String
}
```

보통은 서비스에서 워커로 의존성 방향이 흐릅니다. 이를 역전 시키려면 `working` 인터페이스를 워커가 구현하게 하는 방법밖에 없습니다. 의존성 역전은 `Clean Architecture` 에서 매우 중요하게 다루는 테마입니다. 시스템의 중심에 서비스가 배치되고, 워커는 이 시스템의 플러그인이 되는 셈이죠. 스크린도 마찬가지입니다.

스크린은 그냥 냅둬도 의존성 방향이 서비스로 향합니다. 그럼에도 `Serving` 인터페이스로 노출시킨 이유는 프리뷰나 테스트에서 컨테이너 자체를 교체할 수 있기 때문입니다(`Vessel` / `Raft`).


## `Usecase` 는 클래스에서 함수로

```
╔═[ AppState ]═╗╔═[ Repository ]═╗╔═[ Repository ]═╗
╚════╤═════════╝╚═══════╤════════╝╚═════════╤══════╝
     └─┬──────────┬─────┴────────┬──────────┴────┐
       │  ╔═[ Usecase ]═╗ ╔═[ Usecase ]═╗ ╔═[ Usecase ]═╗
       │  ╚══════╤══════╝ ╚═══════╤═════╝ ╚══════╤══════╝
       └─────────┴──────┬─────────┴──────────────┘
               ╔══[ Container ]═╗
               ╚════════════════╝
               ┌────────┴───────┐
          ╔═[ View ]═╗  ╔═[ ViewModel ]═╗
          ╚══════════╝  ╚═══════════════╝
```

어떤 시스템이든 의존 관계는 복잡합니다. 컨테이너 구성 부분을 보겠습니다. `Vessel` 은 일반적인 Container 가 아닙니다. 그래서 고민을 하다가 이름을 `Vessel` 로 지었습니다. 베쓸은 메인에서 팩토리입니다. 그래서 플러그인으로 붙게 되는 워커들을 초기화할 수 있습니다. 워커의 초기화는 경우에 따라 엄청 복잡할 수 있는데, 어찌됐든 베쓸 내부에서 다 합니다. 그렇게 베쓸이 완성되서 메인을 벗어나게 되면 `Serving` 으로 노출되는 서비스 컨테이너가 되는 것이죠.

이 과정은, 팩토리와 컨테이너를 따로 초기화 해서 주입하고 컨테이너 내부에서 팩토리를 호출해 서로 공통인 것들을 엮어서 원하는 워커를 비로소 만들어 내는, 별 의미없는 인젝션 과정을 다 생략한 형태입니다. 그런 멋진 과정은 실용적이지도 않고 몇 달 뒤 코드를 열어 수정하려고 할 때에도 별로 도움이 되지 않았어요.

서비스는 보통 클래스로 묶어 그룹으로 구성됩니다. 그러나 `Clean` 에서는 행위에 집중하기 때문에 단일 클래스에 단일 함수만 공개하는 것이 일반적입니다. 그룹 형태는 그 파일에서 관련 작업을 효율적이고 집약적으로 관리할 수 있는 장점이 있습니다. 행위 형태는 서비스 성격을 쉽게 알 수 있고 연관 로직을 직관적으로 표현하기 좋습니다.

```java
public class MovieService {
    private final MovieRepository moviestore;
    public List<Info> getMovieInfo(int id) {
        return moviestore.findInfo(id);
    }
    public void delMovie(int id) {
        moviestore.deleteById(id);
    }
    ...
}

class GetMovieInfoUsecase {
    private final MovieRepository moviestore;
    public List<Info> execute(int id) {
        return moviestore.findInfo(id);
    }
}
```

그룹이든 행위든 유지관리에 큰 차이가 있는 것은 아닙니다. 서버라면 백엔드로 들어가는 요구 스펙이 정해진 경우가 많기 때문에 그룹 형태가 좋지만, 앱이라면 `Clean` 의 방법이 나을지도 모릅니다. 왜냐면 분류하기 애매한 행위도 고민 없이 유스케이스 폴더에 던져넣을 수 있기 때문입니다.

가끔 그런 복합적인 행위를 만나게 되는데요, 예를 들어 Mute 라는 액션은 VoiceService 에 넣어야 할까요 EffectService 에 넣어야 할까요? 애초부터 SoundService 라고 만들었으면 문제가 없었겠죠! 그래서 행위 형태가 약간 더 유연합니다. 다만, 폴더를 열어 시스템의 동작을 한눈에 파악하기는 편하지만, 파일이 쪼개지기 때문에 인젝션으로 인한 구성이 조금 복잡할 수 있습니다.

유스케이스 형태는 하나의 집합적인 일을 하는 단품 서비스입니다. 이건 `SAM`(Single Abstract Method)과 다르지 않습니다.

```java
@FunctionalInterface
public interface Runnable {
    public abstract void run();
}
```

자바 쓰레딩에 흔하게 사용되는 러너블을 생각하면 됩니다. 익명클래스는 곧 람다로 대체됩니다. 유스케이스도 마찬가지로 굳이 클래스일 필요가 없습니다.

자바와는 달리 코틀린과 스위프트는 파일명과 클래스명에 대한 제약도 없고, 확장함수까지 지원합니다. 함수 자체를 파일로 분리할 수 있고 본체의 프로퍼티에 접근해 필요한 소스를 그냥 가져오면 되니까 인젝션도 필요없게 되죠.

서비스를 요청하면 클래스가 아니라 함수 포인터를 꽂아주어도 이상하지 않습니다. 워커를 lazy 처리할 경우 한 번 호출한 뒤 반환하면 되고, weak 처리할 경우 호출한 뒤 람다에 캡쳐해서 반환하면 됩니다. 즉 베쓸의 워커 관리 계획에 따라 유스케이스의 반환 형태를 달리 작성해주면 되는 것이죠. 코드를 봅시다!

```kotlin
// Vessel.kt
class Vessel(context: Context): Serving  {
    val personDBWork: PersonDBWork = PersonDBRepository(context, ...)
    val personWebData: PersonWebWork by lazy { PersonWebRepository() }
    ...
    override val loadPersonAction: LoadPersonUsecase  get() = ::loadPerson
    override val moveHereAction: MoveHereUsecase  get() {
        val pwd = this.personWebData
        return usecase@{ isLeg, isWing ->
            return@usecase moveHere(isLeg, isWing)
        }
    }
    ...
}

// Usecase
suspend fun Vessel.loadPerson(idnt: PersonIdType): Person { ... }
suspend fun Vessel.moveHere(isLeg: Boolean, isWing: Boolean): String { ... }
```

```swift
// Vessel.swift
final class Vessel: Serving {
    let personDBWork: PersonDBWork = PersonDBRepository()
    lazy var personWebWork: PersonWebWork = PersonWebRepository()
    ...
}

// Usecase
extension Vessel {
    var loadPersonAction: LoadPersonUsecase { return loadPerson }
    private func loadPerson(idnt: Person.ID) async throws -> Person { ... }
}
extension Vessel {
    var moveHereAction: MoveHereUsecase {
        let personWebWork = self.personWebWork
        return { (isLeg, isWing) in .. }
    }
}
```

베쓸은 프로퍼티로 유스케이스를 제공할 때 람다를 반환할지 내부함수를 반환할지 결정할 수 있습니다. 게다가 유스케이스가 워커 함수를 단순 연결하는 경우에도 간편합니다. 이 형태는 구성상 typealias 만 정의하면 인터페이스를 따로 만들지 않아도 되기 때문에 매우 유연합니다. 서비스 목적만 달성하면 되니까 클래스냐 아니냐는 중요하지 않습니다!

저는 이것이 Usecase 의 형태에 더 적합하다고 생각합니다. 이상하게도, 클린아키텍처 형태로 구성했다는 수많은 샘플들을 검토해봤지만 이렇게 설계하는 경우를 본 적이 없네요.


## 관찰 가능한 전역 상태 `AppState`

앱상태가 필요한 이유는 개별적인 상태의 동기화 때문입니다. 어떤 이벤트가 발생해 특정 상태로 변했을 때 이와 함께 여러 객체가 반응해야 되는 경우가 있습니다. 예를 들어 사용자가 토글을 터치해 지역정보를 꺼버렸을 때, 현재 화면뿐만 아니라 어느 화면에서도 지역정보를 보여주지 말아야 하겠죠. 이 부분은 바인딩을 사용하는 것이 좋습니다.

`AppState` 는 관찰가능한 객체입니다. `Rx` 를 사용해도 상관없지만 `Flow` 와 `Combine` 이 있는 마당에 굳이 그럴 필요는 없어 보이네요. 저는 안드로이드에서 `StateFlow`, iOS 에서 `CurrentValueSubject` 를 사용했습니다. 이것도 임포트 받기 싫으면 그냥 만들어도 됩니다. 이런 종류의 Hot observable chain 은 구현하는 것이 그리 어렵지 않습니다.

```kotlin
// AppState.kt
data class Roger (
    val sys: Sys = Sys(),
    val route: Route = Route(),
    val query: Query = Query(),
    val field: Field = Field()
) {
    data class Sys(
        val last: Signal = Signal.READY,
    )
    ...
}
```

```swift
// AppState.swift
struct Roger: Equatable {
    var sys: Sys = Sys()
    var route: Route = Route()
    var query: Query = Query()
    var field: Field = Field()
}
extension Roger {
    struct Sys: Equatable {
        var last: Signal = .ready
    }
    ...
}
```

`AppState` 는 그냥 컨테이너고 실제 상태는 내부 Value 입니다. 저는 이걸 `Roger` 라고 이름붙였습니다. 이름짓기가 함수 작성하는 것보다 어렵네요. 어쨌든 뭐라 이름붙여도 비교 가능하다면 상관 없습니다. 그리고 저는 내부를 2중 구조(`그룹-내용`)로 했습니다. 더 깊은 중첩 구조는 사용하기 번거로워서요.


```kotlin
// DetailViewModel.kt
class DetailViewModel(service: Serving, destID: PersonIdType): ViewModel() {
    val isRegionStored = service.appState.stored { it.field.isRegion }
    ...
}

typealias Stored<T> = Flow<T>

inline fun <T, R> Flow<T>.stored(crossinline transform: suspend (value: T) -> R): Stored<R>
= map(transform).distinctUntilChanged()
```

```swift
// DetailViewModel.swift
extension DetailView {
  final class ViewModel: ObservableObject {
      @Published var isRegion: Bool = true

      init(_ service: Serving, idnt: Person.ID) {
          service.appState.stored(keyPath: \.field.isRegion).give(to: &$isRegion)
          ...
      }
  }
}

typealias Stored<T> = AnyPublisher<T, Never>

extension Publisher where Self.Failure == Never {
    func stored<T: Equatable>(keyPath: KeyPath<Output, T>) -> Stored<T> {
        return map(keyPath).removeDuplicates().eraseToAnyPublisher()
    }
    func give(to published: inout Published<Self.Output>.Publisher) {
        receive(on: DispatchQueue.main).assign(to: &published)
    }
}
```

뷰모델이 앱상태를 가져오는 코드를 보겠습니다. 이 객체는 `field` 그룹의 `isRegion` 속성이 바뀌는 것에만 관심 있습니다. 여러 조건을 묶어서 다른 `Stored` 를 만들 수도 있습니다.

이쯤 되면 차라리 Multi-Source 가 낫지 않냐고 할 수도 있는데, 그러면 컨테이너만 많아지고 관리하는 것이 번거롭게 됩니다. Single-Source 가 더 유연해 보입니다. 필요한 속성을 조합하여 distinct 처리를 할 수 있고, 특정 조합이 상당히 반복된다면 리팩토링 과정에서 Shared 처리하여 부하를 더 줄일 수도 있으니까요.


## 상태변화는 `Action`, 자료읽기는 `Query`

서비스 컨테이너에서 제공하는 앱상태는 읽기전용입니다. 앱상태를 고치려면 유스케이스 액션을 반드시 거치게 했습니다. 이건 사실 불편한 방식입니다.

우리가 싱글톤을 피하는 이유는 속성 변경을 통제하기 어렵기 때문이기도 합니다. `AppState` 를 전역으로 두었을 때 발생하는 문제도 이와 같습니다. 뷰나 뷰모델 여기 저기에서 전역상태를 고쳐대기 시작하면 앱이 커질수록 점점 더 관리하기 힘들어집니다.

그래서 앱상태가 실제로 고쳐지는 부분은 한 곳에 있어야 합니다. 어차피 뷰나 뷰모델이 이걸 가져다 쓰기는 하겠지만, 그래도 한 곳에 있다면 해당 문맥상 발생하는 수정이기 때문에 통제하기 훨씬 쉬워집니다.


```kotlin
// Vessel.kt
class Vessel(context: Context): MutableStore<Roger> by MutableStateFlow(Roger()), Serving  {
    override val appState: AppState  get() = this
    ...
}

object Raft: Serving {
    private val storage: MutableStore<Roger> = MutableStateFlow(Roger(...))
    override val appState: AppState get () = storage
```

```swift
// Vessel.swift
final class Vessel: MutableStore<Roger>, Serving {
    var appState: AppState { toStore() }
    ...
}

final class Raft: Serving, @unchecked Sendable {
    private let state = CurrentValueSubject<Roger, Never>(Roger( ... ))
    static let shared = Raft()
    private init() { }
    var appState: AppState { state.toStore() }
    ...
}
```

베쓸에서 앱상태를 처리하는 부분은 코틀린과 스위프트가 약간 다르긴 합니다만, 동일하게 `Serving` 을 통해 외부로 노출되는 형태는 Read-only 입니다. 편의성 때문에 `Vessel` 에서는 자신이 직접 상태 컨테이너로 동작하게 했습니다. 그러나 필수적인 것은 아닙니다. `Raft` 처럼 내부에 private 로 갖고 있어도 상관없습니다. 상태는 오직 내부 함수인 유스케이스를 통해서만 고쳐집니다. 스위프트는 bulk update 때문에 약간의 처리를 더 했습니다만 그것도 필수적인 것은 아닙니다.

저는 `Action` 과 `Query` 를 구분하고 있습니다. 액션은 그 행위로 인해 상태변화를 촉발하는 것을 말합니다. 쿼리는 지정된 조건 하에서 일방적으로 자료를 동기화하는 것을 뜻합니다(DB의 쿼리가 아닙니다). 예를 들어 사용자 정보를 찾는 행위는 그것으로 인해 DB 검색이 이뤄지고 최근 검색 목록이 고쳐지게 됩니다. 그래서 `Action` 입니다. 반면 갱신된 데이터베이스 목록을 일방적으로 받아와서 리스트에 표현하는 것은 단순 결과이기 때문에 `Query` 입니다.

![Action Flow](/assets/architecture-action-flow.svg)

유스케이스의 대부분은 `Action` 이 되겠죠. 사용자의 Request 에 대해 어떤 식으로든 반응을 해줘야 하니까요. 액션은 모든 서비스가 다 그렇듯이 비스니스 로직에 따른 제어흐름은 탑니다. 즉 제어 코드만 있는 날씬한 어댑터입니다. 그리하여 최종적으로, 작업의 결과를 반환할 것인지 앱상태를 갱신할 것인지 아니면 둘 다 할 것인지 결정할 수 있습니다.

`Clean`으로 구성했다는 프로젝트 샘플들을 보면 가끔 유스케이스의 인자로 아웃풋포트 객체를 함께 넣는 것을 보게 됩니다. 아웃풋포트는 뷰 갱신 컴플리션 핸들러입니다. 코루틴을 이용하면 컴플리션 핸들러가 필요 없어지고 우리는 앱상태도 가지고 있기 때문에 아웃풋 포트를 구성하는 건 더더욱 의미가 없습니다.


## 잠깐 거쳐가는 도메인 모델

실제 프로젝트에서 `Model` 폴더는 도메인 데이터입니다. Entity 와 Value 가 정의됩니다. 필요하다면 aggregate 로 그룹화할 수 있겠지만, 그렇게 집합적으로 사용한 적은 없네요.


```kotlin
// PersonDBRepository.kt
private fun PureDatabase.HumanMO.toEntity(): Person {
    return Person(
        id = id,
        name = name,
        username = username,
        gender = Gender.valueOf(gender.uppercase()),
        email = email,
        age = age,
        country = country,
        cellphone = cellphone,
        photo = photo
    )
}
```

```swift
// PersonWebRepository.swift
private extension HTTPRandomuserAccess.User {
    func toEntity() -> Person {
        return Person(
            id: login.uuid!,
            name: "\(name.first ?? "") \(name.last ?? "")".trimmingCharacters(in: .whitespaces),
            username: login.username ?? "",
            gender: Gender(rawValue: gender ?? ""),
            email: email ?? "",
            age: dob.age ?? 0,
            country: nat ?? "ZZ",
            cellphone: cell,
            photo: picture.large
        )
    }
}
```

도메인 엔티티와 워커 개별 엔티티는 구별해야 합니다. 지금은 동일해 보일지는 몰라도 미래에는 일치하지 않게 됩니다. 흔한 일은 아니지만 DB 의 튜닝이나 관계형 설정에 따라 테이블을 변경할 일도 생기니까요. 그리고 이렇게 구별하는 것이 의존성 방향에 맞습니다. 제가 구성한 예시 프로젝트에서는 직관적으로 보여주기 위해 관계형으로 구성하지 않았습니다. 그래서 더욱 비슷하게 보일 수는 있습니다. 하지만 실제 앱에서 이렇게 단순하게 구성하는 경우는 거의 없습니다.

도메인 Entity 는 순수하게 유지하는 것이 정신건강에 좋습니다. 문자열, 숫자, 배열 등 기본 타입으로만 제한하면 다른 타입으로 바꿀 때도 좋습니다. SQLite 나 JSON 을 기준으로 삼아도 괜찮습니다. 저는 엔티티에 `Date` 타입도 사용하지 않습니다. 문자열로 할당했다가 DTO로 매핑할 때 날짜타입으로 바꿉니다. 이 정도 오버헤드는 아무 것도 아닙니다.

도메인 맵퍼에서는 `UTIL` 을 사용할 수도 있습니다. 유틸은 랭귀지의 스탠다드 라이브러리나 퍼스트가 제공하는 로직 프레임워크의 서브클래스 혹은 확장함수를 담습니다. 예를 들어 `String` Extention 이나 `Flow` / `Combine` 의 새로운 오퍼레이터 종류 등이 이에 해당합니다. 서드파티나 UI가 담겨서는 안 됩니다.

예시 프로젝트를 보면 `Model` 폴더에 특이하게도 에러 타입 `Fizzle` 이 정의되어 있는 것을 볼 수 있습니다.


```kotlin
// Fizzle.kt
sealed class Fizzle(msg: String): Exception(msg) {
    class Unknown : Fizzle("An unknown error has occurred.")
    class NoInternet: Fizzle("Check Your Internet Connection.")
    ...
}
```

```swift
// Fizzle.swift
enum Fizzle: LocalizedError {
    case unknown
    case noInternet
    ...
    var errorDescription: String? { switch self {
        case .unknown: return "An unknown error has occurred."
        case .noInternet: return "Check Your Internet Connection."
        ...
    } }
}
```

서비스로 올라오는 에러는 반드시 사용자에게 알려야만 하는 에러입니다. 개발자가 보는 에러가 워커에서 서비스로 빠져서는 안 된다고 생각합니다.


## `Gear` 는 `Worker`를 움직이는 힘

![Worker visibility](/assets/architecture-worker-visibility.svg)

워커의 가시성은 도메인이나 유틸을 포함하여 `Gear` 도 해당합니다. 기어는 서드파트 로직 라이브러리를 래핑하거나 외부 API 를 접근하는 엑세서 등을 정의할 때 사용합니다. 기어가 의존하는 것은 외부 드라이버나 내부 유틸뿐입니다. 현재 시스템에 독립적이므로 다른 프로젝트에서도 완전히 재활용 가능합니다.

워커는 유틸이나 기어를 핸들링하여 내부의 `working` 인터페이스를 구현하는 객체입니다. 그래서 하는 일이 많습니다. 데이터베이스뿐만 아니라 이미지 처리나 사운드 리소스도 담당할 수 있고 파일 작업을 할 수도 있습니다.

워커에서는 에러가 발생하기 쉽습니다. 에러 핸들링은 워커에서 모두 처리한 상태로 서비스에 반환되어야 합니다. 네트워크처럼 일시적인 오류면 다시 시도해볼 수 있고, DB의 경우 없는 자료를 사용자가 요구할 때는 적절한 `Fizzle` 타입을 반환하여 사용자에게 알려야 합니다. 어처구니없는 에러라면 여기에서 로깅을 해야 합니다. 이런 데이터는 나중에 개발자에게 보내질 것입니다.


## Statefull `View`, Stateless `Show`

뷰나 뷰모델의 경우도 가시권이 `SHOW` 를 비롯해 도메인 모델과 유틸을 포함합니다. 쇼는 `UiKit` 클래스를 재정의 하거나, `SwiftUI` 나 `Composable` 단품 뷰를 정의하게 되는 시스템 독립적인 UI Component 입니다. 예시 프로젝트 내부에는 `Show` - `Util`- `Gear` 가 함께 있지만 별개 라이브러리로 빠져도 상관없습니다. 독립적이니까요.

![Butterfly](/assets/architecture-butterfly.svg)

예전에는 라우터를 만들어서 뷰를 런칭하곤 했습니다. 그랬던 이유는 Ui Controller 간 의존성을 없애고 구성 시 필요한 각종 객체를 주입하기 위해서였습니다. 명령형 UI 에서는 한 화면을 구성하기 위해 컨트롤러 내부에서 해야 될 작업이 굉장히 많습니다. UI빌더로 XML 형태의 닙을 만들어 세부 설정을 하는 경우도 있었고, 레이아웃만 잡은 뒤 코드로 올리고 컨트롤 하는 경우도 많았습니다. 차일드를 독립시켜 재활용 하기 위해 뷰모델을 주입하는 경우도 있었죠.

그러나 차일드 컨트롤러를 독립시킬수록 우리의 기대와는 다르게 구성이 복잡해지고 수정할 때 불편해진다는 것을 어렵지 않게 경험하게 됩니다. 차라리 Ui Controller 의 재활용을 깔끔하게 포기하고 컴포넌트의 재활용을 극대화하는 건 어떨까요?

저는 한 화면을 구성하는 바닥 판을 Screen 폴더에 넣고 있습니다. Ui Controller 인 거죠. 이 컨트롤러 뷰는 한 화면 전부를 담당하고 한 개의 뷰모델만 가질 수 있도록 제약을 했습니다. 말하자면 바닥의 뷰만 상태를 가지며, 나머지는 상태를 가질 수 없는 것입니다. 선언형 UI 의 권고 사항은 명령형 UI 구성에도 참 많은 아이디어를 줍니다.

쇼가 유틸을 사용할 수도 있고, 간혹 기어가 컴포넌트를 만들어주는 경우도 있을 것입니다(이럴 경우 기어는 싱글톤으로 쓰이거나 단순 함수 형태일 것입니다). 그럼에도 가시권이 시스템 내부를 향하지 않기 때문에 다른 프로젝트에서 완전히 재활용 가능합니다. 이와 같은 독립 컴포넌트를 Ui Controller 에서 끌어와 구성하고 바인딩 값을 넣어주는 건 약간 번거로울 수 있습니다. 하지만 중간 컴포넌트를 만들어 줌으로써 어느 정도 극복할 수 있습니다. 이 단순한 규칙은 Trade-off 관계임에도 불구하고 Ui Controller 가 이전보다 훨씬 가벼워지기 때문에 유지보수에 매우 큰 효과를 냅니다.

컴포넌트를 구성할 때 정말 다목적으로 사용하기 위해 극도로 일반화하는 경우가 있습니다. 그런데 이러면 Configurator 구성이 매우 복잡해져 오히려 사용성이 떨어집니다. 적당한 목적에 맞는 적당히 다양한 중간 컴포넌트를 만드세요. 기능이 약간 중복되어도 괜찮습니다. 현재의 화면 구성이 Alert 이나 Sheet 같은 데에서 완전히 동일하게 쓰일지라도 시간이 지나면 조금씩 달라지는 경우가 많습니다. 완전한 재활용을 기대했지만 실제로는 그렇게 되지 않습니다. 그래서 `의도적 중복`은 나쁘지 않습니다.


## 양방향도 괜찮아!

오브젝트 인젝션은 여러 방법이 있는데, 특정 객체에게 필요한 자료를 하나하나 주입하게 되면 조립이 너무 번거롭게 됩니다. 그렇게 한다고 해서 테스트가 더 쉬워지는 것도 아니고요. 차라리 `Serving` 처럼 인터페이스를 노출하고 컨테이너를 넘기는 편이 여러모로 낫습니다.

```kotlin
// DetailView.kt
@Composable
fun DetailView(service: Serving, target: PersonIdType) {
    val viewmodel: DetailViewModel = viewModel(factory = DetailViewModel.by(service, target))
}
```

```swift
// DetailView.swift
struct DetailView: View {
    @StateObject private var viewmodel: ViewModel
    init(_ service: Serving, target: Person.ID) {
        _viewmodel = StateObject(wrappedValue: ViewModel(service, idnt: target))
    }
}
```

- 뷰모델이 있는 뷰: 컨테이너를 그대로 뷰모델로 넘긴다.
- 뷰모델: 필요한 걸 뽑아서 저장하고 컨테이너를 버린다.
- 뷰모델이 없는 뷰: 뷰모델이 한 과정을 동일하게 한다.
- 네이게이터: 컨테이너를 저장한다. 런칭될 뷰에 제공해야 하니까.

뷰의 전개 과정에서 전제되는 것은 퍼스트가 제공하는 것처럼 뷰트리로 진행된다는 점입니다. 저는 가끔 RIBs 정도는 써줘야 진정한 개발자로 성장한다는 분을 목격하게 됩니다. 그런 측면에서 저는 아직 갈 길이 먼 파릇파릇한 개발자입니다. 뷰트리 진행 과정에서 그 흔한 뷰모델 주입도 하지 않으니까 말이죠. 오직 서비스 컨테이너와 네비게이터에서 넘겨받은 인자 정도 넣고 끝나는, 그런 시시하고 고전적인 방법을 사용합니다.

이렇게 해도 문제가 없는 건 우리가 이미 컨테이너 구성을 끝냈기 때문입니다. 이제 서비스가 뷰트리에 의해 좌지우지 되지는 않습니다. 게다가 네비게이터는 뷰모델까지 신경쓰지도 않으니 런칭 구성이 가볍습니다. 이 부분은 매우 중요합니다. 교체를 고려했다면 뷰모델 인터페이스를 만든거나 하다못해 서브클래싱 가능하게 조치를 취했을 것입니다. 그러나 앞서 설명한 구조상 뷰모델 교체는 불필요합니다. 테스트는 컨테이너를 교체함으로써 진행할 겁니다. 뷰모델은 뷰 내부에 있는 final 클래스이며 뷰가 직접 볼 수 있는 뷰의 선택사항일 뿐입니다.

뷰의 갱신 과정도 MVI 나 TCA 를 반드시 써야 하다고 생각하는 분이 있을 겁니다.

공원을 산책하는데 어린이들이 놀고있는 풋살장 펜스 너머로 축구공이 넘어왔다고 합시다. 공을 다시 뻥 차서 펜스로 넘겨주어야 할까요? 아니면 뒤돌아 가서 펜스 문을 열고 던져주어야 할까요? 뭐가 됐든 상관없지만 트래핑 잘 할 수 있게 주면 그만이겠죠. 기특하게도 어린이들은 공을 잘 받습니다.

구조만 단순하다면 단방향은 굉장히 좋습니다. 데이터 흐름을 놓치는 것은 `State` 때문일텐데 단방향은 확실히 실수를 줄여줍니다. 그러나 단방향이라 하더라도 상태를 고려하지 않으면 스텝이 꼬이는 건 마찬가지이고, 양방향이라 하더라도 상태를 고려하여 결과값을 갱신해주면 단방향과 큰 차이가 없게 됩니다. 저는 구조만 단순하다면 단방향이든 양방향이든 상관없다고 생각합니다. 구조가 복잡하면 뭐든 엉망이 되기 쉽습니다.

어찌됐건 퍼스트가 제공한 기본 구조를 너무 비틀지는 않았으면 좋겠습니다. 후유증이 커지게 됩니다. 퍼스트가 기침만 해도 폭풍을 만나게 되는 것이죠. 특히 선언형 UI 에서는 리컴포지션 때문에 컨텍스트가 매우 민감합니다. 뷰모델을 외부에서 주입하는 것이 별로 좋지 못한 이유이기도 합니다.

이렇게... 저의 단순하고 시시한 아키텍처를 전체적으로 살펴보았습니다. 다시 말하지만, 이런 식의 방법은 인기가 별로 없습니다. 큰 기업에서 만들거나 깃허브 별이 많은 구조가 심리적으로 더 안정감을 줄 수 있습니다.

이번 포스트는 잔소리처럼 정말 길었네요. 앞으로는 짧게 써야겠습니다.

