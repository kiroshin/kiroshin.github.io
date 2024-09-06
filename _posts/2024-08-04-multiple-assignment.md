---
layout: post
title: 파이썬의 다중 할당
categories: [Python]
tags: [unpack, multiple, assignment, type]
teaser:
brief: 파이썬은 언팩이나 다중할당을 정말 빈번하게 사용합니다. 그런데 정확하게 이해하지 않고 사용하면 의도치 않은 결과가 나올 수 있습니다. 이번에는 타입 혼용과 다중할당 시 실수하게 되는 사례를 살펴보겠습니다.
---

동적 언어를 다루다보면, 타입을 별로 고려하지 않기 때문에 자유로워서 의식의 흐름대로 코드를 써도 크게 걸리적 거리지 않습니다. 그런데 가끔은 이런 이유로 버그를 유발하는 경우도 있습니다. 굉장히 많은 사례가 있겠지만, 다중 할당의 경우에도 이에 해당하는 것 같습니다.

```python
r = 5
s = [6, 7]
r, r[1], s = s, r, s[1]
print(r, s)
##->>> [6, 5] 7
```

파이썬은 언팩이나 다중할당을 정말 빈번하게 사용합니다. 위와 같은 경우도 의도한 대로 멤버를 잘 교환했습니다. 그런데 아래 코드는 위 코드와 전혀 다른 결과를 보여줍니다. 오늘은 이 부분에 대해 얘기해볼까 합니다.

```python
r = 5
s = [6, 7]
r, r[1] = s, r
s = s[1]
print(r, s)
##->>> [6, 5] 5
```

위 코드의 제일 심각한 문제는, 변수 `r` 이 처음에는 `int` 를 취급했다가, 나중에는 `list` 를 취급한다는 점입니다. 이건 정말 싫습니다... 파이썬이 아무리 타입에서 자유롭다 하더라도, 효율을 위해서 이렇게 사용하다 보면 정말 의도치 않게 버그가 생길 수 있습니다(자바스트립트도 마찬가지입니다). 이렇게 생기는 버그는 아무리 찾아도 잘 보이지도 않습니다. 왜냐면 정상적인 코드이기 때문입니다. 변수 타입을 한 번 정했으면 바꾸지 않는 것이 좋습니다.

그 다음 문제는, 의도한 결과가 `[6, 5] 7` 였다면, 두 번째 코드는 s 를 할당할 때 실수했다는 점입니다.

```
              ┌─────────────────────┐
        ┌─────│─────────────┐       │
 ┌──────│─────│─────┐       │       │
 │      │     │   [6, 7]    5       7
 ▼      ▼     ▼     ▲       ▲       ▲
 r,   r[1],   s =   s,      r,     s[1]

(1): r -> [6, 7],  s -> None
(2): r -> [6, 5],  s -> None
(3): r -> [6, 5],  s -> 7
```

다중할당은 할당 전에 해당 변수를 캡쳐하게 됩니다. 따라서 위 그림처럼 r 과 s 가 순차적으로 변하게 됩니다. 그런데 파이썬은 원시타입을 취급하지 않습니다. 숫라라도 객체로 취급하며 변수에는 스토리지가 없습니다. 할당은 곧 포인터입니다. 그래서 `r, r[1] = s, r` 이 처리되고 나면 s 와 r 은 같은 배열을 가리키게 되고, 다음 줄에 이어진 `s = s[1]` 에서 s 는 배열 `[6, 5]` 의 멤버 중 1번 인덱스의 값인 `숫자 5 객체`를 가리키게 되는 것이죠.

```
        ┌───────────────┐
 ┌──────│───────┐       │
 │      │     [6, 7]    5
 ▼      ▼       ▲       ▲
 r,   r[1]  =   s,      r

(1): s ──▶ [6, 7] ◀── r
(2): s ──▶ [6, 5] ◀── r


┌────────┐
│        5
▼        ▲
s   =   s[1]

(3): s      [6, 5] ◀── r
     │          ▲
     └──────────┘
```

두 번째 코드에서 3개를 할당하지 않고 굳이 2개/1개 로 나눠서 할당하고 싶다면, 아래처럼 임시 변수에 저장하면 원하는 결과를 얻을 수 있습니다.

```python
r = 5
s = [6, 7]
temp = s[1]
r, r[1] = s, r
s = temp
print(r, s)
##->>> [6, 5] 7
```

그런데 파이썬에서는 굳이 이렇게까지는 잘 하지 않죠. 제가 보기에는 애초부터 r 과 s 에 타입을 분명히 했다면 다중할당이 2개든 3개든 헷갈리지 않을 것 같네요. 제가 이런 버그를 봤습니다!!
