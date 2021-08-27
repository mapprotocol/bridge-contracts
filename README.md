## Map Relayer Contracts

### 1.  MapCoin Contract

Map cross-chain bridge special token contract, all tokens need to be mapped to MapCoin for cross-chain operation.

### 2. MapTxVerify Contract

Map cross-chain bridge transaction verification contract, the user verifies the transaction details provided by the relay node.

### 3. MapRouter Contract

Map cross-chain bridge transaction main routing contract for overall agency

#### Event

```solidity
//Cross-chain transfer of tokens to minting
event LogSwapIn(uint orderId, address indexed token, address indexed from, address indexed to, uint amount, uint fromChainID, uint toChainID);

//Token cross-chain transfer out and burn
event LogSwapOut(uint orderId, address indexed token, address indexed from, address indexed to, uint amount, uint fromChainID, uint toChainID);

//Token cross-chain transfer verification failed
event LogSwapInFail(uint orderId, bytes32[] message,address indexed from, address indexed to, uint amount, uint fromChainID, uint toChainID);
```





### Swap

```solidity
//Cross-chain transfer in
function swapIn(uint256 id, address token, address to, uint amount, uint fromChainID, bytes32[] memory data) 

//Cross-chain transfer out
function swapOut(address token, address to, uint amount, uint toChainID)
```



#### Contract address

##### Install  

0xf0C8898B2016Afa0Ec5912413ebe403930446779

##### UsdtCoin

0xeFAa6Ca32b900291C158BB839ea9Ff63c009d399

##### MUsdtCoin

 0x47AF6D8A25beaA68Dc4f6D2A54EA175aB3B7A4B0

##### MapTxVerify

 0x0000000000747856657269667941646472657373

##### MapMpc

 0x3755A486c05A8a9f7CFae5a60c6DAb02f2231b77

##### MapChainRouter

 0xbDAa93E4B47298e4dD5a2D88EAD30ec82da11f9D

