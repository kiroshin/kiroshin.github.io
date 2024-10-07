---
layout: post
title: Pure Python Qt Desktop App
categories: [Python]
tags: [pyside6, qasync, aiohttp]
teaser: "/assets/pure-python-pyside6-preview.jpg"
brief: 파이썬으로 크로스 플랫폼 데스크톱 앱을 만드는 것이 흔한 일은 아닙니다. Qt 는 일반적인 범위에서는 충분히 많은 기능을 제공하고 있으며 속도도 빠르고 안정적입니다. 이번에는 지난 포스트에서 소개한 아키텍처를 Python 과 Qt 를 이용해 구성해 보겠습니다.
---

파이썬은 세상에서 가장 배우기 쉬운 언어입니다. 저는 초등학생 제 아이에게도 재미삼아 가르치고 있습니다. 제가 그만한 나이 때 동네에 컴퓨터 학원이 생겼는데 베이직을 가르쳤습니다. 지금은 그 코드가 기억나지도 않네요. 당시 주로 페르시아 왕자 같은 게임을 했던 기억밖에는... 하지만 제 아이는 커서도 파이썬을 기억하고 사용할 수 있을 것 같습니다. 제가 보기에 파이썬은 생명력이 아주 길 것 같네요.

파이썬은 무척이나 느리지만 언어 자체가 쉽다는 것은 모든 단점을 상쇄하고도 남습니다. 코드 작성의 피로도를 굉장히 줄여주고 논리에만 집중할 수 있게 해줍니다. 다른 언어로 작성된 다양한 라이브러리를 끌어다 쉽게 쓸 수 있고 유지보수 하기에도 편합니다.

그러나 제가 파이썬을 접하고 매우 놀라웠던 점은 GIL(Global Interpreter Lock)의 존재입니다. '쉽게' 사용할 수 있는 것이 절대적인 원칙이라 이러한 제약을 걸어놓은 것이 분명하지만, 제대로 락킹되지 않으면서도 CPU 효율만 떨어뜨리는 아무짝에도 쓸모 없는 제약이기 때문입니다. 그래서 파이썬의 동시성 프로그래밍은 다른 언어에서 사용하는 것과 사뭇 다르게 작동합니다.

GUI 프로그래밍은 화면을 갱신하는 런루프가 돌기 때문에 동시성은 필수입니다. 이를 고려하지 않고 작성하면 해당 작업이 완료될 때까지 화면이 먹통됩니다. GUI 가 먹통이 된 채 몇 분이 지나면 OS는 해당 프로세스를 그냥 죽여버립니다. 수 초 이내에 끝나는 작업이라 하더라도 사용자는 앱이 뚝뚝 끊긴다는 느낌을 받게 됩니다. 따라서 사용자가 보내는 액션을 처리하는 코드는 반드시 동시성으로 처리해야 합니다. threading 이든 asyncio 든 상관없습니다.

파이썬에서 활용할 수 있는 GUI 툴킷은 내장된 `Tk` 를 비롯해 `wx`, `qt` 들이 있는데, 그 중에서 활용도가 가장 으뜸인 것이 `qt` 입니다.

Qt 는 C++ 로 작성된 크로스 플랫폼 GUI 툴킷으로 아직까지 가장 많이 사용하는 버전은 Qt5 버전입니다. 현재는 Qt 6.7 까지 나왔습니다. 파이썬에서 활용할 수 있는 것은 `PyQt` 와 그보다 조금 더 늦게 나온 `PySide` 가 있습니다. PyQT 는 RiveBank Computing 이라는 곳에서, PySide 는 QT 본사인 The Qt Company 에서 관리합니다. 저는 Qt5 버전을 사용할 때에는 PyQt 를, Qt6 버전부터는 PySide 를 사용하고 있습니다. 둘이 거의 비슷해서 뭐가 좋고 나쁘고 할 게 없네요. 똑같은 Qt 라이브러리 링킹입니다.

사실, 파이썬으로 데스크톱 앱을 만든다는 게 그리 흔한 일은 아닙니다. 요즘 크로스 플랫폼 데스크톱 앱은 자바스크립트 일렉트론 기반으로 나오더군요. 그러니까 데스크톱 윈도우 화면에 웹페이지를 띄워서 GUI 를 그려내는 방식입니다. 대표적으로 [VSCode](https://code.visualstudio.com), [Github Desktop](https://github.com/apps/desktop), [Figma](https://www.figma.com/downloads/), [Postman](https://www.postman.com/downloads/) 등이 생각나네요. 제가 보기에 단점은 용량이 크고 이벤트 반응성이 좀 떨어지는 것 정도입니다. 개발사 입장에서는 웹 페이지의 구현로직을 그대로 데스크톱 앱에 사용할 수 있고, 플러그인 구조도 개방적으로 만들 수 있고, 개발인력과 개발기간도 줄일 수 있는 등 정말 엄청난 장점이 있는 것이죠. 특히 자유도에서 일렉트론을 따라갈 툴킷이 없는 것 같습니다. [윈도우95흉내](https://github.com/felixrieseberg/windows95) 까지 하는 걸 보면 할 말 다 했죠.

저는 윈도우용 클라이언트를 제공하고 싶었는데, 자바스크립트나 C# 은 제가 모르는 분야라 어쩔 수 없이 파이썬으로 개발하게 되었습니다. 그래서 선택한 QT 였는데,,, 이거 꾀나 방대합니다. 역시 쉬운 건 없나 봅니다. 장점은 일렉트론에 비해 그리 많지 않습니다. C++ 기반이라 좀 빠르다는 것 정도입니다. 다행스러운 것은 문서가 매우 친절합니다. 애플의 AppKit 보다 훨씬 친절해서 놀랐습니다.

작년에 마지막으로 작성했던 것까지는 쓰레딩 기반으로 올렸는데, 이번에는 Asyncio 를 이용해서 연결했습니다. 문제는 PySide6.6 부터 제공하는 있는 [QtAsyncio](https://doc.qt.io/qtforpython-6/PySide6/QtAsyncio/index.html) 가 미완성이라는 점입니다. 깃허브에 올라온 최신 6.7용 코드조차 미완성입니다. 도대체 이 상태로 왜 릴리즈 했는지 이해할 수 없더군요.

그래서 Qt Runloop 를 asyncio 로 포장해줄 서드파티로 [qasync](https://github.com/CabbageDevelopment/qasync) 를 사용했습니다. 비슷한 라이브러리 중 가장 좋았습니다. 가장 군더더기 없고요. 이렇게 작성해야죠!

## 예시 프로젝트
>> <https://github.com/kiroshin/PurePYQ>


## main
메인부터 시작합시다. 헤드에 달린 주석은 [Nuitka](https://nuitka.net) 컴파일 옵션입니다.

```
(.venv) user@mac PurePYQ % nuitka Pure/main.py
(.venv) C:\Github\PurePYQ> nuitka Pure/main.py
```

물론 일반적으로 많이 사용하는 [PyInstaller](https://pyinstaller.org/) 를 사용할 수도 있습니다.

```
(.venv) user@mac PurePYQ % pyinstaller pure.spec
(.venv) C:\Github\PurePYQ> pyinstaller pure.spec
```

코드 사인 관련 항목을 빠져 있습니다. 혹시나 기업에서 정식으로 배포할 때에는 넣어줘야 합니다.

저는 Nuitka 를 사용하고 있습니다. Python 코드를 C 코드로 바꾼 뒤 완전히 컴파일하는 방식입니다. PyInstaller 와 비교하여 동작 속도는 별 차이 없는데(더 느릴 수 있습니다), 용량은 조금 줄일 수 있습니다. 둘 다 매우 훌륭하게 배포본이 만들어집니다. 다만 onefile 옵션은 빼는 것이 좋습니다. 이 방식은 동작한다 하더라도 결코 좋은 형태는 아닙니다. 앱을 실행하는 순간에 캐시에 모든 걸 풀어낸 다음 런칭됩니다. 이보다는 standalone 으로 처리된 dist 를 [Actual Installer](https://www.actualinstaller.com) 나 [InstallForge](https://installforge.net) 로 패키징하는 것이 좋습니다. 맥이라면 만들어진 앱 번들을 맥 내장 디스크 유틸리티에서 dmg 이미지를 만들거나 좀 더 일반적으로 '끌어서 Application 에 넣기' 를 제공하는 [DropDMG](https://c-command.com/dropdmg/) 를 사용하는 방법이 있습니다.

그 외의 내용은 환경설정과 초기화입니다. 앱의 전체적인 구조도 [이전 포스트](https://kiroshin.github.io/2024-07-22-hello-pure) 에서 말씀드렸던 것과 동일하게 구성되어 있습니다. 다만 안드로이드나 아이폰 등 보통의 GUI 프로그래밍에서 자동으로 해주는 것을 수동으로 잡아줘야 하는 번거로움이 있습니다.


## app state

역시나 이전에 언급한 것과 동일하게 싱글 소스로 구성합니다. 퍼블리싱 구조는 Rx 나 Combine, Flow 등과 동일하게 Hot observable chain 으로 구성했습니다. 이건 나중에 얼마든지 shared 로 튜닝할 수 있습니다. 파이썬에 내장된 게 없기 때문에 직접 만들었습니다. UTIL 에 있는 publisher 와 store 가 그것입니다.

여기에는 [FBLPromises](https://github.com/google/promises/blob/master/Sources/FBLPromises/FBLPromise.m) 처럼 일반적인 Promise 구조가 어울리지 않습니다. 이러한 구조는 Future 나 Task 등 수신 객체와 생사를 함께할 때 사용합니다. 앱상태를 수신하는 객체는 언제든 죽을 수 있기 때문에 이 구조를 사용하게 되면 해제 처리를 따로 해줘야 합니다. 그래서 모든 리소스를 담아 Disposable 로 반환하는 Rx 구조가 낫습니다. 또한 hot 상태를 lazy 로 만들기 위해 subscribe 발생 시 역구조로 타고 올라가야 합니다. publisher 는 stacked lambda 로 처리하고 있습니다.

이전에 아이폰 개발에 Obcj 를 사용하던 시절 [ReactiveObjC](https://github.com/ReactiveCocoa/ReactiveObjC) 를 분석한 적이 있는데 솔직히 너무나 좋지 않았습니다. 그래서 Objc 용으로 observable 을 완전히 새로 구현했는데, 파이썬용으로 된 publisher 는 그때 사용한 로직 일부를 매우 단순화시켜 일부만 남겨둔 것입니다. 왜냐면 app state 를 만들 store 딱 그 용도로만 쓰기 위해서입니다. 다양한 오퍼레이터가 필요하지도 않고, 에러핸들링을 체인 내부에서 할 필요도 없고, 체인 내부에서 다른 퍼블리셔가 반환되지도 않고, 실패 타입이 들어오지도 않기 때문입니다.

AppState 에는 QT 의 Signal 을 쓸 수 없습니다. 이건 Promise 의 구조에 가깝습니다. 만약 예고 없이 죽으면 댕글링이 발생합니다. 제일 밑바닥 판으로부터 올라가는 차일드뷰나 뷰모델은 Signal 로 연결할 수 있습니다. 그런데 생성 시 parent 를 할당해줘야 합니다. 그래야 라이프사이클 상 죽는 시점과 죽는 신호를 부모에게 보낼 수 있습니다. 효율적이긴 하지만 이 쌍방 참조 방식은 좀 위험합니다. 엄격한 수직 그래프가 그려지는 구조에서만 사용해야 합니다. 저는 SCREEN 에서만 쓰고 있습니다.

AppState 에 사용한 publisher 는 weak 로 리소스를 붙잡으며 전체적으로 수평 구조로 구성됩니다. 모든 리소스는 Ticket 에 담겨 반환되며, 앱 상태가 바뀔 때마다 수신객체의 생사를 확인합니다. 파이썬은 가비지 콜렉터를 사용하고 있기 때문에 수신객체를 weak 처리해도 즉각적으로 반응하지는 않습니다. 그럼에도 런루프 몇 번에 해제됩니다. 가비지 콜렉터는 많은 사람들이 우려하는 것과는 대조적으로 성능이 꽤나 좋습니다.

내부 자료로 Roger 객체를 취합니다. 객체 이름은 중요하지 않습니다. 이 자료구조가 immutable 인 것이 중요합니다. 따라서 업데이트할 때 객체 전체를 Shallow Copy 하여 새로운 포인터 주소를 갖는 객체로 만들어주어야 합니다.

```python
# usecase/apply_route.py
def _update(value: Roger, uid: str) -> Roger:
    route = value.route._replace(uid=uid)
    return value._replace(route=route)
```

파이썬에서는 더 간편한 방법이 떠오르지 않네요. named tuple 의 `_replace` 를 이용했습니다. 좋아하는 방법은 아니지만 store 의 `set` 메서드를 통해 키밸류 형태의 딕셔너리를 입력받아 갱신할 수도 있게 해놨습니다. 이럴 경우 가능하면 키 타입을 미리 정의하거나 베쓸에서 set 함수를 재정의 해서 조금 더 명시적으로 사용하기를 추천드립니다. 앱이 커지면 암시적인 형태는 암초가 됩니다.


## usecase
파이썬은 컴파일 언어가 아니기 때문에 클래스의 확장함수를 지원할 수 없는 구조입니다. kotlin 이나 swift 처럼 다른 파일에 특정 클래스의 함수를 정의하는 것이 불가능합니다. 외부 함수를 특정 클래스에 끼워넣기 위해서 몽키패칭을 떠올릴 수 있는데, 이 역시 암초이기 때문에 다루지 않겠습니다. 그 다음으로 떠올릴 수 있는 건 가장 무난한 방법인 callable class 를 만들어서 배쓸에서 가져오는 것인데, 번거롭습니다. 그 다음으로는 런타임 체킹 방식인 파이썬 Protocol 을 정의하여 usecase 에서 참조하는 방식인데, 역시 번거롭고 프로토콜이 큰 의미를 갖지 못합니다. 그래서 다른 프로젝트에서 했던 것처럼 람다로 처리했습니다.

```python
# serving.py
IsShow = bool
ApplyRegionUsecase = Callable[[IsShow], Awaitable]
```

```python
# vessel.py
@property
def apply_region_action(self) -> ApplyRegionUsecase:
    # 순환참조를 방지하기 위해 함수 내부에서 import 합니다.
    from usecase.apply_region import apply_region_action
    return apply_region_action(self)
```

```python
# usecase/apply_region.py
def apply_region_action(self: Vessel) -> ApplyRegionUsecase:
    async def _action(is_show: bool):
        await self.update(_update, is_show)
    return _action
```

이렇게 하면 베쓸의 함수 일부를 외부로 떼어낼 수 있습니다. usecase 를 따로 떼어내는 이유는 이전 포스트에서도 언급했듯이, 이 방식이 조금 더 유연하고 동작을 한눈에 파악하기 더 쉽기 때문입니다. 서버라면 서비스 형태가 명확히 정해져 있기 때문에 굳이 이럴 필요는 없지만, 앱이라면 서버로부터 오는 데이터 가공하여 그 외의 처리도 해야하기 때문에 사용자 액션에 따른 세부 작업이 특정 그룹으로 묶기에는 애매한 경우가 많습니다.

유스케이스는 command 가 아닙니다. 실제 작업은 전부 worker 에서 수행합니다. 유스케이스는 이를 핸들링하는 컨트롤 로직만 있습니다.

```python
# usecase/build_app_data.py
def build_app_data_action(self: Vessel) -> BuildAppDataUsecase:
    async def _action(is_init: bool):
        try:
            if not is_init:
                await self.person_local_work.clear_database()
            if not await self.person_local_work.count():
                await asyncio.gather(
                    self.notice("Downloading..."),
                    self.person_web_work.get_person_all()
                )
            metas = await self.person_local_work.get_person_meta_all()
        except Fizzle as e:
            await self.notice(e.msg())
        else:
            await self.update(_update, metas)

    return _action

# == 앱 데이터를 구축한다 ==
# 1. 이니셜 과정이 아니면 먼저 데이터베이스를 지우고 나서 새로 받는다.
# 2. 메타데이터를 가져와서 앱 상태를 갱신한다.
# 3. 이 과정에서 오류가 있으면 메시지를 보낸다.
```

이처럼 액션을 수행하기 위해 각각의 워커에서 자료를 교환하거나 정보를 보내는 중개자에 불과합니다.


## worker

워커는 GEAR 를 이용하여 실제 작업을 수행합니다. 그래서 GEAR 를 알고 있습니다. 예를 들어 서버의 rest api 에 접속해 자료를 가져올 때 자신이 `request` 를 사용할지 `aiohttp` 를 사용할지 알고 있다는 뜻입니다. 지정한 메서드까지는 일단 async 로 연결됐지만, gear 에 따라 threading 으로 실행시킬지, asyncio 로 실행시킬지 결정할 수 있습니다. 또한 gear 로부터 발생하는 모든 오류처리를 담당합니다. 아래 예시를 보면 `get_person` 메서드는 sqlite3 의 에러와 aiohttp 의 에러를 다루고 있습니다.

```python
# -- person_repository 하나면 충분하지만, 프로젝트에서는 일부러 두 개로 나누었습니다. --
# person_local_repository.py
# working - PersonLocalWork impl
async def get_person(self, uid: PersonID) -> Person:
    try:
        human = self.database.read_human(uid)
        person = _person_from_human(human)
        photo_name = self.cache.get_cache_path(person.photo)
        if not photo_name:
            photo_raw = await self.access.get_picture(human.photo)
            photo_name = self.cache.set_cache_file(human.photo, photo_raw)
        person.photo = photo_name
        return person
    except sqlite3.OperationalError as e:
        logging.error(e)
        raise DBFizzle.operation_error()
    except aiohttp.ClientError as e:
        logging.error(e)
        raise WebFizzle.connection_error()
    except Exception as e:
        logging.critical(e)
        raise Fizzle()
```

그리고 working 을 구현하는 이 객체들은 상호 의존성이 없습니다.

이 메서드는 working 요구사항을 충족하기 위해 구현된 것으로, 주된 작업은 db에서 자료를 빼오고 이 과정에서 photo 가 캐시에 없으면 내려받는 일입니다. 어쩌면 local 은 photo 를 인터넷에서 내려받기 위해 web 이 필요할 수 있습니다. 그러나 local_repository 와 web_repository 는 수평관계로, 서로 참조할 수 없습니다. local 에서 http 통신이 필요하면 web 이 가지고 있는 네트워크 기어를 통해 수행해야 합니다. repository 는 working 을 충족시키기 위한 객체이며 usecase 에서만 호출됩니다. 공통 로직이 필요하면 그걸 처리하는 객체를 공유하십시오.

```python
# vessel.py
def create_workers(self, db_path, app_cache_path):
    access = HttpAioRandomuserAccess()
    database = DBStore(db_path, Asset.Script.schema)
    cache = FileStore(app_cache_path)
    self.person_web_work = PersonWebRepository(access, database)
    self.person_local_work = PersonLocalRepository(database, cache, access)
```

현재 프로젝트에서는 web 과 local 이 서로 access 를 공유하고 있습니다. 만약 이렇게 했음에도 불구하고 동일 코드를 두 번 작성해야 한다면 그냥 두 번 작성하세요. 의도적 중복입니다. 시간이 지날수록 이 코드는 달라지게 될 것입니다. 중복 하나 없이 꽉 조이게 프로그래밍 하고 싶은 건 어느 개발자나 같은 마음이겠지만 유지보수 하다보면 꼭 그렇게 하는 것만이 정답이 아니라는 걸 느끼게 됩니다. 나중에 뜯어낼 때 더욱 고생하게 될 수도 있으니까요.


## fizzle

이 객체는 Custom Exception 입니다. 이름은 중요하지 않습니다. Panic 이라고 해도 되고 그냥 Error 라고 해도 됩니다. swift 에서는 enum으로 kotlin 에서는 sealed class 로 구성했는데, python 에서는 일반 클래스로 만들었습니다. 형태가 중요한 게 아니라 위치가 중요합니다. 이 예외 객체가 model 에 있는 이유는 usecase 와 worker 간 에러 핸들링을 위해서입니다.

```python
@final
class DBFizzle(Fizzle):
    def __init__(self, msg="DB Error"):
        super().__init__(msg, 0b_0100_0000)

    @classmethod
    def operation_error(cls):
        return cls("Database operation failed")

    @classmethod
    def db_fail(cls):
        return cls("Database is damaged")
```

worker 는 정말 다양한 gear 를 취급하는데, 거기서 발생한 에러처리 결과를 fizzle 을 통해 반환합니다. usecase 는 worker 에서 fizzle 이 발생하면 사용자에게 알립니다. 즉, 사용자에게 알릴 메시지는 딱 정해져 있다는 뜻입니다. gear 에서 발생한 오류가 사용자에게 직접 보여지게 되면 안 되고, 이러한 오류 때문에 앱이 뻗어서도 안 됩니다. 저는 이 부분을 굉장히 중요하게 생각합니다.

에러처리는 참 번거롭습니다. 저도 잘 압니다. 그러나 어쩝니까. 안정적이기 위해서는 에러 핸들링이 촘촘해야 합니다.

```python
try:
    self.some_handler.action()
except Exception as e:
    logging.critical(e)
    raise Fizzle()
```

일단은 이 정도로 시작해보세요. 그리고 나서 테스트하면서 Exception 을 구체적으로 추가하면 코드 작성이 조금 더 수월할 수 있겠네요.


## 마무리

데스크톱 앱은 모바일 앱보다 조금 더 어렵습니다. 이벤트 처리할 것도 더 많고 사용자의 행동을 통제하기도 힘듭니다. 그래서 모바일 앱보다 신경을 더 많이 써야 합니다. 이번에 간단하게 구성한 데스크톱 앱은 아키텍처를 설명하기 위한 것이라 뭘 처리할 것도 없었지만, 실제 배포하는 앱에서는 정말 말도 안 되는 경우까지 고려해야 합니다. 그래서 시간이 배는 더 걸리는 것 같습니다.

QT는 네이티브에 버금가는 GUI 와 간편한 EVENT 처리를 지원하는 상당히 훌륭한 툴킷입니다. 게다가 파이썬은 그 풍부한 생태계로 무한에 가까운 사용성을 갖추고 있습니다. 저는 이 둘의 조합이 매우 좋은 구성이라고 생각합니다. 비록 대세는 아니지만 일반적인 범위에서는 충분합니다. 저는 마음에 듭니다.
