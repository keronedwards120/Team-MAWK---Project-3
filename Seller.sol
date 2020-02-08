pragma solidity >=0.4.22 <=0.6.1;

import "./Interfaces/ISeller.sol";

contract Seller is ISeller{
    address payable public seller_address;
    event RegisterSeller(address seller);
    constructor(address payable _beneficiary) public {
        seller_address=_beneficiary;
    }
}