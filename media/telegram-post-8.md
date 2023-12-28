Разберем подробнее метод деплоя. Он находится в MF - контракте Main Factory.

```
  function deploy(uint256 tokenId, bytes memory code) external {
    // TODO check NFT owner
    bytes32 salt = tokenIdToSalt[tokenId];
    _deploy(salt, code);
    _burn(tokenId);
  }
```
Мы получаем соль по id токена, вызываем внутренний метод деплоя и сжигаем NFT – в первой версии продукта он уже не нужен.

Внутренний метод деплоя
```
  function _deploy(bytes32 salt, bytes memory code) internal {
    IntermediateFactory intermediateFactoryClone = IntermediateFactory(
      Clones.cloneDeterministic(address(intermediateFactory), salt)
    );

    intermediateFactoryClone.deploy(code); // deploy from factory using create opcode (not create2)
  }
```
Здесь мы деплоим сначала клон IF (intermediate factory) – мы клонируем именно прокси-контракт. Это важно, потому что в таком случае код контракта-клона всегда одинаковый, и тем самым мы можем спокойно апгрейдить IF, не ломая систему. Если бы код контракта-клона отличался, то его деплой был бы на непредсказуемые заранее адреса (create2 зависит от байткода контракта)

Далее мы у клона вызываем метод `deploy` – это метод другого нашего контракта. Он банальный, учитывая что nonce нового контракта всегда равен единице:
```
  function deploy(bytes memory code) external {
    address addr;

    assembly {
      addr := create(0, add(code, 0x20), mload(code))
      if iszero(extcodesize(addr)) {
        revert(0, 0)
      }
    }
    selfdestruct(payable(msg.sender));
  }
```
А так как он вызывается в транзакции создания контракта, и дальнейшие вызовы деплоя нам не интересны, – какие-либо проверки не требуются.
Ну и подчищаем за собой после деплоя. NFT бёрнится, а промежуточный контракт уничтожается. Повторно этот NFT сминтить не получится, а значит и клона по этому адресу повторно не будет.