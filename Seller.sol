pragma solidity >=0.4.22 <=0.6.1;

//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/drafts/Counters.sol";
import "./Interfaces/ISeller.sol";
import "./Interfaces/ICommon.sol";
contract Seller is ISeller,ICommon{

    event RegisterItem(address owner,string reference_uri,uint amount);
}