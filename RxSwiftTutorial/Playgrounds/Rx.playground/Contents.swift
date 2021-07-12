//: A UIKit based Playground for presenting user interface
  
import UIKit
import RxSwift
import PlaygroundSupport

/** `ЗМІСТ`
 - `Вступ до Rx`
 - `Базові поняття`
 - `Використання Observable`
 - `Rx оператори`
 - `Rx та побудова UI`
 - `Rx та MVVM` */

/** `Вступ до Rx` */
/** - `Rx` - Це поєднання найкращих ідей із шаблону `Observer`, шаблону `Iterator` та `функціонального програмування`.
  - Перше був створений всередині компанії `Microsoft` для платформи `.NET` (`Rx.NET` - 2009 рік).
  - `RxSwift` створений у 2015 році.
  - https://reactivex.io   - документація по Rx API для усіх існуючих платформ.
  - https://rxmarbles.com/ - інтерактивна документація по усіх доступних операторах.
  - https://github.com/sparklone/RxSwift/blob/master/RXSwift%20operators.pdf - шпагалка по оперторам
  - https://habr.com/ru/post/281292/ - шпагалка по оперторам */

/** `Базові поняття` */
/**
 1. Серцем `RxSwift` фреймворка є обєкт `Observable`, який представляє собою послідловність.
 2. `Observable` - це послідовність даних або подій на які можна підписатися  (`Subscribe`) а також розжиряти застосовуючи різні `Rx` оператори `map`, `filter`,  `flatMap`.
 3. `Observable` може надсилати дані асинхронно
 4. `Observable sequences` - можна створити на основі любого типу даних який реалізує `Sequence` протокол (Тип який надає послідовний та інеративний доступ до його елементів) */

/** Картинка: `Observable sequences` */
var urlString = "https://miro.medium.com/max/1400/1*8vI6LmLDIILhOdYOVN6Kmg.png"
var url       = URL(string: urlString)!
var data      = try! Data(contentsOf: url)
var image     = UIImage(data: data)!


/** Створення `Observable sequences`
  `just` - створює послідовність яка містить тільки один зазначений елемент. */
let observabl1 = Observable.just("Hello")                // Observable<String>
/** `of`   - створює послідовнійсть із заданими елементами */
let observable2 = Observable.of(1,2,3,4)                 // Observable<Int>
let observable3 = Observable.of([1,2,3,4],[11,22,33,44]) // Observable<[Int]>
 /** `from` - ствоює послідовність використовуючи елементи заданого массива як події. */
let observable4 = Observable.from([1,2,3,4,5])           // Observable<Int>
/** `Примітка:`
 Оператори `of` та `from` відрізняються тим що `of` прийме массив як елемент послідовності, а `from` функціонуватиме на окремих елементах масиву, а не на цілому масиві.*/

/** `!!!ДУЖЕ ВАЖЛИВО ЗНАТИ!!!`
 В коді наведеному вище ми тільки створили `послідовність подій`, але щоб вона надсилала події нам також треба підписатися (`Subscribe`) на неї. `Observable` сам по собі не надсилатиме події, поки не має підкисників на послідовність подій (`Спостерігачів`). */

/** Реалізація підписки (`Observer`-ів)
Метод `subscribe` - використвуються для того щоб створити `Observer` (Підписку, Спостерігача).
В нього є три параметра: */
/** `onNext`:
Цей метод викликається щоразу, коли Observable надсилає елемент послідовності.
Параметром методу є сам надісланий елемент.
Коли до Observable додається новий елемент послідовності,
то він надсилоається до усіх своїх підписників (`Observer-и`). */
/** `onError`:
 Цей метод викликається щоразу, коли надсилається подія помилки,
 що вказує на те, що `Observable` не зміг сформувати очікувані дані або зіткнувся з
 якоюсь іншою помилкою.
 Подальші виклики до `onNext` або `onCompleted` не здійснюються!
 Метод повертає деталі помилки як параметр.
 Це також припинить спостережувану послідовність. */
/** `onCompleted`:
 Цей метод вискикається після того коли `Observable` надіслав усі події
 та як результат надсилає завершену подію своїм підписникам.
 Цей метод не викликається, якщо трапилася якась помилка. */

observable4.subscribe { value in
    print("\(value)")
} onError: { error in
    print("\(error.localizedDescription)")
} onCompleted: {
    print("onCompleted")
}

/** `Утилазація та припинення підписки`
- Коли ми створюємо підписку, вона повертає вам підписника, і цей підписник
 завжди буде слухати  конкретну спостережувану послідовность.
 Між `Obserbable` та `Observer` створюється retaint сycle.
 Якщо ми не звільноми цих підписників, може статися `Memory Leak`.
 Тому нам потрібно переконатись, що ми утилізуємо ці підписки які нам вже не потрібні.
- Observer обєкти треба додавати до `DisposeBag`, який автоматично скасує підписку
 якщо вона вже не буде потрібна.
 Також `Observer` (це по суті клас `RxSwift.Disposable`) має метод `dispose()` яким можна вручну видалити підписку */

/** Приклад із  викликом `dispose()` */
let observable1 = Observable.of([1,2,3,4],[11,22,33,44])
let subscribeObservable = observable1.subscribe{ event in
    print("Event \(event)")
    if let element = event.element {
        print("Element is \(element)")
    }
}
subscribeObservable.dispose()

/**  Приклад із `DisposeBag` */
let disposeBag = DisposeBag()
Observable<String>.create { observer in
    observer.onNext("A")
    observer.onNext("B")
    observer.onCompleted()
/** `Цей елемент не буде надісланим тому що вище вже був надісланий `completed` */
    observer.onNext("C")
    return Disposables.create()
}.subscribe(onNext: { (value) in
    print(value)
}, onError: { (error) in
    print("onError: \(error.localizedDescription)")
}, onCompleted: {
    print("onCompleted")
}) {
    print("onDisposed")
}.disposed(by: disposeBag)


/** `Використання Observable` */
let apiKey  = "04caf053efeb41d3abe73156210907"
let city    = "London"
urlString   = "http://api.weatherapi.com/v1/current.json?key=\(apiKey)&q=\(city)&aqi=no"
url         = URL(string: urlString)!
let request = URLRequest(url:url)
URLSession.shared
    .rx.response(request:request)
    .subscribe(onNext: { response in
        
    },
    onError: { error in
        
    })


/** `Rx оператори` */

/** `Патерни при побудові UI` */

/** `Rx та MVVM` */
