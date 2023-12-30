Для NFT Address Options я сделал отдельный вид прокси. Зачем?

Для того, чтобы юзер мог деплоить произвольный код на детерминированный адрес, надо чтобы у промежуточной фабрики был фиксированный код. Самый простой вариант – деплоить стандартный прокси типа TransparentUpgradeableProxy с фиксированным адресом (например, нулевым) и сразу менят адрес имплементации. Но хочется оптимизировать по газу, тем более замена имплементации нужна всего один раз

[Вот сам контракт на yul](https://github.com/BAAbstraction/contracts/blob/main/yul/UpgradeableClone.yul)
И [простой тест](https://github.com/BAAbstraction/contracts/blob/main/test/UpgradeableClone.t.sol)