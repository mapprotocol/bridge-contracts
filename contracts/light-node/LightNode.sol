// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol';
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "./lib/RLPReader.sol";
import "./lib/RLPEncode.sol";
// import "hardhat/console.sol";

contract LightNode is UUPSUpgradeable, Initializable {

    using RLPReader for bytes;
    using RLPReader for uint;
    using RLPReader for RLPReader.RLPItem;
    using RLPReader for RLPReader.Iterator;

    struct blockHeader{
        bytes parentHash;
        address coinbase;
        bytes root;
        bytes txHash;
        bytes receipHash;
        bytes bloom;
        uint256 number;
        uint256 gasLimit;
        uint256 gasUsed;
        uint256 time;
        bytes extraData;
        bytes mixDigest;
        bytes nonce;
        uint256 baseFee;
    }

    struct istanbulAggregatedSeal{
        uint256   round;
        bytes     signature;
        uint256   bitmap;
    }

    struct istanbulExtra{
        address[] validators;
        bytes  seal;
        istanbulAggregatedSeal  aggregatedSeal;
        istanbulAggregatedSeal  parentAggregatedSeal;
        uint256  removeList;
        bytes[]  addedPubKey;
    }

    uint256 constant EPOCHCOUNT=3;
    uint256 private epochIdx;
    uint256[EPOCHCOUNT] private epochs;
    // epoch => bls keys
    mapping(uint256 => bytes[]) private blsKey;

    uint256 epochLength;
    uint256 keyNum;

    event validitorsSet(uint256 epoch);
    
    /** initialize  **********************************************************/
    function initialize(bytes memory firstBlock, uint256 epoch) external initializer {
        _changeAdmin(msg.sender);
        epochLength = 20;
    }

    constructor() initializer {
    }

    /** view function *********************************************************/
    function currentEpoch() public view returns(uint256){
        return epochs[epochIdx];
    }

    function currentValidators() public view returns(bytes[] memory){
        return blsKey[currentEpoch()];
    }

    /** external function *********************************************************/

    /** sstore functions *******************************************************/

    function _initFirstBlock(bytes memory firstBlock, uint256 epoch) private {
        blockHeader memory bh = _decodeHeader(firstBlock);
        istanbulExtra memory ist = _decodeExtraData(bh.extraData);

        keyNum = ist.addedPubKey.length;
        // nowNumber = bh.number;
        bytes[] memory keys = new bytes[](keyNum);
        for(uint256 i = 0;i<keyNum;i++){
            keys[i] = ist.addedPubKey[i];
        }
        _setValidators(keys, epoch);
    }

    function _setValidators(bytes[] memory keys, uint256 epoch) public {
        uint256 nextIdx = epochIdx +1;
        if(nextIdx==EPOCHCOUNT){
            nextIdx =0;
        }

        if(epochs[nextIdx]!=0){
            // delete previous data
            delete blsKey[epochs[nextIdx]];
        }

        epochs[nextIdx] = epoch;
        blsKey[epoch] = keys;
        epochIdx = nextIdx;
        emit validitorsSet(epoch);
    }


    /** private functions about header manipulation  ************************************/

    function _decodeHeader(bytes memory rlpBytes) private pure returns(blockHeader memory bh){
        RLPReader.RLPItem[] memory ls = rlpBytes.toRlpItem().toList();

        // legay part1
        RLPReader.RLPItem memory item0 = ls[0]; //parentBlockHash
        RLPReader.RLPItem memory item1 = ls[1]; //coinbase
        RLPReader.RLPItem memory item2 = ls[2]; //root
        RLPReader.RLPItem memory item3 = ls[3]; //txHash
        RLPReader.RLPItem memory item4 = ls[4]; //receipHash
        RLPReader.RLPItem memory item6 = ls[6]; //number
        RLPReader.RLPItem memory item10 = ls[10]; //extra
        // legay part2
        RLPReader.RLPItem memory item5 = ls[5]; //bloom
        RLPReader.RLPItem memory item7 = ls[7]; //gasLimit
        RLPReader.RLPItem memory item8 = ls[8]; //gasUsed
        RLPReader.RLPItem memory item9 = ls[9]; //time
        RLPReader.RLPItem memory item11 = ls[11]; //mixDigest
        RLPReader.RLPItem memory item12 = ls[12]; //nonce
        RLPReader.RLPItem memory item13 = ls[13]; //baseFee
        // legay part1
        bh.parentHash = item0.toBytes();
        bh.coinbase = item1.toAddress();
        bh.root = item2.toBytes();
        bh.txHash = item3.toBytes();
        bh.receipHash = item4.toBytes();
        bh.number = item6.toUint();
        bh.extraData = item10.toBytes();
        // legay part2
        bh.bloom = item5.toBytes();
        bh.gasLimit = item7.toUint();
        bh.gasUsed = item8.toUint();
        bh.time = item9.toUint();
        bh.mixDigest  = item11.toBytes();
        bh.nonce  = item12.toBytes();
        bh.baseFee = item13.toUint();
    }

    function _decodeExtraData(bytes memory extraData) private pure returns(istanbulExtra memory ist){
        bytes memory decodeBytes = _splitExtra(extraData);
        RLPReader.RLPItem[] memory ls = decodeBytes.toRlpItem().toList();
        RLPReader.RLPItem memory item0 = ls[0];
        RLPReader.RLPItem memory item1 = ls[1];
        RLPReader.RLPItem memory item2 = ls[2];
        RLPReader.RLPItem memory item3 = ls[3];
        RLPReader.RLPItem memory item4 = ls[4];
        RLPReader.RLPItem memory item5 = ls[5];

        if (item0.len > 20){
            uint num = item0.len/20;
            ist.validators = new address[](num);
            ist.addedPubKey = new bytes[](num);
            for(uint i=0;i<num;i++){
                ist.validators[i] = item0.toList()[i].toAddress();
                ist.addedPubKey[i] = item1.toList()[i].toBytes();
            }
        }

        ist.removeList = item2.toUint();
        ist.seal = item3.toBytes();
        ist.aggregatedSeal.round = item4.toList()[2].toUint();
        ist.aggregatedSeal.signature = item4.toList()[1].toBytes();
        ist.aggregatedSeal.bitmap = item4.toList()[0].toUint();
        ist.parentAggregatedSeal.round = item5.toList()[2].toUint();
        ist.parentAggregatedSeal.signature = item5.toList()[1].toBytes();
        ist.parentAggregatedSeal.bitmap = item5.toList()[0].toUint();
        return ist;
    }

    function _splitExtra(bytes memory extra) private pure returns (bytes memory newExtra){
        //extraData rlpcode is storaged from No.32 byte to latest byte.
        //So, the extraData need to reduce 32 bytes at the beginning.
        newExtra = new bytes(extra.length - 32);
        // extraDataPre = new bytes(32);
        uint256 n = 0;
        for(uint i=32;i<extra.length;i++){
            newExtra[n] = extra[i];
            n = n + 1;
        }
        // uint m = 0;
        // for(uint i=0;i<32;i++){
        //     extraDataPre[m] = extra[i];
        //     m = m + 1;
        // }
        return newExtra;
    }

    /** UUPS *********************************************************/
    function _authorizeUpgrade(address newImplementation) internal override {
        require(msg.sender==_getAdmin(), "LightNode: only Admin can upgrade");
    }
}