pragma solidity >=0.4.22 <=0.6.1;

<<<<<<< HEAD
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/drafts/Counters.sol";
import "./AuctionHouse.sol";
=======
>>>>>>> fcc867b23d25adcd8f6405afe3573903c41dceaa
import "./Interfaces/ISeller.sol";

contract Seller is ISeller{
    address payable public seller_address;
    event RegisterSeller(address seller);
    constructor(address payable _beneficiary) public {
        seller_address=_beneficiary;
    }
}