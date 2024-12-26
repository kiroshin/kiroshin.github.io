---
layout: post
title: Pure Python Qt Desktop App
categories: [Python]
tags: [pyside6, qasync, aiohttp]
teaser: "/assets/pure-python-pyside6-preview.jpg"
brief: 파이썬으로 크로스 플랫폼 데스크톱 앱을 만드는 것이 흔한 일은 아닙니다. Qt 는 일반적인 범위에서는 충분히 많은 기능을 제공하고 있으며 속도도 빠르고 안정적입니다. 이번에는 지난 포스트에서 소개한 아키텍처를 Python 과 Qt 를 이용해 구성해 보겠습니다.
---

파이썬에서 활용할 수 있는 GUI 툴킷은 내장된 `Tk` 를 비롯해 `wx`, `qt` 등이 있는데, `qt` 가 가장 좋습니다. QT는 꾀나 방대합니다. 다행스러운 것은 문서가 매우 친절합니다. 애플의 AppKit 보다 훨씬 친절합니다.

Qt 는 C++ 로 작성된 크로스 플랫폼 GUI 툴킷으로 아직까지 가장 많이 사용하는 버전은 Qt5 버전입니다. 현재는 Qt 6.7 까지 나왔습니다. 파이썬에서 활용할 수 있는 것은 `PyQt` 와 그보다 조금 더 늦게 나온 `PySide` 가 있습니다. 저는 Qt5 버전은 PyQt를, Qt6 버전부터는 PySide를 사용하고 있습니다.

작년에 마지막으로 작성했던 것까지는 쓰레딩 기반이었는데, 이번에는 Asyncio 를 이용해서 연결했습니다. 그런데 PySide6.6 부터 제공하는 있는 [QtAsyncio](https://doc.qt.io/qtforpython-6/PySide6/QtAsyncio/index.html) 가 미완성이라는 점이 문제였습니다. 그래서 Qt Runloop 를 asyncio 로 포장해줄 서드파티로 [qasync](https://github.com/CabbageDevelopment/qasync) 를 사용했습니다. 비슷한 라이브러리 중 가장 군더더기 없이 좋았습니다.

GUI 프로그래밍은 화면을 갱신하는 런루프가 돌기 때문에 동시성은 필수입니다. 사용자가 보내는 액션은 반드시 동시성으로 처리해야 합니다. 현재 프로젝트는 서비스가 asyncio 로 연결되어 있습니다. 아마 worker 내부에서는 threading 으로 처리할 일이 많을 겁니다.


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

코드 사인 관련 항목은 빠져 있습니다. 기업에서 정식으로 배포하려면 넣어야 합니다.

저는 Nuitka 를 사용하고 있습니다. Python 코드를 C 코드로 바꾼 뒤 완전히 컴파일하는 방식입니다. PyInstaller 와 비교하여 동작 속도는 별 차이가 없는데(더 느릴 수 있습니다), 용량은 조금 줄일 수 있습니다. 둘 다 매우 훌륭하게 배포본이 만들어집니다. 다만 onefile 옵션은 빼는 것이 좋습니다. 이 방식은 동작한다 하더라도 결코 좋은 형태는 아닙니다. 앱을 실행하는 순간에 캐시에 모든 걸 풀어낸 다음 런칭됩니다. 이보다는 standalone 으로 처리된 dist 를 [Actual Installer](https://www.actualinstaller.com) 나 [InstallForge](https://installforge.net) 같은 툴로 패키징하는 것이 좋습니다. 맥이라면 만들어진 앱 번들을 맥 내장 디스크 유틸리티에서 dmg 이미지로 만들거나 좀 더 일반적으로 '끌어서 Application 에 넣기' 를 제공하는 [DropDMG](https://c-command.com/dropdmg/) 를 사용하는 방법이 있습니다.

그 외의 내용은 환경설정과 초기화입니다. 앱의 전체적인 구조도 [이전 포스트](https://kiroshin.github.io/2024-07-22-hello-pure) 에서 말씀드렸던 것과 동일하게 구성되어 있습니다. 다만 안드로이드나 아이폰 등 보통의 GUI 프로그래밍에서 자동으로 해주는 것을 수동으로 잡아줘야 하는 번거로움이 있습니다.

한가지, 이전 쓰레딩 모델과 달라진 점은 `__bootup__ / __shutdown__` 입니다. async runloop 내에서 초기화되고 해제되어야 하는 것들입니다. 사실 이런 비슷한 목적으로 파이썬에서는 `__aenter__ / __aexit__` 가 있습니다만, 이건 with 컨텍스트 내의 인스턴스에 해당하는 것이라 사용 목적이 다르기 때문에 의도적으로 메서드 이름을 다르게 지정했습니다. 이건 Vessel, MainWindow 와 aiohttp 에 사용했습니다.


## app state

역시나 이전에 언급한 것과 동일하게 싱글 소스로 구성합니다. 퍼블리싱 구조는 Rx 나 Combine, Flow 등과 동일하게 Hot observable chain 으로 구성했습니다. 이건 나중에 얼마든지 shared 로 튜닝할 수 있습니다. 파이썬에 내장된 게 없기 때문에 직접 만들었습니다. UTIL 에 있는 publisher 와 store 가 그것입니다.

여기에는 [FBLPromise](https://github.com/google/promises/blob/master/Sources/FBLPromises/FBLPromise.m) 처럼 일반적인 Promise 구조가 어울리지 않습니다. 이러한 구조는 Future 나 Task 처럼 수신 객체와 생사를 함께할 때 사용합니다. AppState 를 수신하는 객체는 언제든 죽을 수 있기 때문에 이 구조를 사용하게 되면 번거롭게도 해제 처리를 따로 해줘야 합니다. 그래서 모든 리소스를 담아 Disposable 로 반환하는 Rx 구조가 더 낫습니다. 또한 hot 상태를 lazy 로 만들기 위해 subscribe 발생 시 역구조로 타고 올라가야 합니다.

이전에 아이폰 개발에 ObjC 를 사용하던 시절 [ReactiveObjC](https://github.com/ReactiveCocoa/ReactiveObjC) 를 분석한 적이 있는데 솔직히 너무나 좋지 않았습니다. 그래서 ObjC 용으로 observable 을 완전히 새로 구현했는데, 파이썬용으로 된 publisher 는 그때 사용한 로직을 매우 단순화시켜 일부만 남겨둔 것입니다. 왜냐면 app state 를 만들 store 딱 그 용도로만 쓰기 위해서입니다. 다양한 오퍼레이터가 필요하지도 않고, 에러핸들링을 체인 내부에서 할 필요도 없고, 체인에서 다른 퍼블리셔가 반환되지도 않고, 실패 타입이 들어오지도 않습니다.

AppState 에 사용한 publisher 는 weak 로 리소스를 붙잡으며 전체적으로 수평 구조로 구성됩니다. 모든 리소스는 Ticket 에 담겨 반환되며, 앱 상태가 바뀔 때마다 수신객체의 생사를 확인합니다. 파이썬은 가비지 콜렉터를 사용하고 있기 때문에 수신객체를 weak 처리해도 즉각적으로 반응하지는 않습니다. 그럼에도 런루프 몇 번에 해제는 됩니다. 가비지 콜렉터는 많은 사람들이 우려하는 것과는 대조적으로 성능이 꽤나 좋습니다.

내부 자료로 Roger 객체를 취합니다. 객체 이름은 중요하지 않습니다. 이 자료구조가 immutable 인 것이 중요합니다. 따라서 업데이트할 때 객체 전체를 Shallow Copy 하여 새로운 포인터 주소를 갖는 객체로 만들어주어야 합니다.

```python
# usecase/apply_route.py
def _update(value: Roger, uid: str) -> Roger:
    route = value.route._replace(uid=uid)
    return value._replace(route=route)
```

파이썬에서는 더 간편한 방법이 떠오르지 않네요. named tuple 의 `_replace` 를 이용했습니다. 좋아하는 방법은 아니지만 store 의 `set` 메서드를 통해 키밸류 형태의 딕셔너리를 입력받아 갱신할 수도 있게 해놨습니다. 이럴 경우 가능하면 키 타입을 미리 정의하거나 베쓸에서 메서드를 재정의 해서 조금 더 명시적으로 사용하기를 추천드립니다. 앱이 커지면 암시적인 형태는 암초가 됩니다.


## usecase
파이썬은 컴파일 언어가 아니기 때문에 클래스의 확장함수를 지원할 수 없는 구조입니다. kotlin 이나 swift 처럼 다른 파일에 특정 클래스의 함수를 정의하는 것이 불가능합니다. 외부 함수를 특정 클래스에 끼워넣기 위해서는 몽키패칭을 쉽게 떠올릴 수 있는데, 이 역시 암초이기 때문에 다루지 않겠습니다. 그 다음으로 떠올릴 수 있는 건 가장 무난한 방법인 callable class 를 만들어서 배쓸에서 가져오는 것인데, 이것도 '굳이 클래스까지' 라는 생각도 들고 번거롭습니다. 그 다음으로는 Protocol 을 정의하여 usecase 에서 참조하는 방식인데, 역시 번거롭고 프로토콜이 큰 의미를 갖지 못합니다. 그래서 다른 프로젝트에서 했던 것처럼 람다로 처리했습니다.

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
    # self 로 Vessel 이 할당됩니다.
    async def _action(is_show: bool):
        await self.update(_update, is_show)
    return _action
```

이렇게 하면 베쓸의 함수 일부를 외부로 떼어낼 수 있습니다. usecase 를 따로 떼어내는 이유는 이전 포스트에서도 언급했듯이, 이 방식이 조금 더 유연하고 동작을 한눈에 파악할 수 있기 때문입니다. 서버라면 서비스 형태가 명확히 정해져 있기 때문에 클래스로 그룹짓는 것이 더 효율적이지만, 일반 앱이라면 서버로부터 오는 데이터 가공뿐만 아니라 사용자의 여러 액션까지 처리해야 하는데 그걸 그룹화 하기에 애매한 경우가 많습니다. 그래서 따로 떼어두는 것이 좀더 유연합니다.

유스케이스 실제 작업은 전부 워커에서 합니다. 유스케이스에는 컨트롤 로직만 있을 뿐입니다.

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

이처럼 액션을 수행하기 위해 워커의 자료를 교환하거나 정보를 보내는 중개자에 불과합니다.

참고로, usecase 는 다른 usecase 를 호출할 수 없습니다. 상호 의존성이 없습니다. 공통 로직이 있더라도 그냥 중복해서 작성하는 것을 권하지만, 뭔가 대단한 처리여서 나중에 한꺼번에 관리해야 한다면 함수 파일을 따로 만들어 상호 import 하십시오.


## worker

워커는 GEAR 를 이용하여 실제 작업을 수행합니다. 그래서 워커는 기어를 알고 있습니다.

예를 들어 서버의 rest api 에 접속해 자료를 가져올 때 자신이 `requests` 를 사용할지 `aiohttp` 를 사용할지 알고 있다는 뜻입니다. 외부에서 기어를 주입해 주더라도 프로토콜을 사용하지 않고 직접 임포트 합니다. working 에서 지정한 메서드까지는 async 로 연결됐지만, 자신이 취급하는 gear 의 특성에 따라 threading 을 사용할지 asyncio 로 연결할지 워커는 결정할 수 있습니다.

또한 워커는 gear 로부터 발생하는 모든 오류처리를 담당합니다. 아래 예시는 sqlite3 의 에러와 aiohttp 의 에러를 다루고 있습니다.

```python
# -- person_repository 하나면 충분하지만, 일부러 두 개로 나누었습니다. --
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

참고로, working 을 구현하는 이 리포지토리 객체는 상호 의존성이 없습니다.

위 메서드는 working 요구사항을 충족하기 위해 구현된 것으로, 주된 작업은 db에서 자료를 빼오고 이 과정에서 photo 가 캐시에 없으면 내려받는 일입니다. 어쩌면 local 은 인터넷 접속을 위해 web 이 필요할 수도 있습니다. 그러나 `local_repository` 와 `web_repository` 는 수평관계라 서로 참조할 수 없습니다. local 에서 http 통신이 필요하면 기어를 통해 수행해야 합니다. working 을 구현하는 워커는 usecase 에서만 호출할 수 있습니다. 공통 로직이 필요하면 그걸 처리하는 객체를 공유하십시오. 현재 프로젝트에는 worker 그룹에 `db_store` 와 `file_store` 가 있습니다.


```python
# vessel.py
def create_workers(self, db_path, app_cache_path):
    access = HttpAioRandomuserAccess()
    database = DBStore(db_path, Asset.Script.schema)
    cache = FileStore(app_cache_path)
    self.person_web_work = PersonWebRepository(access, database)
    self.person_local_work = PersonLocalRepository(database, cache, access)
```

현재 프로젝트에서는 web 과 local 이 서로 access 를 공유하고 있습니다. 만약 이렇게 했음에도 불구하고 동일 코드를 두 번 작성해야 한다면 그냥 두 번 작성하세요. 시간이 지날수록 이 코드는 달라지게 될 것입니다. 중복 하나 없이 꽉 조이게 프로그래밍 하고 싶은 건 어느 개발자나 같은 마음이겠지만 유지보수 하다보면 꼭 그렇게 하는 것만이 정답이 아니라는 걸 느끼게 됩니다. 나중에 뜯어낼 때 더욱 고생하게 될 수도 있으니까요.


## fizzle

이 객체는 Custom Exception 입니다. 이름은 중요하지 않습니다. `Panic` 이라고 해도 되고 그냥 `Error` 라고 해도 됩니다. swift 에서는 enum으로 kotlin 에서는 sealed class 로 구성했는데, python 에서는 일반 클래스로 만들었습니다. 형태가 중요한 게 아니라 위치가 중요합니다. 이 예외 객체가 model 에 있는 이유는 usecase 와 worker 간 에러 핸들링을 위해서입니다.

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

worker 는 정말 다양한 gear 를 취급하는데, 거기서 발생한 에러를 fizzle 을 통해 표현합니다. usecase 는 worker 에서 fizzle 이 발생하면 사용자에게 알립니다. 즉, 사용자에게 알릴 메시지는 딱 정해져 있다는 뜻입니다. gear 에서 발생한 오류가 사용자에게 직접 보여지게 되면 안 되고, 이러한 오류 때문에 앱이 뻗어서도 안 됩니다. 저는 이 부분을 굉장히 중요하게 생각합니다.

```python
try:
    self.some_handler.action()
except Exception as e:
    logging.critical(e)
    raise Fizzle()
```

일단은 이 정도로 시작해보세요. 그리고 나서 테스트하면서 Exception 을 구체적으로 추가하면 코드 작성이 조금 더 수월할 수 있겠네요.


## fin

데스크톱 앱은 모바일 앱보다 조금 더 어렵습니다. 이벤트 처리할 것도 더 많고 사용자의 행동을 통제하기도 힘듭니다. 그래서 모바일 앱보다 신경을 더 많이 써야 합니다. 이번에 간단하게 구성한 데스크톱 앱은 아키텍처를 설명하기 위한 것이라 뭘 처리할 것도 없었지만, 실제 배포하는 앱에서는 정말 말도 안 되는 경우까지 고려해야 합니다. 그래서 시간이 배는 더 걸리는 것 같습니다.

Qt는 네이티브에 버금가는 GUI 와 간편한 EVENT 처리를 지원하는 상당히 훌륭한 툴킷입니다. 게다가 파이썬은 그 풍부한 생태계로 무한에 가까운 사용성을 갖추고 있습니다. 저는 이 둘의 조합이 매우 좋은 구성이라고 생각합니다.

사실, 파이썬으로 데스크톱 앱을 만든다는 게 그리 흔한 일은 아닙니다. 요즘 크로스 플랫폼 데스크톱 앱은 자바스크립트 일렉트론 기반으로 나오더군요. 그러니까 데스크톱 윈도우 화면에 웹페이지를 띄워서 GUI 를 그려내는 방식입니다. [VSCode](https://code.visualstudio.com), [Github Desktop](https://github.com/apps/desktop), [Figma](https://www.figma.com/downloads/), [Postman](https://www.postman.com/downloads/) 등이 생각나네요.

비록 Qt 가 일렉트론만큼 화려하고 자유도가 높지는 않지만 일반적인 데스트톱 앱을 구성하는데 부족함이 없을 정도입니다. 저는 GUI 의 최종 목표가 그 OS 의 네이티브에 제일 가까운 지점이어야 한다고 생각합니다. 그런 점에서 Qt 는 맥에서나 윈도우에서나 이질적이지 않고 자연스러운 모습을 보여줍니다. 심심하다고 할 수도 있겠지만 저는 마음에 듭니다.

