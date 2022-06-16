## MAP Bridge Contracts

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

